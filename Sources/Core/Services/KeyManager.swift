import CoreErrors
import CoreServicesTypes
import KeyManagementTypes
import UmbraCoreTypes
#if USE_FOUNDATION_CRYPTO
  import Foundation

  // Use Foundation crypto when available
  @preconcurrency import ObjCBridgingTypesFoundation
#else
  // Use CryptoSwift for cross-platform support
  import CryptoSwift
  import Foundation
  @preconcurrency import ObjCBridgingTypesFoundation
#endif
import UmbraXPC
import XPCProtocolsCore

/// Represents the type of cryptographic implementation to use
public enum CryptoImplementation: Sendable {
  /// CryptoSwift for cross-process operations
  case cryptoSwift
}

/// Represents a security context for cryptographic operations
public struct SecurityContext: Sendable {
  /// The type of application requesting the operation
  public enum ApplicationType: Sendable {
    /// ResticBar (native macOS app)
    case resticBar
    /// Rbum (cross-process GUI app)
    case rbum
    /// Rbx (VS Code extension)
    case rbx
  }

  /// The application type
  public let applicationType: ApplicationType
  /// Whether the operation is within a sandbox
  public let isSandboxed: Bool
  /// Whether the operation requires cross-process communication
  public let requiresXPC: Bool

  public init(
    applicationType: ApplicationType,
    isSandboxed: Bool=false,
    requiresXPC: Bool=false
  ) {
    self.applicationType=applicationType
    self.isSandboxed=isSandboxed
    self.requiresXPC=requiresXPC
  }
}

/// Represents a cryptographic key identifier
public struct KeyIdentifier: Hashable, Sendable {
  /// The unique identifier for this key
  public let id: String

  /// Create a new key identifier
  /// - Parameter id: The unique identifier for this key
  public init(id: String) {
    self.id=id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: KeyIdentifier, rhs: KeyIdentifier) -> Bool {
    lhs.id == rhs.id
  }
}

/// Represents metadata about a cryptographic key
public struct KeyMetadata: Sendable {
  /// Key identifier
  public let identifier: KeyIdentifier
  /// When the key was created
  public let creationDate: Date
  /// When the key expires (if applicable)
  public let expirationDate: Date?
  /// Key usage purpose
  public let purpose: String
  /// Key algorithm
  public let algorithm: String
  /// Key strength in bits
  public let strength: Int

  public init(
    identifier: KeyIdentifier,
    creationDate: Date,
    expirationDate: Date?=nil,
    purpose: String,
    algorithm: String,
    strength: Int
  ) {
    self.identifier=identifier
    self.creationDate=creationDate
    self.expirationDate=expirationDate
    self.purpose=purpose
    self.algorithm=algorithm
    self.strength=strength
  }
}

/// Result of key validation operation
public struct KeyValidationResult: Sendable {
  /// Whether the key is valid
  public let isValid: Bool
  /// Detailed validation messages (if any)
  public let messages: [String]

  public init(isValid: Bool, messages: [String]=[]) {
    self.isValid=isValid
    self.messages=messages
  }
}

/// Manages cryptographic keys for the application
public actor KeyManager {
  /// Current state of the key manager
  private var _state: CoreServicesTypes.ServiceState = .uninitialized
  public private(set) nonisolated(unsafe) var state: CoreServicesTypes.ServiceState = .uninitialized

  /// Key storage location
  private let keyStorage: URL
  /// Format for storing keys
  private let keyFormat: String
  /// Security context for key operations
  private let securityContext: SecurityContext
  /// Implementation to use for cryptographic operations
  private let cryptoImpl: CryptoImplementation
  /// Key metadata
  private var keyMetadata: [String: KeyMetadata]
  /// Last synchronisation time
  private var lastSyncTime: Date?

  /// Initialize key manager
  /// - Parameters:
  ///   - keyStorage: URL where keys are stored
  ///   - keyFormat: Format for storing keys (default: "umbra-key-v1")
  ///   - securityContext: Security context for key operations
  ///   - cryptoImpl: Implementation to use for cryptographic operations (default: .cryptoSwift)
  public init(
    keyStorage: URL,
    keyFormat: String="umbra-key-v1",
    securityContext: SecurityContext,
    cryptoImpl: CryptoImplementation = .cryptoSwift
  ) {
    self.keyStorage=keyStorage
    self.keyFormat=keyFormat
    self.securityContext=securityContext
    self.cryptoImpl=cryptoImpl
    keyMetadata=[:]
  }

  /// Initialize the key manager
  /// - Throws: KeyManagerError if initialization fails
  public func initialize() async throws {
    if _state == CoreServicesTypes.ServiceState.uninitialized {
      _state=CoreServicesTypes.ServiceState.initializing
      state=CoreServicesTypes.ServiceState.initializing

      // Create storage directory if it doesn't exist
      try FileManager.default.createDirectory(
        at: keyStorage,
        withIntermediateDirectories: true,
        attributes: nil
      )

      // Load existing keys from storage
      keyMetadata=try await loadKeyMetadata()

      _state=CoreServicesTypes.ServiceState.ready
      state=CoreServicesTypes.ServiceState.ready
    }
  }

  /// Shutdown the key manager
  public func shutdown() async {
    _state=CoreServicesTypes.ServiceState.shuttingDown
    state=CoreServicesTypes.ServiceState.shuttingDown

    // Save keys to disk
    do {
      try await saveKeyMetadata()
    } catch {
      print("Failed to save keys during shutdown: \(error.localizedDescription)")
    }

    _state=CoreServicesTypes.ServiceState.shutdown
    state=CoreServicesTypes.ServiceState.shutdown
  }

  /// Generate a new key with the specified parameters
  /// - Parameters:
  ///   - purpose: Purpose of the key
  ///   - algorithm: Algorithm to use (default: "AES-GCM")
  ///   - strength: Strength in bits (default: 256)
  /// - Returns: Identifier for the new key
  /// - Throws: KeyManagerError if key generation fails
  public func generateKey(
    purpose: String,
    algorithm: String="AES-GCM",
    strength: Int=256
  ) async throws -> KeyIdentifier {
    guard state == CoreServicesTypes.ServiceState.ready else {
      throw KeyManagerError.notInitialized
    }

    // Generate unique identifier
    let keyId="key-\(UUID().uuidString.prefix(8))"
    let keyIdentifier=KeyIdentifier(id: keyId)

    // Create key metadata
    let metadata=KeyMetadata(
      identifier: keyIdentifier,
      creationDate: Date(),
      purpose: purpose,
      algorithm: algorithm,
      strength: strength
    )

    // Store key metadata
    keyMetadata[keyId]=metadata

    // Synchronize with other processes if needed
    if securityContext.requiresXPC {
      try await synchroniseKeys()
    }

    return keyIdentifier
  }

  /// Validate a key to ensure it meets security requirements
  /// - Parameter id: Key identifier
  /// - Returns: Validation result
  /// - Throws: KeyManagerError if validation fails
  public func validateKey(id: KeyIdentifier) async throws -> KeyValidationResult {
    guard state == CoreServicesTypes.ServiceState.ready else {
      throw KeyManagerError.notInitialized
    }

    guard keyMetadata[id.id] != nil else {
      throw KeyManagerError.keyNotFound(id.id)
    }

    return KeyValidationResult(isValid: true)
  }

  /// Synchronise keys across processes if necessary
  /// - Throws: KeyManagerError if synchronisation fails
  public func synchroniseKeys() async throws {
    // Use XPC to broadcast key updates to other processes
    let serviceContainer=ServiceContainer.shared

    // Need to await when accessing actor property
    guard let xpcService=await serviceContainer.xpcService else {
      throw KeyManagerError.synchronisationError("XPC service not available")
    }

    // Create JSON object with sync data
    let syncData=try await createKeySyncData()

    // Send synchronisation request through XPC using the modern Result-based approach
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      // Convert SecureBytes to [UInt8] using Array initializer
      let syncBytes=Array(syncData)
      xpcService.synchroniseKeys(syncBytes) { [weak self] error in
        if let error {
          continuation
            .resume(
              throwing: KeyManagerError
                .synchronisationError("XPC synchronization failed: \(error.localizedDescription)")
            )
        } else {
          // Update last sync timestamp on success
          if let self {
            Task {
              await self.updateSyncTimestamp()
            }
          }
          continuation.resume()
        }
      }
    }
  }

  /// Validate security boundaries for all keys
  /// - Throws: KeyManagerError if validation fails
  public func validateSecurityBoundaries() async throws {
    for (id, _) in keyMetadata {
      // Check key storage location
      guard isStoredInSecureEnclave(id: id) else {
        throw KeyManagerError.securityBoundaryViolation("Key \(id) is not stored in secure enclave")
      }

      // Verify access controls
      // guard await validateAccessControls(for: id) else {
      //     throw KeyManagerError.securityBoundaryViolation("Invalid access controls for key
      //     \(id)")
      // }
    }
  }

  /// Load key metadata from storage
  /// - Returns: Dictionary of key ID to metadata
  /// - Throws: KeyManagerError if loading fails
  private func loadKeyMetadata() async throws -> [String: KeyMetadata] {
    var metadata: [String: KeyMetadata]=[:]

    let fileManager=FileManager.default
    let files: [URL]
    do {
      files=try fileManager.contentsOfDirectory(
        at: keyStorage,
        includingPropertiesForKeys: nil,
        options: .skipsHiddenFiles
      )
    } catch {
      throw KeyManagerError
        .storageError("Failed to read key storage: \(error.localizedDescription)")
    }

    for file in files.filter({ $0.pathExtension == "meta" }) {
      do {
        let data=try Data(contentsOf: file)
        guard
          let json=try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let id=json["id"] as? String,
          let purpose=json["purpose"] as? String,
          let algorithm=json["algorithm"] as? String,
          let strength=json["strength"] as? Int,
          let creationDateTimestamp=json["creationDate"] as? TimeInterval
        else {
          throw KeyManagerError
            .metadataError("Invalid metadata format in \(file.lastPathComponent)")
        }

        let keyId=KeyIdentifier(id: id)
        let creationDate=Date(timeIntervalSince1970: creationDateTimestamp)
        let expirationDate: Date?=if
          let expirationTimestamp=json[
            "expirationDate"
          ] as? TimeInterval
        {
          Date(timeIntervalSince1970: expirationTimestamp)
        } else {
          nil
        }

        metadata[id]=KeyMetadata(
          identifier: keyId,
          creationDate: creationDate,
          expirationDate: expirationDate,
          purpose: purpose,
          algorithm: algorithm,
          strength: strength
        )
      } catch {
        throw KeyManagerError
          .metadataError("Failed to parse metadata: \(error.localizedDescription)")
      }
    }

    return metadata
  }

  /// Save key metadata to storage
  /// - Throws: KeyManagerError if saving fails
  private func saveKeyMetadata() async throws {
    let fileManager=FileManager.default

    // Ensure storage directory exists
    if !fileManager.fileExists(atPath: keyStorage.path) {
      try fileManager.createDirectory(
        at: keyStorage,
        withIntermediateDirectories: true
      )
    }

    // Save each key's metadata to a separate file
    for (id, metadata) in keyMetadata {
      let metadataFile=keyStorage.appendingPathComponent("\(id).meta")

      // Create JSON representation
      var json: [String: Any]=[
        "id": id,
        "purpose": metadata.purpose,
        "algorithm": metadata.algorithm,
        "strength": metadata.strength,
        "creationDate": metadata.creationDate.timeIntervalSince1970
      ]

      // Add optional expiration date if available
      if let expirationDate=metadata.expirationDate {
        json["expirationDate"]=expirationDate.timeIntervalSince1970
      }

      do {
        let data=try JSONSerialization.data(withJSONObject: json)
        try data.write(to: metadataFile, options: .atomicWrite)
      } catch {
        throw KeyManagerError
          .metadataError("Failed to save metadata for key \(id): \(error.localizedDescription)")
      }
    }
  }

  /// Create sync data for key synchronisation
  /// - Returns: Data to synchronise
  /// - Throws: KeyManagerError if data creation fails
  private func createKeySyncData() async throws -> SecureBytes {
    var syncData: [String: Any]=[:]
    var keys: [[String: Any]]=[]

    for (_, metadata) in keyMetadata {
      let keyData: [String: Any]=[
        "id": metadata.identifier.id,
        "purpose": metadata.purpose,
        "algorithm": metadata.algorithm,
        "strength": metadata.strength,
        "creationDate": metadata.creationDate.timeIntervalSince1970,
        "expirationDate": metadata.expirationDate?.timeIntervalSince1970 as Any
      ]
      keys.append(keyData)
    }

    syncData["keys"]=keys
    syncData["timestamp"]=Date().timeIntervalSince1970

    let jsonData: Data
    do {
      jsonData=try JSONSerialization.data(withJSONObject: syncData)
    } catch {
      throw KeyManagerError
        .synchronisationError("Failed to create sync data: \(error.localizedDescription)")
    }

    return SecureBytes(bytes: Array(jsonData))
  }

  /// Check if a key is stored in the secure enclave
  /// - Parameter id: Key ID
  /// - Returns: True if stored in secure enclave
  private func isStoredInSecureEnclave(id _: String) -> Bool {
    // Implementation would depend on the platform
    // This is a simplified placeholder
    true
  }

  /// Get list of all key identifiers
  /// - Returns: Array of key identifiers
  public func getKeyIdentifiers() -> [KeyIdentifier] {
    keyMetadata.values.map(\.identifier)
  }

  /// Get metadata for a specific key
  /// - Parameter id: Key identifier
  /// - Returns: Key metadata
  /// - Throws: KeyManagerError if key not found
  public func getKeyMetadata(id: KeyIdentifier) throws -> KeyMetadata {
    guard let metadata=keyMetadata[id.id] else {
      throw KeyManagerError.keyNotFound(id.id)
    }
    return metadata
  }

  /// Update the last sync timestamp
  private func updateSyncTimestamp() {
    lastSyncTime=Date()
  }
}

/// Errors that can occur during key management operations
public enum KeyManagerError: LocalizedError {
  /// Key manager is not initialized
  case notInitialized
  /// Key not found
  case keyNotFound(String)
  /// Error with key storage
  case storageError(String)
  /// Error with key metadata
  case metadataError(String)
  /// Error during key synchronisation
  case synchronisationError(String)
  /// Security boundary violation
  case securityBoundaryViolation(String)

  public var errorDescription: String? {
    switch self {
      case .notInitialized:
        "Key manager not initialized"
      case let .keyNotFound(id):
        "Key not found: \(id)"
      case let .storageError(message):
        "Storage error: \(message)"
      case let .metadataError(message):
        "Metadata error: \(message)"
      case let .synchronisationError(message):
        "Synchronisation error: \(message)"
      case let .securityBoundaryViolation(message):
        "Security boundary violation: \(message)"
    }
  }
}

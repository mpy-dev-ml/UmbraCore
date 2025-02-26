import CryptoSwift
import Foundation
@preconcurrency import CoreServicesTypes
import UmbraXPC

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
        isSandboxed: Bool = false,
        requiresXPC: Bool = false
    ) {
        self.applicationType = applicationType
        self.isSandboxed = isSandboxed
        self.requiresXPC = requiresXPC
    }
}

/// Represents a cryptographic key identifier
public struct KeyIdentifier: Hashable, Sendable {
    /// The unique identifier for this key
    public let id: String

    /// Create a new key identifier
    /// - Parameter id: The unique identifier for this key
    public init(id: String) {
        self.id = id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: KeyIdentifier, rhs: KeyIdentifier) -> Bool {
        lhs.id == rhs.id
    }
}

/// Result of key validation
public struct KeyValidationResult: Sendable {
    /// Whether the key is valid
    public let isValid: Bool
    /// Reason for validation failure, if any
    public let failureReason: String?
    
    /// Initialize a new key validation result
    /// - Parameters:
    ///   - isValid: Whether the key is valid
    ///   - failureReason: Reason for validation failure, if any
    public init(isValid: Bool, failureReason: String? = nil) {
        self.isValid = isValid
        self.failureReason = failureReason
    }
}

/// Orchestrates cryptographic operations across different implementations
public actor KeyManager {
    /// Current state of the key manager
    private var _state: CoreServicesTypes.ServiceState = .uninitialized
    public nonisolated(unsafe) private(set) var state: CoreServicesTypes.ServiceState = .uninitialized

    /// Maps key identifiers to their metadata
    private var keyMetadata: [String: CoreServicesTypes.KeyMetadata] = [:]

    /// Last synchronization timestamp
    private var lastSyncTime: Date?

    /// Initialize the key manager
    public init() {}

    /// Select the appropriate implementation based on the security context
    /// - Parameter context: The security context for the operation
    /// - Returns: The selected cryptographic implementation
    public func selectImplementation(for context: SecurityContext) -> CryptoImplementation {
        switch context.applicationType {
        case .resticBar:
            // ResticBar uses CryptoSwift for cross-process operations
            return .cryptoSwift
        case .rbum, .rbx:
            // Rbum and Rbx use CryptoSwift for cross-process operations
            return .cryptoSwift
        }
    }

    /// Generate a new key for the given context
    /// - Parameter context: The security context for key generation
    /// - Returns: The identifier for the generated key
    /// - Throws: KeyManagerError if key generation fails
    public func generateKey(for context: SecurityContext) async throws -> KeyIdentifier {
        let implementation = selectImplementation(for: context)
        let keyId = UUID().uuidString
        let identifier = KeyIdentifier(id: keyId)

        // Store the implementation choice for this key
        // implementationMap[identifier] = implementation

        switch implementation {
        case .cryptoSwift:
            // Generate a new key using CryptoSwift
            // Placeholder implementation - will be replaced by ResticBar
            throw KeyManagerError.keyGenerationError("Key generation moved to ResticBar")
        }

        return identifier
    }

    /// Rotate a key
    /// - Parameter id: The key identifier to rotate
    /// - Throws: KeyManagerError if rotation fails
    public func rotateKey(id: KeyIdentifier) async throws {
        // guard let implementation = implementationMap[id] else {
        //     throw KeyManagerError.keyNotFound
        // }

        // Generate a new key with the same implementation
        let newKeyId = UUID().uuidString
        let newIdentifier = KeyIdentifier(id: newKeyId)
        // let newIdentifier = try await generateKey(keyId: newKeyId, implementation: implementation)

        // Copy any relevant metadata from the old key
        if let metadata = keyMetadata[id.id] {
            keyMetadata[newIdentifier.id] = metadata
        }

        // Mark the old key as rotated
        // keyMetadata[id]?.status = .rotated(replacedBy: newIdentifier)

        // Schedule the old key for deletion after a grace period
        try await scheduleKeyDeletion(id: id.id, afterDelay: 24 * 60 * 60)
    }

    /// Validate a key
    /// - Parameter id: The key identifier to validate
    /// - Returns: A validation result indicating the key's status
    /// - Throws: KeyManagerError if validation fails
    public func validateKey(id: KeyIdentifier) async throws -> KeyValidationResult {
        // guard let implementation = implementationMap[id],
        //       let key = keyStore[id] else {
        //     throw KeyManagerError.keyNotFound
        // }

        // Check key metadata
        if let metadata = keyMetadata[id.id] {
            // Check if key has been marked as compromised
            if metadata.status == .compromised {
                return KeyValidationResult(isValid: false, failureReason: "Key has been marked as compromised")
            }
            
            // Check if key has been marked as retired
            if metadata.status == .retired {
                return KeyValidationResult(isValid: false, failureReason: "Key has been retired")
            }
            
            // Check if key has expired
            if let expiryDate = metadata.expiryDate,
               expiryDate < Date() {
                return KeyValidationResult(isValid: false, failureReason: "Key has expired")
            }
        }

        // Verify key material integrity
        // switch implementation {
        // case .cryptoSwift:
        //     guard let key = key as? [UInt8],
        //           key.count == AES.blockSize else {
        //         return KeyValidationResult(
        //             isValid: false,
        //             failureReason: "Invalid key type or size for CryptoSwift implementation"
        //         )
        //     }
        // }

        return KeyValidationResult(isValid: true)
    }

    /// Synchronise keys across processes if necessary
    /// - Throws: KeyManagerError if synchronisation fails
    public func synchroniseKeys() async throws {
        // Use XPC to broadcast key updates to other processes
        guard let xpcConnection = await ServiceContainer.shared.xpcConnection else {
            throw KeyManagerError.synchronisationError("XPC connection not available or invalid type")
        }

        // Prepare sync data
        let encoder = JSONEncoder()
        let syncData = try encoder.encode(keyMetadata)

        // Send synchronisation request through XPC
        try await xpcConnection.synchroniseKeys(syncData)

        // Update last sync timestamp
        lastSyncTime = Date()
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
            //     throw KeyManagerError.securityBoundaryViolation("Invalid access controls for key \(id)")
            // }

            // Check for any cross-boundary violations
            // if let violations = await detectCrossBoundaryViolations(for: id),
            //    !violations.isEmpty {
            //     let message = "Cross-boundary violations detected for key \(id): \(violations)"
            //     throw KeyManagerError.securityBoundaryViolation(message)
            // }
        }
    }

    // MARK: - Private Helper Methods

    private func scheduleKeyDeletion(id: String, afterDelay: TimeInterval) async throws {
        guard let metadata = keyMetadata[id] else {
            throw KeyManagerError.keyNotFound("Key \(id) not found")
        }

        let deletionTime = Date().addingTimeInterval(afterDelay)
        var updatedMetadata = metadata
        updatedMetadata.status = .pendingDeletion(deletionTime)
        keyMetadata[id] = updatedMetadata
    }

    /// Check if a key is stored in the Secure Enclave
    /// - Parameter id: Key identifier
    /// - Returns: True if the key is stored in the Secure Enclave
    private func isStoredInSecureEnclave(id: String) -> Bool {
        // Check if the key is stored in the secure enclave
        guard let metadata = keyMetadata[id] else { return false }
        return metadata.storageLocation == .secureEnclave
    }
}

/// Errors that can occur during key management operations
public enum KeyManagerError: LocalizedError {
    /// The requested key was not found
    case keyNotFound(String)
    /// The key is stored in an unsupported location
    case unsupportedStorageLocation(CoreServicesTypes.StorageLocation)
    /// Failed to synchronise keys between processes
    case synchronisationError(String)
    /// Failed to perform key operation
    case operationFailed(String)
    /// The key has expired
    case keyExpired(String)
    /// The key has been compromised
    case keyCompromised(String)
    /// The key has been retired
    case keyRetired(String)
    /// Invalid key state for operation
    case invalidKeyState(String)
    /// Invalid key metadata
    case invalidMetadata(String)
    /// Key access denied
    case accessDenied(String)
    /// Security boundary violation
    case securityBoundaryViolation(String)
    /// Key generation error
    case keyGenerationError(String)

    public var errorDescription: String? {
        switch self {
        case .keyNotFound(let message):
            return "Key not found: \(message)"
        case .unsupportedStorageLocation(let location):
            return "Unsupported storage location: \(location)"
        case .synchronisationError(let message):
            return "Failed to synchronise keys: \(message)"
        case .operationFailed(let message):
            return "Key operation failed: \(message)"
        case .keyExpired(let message):
            return "Key has expired: \(message)"
        case .keyCompromised(let message):
            return "Key has been compromised: \(message)"
        case .keyRetired(let message):
            return "Key has been retired: \(message)"
        case .invalidKeyState(let message):
            return "Invalid key state: \(message)"
        case .invalidMetadata(let message):
            return "Invalid key metadata: \(message)"
        case .accessDenied(let message):
            return "Key access denied: \(message)"
        case .securityBoundaryViolation(let message):
            return "Security boundary violation: \(message)"
        case .keyGenerationError(let message):
            return "Key generation error: \(message)"
        }
    }
}

// MARK: - Supporting Types

public struct KeyMetadata: Sendable {
    public var status: CoreServicesTypes.KeyStatus
    public var storageLocation: CoreServicesTypes.StorageLocation
    public var accessControls: AccessControls
    public var isProcessIsolated: Bool
    public var hasSecureMemoryBoundaries: Bool
    public var expiryDate: Date?
    public var scheduledForDeletion: Date?

    public init(
        status: CoreServicesTypes.KeyStatus,
        storageLocation: CoreServicesTypes.StorageLocation,
        accessControls: AccessControls,
        isProcessIsolated: Bool,
        hasSecureMemoryBoundaries: Bool,
        expiryDate: Date? = nil,
        scheduledForDeletion: Date? = nil
    ) {
        self.status = status
        self.storageLocation = storageLocation
        self.accessControls = accessControls
        self.isProcessIsolated = isProcessIsolated
        self.hasSecureMemoryBoundaries = hasSecureMemoryBoundaries
        self.expiryDate = expiryDate
        self.scheduledForDeletion = scheduledForDeletion
    }
}

public enum KeyStatus: Sendable {
    case active
    case compromised
    case retired
    case rotated(replacedBy: KeyIdentifier)
    case pendingDeletion(Date)
}

public enum StorageLocation: Sendable {
    case secureEnclave
    case insecureStorage
}

public struct AccessControls: Sendable {
    public func isCompliant(with policy: SecurityPolicy) -> Bool {
        // Implement access control compliance check
        return true
    }
}

public enum SecurityViolation: Sendable {
    case processIsolationViolation
    case memoryBoundaryViolation
}

public struct SecurityPolicy: Sendable {
    public static var current: SecurityPolicy {
        // Implement current security policy
        return SecurityPolicy()
    }
}

public struct KeySyncData: Sendable {
    public let keys: [KeyIdentifier: [UInt8]]
    public let metadata: [KeyIdentifier: KeyMetadata]
    public let implementations: [KeyIdentifier: CryptoImplementation]

    public init(
        keys: [KeyIdentifier: [UInt8]],
        metadata: [KeyIdentifier: KeyMetadata],
        implementations: [KeyIdentifier: CryptoImplementation]
    ) {
        self.keys = keys
        self.metadata = metadata
        self.implementations = implementations
    }
}

extension TimeInterval {
    static func hours(_ hours: Int) -> TimeInterval {
        return TimeInterval(hours * 60 * 60)
    }
}

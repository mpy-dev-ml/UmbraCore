import Foundation
import KeyManagementTypes

/// Metadata about a cryptographic key
///
/// - Important: This type is deprecated. Please use the canonical `KeyMetadata` instead.
///
/// The canonical implementation is available in the KeyManagementTypes module and provides
/// a standardised representation used across the UmbraCore framework.
@available(*, deprecated, message: "Please use the canonical KeyMetadata instead")
public struct KeyMetadata: Sendable, Codable {
  /// Current status of the key
  public var status: KeyStatus

  /// Storage location of the key
  public let storageLocation: StorageLocation

  /// Access control settings for the key
  public enum AccessControls: String, Sendable, Codable {
    /// No special access controls
    case none
    /// Requires user authentication
    case requiresAuthentication
    /// Requires biometric authentication
    case requiresBiometric
    /// Requires both user and biometric authentication
    case requiresBoth
  }

  /// Access controls applied to the key
  public let accessControls: AccessControls

  /// Creation date of the key
  public let createdAt: Date

  /// Last modification date of the key
  public var lastModified: Date

  /// Expiry date of the key (if applicable)
  public var expiryDate: Date?

  /// Key algorithm and parameters
  public let algorithm: String

  /// Key size in bits
  public let keySize: Int

  /// Unique identifier for the key
  public let identifier: String

  /// Version of the key
  public var version: Int

  /// Whether the key can be exported
  public var exportable: Bool

  /// Whether this is a system key
  public var isSystemKey: Bool

  /// Whether this key is process isolated
  public var isProcessIsolated: Bool

  /// Custom metadata for the key
  public var customMetadata: [String: String]?

  /// Create new key metadata
  /// - Parameters:
  ///   - status: Current status of the key
  ///   - storageLocation: Where the key is stored
  ///   - accessControls: Access control settings
  ///   - createdAt: Creation date
  ///   - lastModified: Last modification date
  ///   - expiryDate: Optional expiry date
  ///   - algorithm: Key algorithm
  ///   - keySize: Key size in bits
  ///   - identifier: Unique identifier
  ///   - version: Key version
  ///   - exportable: Whether the key can be exported
  ///   - isSystemKey: Whether this is a system key
  ///   - isProcessIsolated: Whether this key is process isolated
  ///   - customMetadata: Custom metadata for the key
  public init(
    status: KeyStatus = .active,
    storageLocation: StorageLocation,
    accessControls: AccessControls = .none,
    createdAt: Date=Date(),
    lastModified: Date=Date(),
    expiryDate: Date?=nil,
    algorithm: String,
    keySize: Int,
    identifier: String,
    version: Int=1,
    exportable: Bool=false,
    isSystemKey: Bool=false,
    isProcessIsolated: Bool=false,
    customMetadata: [String: String]?=nil
  ) {
    self.status=status
    self.storageLocation=storageLocation
    self.accessControls=accessControls
    self.createdAt=createdAt
    self.lastModified=lastModified
    self.expiryDate=expiryDate
    self.algorithm=algorithm
    self.keySize=keySize
    self.identifier=identifier
    self.version=version
    self.exportable=exportable
    self.isSystemKey=isSystemKey
    self.isProcessIsolated=isProcessIsolated
    self.customMetadata=customMetadata
  }

  /// Create new key metadata with basic parameters
  /// - Parameters:
  ///   - storageLocation: Where the key is stored
  ///   - accessControls: Access control settings
  ///   - algorithm: Key algorithm
  ///   - keySize: Key size in bits
  ///   - expiryDate: Optional expiry date for the key
  public init(
    storageLocation: StorageLocation,
    accessControls: AccessControls = .none,
    algorithm: String,
    keySize: Int,
    expiryDate: Date?=nil
  ) {
    status=KeyStatus.active
    self.storageLocation=storageLocation
    self.accessControls=accessControls
    self.algorithm=algorithm
    self.keySize=keySize
    createdAt=Date()
    lastModified=Date()
    self.expiryDate=expiryDate
    identifier=UUID().uuidString
    version=1
    exportable=false
    isSystemKey=false
    isProcessIsolated=false
    customMetadata=nil
  }

  /// Check if the key is expired
  /// - Returns: True if the key is expired
  public func isExpired() -> Bool {
    if let expiryDate {
      return expiryDate < Date()
    }
    return false
  }

  /// Create a new metadata with updated status
  /// - Parameter newStatus: The new status
  /// - Returns: Updated metadata
  public func withStatus(_ newStatus: KeyStatus) -> KeyMetadata {
    var updated=self
    updated.status=newStatus
    updated.lastModified=Date()
    return updated
  }
}

// MARK: - Raw Conversion Extension (for KeyManagementTypes)

/// Extension to provide conversion to/from the raw representation
/// This will be used by the KeyManagementTypes module through type extension
extension KeyMetadata {
  /// Raw representation that matches the canonical type's raw metadata
  public struct RawRepresentation: Sendable {
    public var status: KeyManagementTypes.KeyStatus
    public let storageLocation: KeyManagementTypes.StorageLocation
    public let accessControls: KeyManagementTypes.KeyMetadata.AccessControls
    public let createdAt: Date
    public var lastModified: Date
    public var expiryDate: Date?
    public let algorithm: String
    public let keySize: Int
    public let identifier: String
    public var version: Int
    public var exportable: Bool
    public var isSystemKey: Bool
    public var isProcessIsolated: Bool
    public var customMetadata: [String: String]?

    /// Initialise a new KeyMetadata.RawRepresentation
    /// - Parameters:
    ///   - status: Status of the key
    ///   - storageLocation: Storage location
    ///   - accessControls: Access control settings
    ///   - createdAt: Creation date
    ///   - lastModified: Last modification date
    ///   - expiryDate: Expiry date
    ///   - algorithm: Key algorithm
    ///   - keySize: Key size in bits
    ///   - identifier: Unique identifier
    ///   - version: Key version
    public init(
      status: KeyManagementTypes.KeyStatus = .active,
      storageLocation: KeyManagementTypes.StorageLocation,
      accessControls: KeyManagementTypes.KeyMetadata.AccessControls = .none,
      createdAt: Date=Date(),
      lastModified: Date=Date(),
      expiryDate: Date?=nil,
      algorithm: String="AES-GCM",
      keySize: Int=256,
      identifier: String=UUID().uuidString,
      version: Int=1,
      exportable: Bool=false,
      isSystemKey: Bool=false,
      isProcessIsolated: Bool=false,
      customMetadata: [String: String]?=nil
    ) {
      self.status=status
      self.storageLocation=storageLocation
      self.accessControls=accessControls
      self.createdAt=createdAt
      self.lastModified=lastModified
      self.expiryDate=expiryDate
      self.algorithm=algorithm
      self.keySize=keySize
      self.identifier=identifier
      self.version=version
      self.exportable=exportable
      self.isSystemKey=isSystemKey
      self.isProcessIsolated=isProcessIsolated
      self.customMetadata=customMetadata
    }

    public init(
      status: KeyManagementTypes.KeyStatus = .active,
      storageLocation: KeyManagementTypes.StorageLocation,
      accessControls: KeyManagementTypes.KeyMetadata.AccessControls = .none,
      createdAtTimestamp: Int64,
      lastModifiedTimestamp: Int64,
      expiryTimestamp: Int64?=nil,
      algorithm: String,
      keySize: Int,
      identifier: String,
      version: Int=1,
      exportable: Bool=false,
      isSystemKey: Bool=false,
      isProcessIsolated: Bool=false,
      customMetadata: [String: String]?=nil
    ) {
      self.status=status
      self.storageLocation=storageLocation
      self.accessControls=accessControls
      createdAt=Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp))
      lastModified=Date(timeIntervalSince1970: TimeInterval(lastModifiedTimestamp))
      if let expiryTimestamp {
        expiryDate=Date(timeIntervalSince1970: TimeInterval(expiryTimestamp))
      } else {
        expiryDate=nil
      }
      self.algorithm=algorithm
      self.keySize=keySize
      self.identifier=identifier
      self.version=version
      self.exportable=exportable
      self.isSystemKey=isSystemKey
      self.isProcessIsolated=isProcessIsolated
      self.customMetadata=customMetadata
    }
  }

  /// Convert to the canonical raw representation
  /// - Returns: RawRepresentation that can be used with KeyManagementTypes
  public func toRawRepresentation() -> RawRepresentation {
    RawRepresentation(
      status: status.toRawRepresentation(),
      storageLocation: storageLocation.toRawRepresentation(),
      accessControls: KeyManagementTypes.KeyMetadata
        .AccessControls(rawValue: accessControls.rawValue)!,
      createdAt: createdAt,
      lastModified: lastModified,
      expiryDate: expiryDate,
      algorithm: algorithm,
      keySize: keySize,
      identifier: identifier,
      version: version,
      exportable: exportable,
      isSystemKey: isSystemKey,
      isProcessIsolated: isProcessIsolated,
      customMetadata: customMetadata
    )
  }

  /// Create from the canonical raw representation
  /// - Parameter rawRepresentation: Raw representation from KeyManagementTypes
  /// - Returns: Legacy KeyMetadata
  public static func from(rawRepresentation: RawRepresentation) -> KeyMetadata {
    KeyMetadata(
      status: KeyStatus.from(rawRepresentation: rawRepresentation.status),
      storageLocation: StorageLocation.from(rawRepresentation: rawRepresentation.storageLocation),
      accessControls: AccessControls(rawValue: rawRepresentation.accessControls.rawValue)!,
      createdAt: rawRepresentation.createdAt,
      lastModified: rawRepresentation.lastModified,
      expiryDate: rawRepresentation.expiryDate,
      algorithm: rawRepresentation.algorithm,
      keySize: rawRepresentation.keySize,
      identifier: rawRepresentation.identifier,
      version: rawRepresentation.version,
      exportable: rawRepresentation.exportable,
      isSystemKey: rawRepresentation.isSystemKey,
      isProcessIsolated: rawRepresentation.isProcessIsolated,
      customMetadata: rawRepresentation.customMetadata
    )
  }
}

/// Extension to provide conversion to/from the raw representation
/// This will be used by KeyManagementTypes module through type extension
extension KeyStatus {
  /// The raw representation that matches the canonical type's raw status
  public func toRawRepresentation() -> KeyManagementTypes.KeyStatus {
    switch self {
      case .active: .active
      case .compromised: .compromised
      case .retired: .retired
      case let .pendingDeletion(date): .pendingDeletion(date)
    }
  }

  /// Create from the canonical raw representation
  /// - Parameter rawRepresentation: Raw representation from KeyManagementTypes
  /// - Returns: Legacy KeyStatus
  public static func from(rawRepresentation: KeyManagementTypes.KeyStatus) -> KeyStatus {
    switch rawRepresentation {
      case .active: .active
      case .compromised: .compromised
      case .retired: .retired
      case let .pendingDeletion(date): .pendingDeletion(date)
    }
  }
}

/// Extension to provide conversion to/from the raw representation
/// This will be used by KeyManagementTypes module through type extension
extension StorageLocation {
  /// The raw representation that matches the canonical type's raw locations
  public func toRawRepresentation() -> KeyManagementTypes.StorageLocation {
    switch self {
      case .secureEnclave: .secureEnclave
      case .keychain: .keychain
      case .memory: .memory
    }
  }

  /// Create from the canonical raw representation
  /// - Parameter rawRepresentation: Raw representation from KeyManagementTypes
  /// - Returns: Legacy StorageLocation
  public static func from(
    rawRepresentation: KeyManagementTypes
      .StorageLocation
  ) -> StorageLocation {
    switch rawRepresentation {
      case .secureEnclave: .secureEnclave
      case .keychain: .keychain
      case .memory: .memory
    }
  }
}

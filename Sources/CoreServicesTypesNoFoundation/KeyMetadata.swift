/// Metadata about a cryptographic key
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

  /// Creation date of the key (Unix timestamp)
  public let createdAtTimestamp: Int64

  /// Last modification date of the key (Unix timestamp)
  public var lastModifiedTimestamp: Int64

  /// Identifier for the key
  public let identifier: String

  /// Version of the key
  public var version: Int

  /// Algorithm used for the key
  public let algorithm: String

  /// Key length in bits
  public let keyLengthBits: Int

  /// Whether the key can be exported
  public let exportable: Bool

  /// Whether the key is a system key
  public let isSystemKey: Bool

  /// Create a new key metadata
  public init(
    status: KeyStatus,
    storageLocation: StorageLocation,
    accessControls: AccessControls,
    createdAtTimestamp: Int64,
    lastModifiedTimestamp: Int64,
    identifier: String,
    version: Int,
    algorithm: String,
    keyLengthBits: Int,
    exportable: Bool,
    isSystemKey: Bool
  ) {
    self.status=status
    self.storageLocation=storageLocation
    self.accessControls=accessControls
    self.createdAtTimestamp=createdAtTimestamp
    self.lastModifiedTimestamp=lastModifiedTimestamp
    self.identifier=identifier
    self.version=version
    self.algorithm=algorithm
    self.keyLengthBits=keyLengthBits
    self.exportable=exportable
    self.isSystemKey=isSystemKey
  }
}

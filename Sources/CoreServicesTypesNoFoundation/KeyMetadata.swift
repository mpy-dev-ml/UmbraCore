import KeyManagementTypes

/// Metadata about a cryptographic key
///
/// - Important: This type is deprecated. Please use `KeyManagementTypes.KeyMetadata` instead.
///
/// The canonical implementation is available in the KeyManagementTypes module and provides
/// a standardised representation used across the UmbraCore framework.
@available(*, deprecated, message: "Please use KeyManagementTypes.KeyMetadata instead")
public struct KeyMetadata: Sendable, Codable {
  /// Current status of the key
  public var status: KeyManagementTypes.KeyStatus

  /// Storage location of the key
  public let storageLocation: KeyManagementTypes.StorageLocation

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
    status: KeyManagementTypes.KeyStatus,
    storageLocation: KeyManagementTypes.StorageLocation,
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

  /// Convert to the canonical KeyMetadata type
  /// - Returns: The equivalent canonical KeyMetadata
  public func toCanonical() -> KeyManagementTypes.KeyMetadata {
    // Map AccessControls to canonical enum
    let canonicalControls: KeyManagementTypes.KeyMetadata.AccessControls
    switch accessControls {
    case .none: canonicalControls = .none
    case .requiresAuthentication: canonicalControls = .requiresAuthentication
    case .requiresBiometric: canonicalControls = .requiresBiometric
    case .requiresBoth: canonicalControls = .requiresBoth
    }
    
    return KeyManagementTypes.KeyMetadata.withTimestamps(
      status: status,
      storageLocation: storageLocation,
      accessControls: canonicalControls,
      createdAtTimestamp: createdAtTimestamp,
      lastModifiedTimestamp: lastModifiedTimestamp,
      algorithm: algorithm,
      keySize: keyLengthBits,
      identifier: identifier,
      version: version,
      exportable: exportable,
      isSystemKey: isSystemKey,
      isProcessIsolated: false // Not supported in legacy type
    )
  }

  /// Create from the canonical KeyMetadata type
  /// - Parameter canonical: The canonical KeyMetadata to convert from
  /// - Returns: The equivalent legacy KeyMetadata
  public static func from(canonical: KeyManagementTypes.KeyMetadata) -> KeyMetadata {
    // Map AccessControls from canonical enum
    let legacyControls: AccessControls
    switch canonical.accessControls {
    case .none: legacyControls = .none
    case .requiresAuthentication: legacyControls = .requiresAuthentication
    case .requiresBiometric: legacyControls = .requiresBiometric
    case .requiresBoth: legacyControls = .requiresBoth
    @unknown default:
      // Default to the most restrictive option for any new unknown enum values
      legacyControls = .requiresBoth
    }
    
    return KeyMetadata(
      status: canonical.status,
      storageLocation: canonical.storageLocation,
      accessControls: legacyControls,
      createdAtTimestamp: canonical.createdAtTimestamp,
      lastModifiedTimestamp: canonical.lastModifiedTimestamp,
      identifier: canonical.identifier,
      version: canonical.version,
      algorithm: canonical.algorithm,
      keyLengthBits: canonical.keySize,
      exportable: canonical.exportable,
      isSystemKey: canonical.isSystemKey
    )
  }

  // Helper to convert AccessControls to the canonical type
  private static func convertAccessControls(_ controls: AccessControls) -> KeyManagementTypes.KeyMetadata.AccessControls {
    switch controls {
      case .none:
        .none
      case .requiresAuthentication:
        .requiresAuthentication
      case .requiresBiometric:
        .requiresBiometric
      case .requiresBoth:
        .requiresBoth
    }
  }

  // Helper to convert canonical AccessControls to the legacy type
  private static func convertAccessControls(_ canonicalControls: KeyManagementTypes.KeyMetadata.AccessControls) -> AccessControls {
    switch canonicalControls {
      case .none:
        return .none
      case .requiresAuthentication:
        return .requiresAuthentication
      case .requiresBiometric:
        return .requiresBiometric
      case .requiresBoth:
        return .requiresBoth
      @unknown default:
        // Default to 'none' for any future cases
        return .none
    }
  }
}

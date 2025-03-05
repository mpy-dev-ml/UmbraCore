import Foundation
import SecurityProtocolsCore

/// Security level options for the security provider
@frozen
public enum SecurityLevel: Int, Sendable {
  case basic=0
  case standard=1
  case advanced=2
  case maximum=3
}

/// Configuration for security operations
public struct SecurityConfiguration: Sendable {
  /// The security level to use
  public let securityLevel: SecurityLevel

  /// The encryption algorithm to use (e.g., "AES-256")
  public let encryptionAlgorithm: String

  /// The hash algorithm to use (e.g., "SHA-256")
  public let hashAlgorithm: String

  /// Additional options for configuration
  public let options: [String: String]?

  /// Initialize with specific security settings
  /// - Parameters:
  ///   - securityLevel: The security level to use
  ///   - encryptionAlgorithm: The encryption algorithm to use
  ///   - hashAlgorithm: The hash algorithm to use
  ///   - options: Additional options for configuration
  public init(
    securityLevel: SecurityLevel,
    encryptionAlgorithm: String,
    hashAlgorithm: String,
    options: [String: String]?
  ) {
    self.securityLevel=securityLevel
    self.encryptionAlgorithm=encryptionAlgorithm
    self.hashAlgorithm=hashAlgorithm
    self.options=options
  }

  /// Default configuration with standard security settings
  public static let `default`=SecurityConfiguration(
    securityLevel: .standard,
    encryptionAlgorithm: "AES-256",
    hashAlgorithm: "SHA-256",
    options: nil
  )

  /// Configuration with minimal security settings for testing
  public static let minimal=SecurityConfiguration(
    securityLevel: .basic,
    encryptionAlgorithm: "AES-128",
    hashAlgorithm: "SHA-1",
    options: nil
  )

  /// Configuration with maximum security settings
  public static let maximum=SecurityConfiguration(
    securityLevel: .maximum,
    encryptionAlgorithm: "AES-GCM-256",
    hashAlgorithm: "SHA-512",
    options: ["keyRotation": "enabled", "remoteAttestation": "required"]
  )

  /// Convert to a dictionary representation for interoperability
  /// - Returns: Dictionary representation of this configuration
  public func toDictionary() -> [String: Any] {
    var result: [String: Any]=[
      "securityLevel": securityLevel.rawValue,
      "encryptionAlgorithm": encryptionAlgorithm,
      "hashAlgorithm": hashAlgorithm
    ]

    if let options {
      for (key, value) in options {
        result[key]=value
      }
    }

    return result
  }

  /// Convert to a SecurityProtocolsCore configuration object
  /// - Returns: A SecurityConfig instance
  public func toSecurityProtocolsConfig() -> SecurityConfig {
    SecurityConfig(
      algorithm: encryptionAlgorithm,
      keySizeInBits: securityLevel == .basic ? 128 : (securityLevel == .standard ? 256 : 512)
    )
  }
}

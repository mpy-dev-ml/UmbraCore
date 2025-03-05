import Foundation

/// Errors that can occur during cryptographic operations
public enum CryptoError: LocalizedError, Sendable {
  /// Failed to generate a cryptographic key
  case keyGenerationFailed

  /// Failed to generate an initialization vector
  case ivGenerationFailed

  /// Failed to encrypt data
  case encryptionFailed

  /// Failed to decrypt data
  case decryptionFailed

  /// Failed to generate an authentication tag
  case tagGenerationFailed

  /// Failed to derive a key from a password
  case keyDerivationFailed

  /// Invalid key size
  case invalidKeySize

  /// Invalid initialization vector
  case invalidIV

  /// Invalid authentication tag
  case invalidAuthenticationTag

  /// Failed to generate random data
  case randomGenerationFailed

  public var errorDescription: String? {
    switch self {
      case .keyGenerationFailed:
        "Failed to generate cryptographic key"
      case .ivGenerationFailed:
        "Failed to generate initialization vector"
      case .encryptionFailed:
        "Failed to encrypt data"
      case .decryptionFailed:
        "Failed to decrypt data"
      case .tagGenerationFailed:
        "Failed to generate authentication tag"
      case .keyDerivationFailed:
        "Failed to derive key from password"
      case .invalidKeySize:
        "Invalid key size"
      case .invalidIV:
        "Invalid initialization vector"
      case .invalidAuthenticationTag:
        "Invalid authentication tag"
      case .randomGenerationFailed:
        "Failed to generate random data"
    }
  }
}

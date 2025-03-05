import Foundation

// Import CoreErrors for migration path
import CoreErrors

/// Errors that can occur during cryptographic operations
///
/// @deprecated This will be replaced by CoreErrors.CryptoError in a future version.
/// New code should use CoreErrors.CryptoError directly.
@available(*, deprecated, message: "Use CoreErrors.CryptoError instead")
@frozen
public enum CryptoError: LocalizedError, Sendable {
  /// Invalid key length
  case invalidKeyLength(expected: Int, got: Int)
  /// Invalid initialization vector length
  case invalidIVLength(expected: Int, got: Int)
  /// Invalid salt length
  case invalidSaltLength(expected: Int, got: Int)
  /// Invalid iteration count
  case invalidIterationCount(expected: Int, got: Int)
  /// General encryption error
  case encryptionFailed(reason: String)
  /// General decryption error
  case decryptionFailed(reason: String)
  /// Key derivation error
  case keyDerivationFailed(reason: String)
  /// Authentication failed
  case authenticationFailed(reason: String)
  /// Random number generation failed
  case randomGenerationFailed(status: OSStatus)
  /// Key not found
  case keyNotFound(identifier: String)
  /// Key already exists
  case keyExists(identifier: String)
  /// Keychain operation failed
  case keychainError(status: OSStatus)
  /// Invalid key data
  case invalidKey(reason: String)

  public var errorDescription: String? {
    switch self {
      case let .invalidKeyLength(expected, got):
        "Invalid key length: expected \(expected) bytes, got \(got) bytes"
      case let .invalidIVLength(expected, got):
        "Invalid IV length: expected \(expected) bytes, got \(got) bytes"
      case let .invalidSaltLength(expected, got):
        "Invalid salt length: expected \(expected) bytes, got \(got) bytes"
      case let .invalidIterationCount(expected, got):
        "Invalid iteration count: expected at least \(expected), got \(got)"
      case let .encryptionFailed(reason):
        "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        "Decryption failed: \(reason)"
      case let .keyDerivationFailed(reason):
        "Key derivation failed: \(reason)"
      case let .authenticationFailed(reason):
        "Authentication failed: \(reason)"
      case let .randomGenerationFailed(status):
        "Random number generation failed: \(status)"
      case let .keyNotFound(identifier):
        "Key not found: \(identifier)"
      case let .keyExists(identifier):
        "Key already exists: \(identifier)"
      case let .keychainError(status):
        "Keychain operation failed with status: \(status)"
      case let .invalidKey(reason):
        "Invalid key: \(reason)"
    }
  }
}

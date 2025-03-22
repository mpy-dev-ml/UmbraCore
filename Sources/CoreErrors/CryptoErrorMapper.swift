import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// Provides mapping functions between CoreErrors.CryptoError and canonical Crypto error types
///
/// This mapper facilitates the transition from the legacy CryptoError type to the
/// canonical error types. It ensures consistent error mapping
/// across the codebase and maintains backward compatibility where needed.
public enum CryptoErrorMapper {
  /// Maps from legacy CoreErrors.CryptoError to canonical Crypto.Core error type
  ///
  /// - Parameter error: Legacy CryptoError to map
  /// - Returns: Equivalent canonical Crypto.Core error instance
  static func mapToCanonicalError(_ error: CryptoError) -> UmbraErrors.Crypto.Core {
    switch error {
      case let .invalidKeyLength(expected, got):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "keyLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )

      case let .invalidIVLength(expected, got):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "ivLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )

      case let .invalidSaltLength(expected, got):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "saltLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )

      case let .invalidIterationCount(expected, got):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "iterations",
          reason: "Expected at least \(expected), got \(got)"
        )

      case .keyGenerationFailed:
        .keyGenerationFailed(
          keyType: "unknown",
          reason: "Failed to generate cryptographic key"
        )

      case .ivGenerationFailed:
        .randomGenerationFailed(
          reason: "Failed to generate initialization vector"
        )

      case let .encryptionFailed(reason):
        .encryptionFailed(
          algorithm: "unknown",
          reason: reason
        )

      case let .decryptionFailed(reason):
        .decryptionFailed(
          algorithm: "unknown",
          reason: reason
        )

      case .tagGenerationFailed:
        .internalError(
          "Failed to generate authentication tag"
        )

      case let .keyDerivationFailed(reason):
        .keyDerivationFailed(
          algorithm: "unknown",
          reason: reason
        )

      case let .authenticationFailed(reason):
        .signatureVerificationFailed(
          algorithm: "unknown",
          reason: reason
        )

      case let .randomGenerationFailed(status):
        .randomGenerationFailed(
          reason: "Random number generation failed with status: \(status)"
        )

      case let .keyNotFound(identifier):
        .keyNotFound(
          keyIdentifier: identifier
        )

      case let .keyExists(identifier):
        .internalError(
          "Key already exists: \(identifier)"
        )

      case let .keychainError(status):
        .internalError(
          "Keychain operation failed with status: \(status)"
        )

      case let .invalidKey(reason):
        .invalidKey(
          keyType: "unknown",
          reason: reason
        )

      case let .invalidKeySize(reason):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "keySize",
          reason: reason
        )

      case let .invalidKeyFormat(reason):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "keyFormat",
          reason: reason
        )

      case let .invalidCredentialIdentifier(reason):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "credentialIdentifier",
          reason: reason
        )

      // New cases
      case let .encryptionError(message):
        .encryptionFailed(
          algorithm: "unknown",
          reason: message
        )

      case let .decryptionError(message):
        .decryptionFailed(
          algorithm: "unknown",
          reason: message
        )

      case let .keyGenerationError(reason):
        .keyGenerationFailed(
          keyType: "unknown",
          reason: reason
        )

      case let .encodingError(message):
        .internalError(
          "Encoding error: \(message)"
        )

      case let .decodingError(message):
        .internalError(
          "Decoding error: \(message)"
        )

      case let .keyStorageError(reason):
        .internalError(
          "Key storage error: \(reason)"
        )

      case let .keyDeletionError(reason):
        .internalError(
          "Key deletion error: \(reason)"
        )

      case let .asymmetricEncryptionError(message):
        .encryptionFailed(
          algorithm: "asymmetric",
          reason: message
        )

      case let .asymmetricDecryptionError(message):
        .decryptionFailed(
          algorithm: "asymmetric",
          reason: message
        )

      case let .hashingError(message):
        .hashingFailed(
          algorithm: "unknown",
          reason: message
        )

      case let .signatureError(reason):
        .signatureFailed(
          algorithm: "unknown",
          reason: reason
        )

      case let .unsupportedAlgorithm(algorithm):
        .unsupportedAlgorithm(
          algorithm: algorithm
        )

      case let .invalidLength(length):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "length",
          reason: "Invalid data length: \(length)"
        )

      case let .invalidParameters(reason):
        .invalidParameters(
          algorithm: "unknown",
          parameter: "generic",
          reason: reason
        )
    }
  }

  /// Maps from canonical Crypto.Core error to legacy CoreErrors.CryptoError
  ///
  /// Note: This mapping is lossy as the canonical error type has more specific cases than the
  /// legacy type.
  /// It should be used only for backward compatibility with code that still requires the legacy
  /// type.
  ///
  /// - Parameter error: Canonical Crypto.Core error to map
  /// - Returns: Best-fit equivalent CoreErrors.CryptoError instance
  static func mapToLegacyError(_ error: UmbraErrors.Crypto.Core) -> CryptoError {
    switch error {
      case let .encryptionFailed(algorithm, reason):
        .encryptionFailed(reason: "\(algorithm): \(reason)")

      case let .decryptionFailed(algorithm, reason):
        .decryptionFailed(reason: "\(algorithm): \(reason)")

      case let .invalidCiphertext(reason):
        .decryptionFailed(reason: "Invalid ciphertext: \(reason)")

      case let .paddingValidationFailed(algorithm):
        .decryptionFailed(reason: "Padding validation failed with \(algorithm)")

      case .keyGenerationFailed:
        .keyGenerationFailed

      case let .keyDerivationFailed(algorithm, reason):
        .keyDerivationFailed(reason: "\(algorithm): \(reason)")

      case let .invalidKey(keyType, reason):
        .invalidKey(reason: "\(keyType): \(reason)")

      case let .keyNotFound(keyIdentifier):
        .keyNotFound(identifier: keyIdentifier)

      case let .signatureFailed(algorithm, reason):
        .authenticationFailed(reason: "Signature failed with \(algorithm): \(reason)")

      case let .signatureVerificationFailed(algorithm, reason):
        .authenticationFailed(reason: "Signature verification failed with \(algorithm): \(reason)")

      case let .invalidSignature(reason):
        .authenticationFailed(reason: "Invalid signature: \(reason)")

      case let .hashingFailed(algorithm, reason):
        .encryptionFailed(reason: "Hashing failed with \(algorithm): \(reason)")

      case let .hashVerificationFailed(algorithm):
        .authenticationFailed(reason: "Hash verification failed with \(algorithm)")

      case let .unsupportedAlgorithm(algorithm):
        .encryptionFailed(reason: "Unsupported algorithm: \(algorithm)")

      case let .invalidParameters(algorithm, parameter, reason):
        if parameter == "keyLength" {
          .invalidKeyLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "ivLength" {
          .invalidIVLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "saltLength" {
          .invalidSaltLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "keySize" {
          .invalidKeySize(reason: "\(algorithm): \(reason)")
        } else if parameter == "length" {
          .invalidLength(0) // Cannot extract specific value from the reason
        } else {
          .invalidParameters(reason: "Invalid parameter \(parameter) for \(algorithm): \(reason)")
        }

      case let .incompatibleParameters(algorithm, parameter, _):
        .invalidParameters(reason: "Incompatible parameter \(parameter) for \(algorithm)")

      case .randomGenerationFailed:
        // We can't use the reason for the OSStatus but we're acknowledging its existence
        .randomGenerationFailed(status: 0)

      case .insufficientEntropy:
        .randomGenerationFailed(status: -1)

      case let .internalError(description):
        .encryptionFailed(reason: "Internal error: \(description)")

      default:
        .encryptionFailed(reason: "Unmapped crypto error")
    }
  }

  /// Maps the error and returns it as Any to avoid exposing the internal type in public interfaces
  ///
  /// - Parameter error: Legacy CryptoError to map
  /// - Returns: The canonical error as an opaque Any type
  public static func mapToCanonicalErrorType(_ error: CryptoError) -> Any {
    mapToCanonicalError(error)
  }

  /// Maps the error from Any type back to the legacy type
  ///
  /// - Parameter error: Canonical error as Any
  /// - Returns: Equivalent CoreErrors.CryptoError instance or nil if type doesn't match
  public static func mapFromCanonicalErrorType(_ error: Any) -> CryptoError? {
    if let canonicalError=error as? UmbraErrors.Crypto.Core {
      return mapToLegacyError(canonicalError)
    }
    return nil
  }
}

extension CryptoError {
  /// Converts this legacy CryptoError to the canonical error type
  /// Note: Returns as Any to avoid exposing internal type in public interface
  ///
  /// - Returns: The canonical error as an opaque Any type
  public func toCanonical() -> Any {
    CryptoErrorMapper.mapToCanonicalError(self)
  }

  /// Attempts to create a CryptoError from a canonical error
  ///
  /// - Parameter error: Canonical error as Any
  /// - Returns: CryptoError instance if conversion is possible
  public static func fromCanonical(_ error: Any) -> CryptoError? {
    CryptoErrorMapper.mapFromCanonicalErrorType(error)
  }
}

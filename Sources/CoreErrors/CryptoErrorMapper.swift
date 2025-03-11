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
  internal static func mapToCanonicalError(_ error: CryptoError) -> UmbraErrors.Crypto.Core {
    switch error {
      case let .invalidKeyLength(expected, got):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "keyLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )
        
      case let .invalidIVLength(expected, got):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "ivLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )
        
      case let .invalidSaltLength(expected, got):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "saltLength",
          reason: "Expected \(expected) bytes, got \(got) bytes"
        )
        
      case let .invalidIterationCount(expected, got):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "iterations",
          reason: "Expected at least \(expected), got \(got)"
        )
        
      case .keyGenerationFailed:
        return .keyGenerationFailed(
          keyType: "unknown",
          reason: "Failed to generate cryptographic key"
        )
        
      case .ivGenerationFailed:
        return .randomGenerationFailed(
          reason: "Failed to generate initialization vector"
        )
        
      case let .encryptionFailed(reason):
        return .encryptionFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .decryptionFailed(reason):
        return .decryptionFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case .tagGenerationFailed:
        return .internalError(
          "Failed to generate authentication tag"
        )
        
      case let .keyDerivationFailed(reason):
        return .keyDerivationFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .authenticationFailed(reason):
        return .signatureVerificationFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .randomGenerationFailed(status):
        return .randomGenerationFailed(
          reason: "Random number generation failed with status: \(status)"
        )
        
      case let .keyNotFound(identifier):
        return .keyNotFound(
          keyIdentifier: identifier
        )
        
      case let .keyExists(identifier):
        return .internalError(
          "Key already exists: \(identifier)"
        )
        
      case let .keychainError(status):
        return .internalError(
          "Keychain operation failed with status: \(status)"
        )
        
      case let .invalidKey(reason):
        return .invalidKey(
          keyType: "unknown",
          reason: reason
        )
        
      case let .invalidKeySize(reason):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "keySize",
          reason: reason
        )
        
      case let .invalidKeyFormat(reason):
        return .invalidKey(
          keyType: "unknown",
          reason: reason
        )
        
      case let .invalidCredentialIdentifier(reason):
        return .internalError(
          "Invalid credential identifier: \(reason)"
        )
    }
  }
  
  /// Maps from canonical Crypto.Core error to legacy CoreErrors.CryptoError
  ///
  /// Note: This mapping is lossy as the canonical error type has more specific cases than the legacy type.
  /// It should be used only for backward compatibility with code that still requires the legacy type.
  ///
  /// - Parameter error: Canonical Crypto.Core error to map
  /// - Returns: Best-fit equivalent CoreErrors.CryptoError instance
  internal static func mapToLegacyError(_ error: UmbraErrors.Crypto.Core) -> CryptoError {
    switch error {
      case let .encryptionFailed(algorithm, reason):
        return .encryptionFailed(reason: "\(algorithm): \(reason)")
        
      case let .decryptionFailed(algorithm, reason):
        return .decryptionFailed(reason: "\(algorithm): \(reason)")
        
      case let .invalidCiphertext(reason):
        return .decryptionFailed(reason: "Invalid ciphertext: \(reason)")
        
      case let .paddingValidationFailed(algorithm):
        return .decryptionFailed(reason: "Padding validation failed with \(algorithm)")
        
      case .keyGenerationFailed(_, _):
        return .keyGenerationFailed
        
      case let .keyDerivationFailed(algorithm, reason):
        return .keyDerivationFailed(reason: "\(algorithm): \(reason)")
        
      case let .invalidKey(keyType, reason):
        return .invalidKey(reason: "\(keyType): \(reason)")
        
      case let .keyNotFound(keyIdentifier):
        return .keyNotFound(identifier: keyIdentifier)
        
      case let .signatureFailed(algorithm, reason):
        return .authenticationFailed(reason: "Signature failed with \(algorithm): \(reason)")
        
      case let .signatureVerificationFailed(algorithm, reason):
        return .authenticationFailed(reason: "Signature verification failed with \(algorithm): \(reason)")
        
      case let .invalidSignature(reason):
        return .authenticationFailed(reason: "Invalid signature: \(reason)")
        
      case let .hashingFailed(algorithm, reason):
        return .encryptionFailed(reason: "Hashing failed with \(algorithm): \(reason)")
        
      case let .hashVerificationFailed(algorithm):
        return .authenticationFailed(reason: "Hash verification failed with \(algorithm)")
        
      case let .unsupportedAlgorithm(algorithm):
        return .encryptionFailed(reason: "Unsupported algorithm: \(algorithm)")
        
      case let .invalidParameters(algorithm, parameter, reason):
        if parameter == "keyLength" {
          return .invalidKeyLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "ivLength" {
          return .invalidIVLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "saltLength" {
          return .invalidSaltLength(expected: 0, got: 0) // Cannot extract specific values from the reason
        } else if parameter == "keySize" {
          return .invalidKeySize(reason: "\(algorithm): \(reason)")
        } else {
          return .encryptionFailed(reason: "Invalid parameter \(parameter) for \(algorithm): \(reason)")
        }
        
      case let .incompatibleParameters(algorithm, parameter, reason):
        return .encryptionFailed(reason: "Incompatible parameter \(parameter) for \(algorithm): \(reason)")
        
      case .randomGenerationFailed(_):
        return .randomGenerationFailed(status: 0) // Cannot convert string reason to OSStatus
        
      case .insufficientEntropy:
        return .randomGenerationFailed(status: -1)
        
      case let .internalError(description):
        return .encryptionFailed(reason: "Internal error: \(description)")
        
      default:
        return .encryptionFailed(reason: "Unmapped crypto error")
    }
  }
  
  /// Maps the error and returns it as Any to avoid exposing the internal type in public interfaces
  ///
  /// - Parameter error: Legacy CryptoError to map
  /// - Returns: The canonical error as an opaque Any type
  public static func mapToCanonicalErrorType(_ error: CryptoError) -> Any {
    return mapToCanonicalError(error)
  }
  
  /// Maps the error from Any type back to the legacy type
  ///
  /// - Parameter error: Canonical error as Any
  /// - Returns: Equivalent CoreErrors.CryptoError instance or nil if type doesn't match
  public static func mapFromCanonicalErrorType(_ error: Any) -> CryptoError? {
    if let canonicalError = error as? UmbraErrors.Crypto.Core {
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

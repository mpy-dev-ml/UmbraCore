import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// Provides mapping functions between SecurityImplementation's CryptoError and UmbraErrors.Crypto.Core
///
/// This mapper facilitates the transition from the implementation-specific CryptoError type to the
/// canonical UmbraErrors.Crypto.Core type. It ensures consistent error handling
/// across the codebase.
public enum CryptoErrorMapper {
  
  /// Maps from SecurityImplementation's CryptoError to canonical UmbraErrors.Crypto.Core
  ///
  /// - Parameter error: Implementation-specific CryptoError to map
  /// - Returns: Equivalent UmbraErrors.Crypto.Core instance
  public static func mapToCanonicalError(_ error: CryptoError) -> UmbraErrors.Crypto.Core {
    switch error {
      case let .encryptionError(reason):
        return .encryptionFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .decryptionError(reason):
        return .decryptionFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .hashingError(reason):
        return .hashingFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .keyGenerationError(reason):
        return .keyGenerationFailed(
          keyType: "unknown",
          reason: reason
        )
        
      case let .keyDerivationError(reason):
        return .keyDerivationFailed(
          algorithm: "unknown",
          reason: reason
        )
        
      case let .invalidKeySize(size):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "keySize",
          reason: "Invalid key size: \(size)"
        )
        
      case let .invalidLength(length):
        return .invalidParameters(
          algorithm: "unknown",
          parameter: "length",
          reason: "Invalid data length: \(length)"
        )
        
      case let .unsupportedAlgorithm(algorithm):
        return .unsupportedAlgorithm(
          algorithm: algorithm
        )
        
      case let .asymmetricEncryptionError(reason):
        return .encryptionFailed(
          algorithm: "asymmetric",
          reason: reason
        )
        
      case let .asymmetricDecryptionError(reason):
        return .decryptionFailed(
          algorithm: "asymmetric",
          reason: reason
        )
        
      case let .randomDataGenerationError(reason):
        return .randomGenerationFailed(
          reason: reason
        )
    }
  }
  
  /// Maps from canonical UmbraErrors.Crypto.Core to SecurityImplementation's CryptoError
  ///
  /// Note: This mapping is lossy as the canonical error type has more specific cases than the implementation-specific type.
  /// It should be used only where compatibility with the implementation-specific type is required.
  ///
  /// - Parameter error: Canonical UmbraErrors.Crypto.Core error to map
  /// - Returns: Best-fit equivalent CryptoError instance for the SecurityImplementation module
  public static func mapToImplementationError(_ error: UmbraErrors.Crypto.Core) -> CryptoError {
    switch error {
      case let .encryptionFailed(algorithm, reason):
        if algorithm.contains("asymmetric") {
          return .asymmetricEncryptionError("\(algorithm): \(reason)")
        } else {
          return .encryptionError("\(algorithm): \(reason)")
        }
        
      case let .decryptionFailed(algorithm, reason):
        if algorithm.contains("asymmetric") {
          return .asymmetricDecryptionError("\(algorithm): \(reason)")
        } else {
          return .decryptionError("\(algorithm): \(reason)")
        }
        
      case let .invalidCiphertext(reason):
        return .decryptionError("Invalid ciphertext: \(reason)")
        
      case let .paddingValidationFailed(algorithm):
        return .decryptionError("Padding validation failed with \(algorithm)")
        
      case let .keyGenerationFailed(keyType, reason):
        return .keyGenerationError("\(keyType): \(reason)")
        
      case let .keyDerivationFailed(algorithm, reason):
        return .keyDerivationError("\(algorithm): \(reason)")
        
      case let .invalidKey(keyType, reason):
        return .keyGenerationError("Invalid key of type \(keyType): \(reason)")
        
      case .keyNotFound:
        return .keyGenerationError("Key not found")
        
      case let .signatureFailed(algorithm, reason),
           let .signatureVerificationFailed(algorithm, reason):
        return .asymmetricEncryptionError("Signature operation failed: \(reason)")
        
      case let .invalidSignature(reason):
        return .asymmetricEncryptionError("Signature operation failed: \(reason)")
        
      case let .hashingFailed(algorithm, reason):
        return .hashingError("\(algorithm): \(reason)")
        
      case let .hashVerificationFailed(algorithm):
        return .hashingError("Hash verification failed for \(algorithm)")
        
      case let .unsupportedAlgorithm(algorithm):
        return .unsupportedAlgorithm(algorithm)
        
      case let .invalidParameters(algorithm, parameter, reason):
        if parameter.contains("keySize") || parameter.contains("key") {
          return .invalidKeySize(0) // Cannot determine exact size from the reason
        } else {
          return .invalidLength(0) // Cannot determine exact length from the reason
        }
        
      case let .incompatibleParameters(algorithm, parameter, reason):
        return .encryptionError("Incompatible parameter \(parameter) for \(algorithm): \(reason)")
        
      case let .randomGenerationFailed(reason):
        return .randomDataGenerationError(reason)
        
      case .insufficientEntropy:
        return .randomDataGenerationError("Insufficient entropy")
        
      case let .internalError(message):
        return .encryptionError("Internal error: \(message)")
        
      @unknown default:
        return .encryptionError("Unmapped crypto error: \(error)")
    }
  }
}

extension CryptoError {
  /// Converts this implementation-specific CryptoError to the canonical UmbraErrors.Crypto.Core type
  ///
  /// - Returns: Equivalent UmbraErrors.Crypto.Core instance
  public func toCanonical() -> UmbraErrors.Crypto.Core {
    CryptoErrorMapper.mapToCanonicalError(self)
  }
}

extension UmbraErrors.Crypto.Core {
  /// Converts this canonical error to the implementation-specific CryptoError type
  ///
  /// Note: This is lossy conversion and should only be used where necessary.
  ///
  /// - Returns: Best-fit equivalent CryptoError instance for the SecurityImplementation module
  public func toImplementation() -> CryptoError {
    CryptoErrorMapper.mapToImplementationError(self)
  }
}

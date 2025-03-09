import ErrorHandlingInterfaces
import Foundation

/// Core cryptography error domain for UmbraCore
///
/// This file defines standardised error types for cryptographic operations in the UmbraCore framework.
/// These errors represent failures related to encryption/decryption, key management, signing/verification,
/// and other cryptographic operations.
///
/// ## Usage Examples
///
/// ### Throwing cryptography errors:
/// ```swift
/// func encryptData(_ data: Data, using key: CryptoKey) throws -> Data {
///   guard key.isValid else {
///     throw UmbraErrors.Crypto.Core.invalidKey(reason: "Key has expired")
///   }
///   
///   guard isAlgorithmSupported(key.algorithm) else {
///     throw UmbraErrors.Crypto.Core.unsupportedAlgorithm(algorithm: key.algorithm)
///   }
///   
///   // Encryption implementation...
/// }
/// ```
///
/// ### Handling cryptography errors:
/// ```swift
/// do {
///   let encryptedData = try cryptoService.encrypt(data, using: key)
/// } catch let error as UmbraErrors.Crypto.Core {
///   switch error {
///   case let .invalidKey(reason):
///     // Handle invalid key error
///   case let .unsupportedAlgorithm(algorithm):
///     // Handle unsupported algorithm
///   case let .encryptionFailed(algorithm, reason):
///     // Handle encryption failure
///   default:
///     // Handle other crypto errors
///   }
/// }
/// ```
///
/// Use the `UmbraErrorMapper` to convert between domain-specific errors and public API errors:
/// ```swift
/// let publicError = UmbraErrorMapper.shared.mapCryptoError(cryptoError)
/// ```
extension UmbraErrors.Crypto {
  /// Core cryptography errors related to cryptographic operations
  public enum Core: Error, UmbraError, StandardErrorCapabilities {
    // Encryption/Decryption errors
    /// Failed to encrypt data
    case encryptionFailed(algorithm: String, reason: String)
    
    /// Failed to decrypt data
    case decryptionFailed(algorithm: String, reason: String)
    
    /// Invalid or corrupted ciphertext
    case invalidCiphertext(reason: String)
    
    /// Padding validation failed during decryption
    case paddingValidationFailed(algorithm: String)
    
    // Key management errors
    /// Failed to generate cryptographic key
    case keyGenerationFailed(keyType: String, reason: String)
    
    /// Failed to derive key from password or other material
    case keyDerivationFailed(algorithm: String, reason: String)
    
    /// Key has invalid format or size
    case invalidKey(keyType: String, reason: String)
    
    /// Key not found
    case keyNotFound(keyIdentifier: String)
    
    // Signing/Verification errors
    /// Failed to sign data
    case signatureFailed(algorithm: String, reason: String)
    
    /// Signature verification failed
    case signatureVerificationFailed(algorithm: String, reason: String)
    
    /// Invalid signature format
    case invalidSignature(reason: String)
    
    // Hash/Digest errors
    /// Failed to compute hash
    case hashingFailed(algorithm: String, reason: String)
    
    /// Hash verification failed
    case hashVerificationFailed(algorithm: String)
    
    // Algorithm errors
    /// Cryptographic algorithm not supported
    case unsupportedAlgorithm(algorithm: String)
    
    /// Invalid algorithm parameters
    case invalidParameters(algorithm: String, parameter: String, reason: String)
    
    /// Incompatible algorithm parameters
    case incompatibleParameters(algorithm: String, parameter: String, reason: String)
    
    // Random number generation errors
    /// Failed to generate secure random data
    case randomGenerationFailed(reason: String)
    
    /// Insufficient entropy for secure operation
    case insufficientEntropy
    
    // Internal errors
    /// Internal cryptographic error
    case internalError(String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for crypto core errors
    public var domain: String {
      "Crypto.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .encryptionFailed:
        return "encryption_failed"
      case .decryptionFailed:
        return "decryption_failed"
      case .invalidCiphertext:
        return "invalid_ciphertext"
      case .paddingValidationFailed:
        return "padding_validation_failed"
      case .keyGenerationFailed:
        return "key_generation_failed"
      case .keyDerivationFailed:
        return "key_derivation_failed"
      case .invalidKey:
        return "invalid_key"
      case .keyNotFound:
        return "key_not_found"
      case .signatureFailed:
        return "signature_failed"
      case .signatureVerificationFailed:
        return "signature_verification_failed"
      case .invalidSignature:
        return "invalid_signature"
      case .hashingFailed:
        return "hashing_failed"
      case .hashVerificationFailed:
        return "hash_verification_failed"
      case .unsupportedAlgorithm:
        return "unsupported_algorithm"
      case .invalidParameters:
        return "invalid_parameters"
      case .incompatibleParameters:
        return "incompatible_parameters"
      case .randomGenerationFailed:
        return "random_generation_failed"
      case .insufficientEntropy:
        return "insufficient_entropy"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .encryptionFailed(algorithm, reason):
        return "Failed to encrypt data with algorithm '\(algorithm)': \(reason)"
      case let .decryptionFailed(algorithm, reason):
        return "Failed to decrypt data with algorithm '\(algorithm)': \(reason)"
      case let .invalidCiphertext(reason):
        return "Invalid or corrupted ciphertext: \(reason)"
      case let .paddingValidationFailed(algorithm):
        return "Padding validation failed during decryption with algorithm '\(algorithm)'"
      case let .keyGenerationFailed(keyType, reason):
        return "Failed to generate cryptographic key of type '\(keyType)': \(reason)"
      case let .keyDerivationFailed(algorithm, reason):
        return "Failed to derive key using algorithm '\(algorithm)': \(reason)"
      case let .invalidKey(keyType, reason):
        return "Invalid cryptographic key of type '\(keyType)': \(reason)"
      case let .keyNotFound(keyIdentifier):
        return "Cryptographic key not found: \(keyIdentifier)"
      case let .signatureFailed(algorithm, reason):
        return "Failed to sign data with algorithm '\(algorithm)': \(reason)"
      case let .signatureVerificationFailed(algorithm, reason):
        return "Signature verification failed with algorithm '\(algorithm)': \(reason)"
      case let .invalidSignature(reason):
        return "Invalid signature format: \(reason)"
      case let .hashingFailed(algorithm, reason):
        return "Failed to compute hash with algorithm '\(algorithm)': \(reason)"
      case let .hashVerificationFailed(algorithm):
        return "Hash verification failed with algorithm '\(algorithm)'"
      case let .unsupportedAlgorithm(algorithm):
        return "Cryptographic algorithm not supported: '\(algorithm)'"
      case let .invalidParameters(algorithm, parameter, reason):
        return "Invalid parameter '\(parameter)' for algorithm '\(algorithm)': \(reason)"
      case let .incompatibleParameters(algorithm, parameter, reason):
        return "Incompatible parameter '\(parameter)' for algorithm '\(algorithm)': \(reason)"
      case let .randomGenerationFailed(reason):
        return "Failed to generate secure random data: \(reason)"
      case .insufficientEntropy:
        return "Insufficient entropy for secure cryptographic operation"
      case let .internalError(message):
        return "Internal cryptographic error: \(message)"
      }
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "crypto_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .encryptionFailed(algorithm, reason):
        return .encryptionFailed(algorithm: algorithm, reason: reason)
      case let .decryptionFailed(algorithm, reason):
        return .decryptionFailed(algorithm: algorithm, reason: reason)
      case let .invalidCiphertext(reason):
        return .invalidCiphertext(reason: reason)
      case let .paddingValidationFailed(algorithm):
        return .paddingValidationFailed(algorithm: algorithm)
      case let .keyGenerationFailed(keyType, reason):
        return .keyGenerationFailed(keyType: keyType, reason: reason)
      case let .keyDerivationFailed(algorithm, reason):
        return .keyDerivationFailed(algorithm: algorithm, reason: reason)
      case let .invalidKey(keyType, reason):
        return .invalidKey(keyType: keyType, reason: reason)
      case let .keyNotFound(keyIdentifier):
        return .keyNotFound(keyIdentifier: keyIdentifier)
      case let .signatureFailed(algorithm, reason):
        return .signatureFailed(algorithm: algorithm, reason: reason)
      case let .signatureVerificationFailed(algorithm, reason):
        return .signatureVerificationFailed(algorithm: algorithm, reason: reason)
      case let .invalidSignature(reason):
        return .invalidSignature(reason: reason)
      case let .hashingFailed(algorithm, reason):
        return .hashingFailed(algorithm: algorithm, reason: reason)
      case let .hashVerificationFailed(algorithm):
        return .hashVerificationFailed(algorithm: algorithm)
      case let .unsupportedAlgorithm(algorithm):
        return .unsupportedAlgorithm(algorithm: algorithm)
      case let .invalidParameters(algorithm, parameter, reason):
        return .invalidParameters(algorithm: algorithm, parameter: parameter, reason: reason)
      case let .incompatibleParameters(algorithm, parameter, reason):
        return .incompatibleParameters(algorithm: algorithm, parameter: parameter, reason: reason)
      case let .randomGenerationFailed(reason):
        return .randomGenerationFailed(reason: reason)
      case .insufficientEntropy:
        return .insufficientEntropy
      case let .internalError(message):
        return .internalError(message)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Crypto.Core {
  /// Create an error for a failed encryption operation
  public static func encryptionFailed(
    algorithm: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .encryptionFailed(algorithm: algorithm, reason: reason)
  }
  
  /// Create an error for a failed decryption operation
  public static func decryptionFailed(
    algorithm: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .decryptionFailed(algorithm: algorithm, reason: reason)
  }
  
  /// Create an error for failed key generation
  public static func keyGenerationFailed(
    keyType: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .keyGenerationFailed(keyType: keyType, reason: reason)
  }
  
  /// Create an error for an invalid key
  public static func invalidKey(
    keyType: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .invalidKey(keyType: keyType, reason: reason)
  }
  
  /// Create an error for a key that was not found
  public static func keyNotFound(
    keyIdentifier: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .keyNotFound(keyIdentifier: keyIdentifier)
  }
  
  /// Create an error for an unsupported algorithm
  public static func unsupportedAlgorithm(
    algorithm: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .unsupportedAlgorithm(algorithm: algorithm)
  }
}

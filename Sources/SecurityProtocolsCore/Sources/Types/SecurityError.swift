/// Foundation-free error type for security operations.
/// Designed to be used throughout the security interface without
/// relying on Foundation-specific error types.
public enum SecurityError: Error, Sendable, Equatable {
  /// General encryption failure
  case encryptionFailed(reason: String)

  /// General decryption failure
  case decryptionFailed(reason: String)

  /// Key generation failed
  case keyGenerationFailed(reason: String)

  /// Provided key is invalid or in an incorrect format
  case invalidKey

  /// Hash verification failed
  case hashVerificationFailed

  /// Secure random number generation failed
  case randomGenerationFailed(reason: String)

  /// Input data is in an invalid format
  case invalidInput(reason: String)

  /// Secure storage operation failed
  case storageOperationFailed(reason: String)

  /// Security operation timed out
  case timeout

  /// General security service error
  case serviceError(code: Int, reason: String)

  /// Internal error within the security system
  case internalError(String)

  /// Operation not implemented
  case notImplemented
}

// MARK: - CustomStringConvertible Extension

extension SecurityError: CustomStringConvertible {
  public var description: String {
    switch self {
      case let .encryptionFailed(reason):
        "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        "Decryption failed: \(reason)"
      case let .keyGenerationFailed(reason):
        "Key generation failed: \(reason)"
      case .invalidKey:
        "Invalid key"
      case .hashVerificationFailed:
        "Hash verification failed"
      case let .randomGenerationFailed(reason):
        "Secure random number generation failed: \(reason)"
      case let .invalidInput(reason):
        "Invalid input: \(reason)"
      case let .storageOperationFailed(reason):
        "Storage operation failed: \(reason)"
      case .timeout:
        "Security operation timed out"
      case let .serviceError(code, reason):
        "Security service error (\(code)): \(reason)"
      case let .internalError(message):
        "Internal security error: \(message)"
      case .notImplemented:
        "Operation not implemented"
    }
  }
}

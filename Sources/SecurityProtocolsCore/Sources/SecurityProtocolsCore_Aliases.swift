import CoreErrors
import Foundation

/// Type alias for backward compatibility
/// Renamed to avoid conflict with native SecurityProtocolsCore.SecurityError
public typealias CoreSecurityError=CoreErrors.SecurityError

/// Create a mapping function to convert between CoreErrors.SecurityError and local SecurityError
/// types
/// This helps when working with external modules that expect the core error type
public func mapCoreSecurityError(_ error: CoreSecurityError) -> SecurityError {
  switch error {
    case .bookmarkError:
      return SecurityError.internalError("Bookmark error")
    case .accessError:
      return SecurityError.invalidInput(reason: "Access error")
    case .cryptoError:
      return SecurityError.internalError("Generic crypto error")
    case .bookmarkCreationFailed:
      return SecurityError.storageOperationFailed(reason: "Bookmark creation failed")
    case .bookmarkResolutionFailed:
      return SecurityError.storageOperationFailed(reason: "Bookmark resolution failed")
    case .encryptionFailed:
      return SecurityError.encryptionFailed(reason: "Encryption operation failed")
    case .decryptionFailed:
      return SecurityError.decryptionFailed(reason: "Decryption operation failed")
    case .keyGenerationFailed:
      return SecurityError.keyGenerationFailed(reason: "Key generation failed")
    case .invalidData:
      return SecurityError.invalidInput(reason: "Invalid data format")
    case .hashingFailed:
      return SecurityError.hashVerificationFailed
    case .serviceFailed:
      return SecurityError.serviceError(code: 1001, reason: "Service operation failed")
    case .notImplemented:
      return SecurityError.notImplemented
    case let .general(message):
      return SecurityError.internalError(message)
    @unknown default:
      return SecurityError.internalError("Unknown security error")
  }
}

/// Map from local SecurityError to CoreErrors.SecurityError
/// This is needed when other modules expect the core error type
public func mapToCoreSecurity(_ error: SecurityError) -> CoreSecurityError {
  switch error {
    case .encryptionFailed:
      return .encryptionFailed
    case .decryptionFailed:
      return .decryptionFailed
    case .keyGenerationFailed:
      return .keyGenerationFailed
    case .invalidKey:
      return .invalidData
    case .hashVerificationFailed:
      return .hashingFailed
    case .randomGenerationFailed:
      return .cryptoError
    case .invalidInput:
      return .invalidData
    case .storageOperationFailed:
      return .serviceFailed
    case .timeout:
      return .serviceFailed
    case .serviceError:
      return .serviceFailed
    case .internalError:
      return .cryptoError
    case .notImplemented:
      return .notImplemented
    @unknown default:
      return .general("Unknown security error")
  }
}

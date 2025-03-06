import Foundation
import SecurityProtocolsCore

/// Error types that can be thrown by the SecurityBridge module
extension SecurityBridge {
  /// Error types specific to the bridge layer
  public enum SecurityBridgeError: Error, Sendable {
    /// Bookmark resolution failed
    case bookmarkResolutionFailed
    /// Implementation is missing
    case implementationMissing(String)
  }
}

/// Mapper to convert between SecurityError and SecurityBridgeError
public enum SecurityBridgeErrorMapper {
  /// Map a SecurityError to a bridge error
  /// - Parameter error: The security error to map
  /// - Returns: A bridge error
  public static func mapToBridgeError(_ error: Error) -> Error {
    guard let securityError = error as? SecurityError else {
      return SecurityBridge.SecurityBridgeError
        .implementationMissing("Unknown error: \(error.localizedDescription)")
    }

    switch securityError {
      case let .internalError(message):
        return SecurityBridge.SecurityBridgeError.implementationMissing(message)
      case let .encryptionFailed(reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Encryption failed: \(reason)")
      case let .decryptionFailed(reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Decryption failed: \(reason)")
      case let .serviceError(code, reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Service error \(code): \(reason)")
      case let .keyGenerationFailed(reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Key generation failed: \(reason)")
      case .invalidKey:
        return SecurityBridge.SecurityBridgeError.implementationMissing("Invalid key")
      case .hashVerificationFailed:
        return SecurityBridge.SecurityBridgeError.implementationMissing("Hash verification failed")
      case let .randomGenerationFailed(reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Random generation failed: \(reason)")
      case let .invalidInput(reason):
        return SecurityBridge.SecurityBridgeError.implementationMissing("Invalid input: \(reason)")
      case let .storageOperationFailed(reason):
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Storage operation failed: \(reason)")
      case .timeout:
        return SecurityBridge.SecurityBridgeError.implementationMissing("Timeout")
      case .notImplemented:
        return SecurityBridge.SecurityBridgeError.implementationMissing("Not implemented")
      @unknown default:
        return SecurityBridge.SecurityBridgeError
          .implementationMissing("Unknown security error: \(securityError)")
    }
  }

  /// Map a bridge error to a SecurityError
  /// - Parameter error: The bridge error to map
  /// - Returns: A SecurityError
  public static func mapToSecurityError(_ error: Error) -> Error {
    guard let bridgeError = error as? SecurityBridge.SecurityBridgeError else {
      return SecurityError.internalError("Unknown bridge error: \(error.localizedDescription)")
    }

    switch bridgeError {
      case .bookmarkResolutionFailed:
        return SecurityError.storageOperationFailed(reason: "Bookmark resolution failed")
      case let .implementationMissing(message):
        return SecurityError.internalError(message)
    }
  }
}

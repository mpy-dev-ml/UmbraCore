import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore

/// Error type specific to the security bridge layer
public enum SecurityBridgeError: Error {
  case invalidInputType
  case mappingFailed
  case unsupportedErrorType
  case invalidConfiguration
}

/// Maps between different security error types to provide
/// a consistent error handling interface across security modules
public enum SecurityBridgeErrorMapper {

  /// Maps any error to a SecurityError
  /// - Parameter error: The error to map
  /// - Returns: A SecurityError representation of the error
  public static func mapToSecurityError(_ error: Error) -> SecurityError {
    // Handle different error types
    if let secError = error as? SecurityError {
      // Already a SecurityError
      return secError
    } else if let xpcError = error as? XPCProtocolsCore.SecurityError {
      // Map from SecurityError
      switch xpcError {
        case .notImplemented:
          return SecurityError.invalidInput(reason: "Operation not implemented")
        case .invalidData:
          return SecurityError.invalidInput(reason: "Invalid data format")
        case .encryptionFailed:
          return SecurityError.encryptionFailed(reason: "XPC encryption operation failed")
        case .decryptionFailed:
          return SecurityError.decryptionFailed(reason: "XPC decryption operation failed")
        case .keyGenerationFailed:
          return SecurityError.keyGenerationFailed(reason: "XPC key generation failed")
        case .hashingFailed:
          return SecurityError.hashVerificationFailed
        case .serviceFailed:
          return SecurityError.invalidInput(reason: "XPC service failure")
        case let .general(message):
          return SecurityError.internalError("XPC general error: \(message)")
        case .cryptoError:
          return SecurityError.internalError("Crypto operation failed")
      }
    } else if let bridgeError = error as? SecurityBridgeError {
      // Map from bridge-specific errors
      switch bridgeError {
        case .invalidInputType:
          return SecurityError.invalidInput(reason: "Invalid input type")
        case .mappingFailed:
          return SecurityError.internalError("Error mapping failed")
        case .unsupportedErrorType:
          return SecurityError.internalError("Unsupported error type")
        case .invalidConfiguration:
          return SecurityError.internalError("Invalid security configuration")
      }
    } else {
      // Default case for unknown error types
      let errorString = String(describing: error)
      return SecurityError.internalError("Unknown error: \(errorString)")
    }
  }

  /// Maps any error to a SecurityError
  /// - Parameter error: The error to map
  /// - Returns: A SecurityError representation of the error
  public static func mapToXPCError(_ error: Error) -> XPCServiceProtocolComplete.SecurityError {
    // Handle different error types
    if let xpcError = error as? XPCServiceProtocolComplete.SecurityError {
      // Already a SecurityError
      return xpcError
    } else if let secError = error as? SecurityError {
      // Map from SecurityError
      switch secError {
        case .encryptionFailed:
          return XPCServiceProtocolComplete.SecurityError.encryptionFailed
        case .decryptionFailed:
          return XPCServiceProtocolComplete.SecurityError.decryptionFailed
        case .keyGenerationFailed:
          return XPCServiceProtocolComplete.SecurityError.keyGenerationFailed
        case .invalidKey:
          return XPCServiceProtocolComplete.SecurityError.invalidData
        case .hashVerificationFailed:
          return XPCServiceProtocolComplete.SecurityError.hashingFailed
        case .randomGenerationFailed:
          return XPCServiceProtocolComplete.SecurityError.serviceFailed
        case .invalidInput:
          return XPCServiceProtocolComplete.SecurityError.invalidData
        case .storageOperationFailed:
          return XPCServiceProtocolComplete.SecurityError.serviceFailed
        case .timeout:
          return XPCServiceProtocolComplete.SecurityError.serviceFailed
        case .serviceError:
          return XPCServiceProtocolComplete.SecurityError.serviceFailed
        case let .internalError(message):
          return XPCServiceProtocolComplete.SecurityError.general(message)
        case .notImplemented:
          return XPCServiceProtocolComplete.SecurityError.notImplemented
      }
    } else if let bridgeError = error as? SecurityBridgeError {
      // Map from bridge-specific errors
      switch bridgeError {
        case .invalidInputType:
          return XPCServiceProtocolComplete.SecurityError.invalidData
        case .mappingFailed, .unsupportedErrorType, .invalidConfiguration:
          return XPCServiceProtocolComplete.SecurityError.serviceFailed
      }
    } else {
      // Default case for unknown error types
      let errorString = String(describing: error)
      return XPCServiceProtocolComplete.SecurityError.general("Unknown error: \(errorString)")
    }
  }
}

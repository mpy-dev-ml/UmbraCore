import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore

/// Type aliases to disambiguate between similarly named types from different modules
typealias SPCSecurityError=SecurityProtocolsCore.SecurityError
typealias XPCSecurityError=XPCProtocolsCore.SecurityError

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
  public static func mapToSecurityError(_ error: Error) -> SPCSecurityError {
    // Handle different error types
    if let secError=error as? SPCSecurityError {
      // Already a SecurityError
      return secError
    } else if let xpcError=error as? XPCSecurityError {
      // Map from SecurityError
      switch xpcError {
        case .notImplemented:
          return .invalidInput(reason: "Operation not implemented")
        case .invalidData:
          return .invalidInput(reason: "Invalid data format")
        case .encryptionFailed:
          return .encryptionFailed(reason: "XPC encryption operation failed")
        case .decryptionFailed:
          return .decryptionFailed(reason: "XPC decryption operation failed")
        case .keyGenerationFailed:
          return .keyGenerationFailed(reason: "XPC key generation failed")
        case .hashingFailed:
          return .hashVerificationFailed
        case .serviceFailed:
          return .invalidInput(reason: "XPC service failure")
        case let .general(message):
          return .internalError("XPC general error: \(message)")
      }
    } else if let bridgeError=error as? SecurityBridgeError {
      // Map from bridge-specific errors
      switch bridgeError {
        case .invalidInputType:
          return .invalidInput(reason: "Invalid input type")
        case .mappingFailed:
          return .internalError("Error mapping failed")
        case .unsupportedErrorType:
          return .internalError("Unsupported error type")
        case .invalidConfiguration:
          return .internalError("Invalid security configuration")
      }
    } else {
      // Default case for unknown error types
      let errorString=String(describing: error)
      return .internalError("Unknown error: \(errorString)")
    }
  }

  /// Maps any error to a SecurityError
  /// - Parameter error: The error to map
  /// - Returns: A SecurityError representation of the error
  public static func mapToXPCError(_ error: Error) -> XPCSecurityError {
    // Handle different error types
    if let xpcError=error as? XPCSecurityError {
      // Already a SecurityError
      return xpcError
    } else if let secError=error as? SPCSecurityError {
      // Map from SecurityError
      switch secError {
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
          return .serviceFailed
        case .invalidInput:
          return .invalidData
        case .storageOperationFailed:
          return .serviceFailed
        case .timeout:
          return .serviceFailed
        case .serviceError:
          return .serviceFailed
        case let .internalError(message):
          return .general(message)
        case .notImplemented:
          return .notImplemented
      }
    } else if let bridgeError=error as? SecurityBridgeError {
      // Map from bridge-specific errors
      switch bridgeError {
        case .invalidInputType:
          return .invalidData
        case .mappingFailed, .unsupportedErrorType, .invalidConfiguration:
          return .serviceFailed
      }
    } else {
      // Default case for unknown error types
      let errorString=String(describing: error)
      return .general("Unknown error: \(errorString)")
    }
  }
}

import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore
import CoreErrors

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
  /// - Returns: A SecurityProtocolsCore.SecurityError representation of the error
  public static func mapToSecurityError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
    // Handle different error types
    if let secError = error as? SecurityProtocolsCore.SecurityError {
      // Already a SecurityError
      return secError
    } else if let ceError = error as? CoreErrors.SecurityError {
      // Map from CoreErrors.SecurityError
      switch ceError {
        case .notImplemented:
          return SecurityProtocolsCore.SecurityError.invalidInput(reason: "Operation not implemented")
        case .invalidData:
          return SecurityProtocolsCore.SecurityError.invalidInput(reason: "Invalid data format")
        case .encryptionFailed:
          return SecurityProtocolsCore.SecurityError.encryptionFailed(reason: "Encryption operation failed")
        case .decryptionFailed:
          return SecurityProtocolsCore.SecurityError.decryptionFailed(reason: "Decryption operation failed")
        case .keyGenerationFailed:
          return SecurityProtocolsCore.SecurityError.keyGenerationFailed(reason: "Key generation failed")
        case .hashingFailed:
          return SecurityProtocolsCore.SecurityError.hashVerificationFailed
        case .serviceFailed:
          return SecurityProtocolsCore.SecurityError.invalidInput(reason: "Service failure")
        case let .general(message):
          return SecurityProtocolsCore.SecurityError.internalError("Error: \(message)")
        case .cryptoError:
          return SecurityProtocolsCore.SecurityError.internalError("Crypto operation failed")
        case .bookmarkError:
          return SecurityProtocolsCore.SecurityError.storageOperationFailed(reason: "Bookmark operation failed")
        case .accessError:
          return SecurityProtocolsCore.SecurityError.storageOperationFailed(reason: "Access error")
      }
    } else if let xpcError = error as? CoreErrors.XPCErrors.SecurityError {
      // Map from CoreErrors.XPCErrors.SecurityError
      switch xpcError {
        case .xpcConnectionFailed:
          return SecurityProtocolsCore.SecurityError.internalError("XPC connection failed")
        case .serviceNotAvailable:
          return SecurityProtocolsCore.SecurityError.internalError("XPC service not available")
        case .communicationError:
          return SecurityProtocolsCore.SecurityError.internalError("XPC communication error")
        case .protocolError:
          return SecurityProtocolsCore.SecurityError.internalError("XPC protocol error")
        case .versionMismatch:
          return SecurityProtocolsCore.SecurityError.internalError("XPC version mismatch")
        case let .general(message):
          return SecurityProtocolsCore.SecurityError.internalError("XPC error: \(message)")
      }
    } else if let protocolError = error as? XPCProtocolsCore.SecurityProtocolError {
      // Map from SecurityProtocolError
      switch protocolError {
        case let .implementationMissing(reason):
          return SecurityProtocolsCore.SecurityError.internalError("Implementation missing: \(reason)")
      }
    } else if let bridgeError = error as? SecurityBridgeError {
      // Map from SecurityBridgeError
      switch bridgeError {
        case .invalidInputType:
          return SecurityProtocolsCore.SecurityError.invalidInput(reason: "Invalid input type")
        case .mappingFailed:
          return SecurityProtocolsCore.SecurityError.internalError("Error mapping failed")
        case .unsupportedErrorType:
          return SecurityProtocolsCore.SecurityError.internalError("Unsupported error type")
        case .invalidConfiguration:
          return SecurityProtocolsCore.SecurityError.internalError("Invalid configuration")
      }
    }
    
    // Default case - map to a generic internal error
    return SecurityProtocolsCore.SecurityError.internalError("Unknown error: \(error.localizedDescription)")
  }

  /// Maps a security error to an XPC error type for transmission over XPC
  /// - Parameter error: The error to map
  /// - Returns: An CoreErrors.XPCErrors.SecurityError representation of the error
  public static func mapToXPCError(_ error: Error) -> CoreErrors.XPCErrors.SecurityError {
    // Handle different error types
    if let xpcError = error as? CoreErrors.XPCErrors.SecurityError {
      // Already an XPC SecurityError
      return xpcError
    } else if let ceError = error as? CoreErrors.SecurityError {
      // Map from CoreErrors.SecurityError
      switch ceError {
        case .notImplemented:
          return CoreErrors.XPCErrors.SecurityError.general("Operation not implemented")
        case .invalidData:
          return CoreErrors.XPCErrors.SecurityError.general("Invalid data format")
        case .encryptionFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Encryption operation failed")
        case .decryptionFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Decryption operation failed")
        case .keyGenerationFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Key generation failed")
        case .hashingFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Hashing failed")
        case .serviceFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Service failure")
        case let .general(message):
          return CoreErrors.XPCErrors.SecurityError.general("Error: \(message)")
        case .cryptoError:
          return CoreErrors.XPCErrors.SecurityError.general("Crypto operation failed")
        case .bookmarkError:
          return CoreErrors.XPCErrors.SecurityError.general("Bookmark operation failed")
        case .accessError:
          return CoreErrors.XPCErrors.SecurityError.general("Access error")
      }
    } else if let secError = error as? SecurityProtocolsCore.SecurityError {
      // Map from SecurityProtocolsCore.SecurityError
      switch secError {
        case let .encryptionFailed(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Decryption failed: \(reason)")
        case let .keyGenerationFailed(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Key generation failed: \(reason)")
        case .invalidKey:
          return CoreErrors.XPCErrors.SecurityError.general("Invalid key")
        case .hashVerificationFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Hash verification failed")
        case let .randomGenerationFailed(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Random generation failed: \(reason)")
        case let .invalidInput(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Invalid input: \(reason)")
        case let .storageOperationFailed(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Storage operation failed: \(reason)")
        case .timeout:
          return CoreErrors.XPCErrors.SecurityError.general("Operation timed out")
        case let .internalError(message):
          return CoreErrors.XPCErrors.SecurityError.general("Internal error: \(message)")
        case let .protocolError(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Protocol error")
      }
    } else if let protocolError = error as? XPCProtocolsCore.SecurityProtocolError {
      // Map from SecurityProtocolError
      switch protocolError {
        case let .implementationMissing(reason):
          return CoreErrors.XPCErrors.SecurityError.general("Implementation missing: \(reason)")
      }
    } else if let bridgeError = error as? SecurityBridgeError {
      // Map from SecurityBridgeError
      switch bridgeError {
        case .invalidInputType:
          return CoreErrors.XPCErrors.SecurityError.general("Invalid input type")
        case .mappingFailed:
          return CoreErrors.XPCErrors.SecurityError.general("Error mapping failed")
        case .unsupportedErrorType:
          return CoreErrors.XPCErrors.SecurityError.general("Unsupported error type")
        case .invalidConfiguration:
          return CoreErrors.XPCErrors.SecurityError.general("Invalid configuration")
      }
    }
    
    // Default case - map to a generic XPC error
    return CoreErrors.XPCErrors.SecurityError.general("Unknown error: \(error.localizedDescription)")
  }
}

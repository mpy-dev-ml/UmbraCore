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
    } else if let xpcError = error as? XPCProtocolsCore.XPCErrors.SecurityError {
      // Map from XPCProtocolsCore.SecurityError
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
    } else if let protocolError = error as? SecurityInterfacesProtocols.SecurityProtocolError {
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
  /// - Returns: An XPCProtocolsCore.XPCErrors.SecurityError representation of the error
  public static func mapToXPCError(_ error: Error) -> XPCProtocolsCore.XPCErrors.SecurityError {
    // Handle different error types
    if let xpcError = error as? XPCProtocolsCore.XPCErrors.SecurityError {
      // Already an XPC SecurityError
      return xpcError
    } else if let ceError = error as? CoreErrors.SecurityError {
      // Map from CoreErrors.SecurityError
      switch ceError {
        case .notImplemented:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Operation not implemented")
        case .invalidData:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Invalid data format")
        case .encryptionFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Encryption operation failed")
        case .decryptionFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Decryption operation failed")
        case .keyGenerationFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Key generation failed")
        case .hashingFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Hashing failed")
        case .serviceFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.communicationError
        case let .general(message):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Error: \(message)")
        case .cryptoError:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Crypto operation failed")
        case .bookmarkError:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Bookmark operation failed")
        case .accessError:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Access error")
      }
    } else if let secError = error as? SecurityProtocolsCore.SecurityError {
      // Map from SecurityProtocolsCore.SecurityError
      switch secError {
        case let .encryptionFailed(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Decryption failed: \(reason)")
        case let .keyGenerationFailed(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Key generation failed: \(reason)")
        case .invalidKey:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Invalid key")
        case .hashVerificationFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Hash verification failed")
        case let .randomGenerationFailed(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Random generation failed: \(reason)")
        case let .invalidInput(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Invalid input: \(reason)")
        case let .storageOperationFailed(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Storage operation failed: \(reason)")
        case .timeout:
          return XPCProtocolsCore.XPCErrors.SecurityError.communicationError
        case let .internalError(message):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Internal error: \(message)")
        case let .protocolError(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.protocolError
      }
    } else if let protocolError = error as? SecurityInterfacesProtocols.SecurityProtocolError {
      // Map from SecurityProtocolError
      switch protocolError {
        case let .implementationMissing(reason):
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Implementation missing: \(reason)")
      }
    } else if let bridgeError = error as? SecurityBridgeError {
      // Map from SecurityBridgeError
      switch bridgeError {
        case .invalidInputType:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Invalid input type")
        case .mappingFailed:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Error mapping failed")
        case .unsupportedErrorType:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Unsupported error type")
        case .invalidConfiguration:
          return XPCProtocolsCore.XPCErrors.SecurityError.general("Invalid configuration")
      }
    }
    
    // Default case - map to a generic XPC error
    return XPCProtocolsCore.XPCErrors.SecurityError.general("Unknown error: \(error.localizedDescription)")
  }
}

import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

/// A type alias for our new, consolidated SecurityError type
public typealias UmbraSecurityError=ErrorHandlingDomains.SecurityError

/// Maps between different SecurityError implementations
public struct SecurityErrorMapper {
  /// Initialises a new mapper
  public init() {}

  /// Maps from SecurityProtocolsCore.SecurityError to our consolidated UmbraSecurityError
  /// Note: We avoid using fully qualified names to prevent type resolution issues
  /// described in the module structure
  /// - Parameter error: The source SecurityError
  /// - Returns: The mapped UmbraSecurityError
  public func mapFromSecurityProtocolsCore(_ error: Error) -> UmbraSecurityError {
    // Extract the type information using reflection to avoid direct type names
    // which would cause compilation issues
    let errorDescription=String(describing: error)

    // Map common cases by examining the error description
    if errorDescription.contains("authentication") {
      return .authenticationFailed("Authentication failed (mapped)")
    } else if errorDescription.contains("authorization") {
      return .unauthorizedAccess("Authorization failed (mapped)")
    } else if errorDescription.contains("credential") {
      return .invalidCredentials("Invalid credentials (mapped)")
    } else if errorDescription.contains("session") {
      return .sessionExpired("Session expired (mapped)")
    } else if errorDescription.contains("token") {
      return .tokenExpired("Token expired (mapped)")
    } else if errorDescription.contains("encryption") {
      return .encryptionFailed("Encryption failed (mapped)")
    } else if errorDescription.contains("decryption") {
      return .decryptionFailed("Decryption failed (mapped)")
    } else if errorDescription.contains("signature") {
      return .signatureInvalid("Signature invalid (mapped)")
    } else if errorDescription.contains("permission") {
      return .permissionDenied("Permission denied (mapped)")
    } else if errorDescription.contains("certificate") {
      return .certificateInvalid("Certificate invalid (mapped)")
    } else {
      return .unknown("Mapped from SecurityProtocolsCore: \(errorDescription)")
    }
  }

  /// Maps from SecurityTypes.SecurityError to our consolidated UmbraSecurityError
  /// - Parameter error: The source SecurityError
  /// - Returns: The mapped UmbraSecurityError
  public func mapFromSecurityTypes(_ error: Error) -> UmbraSecurityError {
    let errorDescription=String(describing: error)

    // Map based on error description
    if errorDescription.contains("authentication") {
      return .authenticationFailed("Authentication failed (mapped from SecurityTypes)")
    } else if errorDescription.contains("authorization") {
      return .unauthorizedAccess("Authorization failed (mapped from SecurityTypes)")
    } else if errorDescription.contains("crypto") {
      return .encryptionFailed("Cryptographic operation failed (mapped from SecurityTypes)")
    } else {
      return .unknown("Mapped from SecurityTypes: \(errorDescription)")
    }
  }

  /// Maps from XPCProtocolsCore.SecurityProtocolError to our consolidated UmbraSecurityError
  /// - Parameter error: The source SecurityProtocolError
  /// - Returns: The mapped UmbraSecurityError
  public func mapFromXPCProtocolsCore(_ error: Error) -> UmbraSecurityError {
    // Similar approach for XPC errors
    let errorDescription=String(describing: error)

    if errorDescription.contains("permission") {
      return .permissionDenied("Permission denied (mapped from XPC)")
    } else if errorDescription.contains("authentication") {
      return .authenticationFailed("Authentication failed (mapped from XPC)")
    } else {
      return .unknown("Mapped from XPC: \(errorDescription)")
    }
  }

  /// Maps from UmbraErrors.Security.Core to our consolidated UmbraSecurityError
  /// - Parameter error: The source UmbraErrors.Security.Core error
  /// - Returns: The mapped UmbraSecurityError
  public func mapFromTyped(_ error: UmbraErrors.Security.Core) -> UmbraSecurityError {
    switch error {
    case .invalidKey(let reason):
      return .invalidCredentials("Invalid key: \(reason)")
    case .invalidInput(let reason):
      if reason.contains("authentication") {
        return .authenticationFailed("Authentication failed: \(reason)")
      } else if reason.contains("permission") {
        return .permissionDenied("Permission denied: \(reason)")
      } else if reason.contains("session") {
        return .sessionExpired("Session expired: \(reason)")
      } else {
        return .securityConfigurationError("Invalid input: \(reason)")
      }
    case .internalError(let details):
      return .unknown("Internal error: \(details)")
    case .encryptionFailed(let reason):
      return .encryptionFailed("Encryption failed: \(reason)")
    case .decryptionFailed(let reason):
      return .decryptionFailed("Decryption failed: \(reason)")
    case .keyGenerationFailed(let reason):
      return .keyGenerationFailed("Key generation failed: \(reason)")
    case .hashVerificationFailed(let reason):
      return .hashingFailed("Hash verification failed: \(reason)")
    case .randomGenerationFailed(let reason):
      return .securityConfigurationError("Random generation failed: \(reason)")
    case .storageOperationFailed(let reason):
      return .securityConfigurationError("Storage operation failed: \(reason)")
    case .timeout(let operation):
      return .secureChannelFailed("Operation timed out: \(operation)")
    case .serviceError(let code, let reason):
      return .unknown("Service error \(code): \(reason)")
    case .notImplemented(let feature):
      return .securityConfigurationError("Feature not implemented: \(feature)")
    @unknown default:
      return .unknown("Unknown security error: \(error)")
    }
  }

  /// Maps any Error to our consolidated UmbraSecurityError if it represents a security issue
  /// - Parameter error: Any error type
  /// - Returns: The mapped UmbraSecurityError if applicable, nil otherwise
  public func mapFromAny(_ error: Error) -> UmbraSecurityError? {
    // First, check if it's already our type
    if let umbraError=error as? UmbraSecurityError {
      return umbraError
    }

    // Check the module name to determine how to map
    let errorType=String(describing: type(of: error))

    if errorType.contains("SecurityProtocolsCore") {
      return mapFromSecurityProtocolsCore(error)
    } else if errorType.contains("SecurityTypes") {
      return mapFromSecurityTypes(error)
    } else if errorType.contains("XPCProtocolsCore") {
      return mapFromXPCProtocolsCore(error)
    } else if errorType.contains("UmbraErrors.Security.Core") {
      if let typedError = error as? UmbraErrors.Security.Core {
        return mapFromTyped(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Security.Core")
    } else {
      // Only map if it seems like a security error
      let errorDescription=String(describing: error).lowercased()
      if
        errorDescription.contains("security") ||
        errorDescription.contains("authentication") ||
        errorDescription.contains("authorization") ||
        errorDescription.contains("permission") ||
        errorDescription.contains("crypto")
      {
        return .unknown("Mapped from unknown type: \(errorDescription)")
      }
      return nil
    }
  }
}

/// Error registry extension for registering the security error mapper
extension ErrorRegistry {
  /// Register the security error mapper with the error registry
  public func registerSecurityErrorMapper() {
    // This is a placeholder for now - we'll implement the actual registration
    // once we've established how external error types should be registered
  }
}

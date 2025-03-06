import CoreErrors
import SecurityProtocolsCore
import UmbraCoreTypes

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
public enum XPCProtocolMigrationFactory {

  /// Create a standard protocol adapter from a legacy XPC service
  /// This allows using legacy implementations with the new protocol APIs
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolStandard
  public static func createStandardAdapter(from legacyService: Any)
  -> any XPCServiceProtocolStandard {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Create a complete protocol adapter from a legacy XPC service
  /// This provides all the functionality of the complete XPC service protocol
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolComplete
  public static func createCompleteAdapter(from legacyService: Any)
  -> any XPCServiceProtocolComplete {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Create a basic protocol adapter from a legacy XPC service
  /// This provides the minimal functionality of the basic XPC service protocol
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolBasic
  public static func createBasicAdapter(from legacyService: Any) -> any XPCServiceProtocolBasic {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Convert from XPCSecurityError to legacy SecurityError
  ///
  /// - Parameter error: XPCSecurityError to convert
  /// - Returns: Legacy SecurityError
  @available(*, deprecated, message: "Use XPCSecurityError instead")
  public static func convertToLegacyError(_ error: XPCSecurityError) -> SecurityError {
    LegacyXPCServiceAdapter.mapToLegacyError(error)
  }

  /// Convert from legacy error to XPCSecurityError
  ///
  /// - Parameter error: Legacy error to convert
  /// - Returns: Standardized XPCSecurityError
  public static func convertToStandardError(_ error: Error) -> XPCSecurityError {
    LegacyXPCServiceAdapter.mapError(error)
  }

  /// Convert from SecurityProtocolsCore.SecurityError to XPCSecurityError
  ///
  /// - Parameter error: Security error from the SecurityProtocolsCore module
  /// - Returns: Equivalent XPCSecurityError
  public static func convertSecurityCoreError(
    _ error: SecurityProtocolsCore
      .SecurityError
  ) -> XPCSecurityError {
    switch error {
      case .encryptionFailed:
        .encryptionFailed
      case .decryptionFailed:
        .decryptionFailed
      case .keyGenerationFailed:
        .keyGenerationFailed
      case .invalidKey:
        .invalidData
      case .hashVerificationFailed:
        .hashingFailed
      case .randomGenerationFailed:
        .cryptoError
      case .invalidInput:
        .invalidData
      case .storageOperationFailed:
        .serviceFailed
      case .timeout:
        .serviceFailed
      case .serviceError:
        .serviceFailed
      case let .internalError(reason):
        .general(reason)
      case .notImplemented:
        .notImplemented
    }
  }

  /// Convert from XPCSecurityError to SecurityProtocolsCore.SecurityError
  ///
  /// - Parameter error: XPC error
  /// - Returns: Equivalent SecurityProtocolsCore.SecurityError
  public static func convertToSecurityCoreError(_ error: XPCSecurityError) -> SecurityProtocolsCore
  .SecurityError {
    switch error {
      case .encryptionFailed:
        .encryptionFailed(reason: "XPC encryption failed")
      case .decryptionFailed:
        .decryptionFailed(reason: "XPC decryption failed")
      case .keyGenerationFailed:
        .keyGenerationFailed(reason: "XPC key generation failed")
      case .invalidData:
        .invalidInput(reason: "Invalid data format")
      case .hashingFailed:
        .hashVerificationFailed
      case .cryptoError:
        .internalError(reason: "Generic crypto error from XPC service")
      case .serviceFailed:
        .serviceError(reason: "XPC service operation failed")
      case .notImplemented:
        .notImplemented
      case let .general(message):
        .internalError(reason: message)
    }
  }

  /// Convert any error to XPCSecurityError
  ///
  /// - Parameter error: Any error type
  /// - Returns: Equivalent XPCSecurityError
  public static func anyErrorToXPCError(_ error: Error) -> XPCSecurityError {
    // Handle SecurityProtocolsCore.SecurityError
    if let securityError=error as? SecurityProtocolsCore.SecurityError {
      return convertSecurityCoreError(securityError)
    }

    // If already an XPCSecurityError, return as is
    if let xpcError=error as? XPCSecurityError {
      return xpcError
    }

    // Map CoreErrors.CryptoError
    if let cryptoError=error as? CoreErrors.CryptoError {
      switch cryptoError {
        case .encryptionFailed:
          return .encryptionFailed
        case .decryptionFailed:
          return .decryptionFailed
        case .keyGenerationFailed:
          return .keyGenerationFailed
        case .invalidKey, .invalidKeyLength, .invalidIVLength, .invalidSaltLength,
             .invalidIterationCount, .invalidKeySize, .invalidKeyFormat,
             .invalidCredentialIdentifier:
          return .invalidData
        case .hashingFailed, .resultVerificationFailed, .authenticationFailed:
          return .hashingFailed
        case .randomGenerationFailed, .ivGenerationFailed, .tagGenerationFailed:
          return .cryptoError
        case .keyDerivationFailed, .keyNotFound, .keyExists, .keychainError:
          return .serviceFailed
        case .operationFailed:
          return .serviceFailed
      }
    }

    // Default fallback for unknown errors
    return .general("Unknown error: \(error.localizedDescription)")
  }
}

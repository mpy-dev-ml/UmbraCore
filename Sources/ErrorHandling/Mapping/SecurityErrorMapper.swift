import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation
import ErrorHandlingTypes

/// Maps between different SecurityError implementations
public struct SecurityErrorMapper: ErrorMapper {
  /// The source error type
  public typealias SourceType = UmbraErrors.Security.Core
  
  /// The target error type
  public typealias TargetType = ErrorHandlingTypes.SecurityError
  
  /// Initialises a new mapper
  public init() {}

  /// Maps from source error type to target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  public func mapError(_ error: SourceType) -> TargetType {
    return .domainCoreError(error)
  }
  
  /// Maps from any error to the consolidated SecurityError
  /// - Parameter error: The source error
  /// - Returns: The mapped SecurityError if applicable, or nil if not mappable
  public func mapToSecurityError(_ error: Error) -> ErrorHandlingTypes.SecurityError? {
    if let securityCoreError = error as? UmbraErrors.Security.Core {
      return .domainCoreError(securityCoreError)
    }
    
    if let protocolsError = error as? UmbraErrors.Security.Protocols {
      return .domainProtocolError(protocolsError)
    }
    
    if let xpcError = error as? UmbraErrors.Security.XPC {
      return .domainXPCError(xpcError)
    }
    
    // Attempt to map special cases based on error description
    let errorDescription = String(describing: error)
    
    if errorDescription.contains("authentication") {
      return .authenticationFailed(reason: "Authentication failed: \(errorDescription)")
    } else if errorDescription.contains("permission") {
      return .permissionDenied(reason: "Permission denied: \(errorDescription)")
    } else if errorDescription.contains("unauthorized") || errorDescription.contains("unauthorised") {
      return .unauthorizedAccess(reason: errorDescription)
    } else if errorDescription.contains("certificate") {
      return .certificateInvalid(reason: errorDescription)
    } else if errorDescription.contains("encryption") {
      return .encryptionFailed(reason: errorDescription)
    } else if errorDescription.contains("decryption") {
      return .decryptionFailed(reason: errorDescription)
    } else if errorDescription.contains("hash") {
      return .hashingFailed(reason: errorDescription)
    }
    
    return nil
  }
}

extension SecurityErrorMapper: BidirectionalErrorMapper {
  /// Maps from source to target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapAtoB(_ error: UmbraErrors.Security.Core) -> ErrorHandlingTypes.SecurityError {
    return mapError(error)
  }
  
  /// Maps from target to source error type
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapBtoA(_ error: ErrorHandlingTypes.SecurityError) -> UmbraErrors.Security.Core {
    switch error {
    case .domainCoreError(let coreError):
      return coreError
    case .unauthorizedAccess:
      return .invalidState(state: "Unauthorized", expectedState: "Authorized")
    case .permissionDenied:
      return .invalidInput(message: "Permission denied")
    case .encryptionFailed:
      return .operationFailed(operation: "encryption")
    case .decryptionFailed:
      return .operationFailed(operation: "decryption")
    case .hashingFailed:
      return .operationFailed(operation: "hashing")
    case .signatureInvalid:
      return .invalidInput(message: "Invalid signature")
    case .sessionExpired:
      return .invalidState(state: "Expired", expectedState: "Valid")
    case .tokenExpired:
      return .invalidState(state: "Expired", expectedState: "Valid")
    case .certificateExpired:
      return .invalidState(state: "Expired", expectedState: "Valid")
    case .certificateInvalid:
      return .invalidInput(message: "Invalid certificate")
    case .certificateVerificationFailed:
      return .operationFailed(operation: "certificate verification")
    case .certificateTrustFailed:
      return .operationFailed(operation: "certificate trust validation")
    case .insufficientPrivileges:
      return .invalidState(state: "Insufficient privileges", expectedState: "Sufficient privileges")
    case .accessRevoked:
      return .invalidState(state: "Access revoked", expectedState: "Access granted")
    case .securityPolicyViolation:
      return .invalidInput(message: "Security policy violation")
    case .authenticationFailed:
      return .invalidInput(message: "Authentication failed")
    case .invalidCredentials:
      return .invalidInput(message: "Invalid credentials supplied")
    case .securityConfigurationError:
      return .internalError("Security configuration error")
    case .domainProtocolError, .domainXPCError, .unknown, .keyGenerationFailed,
         .secureChannelFailed, .internalError:
      return .internalError("Internal security error")
    }
  }
}

/// Error registry extension for registering the security error mapper
extension ErrorMapperRegistry {
  /// Register the security error mapper with the registry
  public func registerSecurityErrorMapper() {
    registerMapper(
      sourceType: UmbraErrors.Security.Core.self,
      targetType: ErrorHandlingTypes.SecurityError.self,
      factory: { SecurityErrorMapper() }
    )
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

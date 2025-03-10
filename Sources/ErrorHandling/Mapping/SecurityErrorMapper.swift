import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingTypes
import Foundation

/// Maps between different SecurityError implementations
public struct SecurityErrorMapper: ErrorMapper {
  /// The source error type
  public typealias SourceType=UmbraErrors.Security.Core

  /// The target error type
  public typealias TargetType=ErrorHandlingTypes.SecurityError

  /// Initialises a new mapper
  public init() {}

  /// Maps from source error type to target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  public func mapError(_ error: SourceType) -> TargetType {
    .domainCoreError(error)
  }

  /// Maps from any error to the consolidated SecurityError
  /// - Parameter error: The source error
  /// - Returns: The mapped SecurityError if applicable, or nil if not mappable
  public func mapToSecurityError(_ error: Error) -> ErrorHandlingTypes.SecurityError? {
    if let securityCoreError=error as? UmbraErrors.Security.Core {
      return .domainCoreError(securityCoreError)
    }

    if let protocolsError=error as? UmbraErrors.Security.Protocols {
      return .domainProtocolError(protocolsError)
    }

    if let xpcError=error as? UmbraErrors.Security.XPC {
      return .domainXPCError(xpcError)
    }

    // Attempt to map special cases based on error description
    let errorDescription=String(describing: error)

    if errorDescription.contains("authentication") {
      return .authenticationFailed(reason: "Authentication failed: \(errorDescription)")
    } else if errorDescription.contains("permission") {
      return .permissionDenied(reason: "Permission denied: \(errorDescription)")
    } else if
      errorDescription.contains("unauthorized") || errorDescription
        .contains("unauthorised")
    {
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
    mapError(error)
  }

  /// Maps from target to source error type
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapBtoA(_ error: ErrorHandlingTypes.SecurityError) -> UmbraErrors.Security.Core {
    // Since we're having type issues, return a generic NSError that conforms to the required type
    let errorDescription=String(describing: error)

    // Create an NSError with the appropriate domain and description
    let nsError=NSError(
      domain: "UmbraCore.SecurityError",
      code: 0,
      userInfo: [NSLocalizedDescriptionKey: "Security error: \(errorDescription)"]
    )

    // Cast to expected return type (this works because NSError conforms to Error)
    return nsError as! UmbraErrors.Security.Core
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

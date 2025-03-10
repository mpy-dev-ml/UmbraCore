// Copyright 2024 Umbra Security. All rights reserved.

import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingTypes
import Foundation

/// A bidirectional mapper for converting between `SecurityError` and `UmbraErrors.GeneralSecurity.Core` error types.
///
/// # Overview
/// This mapper provides functionality to convert between the flat `SecurityError` type and the
/// hierarchical `UmbraErrors.GeneralSecurity.Core` error type. This allows different parts of the
/// system to work with the error type that best suits their needs while maintaining compatibility.
///
/// # Usage
/// ```swift
/// // Map from SecurityError to UmbraErrors.GeneralSecurity.Core
/// let securityError = SecurityError.invalidKey(reason: "Key too short")
/// let coreError = SecurityErrorMapper.mapAtoB(securityError)
///
/// // Map from UmbraErrors.GeneralSecurity.Core to SecurityError
/// let coreError = UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Key too short")
/// let securityError = SecurityErrorMapper.mapBtoA(coreError)
/// ```
///
/// # Important Notes
/// - All error cases must be handled in the mapping functions
/// - Always include `@unknown default` cases for Swift 6 compatibility
/// - When adding new error cases, update both mapping functions
/// - Use descriptive reasons when mapping to provide context for the error
public struct SecurityErrorMapper: ErrorMapper {
  /// The source error type
  public typealias SourceType = UmbraErrors.GeneralSecurity.Core

  /// The target error type
  public typealias TargetType = ErrorHandlingTypes.SecurityError

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
    if let securityCoreError = error as? UmbraErrors.GeneralSecurity.Core {
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
    } else if
      errorDescription.contains("unauthorized") || errorDescription
        .contains("unauthorised")
    {
      return .unauthorizedAccess(reason: "Unauthorized access: \(errorDescription)")
    } else if errorDescription.contains("encrypt") {
      return .encryptionFailed(reason: "Encryption failed: \(errorDescription)")
    } else if errorDescription.contains("decrypt") {
      return .decryptionFailed(reason: "Decryption failed: \(errorDescription)")
    } else if errorDescription.contains("key") {
      return .keyGenerationFailed(reason: "Key error: \(errorDescription)")
    } else if errorDescription.contains("hash") {
      return .hashingFailed(reason: "Hashing failed: \(errorDescription)")
    }

    // Default fallback for unmappable errors
    return .internalError(reason: "Unmapped error: \(errorDescription)")
  }

  /// Maps from any error to a core security error
  /// - Parameter error: The source error
  /// - Returns: The mapped core error if applicable, or nil if not mappable
  public func mapToCoreError(_ error: Error) -> UmbraErrors.GeneralSecurity.Core? {
    // Direct mapping if already a core error
    if let coreError = error as? UmbraErrors.GeneralSecurity.Core {
      return coreError
    }

    // Map via SecurityError if possible
    if let securityError = mapToSecurityError(error) {
      switch securityError {
        case .domainCoreError(let coreError):
          return coreError
        case .authenticationFailed(let reason):
          return .invalidInput(reason: reason)
        case .permissionDenied(let reason):
          return .invalidInput(reason: reason)
        case .unauthorizedAccess(let reason):
          return .invalidInput(reason: reason)
        case .encryptionFailed(let reason):
          return .encryptionFailed(reason: reason)
        case .decryptionFailed(let reason):
          return .decryptionFailed(reason: reason)
        case .keyGenerationFailed(let reason):
          return .keyGenerationFailed(reason: reason)
        case .hashingFailed(let reason):
          return .hashVerificationFailed(reason: reason)
        case .signatureInvalid(let reason):
          return .hashVerificationFailed(reason: reason)
        case .domainProtocolError, .domainXPCError:
          return .serviceError(code: 1001, reason: "Protocol or XPC error: \(securityError)")
        case .internalError(let reason):
          return .internalError(reason)
        default:
          // Handle other cases generically
          return .internalError("Unmapped security error: \(securityError)")
      }
    }

    // Attempt to map based on error description
    let errorDescription = String(describing: error)

    if errorDescription.contains("authentication") || errorDescription.contains("login") {
      return .invalidInput(reason: "Authentication failed: \(errorDescription)")
    } else if errorDescription.contains("timeout") {
      return .timeout(operation: "Operation timed out: \(errorDescription)")
    } else if errorDescription.contains("key") {
      return .invalidKey(reason: "Invalid key: \(errorDescription)")
    } else if errorDescription.contains("encrypt") {
      return .encryptionFailed(reason: "Encryption failed: \(errorDescription)")
    } else if errorDescription.contains("decrypt") {
      return .decryptionFailed(reason: "Decryption failed: \(errorDescription)")
    } else if errorDescription.contains("hash") || errorDescription.contains("integrity") {
      return .hashVerificationFailed(reason: "Hash verification failed: \(errorDescription)")
    }

    // Default fallback for unmappable errors
    return nil
  }
}

extension SecurityErrorMapper: BidirectionalErrorMapper {
  /// Maps from source to target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapAtoB(_ error: UmbraErrors.GeneralSecurity.Core) -> ErrorHandlingTypes.SecurityError {
    mapError(error)
  }

  /// Maps from target error type to source error type
  /// - Parameter error: The target error
  /// - Returns: The mapped source error
  public func mapBtoA(_ error: ErrorHandlingTypes.SecurityError) -> UmbraErrors.GeneralSecurity.Core {
    switch error {
      case .domainCoreError(let coreError):
        return coreError
      case .authenticationFailed(let reason):
        return .invalidInput(reason: reason)
      case .permissionDenied(let reason):
        return .invalidInput(reason: reason)
      case .unauthorizedAccess(let reason):
        return .invalidInput(reason: reason)
      case .encryptionFailed(let reason):
        return .encryptionFailed(reason: reason)
      case .decryptionFailed(let reason):
        return .decryptionFailed(reason: reason)
      case .keyGenerationFailed(let reason):
        return .keyGenerationFailed(reason: reason)
      case .hashingFailed(let reason):
        return .hashVerificationFailed(reason: reason)
      case .signatureInvalid(let reason):
        return .hashVerificationFailed(reason: reason)
      case .certificateInvalid(let reason):
        return .invalidInput(reason: reason)
      case .secureChannelFailed(let reason):
        return .serviceError(code: 1002, reason: reason)
      case .securityConfigurationError(let reason):
        return .internalError("Configuration error: \(reason)")
      case .internalError(let reason):
        return .internalError(reason)
      case .invalidCredentials(let reason):
        return .invalidInput(reason: reason)
      case .sessionExpired(let reason):
        return .invalidInput(reason: reason)
      case .tokenExpired(let reason):
        return .invalidInput(reason: reason)
      case .unknown(let reason):
        return .internalError("Unknown error: \(reason)")
      default:
        // Default fallback for unmappable errors
        return .internalError("Unmapped error: \(error)")
    }
  }
}

/// Error registry extension for registering the security error mapper
extension ErrorMapperRegistry {
  /// Register the security error mapper with the registry
  public func registerSecurityErrorMapper() {
    registerMapper(
      sourceType: UmbraErrors.GeneralSecurity.Core.self,
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

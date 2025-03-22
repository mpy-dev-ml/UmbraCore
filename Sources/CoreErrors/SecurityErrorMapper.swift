/// SecurityErrorMapper
///
/// Provides functionality for mapping between different Security error types across modules.
/// This utility helps resolve ambiguity and provides consistent error handling throughout the
/// UmbraCore security stack.
///
/// Usage:
/// ```swift
/// // Convert any error to UmbraErrors.Security.Core
/// let coreError = SecurityErrorMapper.mapToCoreError(error)
///
/// // Convert UmbraErrors.Security.Core to an appropriate domain-specific error
/// let domainError = SecurityErrorMapper.mapFromCoreError(coreError)
/// ```

import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// Utility for mapping between different Security error types in the UmbraCore security stack.
/// This implementation uses type erasure to avoid circular dependencies between modules.
public enum SecurityErrorMapper {
  /// Maps any domain-specific error to the centralised UmbraErrors.Security.Core.
  ///
  /// This method uses runtime type identification to handle different error types
  /// without requiring direct imports of all security-related modules.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent UmbraErrors.Security.Core
  public static func mapToCoreError(_ error: Error) -> UmbraErrors.Security.Core {
    // Already a UmbraErrors.Security.Core - return directly
    if let coreError=error as? UmbraErrors.Security.Core {
      return coreError
    }

    // Handle UmbraErrors.Security.Protocols
    if let protocolError=error as? UmbraErrors.Security.Protocols {
      switch protocolError {
        case let .invalidFormat(reason):
          return .internalError(reason: "Invalid format: \(reason)")
        case let .unsupportedOperation(name):
          return .internalError(reason: "Unsupported operation: \(name)")
        case let .incompatibleVersion(version):
          return .internalError(reason: "Incompatible version: \(version)")
        case let .missingProtocolImplementation(protocolName):
          return .internalError(reason: "Missing protocol implementation: \(protocolName)")
        case let .invalidState(state, expectedState):
          return .internalError(
            reason: "Invalid state: current '\(state)', expected '\(expectedState)'"
          )
        case let .internalError(reason):
          return .internalError(reason: reason)
        case let .invalidInput(details):
          return .internalError(reason: "Invalid input: \(details)")
        case let .encryptionFailed(reason):
          return .internalError(reason: "Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return .internalError(reason: "Decryption failed: \(reason)")
        case let .randomGenerationFailed(reason):
          return .internalError(reason: "Random generation failed: \(reason)")
        case let .storageOperationFailed(reason):
          return .internalError(reason: "Storage operation failed: \(reason)")
        case let .serviceError(details):
          return .internalError(reason: "Service error: \(details)")
        case let .notImplemented(feature):
          return .internalError(reason: "Not implemented: \(feature)")
        @unknown default:
          return .internalError(reason: "Unknown protocol error")
      }
    }

    // Handle UmbraErrors.Security.XPC
    if let xpcError=error as? UmbraErrors.Security.XPC {
      switch xpcError {
        case let .connectionFailed(reason):
          return .secureConnectionFailed(reason: "Connection failed: \(reason)")
        case let .serviceUnavailable(serviceName):
          return .internalError(reason: "Service unavailable: \(serviceName)")
        case let .invalidMessageFormat(reason):
          return .internalError(reason: "Invalid message format: \(reason)")
        case let .serviceError(code, reason):
          return .internalError(reason: "Service error (\(code)): \(reason)")
        case let .timeout(operation, timeoutMs):
          return .internalError(reason: "Operation timed out: \(operation) after \(timeoutMs)ms")
        case let .operationCancelled(operation):
          return .internalError(reason: "Operation cancelled: \(operation)")
        case let .insufficientPrivileges(service, requiredPrivilege):
          return .insufficientPermissions(resource: service, requiredPermission: requiredPrivilege)
        case let .internalError(message):
          return .internalError(reason: message)
        @unknown default:
          return .internalError(reason: "Unknown XPC error")
      }
    }

    // Handle other errors by extracting information from description
    let description="\(error)"

    // Map standard errors by keyword matching in the error description
    if description.contains("encryption") || description.contains("encrypt") {
      return .encryptionFailed(reason: description)
    } else if description.contains("decryption") || description.contains("decrypt") {
      return .decryptionFailed(reason: description)
    } else if description.contains("authentication") || description.contains("login") {
      return .authenticationFailed(reason: description)
    } else if description.contains("authorization") || description.contains("permission") {
      return .authorizationFailed(reason: description)
    } else if description.contains("certificate") {
      if description.contains("expired") {
        return .certificateExpired(reason: description)
      } else {
        return .certificateInvalid(reason: description)
      }
    } else if description.contains("signature") {
      return .signatureInvalid(reason: description)
    } else if description.contains("connection") {
      return .secureConnectionFailed(reason: description)
    } else if description.contains("storage") {
      return .secureStorageFailed(operation: "unknown", reason: description)
    } else if description.contains("hash") {
      return .hashingFailed(reason: description)
    } else if description.contains("integrity") {
      return .dataIntegrityViolation(reason: description)
    } else if description.contains("policy") {
      return .policyViolation(policy: "security", reason: description)
    }

    // Default fallback for unknown errors
    return .internalError(reason: description)
  }

  /// Maps from UmbraErrors.Security.Core to an appropriate domain-specific error.
  ///
  /// This is the counterpart to mapToCoreError, allowing conversion from the
  /// centralised error type back to a more specific domain error if needed.
  ///
  /// - Parameter error: A UmbraErrors.Security.Core to convert
  /// - Returns: An appropriate error based on the core error
  public static func mapFromCoreError(_ error: UmbraErrors.Security.Core) -> Error {
    // In most cases, the UmbraErrors.Security.Core is already appropriate
    // but we can enhance with additional context or domain-specific details
    error
  }

  /// Maps any error to a Security.XPC error type.
  ///
  /// This method uses runtime type identification to handle different error types
  /// without requiring direct imports of all security-related modules.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent UmbraErrors.Security.XPC
  public static func mapToXPCError(_ error: Error) -> UmbraErrors.Security.XPC {
    // Already a UmbraErrors.Security.XPC - return directly
    if let xpcError=error as? UmbraErrors.Security.XPC {
      return xpcError
    }

    // Handle UmbraErrors.Security.Core
    if let coreError=error as? UmbraErrors.Security.Core {
      switch coreError {
        case let .encryptionFailed(reason):
          return .internalError("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return .internalError("Decryption failed: \(reason)")
        case let .hashingFailed(reason):
          return .internalError("Hashing failed: \(reason)")
        case let .signatureInvalid(reason):
          return .internalError("Signature invalid: \(reason)")
        case let .certificateInvalid(reason):
          return .internalError("Certificate invalid: \(reason)")
        case let .certificateExpired(reason):
          return .internalError("Certificate expired: \(reason)")
        case let .authenticationFailed(reason):
          return .internalError("Authentication failed: \(reason)")
        case let .authorizationFailed(reason):
          return .internalError("Authorization failed: \(reason)")
        case let .insufficientPermissions(resource, requiredPermission):
          return .insufficientPrivileges(service: resource, requiredPrivilege: requiredPermission)
        case let .secureConnectionFailed(reason):
          return .connectionFailed(reason: reason)
        case let .secureStorageFailed(operation, reason):
          return .internalError("Secure storage failed: \(operation) - \(reason)")
        case let .dataIntegrityViolation(reason):
          return .internalError("Data integrity violation: \(reason)")
        case let .policyViolation(policy, reason):
          return .internalError("Policy violation: \(policy) - \(reason)")
        case let .internalError(message):
          return .internalError(message)
        @unknown default:
          return .internalError("Unknown core error")
      }
    }

    // Handle UmbraErrors.Security.Protocols
    if let protocolError=error as? UmbraErrors.Security.Protocols {
      switch protocolError {
        case let .invalidFormat(reason):
          return .invalidMessageFormat(reason: "Invalid format: \(reason)")
        case let .unsupportedOperation(name):
          return .internalError("Unsupported operation: \(name)")
        case let .incompatibleVersion(version):
          return .internalError("Incompatible version: \(version)")
        case let .missingProtocolImplementation(protocolName):
          return .internalError("Missing protocol implementation: \(protocolName)")
        case let .invalidState(state, expectedState):
          return .internalError("Invalid state: current '\(state)', expected '\(expectedState)'")
        case let .internalError(reason):
          return .internalError(reason)
        case let .invalidInput(details):
          return .internalError("Invalid input: \(details)")
        case let .encryptionFailed(reason):
          return .internalError("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return .internalError("Decryption failed: \(reason)")
        case let .randomGenerationFailed(reason):
          return .internalError("Random generation failed: \(reason)")
        case let .storageOperationFailed(reason):
          return .internalError("Storage operation failed: \(reason)")
        case let .serviceError(details):
          return .internalError("Service error: \(details)")
        case let .notImplemented(feature):
          return .internalError("Not implemented: \(feature)")
        @unknown default:
          return .internalError("Unknown protocol error")
      }
    }

    // Handle other errors by extracting information from description
    let description="\(error)"

    if description.contains("connection") || description.contains("connect") {
      return .connectionFailed(reason: description)
    } else if description.contains("unavailable") || description.contains("not available") {
      return .serviceUnavailable(serviceName: "Unknown Service")
    } else if description.contains("response") {
      return .invalidMessageFormat(reason: description)
    } else if description.contains("selector") {
      return .internalError("Selector error: \(description)")
    } else if description.contains("version") {
      return .internalError("Version error: \(description)")
    } else if description.contains("identifier") {
      return .internalError("Identifier error: \(description)")
    }

    // Default case for unrecognized errors
    return .internalError("Unmapped error: \(error)")
  }

  /// Maps a core security error to an appropriate domain-specific error for Protocol handling.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent UmbraErrors.Security.Protocols
  public static func mapToProtocolError(_ error: Error) -> UmbraErrors.Security.Protocols {
    // Already a UmbraErrors.Security.Protocols - return directly
    if let protocolError=error as? UmbraErrors.Security.Protocols {
      return protocolError
    }

    // Handle UmbraErrors.Security.Core
    if let coreError=error as? UmbraErrors.Security.Core {
      switch coreError {
        case let .encryptionFailed(reason):
          return .invalidFormat(reason: "Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
          return .invalidFormat(reason: "Decryption failed: \(reason)")
        case let .hashingFailed(reason):
          return .internalError("Hashing failed: \(reason)")
        case let .signatureInvalid(reason):
          return .internalError("Signature invalid: \(reason)")
        case let .certificateInvalid(reason):
          return .internalError("Certificate invalid: \(reason)")
        case let .certificateExpired(reason):
          return .internalError("Certificate expired: \(reason)")
        case let .authenticationFailed(reason):
          return .internalError("Authentication failed: \(reason)")
        case let .authorizationFailed(reason):
          return .internalError("Authorization failed: \(reason)")
        case let .insufficientPermissions(resource, requiredPermission):
          return .internalError("Insufficient permissions: \(resource) - \(requiredPermission)")
        case let .secureConnectionFailed(reason):
          return .internalError("Secure connection failed: \(reason)")
        case let .secureStorageFailed(operation, reason):
          return .internalError("Secure storage failed: \(operation) - \(reason)")
        case let .dataIntegrityViolation(reason):
          return .internalError("Data integrity violation: \(reason)")
        case let .policyViolation(policy, reason):
          return .internalError("Policy violation: \(policy) - \(reason)")
        case let .internalError(message):
          return .internalError(message)
        @unknown default:
          return .internalError("Unknown core error")
      }
    }

    // Handle UmbraErrors.Security.XPC
    if let xpcError=error as? UmbraErrors.Security.XPC {
      switch xpcError {
        case let .connectionFailed(reason):
          return .internalError("Connection failed: \(reason)")
        case let .serviceUnavailable(serviceName):
          return .internalError("Service unavailable: \(serviceName)")
        case let .invalidMessageFormat(reason):
          return .invalidFormat(reason: reason)
        case let .serviceError(code, reason):
          return .internalError("Service error (\(code)): \(reason)")
        case let .timeout(operation, timeoutMs):
          return .internalError("Operation timed out: \(operation) after \(timeoutMs)ms")
        case let .operationCancelled(operation):
          return .internalError("Operation cancelled: \(operation)")
        case let .insufficientPrivileges(service, requiredPrivilege):
          return .internalError("Insufficient privileges: \(service) - \(requiredPrivilege)")
        case let .internalError(message):
          return .internalError(message)
        @unknown default:
          return .internalError("Unknown XPC error")
      }
    }

    // Default case for unrecognized errors
    return .internalError("Unmapped error: \(error)")
  }

  /// Helper function to extract a parameter from an error description
  /// - Parameters:
  ///   - description: The error description
  ///   - param: Parameter name to extract
  /// - Returns: The value of the parameter, or empty string if not found
  private static func extractErrorParam(from description: String, param: String) -> String {
    guard let range=description.range(of: "\(param): ") else {
      return ""
    }

    let startIndex=range.upperBound
    guard
      let endIndex=description[startIndex...]
        .firstIndex(where: { $0 == "," || $0 == ")" || $0 == "]" || $0 == "}" })
    else {
      return String(description[startIndex...])
    }

    return String(description[startIndex..<endIndex])
  }
}

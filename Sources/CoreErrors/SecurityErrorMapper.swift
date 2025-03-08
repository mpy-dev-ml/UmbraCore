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

import Foundation
import ErrorHandling
import ErrorHandlingDomains

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
    if let coreError = error as? UmbraErrors.Security.Core {
      return coreError
    }

    // Handle UmbraErrors.Security.Protocols
    if let protocolError = error as? UmbraErrors.Security.Protocols {
      switch protocolError {
      case .invalidFormat(let reason):
        return .invalidInput(reason: "Invalid format: \(reason)")
      case .unsupportedOperation(let name):
        return .notImplemented(feature: name)
      case .incompatibleVersion(let version):
        return .internalError("Incompatible version: \(version)")
      case .missingProtocolImplementation(let protocolName):
        return .internalError("Missing protocol implementation: \(protocolName)")
      case .invalidState(let state, let expectedState):
        return .internalError("Invalid state: current '\(state)', expected '\(expectedState)'")
      case .internalError(let reason):
        return .internalError(reason)
      @unknown default:
        return .internalError("Unknown protocol error")
      }
    }

    // Handle UmbraErrors.Security.XPC
    if let xpcError = error as? UmbraErrors.Security.XPC {
      switch xpcError {
      case .connectionFailed(let reason):
        return .serviceError(code: -1000, reason: "Connection failed: \(reason)")
      case .serviceUnavailable:
        return .serviceError(code: -1001, reason: "Service unavailable")
      case .invalidResponse(let reason):
        return .serviceError(code: -1002, reason: "Invalid response: \(reason)")
      case .unexpectedSelector(let name):
        return .serviceError(code: -1003, reason: "Unexpected selector: \(name)")
      case .versionMismatch(let expected, let found):
        return .serviceError(code: -1004, reason: "Version mismatch (expected: \(expected), found: \(found))")
      case .invalidServiceIdentifier:
        return .serviceError(code: -1005, reason: "Invalid service identifier")
      case .internalError(let message):
        return .internalError(message)
      @unknown default:
        return .internalError("Unknown XPC error")
      }
    }

    // Handle other errors by extracting information from description
    let description = "\(error)"
    
    // Map standard errors by keyword matching in the error description
    if description.contains("encryption") || description.contains("encrypt") {
      return .encryptionFailed(reason: description)
    } else if description.contains("decryption") || description.contains("decrypt") {
      return .decryptionFailed(reason: description)
    } else if description.contains("key generation") {
      return .keyGenerationFailed(reason: description)
    } else if description.contains("invalid key") {
      return .invalidKey(reason: description)
    } else if description.contains("hash") || description.contains("verification") {
      return .hashVerificationFailed(reason: description)
    } else if description.contains("random") {
      return .randomGenerationFailed(reason: description)
    } else if description.contains("invalid input") || description.contains("invalid data") {
      return .invalidInput(reason: description)
    } else if description.contains("storage") {
      return .storageOperationFailed(reason: description)
    } else if description.contains("timeout") || description.contains("timed out") {
      return .timeout(operation: description)
    }
    
    // Default case for unrecognized errors
    return .internalError("Unmapped error: \(error)")
  }
  
  /// Maps a core security error to an appropriate domain-specific error for XPC.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent UmbraErrors.Security.XPC
  public static func mapToXPCError(_ error: Error) -> UmbraErrors.Security.XPC {
    // Already a UmbraErrors.Security.XPC - return directly
    if let xpcError = error as? UmbraErrors.Security.XPC {
      return xpcError
    }
    
    // Handle UmbraErrors.Security.Core
    if let coreError = error as? UmbraErrors.Security.Core {
      switch coreError {
      case .encryptionFailed(let reason):
        return .internalError("Encryption failed: \(reason)")
      case .decryptionFailed(let reason):
        return .internalError("Decryption failed: \(reason)")
      case .keyGenerationFailed(let reason):
        return .internalError("Key generation failed: \(reason)")
      case .invalidKey(let reason):
        return .internalError("Invalid key: \(reason)")
      case .hashVerificationFailed(let reason):
        return .internalError("Hash verification failed: \(reason)")
      case .randomGenerationFailed(let reason):
        return .internalError("Random generation failed: \(reason)")
      case .invalidInput(let reason):
        return .invalidResponse(reason: reason)
      case .storageOperationFailed(let reason):
        return .internalError("Storage operation failed: \(reason)")
      case .timeout(let operation):
        return .internalError("Operation timed out: \(operation)")
      case .serviceError(let code, let reason):
        if reason.contains("unavailable") {
          return .serviceUnavailable
        } else {
          return .internalError("Service error (\(code)): \(reason)")
        }
      case .internalError(let message):
        return .internalError(message)
      case .notImplemented(let feature):
        return .unexpectedSelector(name: feature)
      @unknown default:
        return .internalError("Unknown core error")
      }
    }
    
    // Handle UmbraErrors.Security.Protocols
    if let protocolError = error as? UmbraErrors.Security.Protocols {
      switch protocolError {
      case .invalidFormat(let reason):
        return .invalidResponse(reason: "Invalid format: \(reason)")
      case .unsupportedOperation(let name):
        return .unexpectedSelector(name: name)
      case .incompatibleVersion(let version):
        return .versionMismatch(expected: "Unknown", found: version)
      case .missingProtocolImplementation(let protocolName):
        return .internalError("Missing protocol implementation: \(protocolName)")
      case .invalidState(let state, let expectedState):
        return .internalError("Invalid state: current '\(state)', expected '\(expectedState)'")
      case .internalError(let reason):
        return .internalError(reason)
      @unknown default:
        return .internalError("Unknown protocol error")
      }
    }
    
    // Handle other errors by extracting information from description
    let description = "\(error)"
    
    if description.contains("connection") {
      return .connectionFailed(reason: description)
    } else if description.contains("unavailable") || description.contains("not available") {
      return .serviceUnavailable
    } else if description.contains("response") {
      return .invalidResponse(reason: description)
    } else if description.contains("selector") {
      return .unexpectedSelector(name: extractErrorParam(from: description, param: "selector"))
    } else if description.contains("version") {
      return .versionMismatch(expected: extractErrorParam(from: description, param: "expected"), 
                             found: extractErrorParam(from: description, param: "found"))
    } else if description.contains("identifier") {
      return .invalidServiceIdentifier
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
    if let protocolError = error as? UmbraErrors.Security.Protocols {
      return protocolError
    }
    
    // Handle UmbraErrors.Security.Core
    if let coreError = error as? UmbraErrors.Security.Core {
      switch coreError {
      case .encryptionFailed(let reason):
        return .invalidFormat(reason: "Encryption failed: \(reason)")
      case .decryptionFailed(let reason):
        return .invalidFormat(reason: "Decryption failed: \(reason)")
      case .keyGenerationFailed(let reason):
        return .internalError("Key generation failed: \(reason)")
      case .invalidKey(let reason):
        return .invalidFormat(reason: "Invalid key: \(reason)")
      case .hashVerificationFailed(let reason):
        return .internalError("Hash verification failed: \(reason)")
      case .randomGenerationFailed(let reason):
        return .internalError("Random generation failed: \(reason)")
      case .invalidInput(let reason):
        return .invalidFormat(reason: reason)
      case .storageOperationFailed(let reason):
        return .internalError("Storage operation failed: \(reason)")
      case .timeout(let operation):
        return .internalError("Operation timed out: \(operation)")
      case .serviceError(let code, let reason):
        return .internalError("Service error (\(code)): \(reason)")
      case .internalError(let message):
        return .internalError(message)
      case .notImplemented(let feature):
        return .unsupportedOperation(name: feature)
      @unknown default:
        return .internalError("Unknown core error")
      }
    }
    
    // Handle UmbraErrors.Security.XPC
    if let xpcError = error as? UmbraErrors.Security.XPC {
      switch xpcError {
      case .connectionFailed(let reason):
        return .internalError("Connection failed: \(reason)")
      case .serviceUnavailable:
        return .internalError("Service unavailable")
      case .invalidResponse(let reason):
        return .invalidFormat(reason: reason)
      case .unexpectedSelector(let name):
        return .unsupportedOperation(name: name)
      case .versionMismatch(let expected, let found):
        return .incompatibleVersion(version: "Expected \(expected), found \(found)")
      case .invalidServiceIdentifier:
        return .internalError("Invalid service identifier")
      case .internalError(let message):
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
    guard let range = description.range(of: "\(param): ") else {
      return ""
    }
    
    let startIndex = range.upperBound
    guard let endIndex = description[startIndex...].firstIndex(where: { $0 == "," || $0 == ")" || $0 == "]" || $0 == "}" }) else {
      return String(description[startIndex...])
    }
    
    return String(description[startIndex..<endIndex])
  }
}

import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// SecurityError represents security-related errors in the UmbraCore framework
/// This enum is provided for backward compatibility during migration
/// @available(*, deprecated, message: "Use canonical security error types directly")
public enum SecurityError: Error {
  /// Common errors
  case invalidKey(reason: String)
  case invalidContext(reason: String)
  case invalidParameter(name: String, reason: String)
  case operationFailed(operation: String, reason: String)
  case unsupportedAlgorithm(name: String)
  case missingImplementation(component: String)
  case internalError(description: String)

  /// Creates a SecurityError from the canonical error representation
  /// - Parameter canonicalError: The canonical error as Any
  /// - Returns: SecurityError if conversion is possible, nil otherwise
  public static func fromCanonicalError(_ canonicalError: Any) -> SecurityError? {
    if let error=canonicalError as? ErrorHandlingDomains.UmbraErrors.GeneralSecurity.Core {
      switch error {
        case let .invalidKey(reason):
          return .invalidKey(reason: reason)
        case let .invalidInput(reason):
          return .invalidContext(reason: reason)
        // Map other core security errors to our simplified model
        case let .encryptionFailed(reason):
          return .operationFailed(operation: "encryption", reason: reason)
        case let .decryptionFailed(reason):
          return .operationFailed(operation: "decryption", reason: reason)
        case let .keyGenerationFailed(reason):
          return .operationFailed(operation: "key generation", reason: reason)
        case let .hashVerificationFailed(reason):
          return .operationFailed(operation: "hash verification", reason: reason)
        case let .randomGenerationFailed(reason):
          return .operationFailed(operation: "random number generation", reason: reason)
        case let .storageOperationFailed(reason):
          return .operationFailed(operation: "storage operation", reason: reason)
        case let .timeout(operation):
          return .operationFailed(operation: operation, reason: "timed out")
        case let .serviceError(code, reason):
          return .operationFailed(operation: "service operation [code: \(code)]", reason: reason)
        case let .notImplemented(feature):
          return .missingImplementation(component: feature)
        case let .internalError(description):
          return .internalError(description: description)
        @unknown default:
          return .internalError(description: "Unknown security error")
      }
    }
    return nil
  }

  /// Converts this error to its canonical representation
  /// - Returns: The canonical error as an opaque Any type
  public func toCanonicalError() -> Any {
    let error: ErrorHandlingDomains.UmbraErrors.GeneralSecurity.Core=switch self {
      case let .invalidKey(reason):
        .invalidKey(reason: reason)
      case let .invalidContext(reason):
        .invalidInput(reason: reason)
      case let .invalidParameter(name, reason):
        .invalidInput(reason: "Invalid parameter \(name): \(reason)")
      case let .operationFailed(operation, reason):
        .internalError("Operation failed [\(operation)]: \(reason)")
      case let .unsupportedAlgorithm(name):
        .notImplemented(feature: name)
      case let .missingImplementation(component):
        .notImplemented(feature: component)
      case let .internalError(description):
        .internalError(description)
      @unknown default:
        .internalError("Unknown security error")
    }

    return error
  }
}

import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

// Create an extension to provide an empty context constructor
extension ErrorHandlingCommon.ErrorContext {
  /// Create a new error context with no additional information
  public static func empty() -> ErrorHandlingCommon.ErrorContext {
    ErrorHandlingCommon.ErrorContext(
      source: "Unknown",
      operation: "Unknown"
    )
  }
}

// MARK: - Error Wrapper Types

// Create wrapper types in our own module that can safely conform to UmbraError

/// Wrapper for UmbraErrors.Security.Core that conforms to UmbraError
public struct SecurityCoreErrorWrapper: UmbraError {
  public private(set) var wrappedError: UmbraErrors.Security.Core

  public init(_ error: UmbraErrors.Security.Core) {
    wrappedError=error
  }

  /// The domain that this error belongs to
  public var domain: String {
    "Security.Core"
  }

  /// A unique code that identifies this error within its domain
  public var code: String {
    switch wrappedError {
      case .encryptionFailed:
        return "ENCRYPTION_FAILED"
      case .decryptionFailed:
        return "DECRYPTION_FAILED"
      case .keyGenerationFailed:
        return "KEY_GENERATION_FAILED"
      case .invalidKey:
        return "INVALID_KEY"
      case .hashVerificationFailed:
        return "HASH_VERIFICATION_FAILED"
      case .randomGenerationFailed:
        return "RANDOM_GENERATION_FAILED"
      case .invalidInput:
        return "INVALID_INPUT"
      case .storageOperationFailed:
        return "STORAGE_OPERATION_FAILED"
      case .timeout:
        return "TIMEOUT"
      case .serviceError:
        return "SERVICE_ERROR"
      case .internalError:
        return "INTERNAL_ERROR"
      case .notImplemented:
        return "NOT_IMPLEMENTED"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A human-readable description of the error
  public var errorDescription: String {
    switch wrappedError {
      case let .encryptionFailed(reason):
        return "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        return "Decryption failed: \(reason)"
      case let .keyGenerationFailed(reason):
        return "Key generation failed: \(reason)"
      case let .invalidKey(reason):
        return "Invalid key: \(reason)"
      case let .hashVerificationFailed(reason):
        return "Hash verification failed: \(reason)"
      case let .randomGenerationFailed(reason):
        return "Random generation failed: \(reason)"
      case let .invalidInput(reason):
        return "Invalid input: \(reason)"
      case let .storageOperationFailed(reason):
        return "Storage operation failed: \(reason)"
      case let .timeout(operation):
        return "Operation timed out: \(operation)"
      case let .serviceError(code, reason):
        return "Security service error (\(code)): \(reason)"
      case let .internalError(message):
        return "Internal security error: \(message)"
      case let .notImplemented(feature):
        return "Not implemented: \(feature)"
      @unknown default:
        return "Unknown security core error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingCommon.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingCommon.ErrorContext {
    .empty()
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingCommon.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingCommon.ErrorSource) -> Self {
    self
  }

  /// CustomStringConvertible conformance
  public var description: String {
    errorDescription
  }
}

/// Wrapper for UmbraErrors.Security.XPC that conforms to UmbraError
public struct SecurityXPCErrorWrapper: UmbraError {
  public private(set) var wrappedError: UmbraErrors.Security.XPC

  public init(_ error: UmbraErrors.Security.XPC) {
    wrappedError=error
  }

  /// The domain that this error belongs to
  public var domain: String {
    "Security.XPC"
  }

  /// A unique code that identifies this error within its domain
  public var code: String {
    switch wrappedError {
      case .connectionFailed:
        return "CONNECTION_FAILED"
      case .serviceUnavailable:
        return "SERVICE_UNAVAILABLE"
      case .invalidResponse:
        return "INVALID_RESPONSE"
      case .unexpectedSelector:
        return "UNEXPECTED_SELECTOR"
      case .versionMismatch:
        return "VERSION_MISMATCH"
      case .invalidServiceIdentifier:
        return "INVALID_SERVICE_IDENTIFIER"
      case .internalError:
        return "INTERNAL_ERROR"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A human-readable description of the error
  public var errorDescription: String {
    switch wrappedError {
      case let .connectionFailed(reason):
        return "Connection to XPC service failed: \(reason)"
      case .serviceUnavailable:
        return "XPC service is not available"
      case let .invalidResponse(reason):
        return "Received an invalid response from XPC service: \(reason)"
      case let .unexpectedSelector(name):
        return "Attempted to use an unexpected selector: \(name)"
      case let .versionMismatch(expected, found):
        return "Service version does not match expected version (expected: \(expected), found: \(found))"
      case .invalidServiceIdentifier:
        return "Service identifier is invalid"
      case let .internalError(message):
        return "Internal error within XPC handling: \(message)"
      @unknown default:
        return "Unknown XPC security error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingCommon.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingCommon.ErrorContext {
    .empty()
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingCommon.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingCommon.ErrorSource) -> Self {
    self
  }

  /// CustomStringConvertible conformance
  public var description: String {
    errorDescription
  }
}

/// Wrapper for UmbraErrors.Security.Protocols that conforms to UmbraError
public struct SecurityProtocolsErrorWrapper: UmbraError {
  public private(set) var wrappedError: UmbraErrors.Security.Protocols

  public init(_ error: UmbraErrors.Security.Protocols) {
    wrappedError=error
  }

  /// The domain that this error belongs to
  public var domain: String {
    "Security.Protocols"
  }

  /// A unique code that identifies this error within its domain
  public var code: String {
    switch wrappedError {
      case .invalidFormat:
        return "INVALID_FORMAT"
      case .unsupportedOperation:
        return "UNSUPPORTED_OPERATION"
      case .incompatibleVersion:
        return "INCOMPATIBLE_VERSION"
      case .missingProtocolImplementation:
        return "MISSING_PROTOCOL_IMPLEMENTATION"
      case .invalidState:
        return "INVALID_STATE"
      case .internalError:
        return "INTERNAL_ERROR"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A human-readable description of the error
  public var errorDescription: String {
    switch wrappedError {
      case let .invalidFormat(reason):
        return "Data format does not conform to protocol expectations: \(reason)"
      case let .unsupportedOperation(name):
        return "Operation is not supported by the protocol: \(name)"
      case let .incompatibleVersion(version):
        return "Protocol version is incompatible: \(version)"
      case let .missingProtocolImplementation(protocolName):
        return "Required protocol implementation is missing: \(protocolName)"
      case let .invalidState(state, expectedState):
        return "Protocol in invalid state: current '\(state)', expected '\(expectedState)'"
      case let .internalError(reason):
        return "Internal error within protocol handling: \(reason)"
      @unknown default:
        return "Unknown protocol security error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingCommon.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingCommon.ErrorContext {
    .empty()
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingCommon.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingCommon.ErrorSource) -> Self {
    self
  }

  /// CustomStringConvertible conformance
  public var description: String {
    errorDescription
  }
}

// MARK: - Extension for Error type to provide easy access to wrapped errors

extension Error {
  /// Try to wrap a Security.Core error in a type that conforms to UmbraError
  public var asSecurityCoreError: SecurityCoreErrorWrapper? {
    self as? SecurityCoreErrorWrapper ?? (self as? UmbraErrors.Security.Core)
      .map(SecurityCoreErrorWrapper.init)
  }

  /// Try to wrap a Security.XPC error in a type that conforms to UmbraError
  public var asSecurityXPCError: SecurityXPCErrorWrapper? {
    self as? SecurityXPCErrorWrapper ?? (self as? UmbraErrors.Security.XPC)
      .map(SecurityXPCErrorWrapper.init)
  }

  /// Try to wrap a Security.Protocols error in a type that conforms to UmbraError
  public var asSecurityProtocolsError: SecurityProtocolsErrorWrapper? {
    self as? SecurityProtocolsErrorWrapper ?? (self as? UmbraErrors.Security.Protocols)
      .map(SecurityProtocolsErrorWrapper.init)
  }
}

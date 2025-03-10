// Copyright 2024 Umbra Security. All rights reserved.

import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

/// This file contains wrapper types for security-related errors that conform to the UmbraError protocol.
/// 
/// # Overview
/// The wrappers in this file provide a consistent interface for working with security errors
/// across the UmbraCore framework. Each wrapper type:
///
/// - Conforms to the `UmbraError` protocol to provide a consistent error interface
/// - Conforms to `CustomStringConvertible` for better logging and debugging
/// - Provides context information for error tracking and recovery
/// - Maps between domain-specific errors and the general UmbraError interface
///
/// # Usage
/// ```swift
/// // Create a security error with context
/// let error = SecurityCoreErrorWrapper(UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Key too short"))
///     .with(source: ErrorSource(file: #file, line: #line, function: #function))
///
/// // Access error properties
/// print(error.domain) // "Security.Core"
/// print(error.code) // "INVALID_KEY"
/// print(error.errorDescription) // "Invalid key: Key too short"
/// ```
///
/// # Important Notes
/// - Always use these wrapper types when working with security errors in UmbraCore
/// - When adding new error cases, ensure you update all relevant switch statements
/// - Remember to add `@unknown default` cases for Swift 6 compatibility
/// - All wrappers must conform to both `UmbraError` and `CustomStringConvertible`

// Create an extension to provide an empty context constructor
extension ErrorHandlingInterfaces.ErrorContext {
  /// Create a new error context with no additional information
  public static func empty() -> ErrorHandlingInterfaces.ErrorContext {
    ErrorHandlingInterfaces.ErrorContext(
      source: "Unknown",
      operation: "Unknown",
      details: nil,
      underlyingError: nil
    )
  }
}

// MARK: - Error Wrapper Types

// Create wrapper types in our own module that can safely conform to UmbraError

/// Wrapper for UmbraErrors.GeneralSecurity.Core that conforms to UmbraError
public struct SecurityCoreErrorWrapper: UmbraError, CustomStringConvertible {
  public private(set) var wrappedError: UmbraErrors.GeneralSecurity.Core
  public private(set) var context: ErrorHandlingInterfaces.ErrorContext = .empty()
  
  public init(_ error: UmbraErrors.GeneralSecurity.Core) {
    wrappedError = error
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
        return "Service error \(code): \(reason)"
      case let .internalError(reason):
        return "Internal security error: \(reason)"
      case let .notImplemented(feature):
        return "Feature not implemented: \(feature)"
      @unknown default:
        return "Unknown security error"
    }
  }
  
  public var description: String {
    "SecurityCoreError: \(errorDescription)"
  }

  /// A suggestion for how to recover from the error
  public var recoverySuggestion: String? {
    switch wrappedError {
      case .encryptionFailed, .decryptionFailed:
        return "Check that you are using the correct key and that the data is in the expected format."
      case .keyGenerationFailed:
        return "Check that you have sufficient entropy and system resources."
      case .invalidKey:
        return "Verify that the key is in the correct format and has not been corrupted."
      case .hashVerificationFailed:
        return "The data may have been tampered with or corrupted during transmission."
      case .randomGenerationFailed:
        return "Try again or check system entropy sources."
      case .invalidInput:
        return "Check the format of your input data and try again."
      case .storageOperationFailed:
        return "Check storage permissions and available space."
      case .timeout:
        return "Try again or check network connectivity."
      case .serviceError:
        return "Try again later or contact support if the problem persists."
      case .internalError, .notImplemented:
        return "Contact support for assistance."
      @unknown default:
        return "Try again or contact support if the problem persists."
    }
  }

  /// The severity of this error
  public var severity: ErrorHandlingInterfaces.ErrorSeverity {
    switch wrappedError {
      case .encryptionFailed, .decryptionFailed, .hashVerificationFailed:
        return .error
      case .keyGenerationFailed, .invalidKey:
        return .error
      case .randomGenerationFailed:
        return .warning
      case .invalidInput:
        return .warning
      case .storageOperationFailed:
        return .error
      case .timeout:
        return .warning
      case .serviceError:
        return .error
      case .internalError:
        return .critical
      case .notImplemented:
        return .error
      @unknown default:
        return .error
    }
  }
  
  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    context.source.isEmpty ? nil : ErrorHandlingInterfaces.ErrorSource(file: context.source)
  }
  
  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    context.underlyingError
  }

  /// Create a new error with the given context
  public func with(context: ErrorHandlingInterfaces.ErrorContext) -> SecurityCoreErrorWrapper {
    var copy = self
    copy.context = context
    return copy
  }

  /// Create a new error with the given source
  public func with(source: ErrorHandlingInterfaces.ErrorSource) -> SecurityCoreErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: source.file,
        operation: context.operation,
        details: context.details,
        underlyingError: context.underlyingError
      )
    )
  }
  
  /// Create a new error with the given underlying error
  public func with(underlyingError: Error) -> SecurityCoreErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: context.source,
        operation: context.operation,
        details: context.details,
        underlyingError: underlyingError
      )
    )
  }

  /// Create a new error with the given operation
  public func with(operation: String) -> SecurityCoreErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: context.source,
        operation: operation,
        details: context.details,
        underlyingError: context.underlyingError
      )
    )
  }
}

/// Wrapper for UmbraErrors.GeneralSecurity.XPC that conforms to UmbraError
public struct SecurityXPCErrorWrapper: UmbraError, CustomStringConvertible {
  public private(set) var wrappedError: UmbraErrors.GeneralSecurity.XPC
  public private(set) var context: ErrorHandlingInterfaces.ErrorContext = .empty()

  public init(_ error: UmbraErrors.GeneralSecurity.XPC) {
    wrappedError = error
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
        return "XPC connection failed: \(reason)"
      case .serviceUnavailable:
        return "XPC service is unavailable"
      case let .invalidResponse(reason):
        return "Invalid XPC response: \(reason)"
      case let .unexpectedSelector(name):
        return "Unexpected XPC selector: \(name)"
      case let .versionMismatch(expected, found):
        return "XPC version mismatch: expected \(expected), found \(found)"
      case .invalidServiceIdentifier:
        return "Invalid XPC service identifier"
      case let .internalError(reason):
        return "Internal XPC error: \(reason)"
      @unknown default:
        return "Unknown XPC error"
    }
  }
  
  public var description: String {
    "SecurityXPCError: \(errorDescription)"
  }

  /// A suggestion for how to recover from the error
  public var recoverySuggestion: String? {
    switch wrappedError {
      case .connectionFailed:
        return "Check that the XPC service is running and accessible."
      case .serviceUnavailable:
        return "The service may be temporarily unavailable. Try again later."
      case .invalidResponse:
        return "Contact support if the problem persists."
      case .unexpectedSelector:
        return "This may indicate a version mismatch. Update your software."
      case .versionMismatch:
        return "Update your software to the latest version."
      case .invalidServiceIdentifier:
        return "Check the service identifier and try again."
      case .internalError:
        return "Contact support if the problem persists."
      @unknown default:
        return "Try again or contact support if the problem persists."
    }
  }

  /// The severity of this error
  public var severity: ErrorHandlingInterfaces.ErrorSeverity {
    switch wrappedError {
      case .connectionFailed:
        return .warning
      case .serviceUnavailable:
        return .warning
      case .invalidResponse:
        return .error
      case .unexpectedSelector:
        return .error
      case .versionMismatch:
        return .warning
      case .invalidServiceIdentifier:
        return .critical
      case .internalError:
        return .critical
      @unknown default:
        return .error
    }
  }
  
  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    context.source.isEmpty ? nil : ErrorHandlingInterfaces.ErrorSource(file: context.source)
  }
  
  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    context.underlyingError
  }

  /// Create a new error with the given context
  public func with(context: ErrorHandlingInterfaces.ErrorContext) -> SecurityXPCErrorWrapper {
    var copy = self
    copy.context = context
    return copy
  }

  /// Create a new error with the given source
  public func with(source: ErrorHandlingInterfaces.ErrorSource) -> SecurityXPCErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: source.file,
        operation: context.operation,
        details: context.details,
        underlyingError: context.underlyingError
      )
    )
  }
  
  /// Create a new error with the given underlying error
  public func with(underlyingError: Error) -> SecurityXPCErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: context.source,
        operation: context.operation,
        details: context.details,
        underlyingError: underlyingError
      )
    )
  }
}

/// Wrapper for UmbraErrors.Security.Protocols that conforms to UmbraError
public struct SecurityProtocolsErrorWrapper: UmbraError, CustomStringConvertible {
  public private(set) var wrappedError: UmbraErrors.Security.Protocols
  public private(set) var context: ErrorHandlingInterfaces.ErrorContext = .empty()

  public init(_ error: UmbraErrors.Security.Protocols) {
    wrappedError = error
  }

  /// The domain that this error belongs to
  public var domain: String {
    "Security.Protocols"
  }

  /// A unique code that identifies this error within its domain
  public var code: String {
    switch wrappedError {
      case .missingProtocolImplementation:
        return "MISSING_PROTOCOL_IMPLEMENTATION"
      case .invalidFormat:
        return "INVALID_FORMAT"
      case .unsupportedOperation:
        return "UNSUPPORTED_OPERATION"
      case .incompatibleVersion:
        return "INCOMPATIBLE_VERSION"
      case .invalidState:
        return "INVALID_STATE"
      case .internalError:
        return "INTERNAL_ERROR"
      case .invalidInput:
        return "INVALID_INPUT"
      case .encryptionFailed:
        return "ENCRYPTION_FAILED"
      case .decryptionFailed:
        return "DECRYPTION_FAILED"
      case .randomGenerationFailed:
        return "RANDOM_GENERATION_FAILED"
      case .storageOperationFailed:
        return "STORAGE_OPERATION_FAILED"
      case .serviceError:
        return "SERVICE_ERROR"
      case .notImplemented:
        return "NOT_IMPLEMENTED"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A human-readable description of the error
  public var errorDescription: String {
    switch wrappedError {
      case let .missingProtocolImplementation(protocolName):
        return "Missing protocol implementation: \(protocolName)"
      case let .invalidFormat(reason):
        return "Invalid format: \(reason)"
      case let .unsupportedOperation(name):
        return "Unsupported operation: \(name)"
      case let .incompatibleVersion(version):
        return "Incompatible version: \(version)"
      case let .invalidState(state, expectedState):
        return "Invalid state: \(state), expected: \(expectedState)"
      case let .internalError(reason):
        return "Internal protocol error: \(reason)"
      case let .invalidInput(message):
        return "Invalid input: \(message)"
      case let .encryptionFailed(message):
        return "Encryption failed: \(message)"
      case let .decryptionFailed(message):
        return "Decryption failed: \(message)"
      case let .randomGenerationFailed(message):
        return "Random data generation failed: \(message)"
      case let .storageOperationFailed(message):
        return "Storage operation failed: \(message)"
      case let .serviceError(message):
        return "Service error: \(message)"
      case let .notImplemented(message):
        return "Operation not implemented: \(message)"
      @unknown default:
        return "Unknown protocol error"
    }
  }
  
  public var description: String {
    "SecurityProtocolsError: \(errorDescription)"
  }

  /// A suggestion for how to recover from the error
  public var recoverySuggestion: String? {
    switch wrappedError {
      case .missingProtocolImplementation:
        return "Contact the developer to provide the missing implementation."
      case .invalidFormat:
        return "Check the format of your input and try again."
      case .unsupportedOperation:
        return "This operation is not supported in the current context."
      case .incompatibleVersion:
        return "Update to a compatible version."
      case .invalidState:
        return "Ensure the system is in the correct state before attempting this operation."
      case .internalError:
        return "Contact support if the problem persists."
      case .invalidInput:
        return "Check the format of your input data and try again."
      case .encryptionFailed:
        return "Check that you are using the correct key and that the data is in the expected format."
      case .decryptionFailed:
        return "Check that you are using the correct key and that the data is in the expected format."
      case .randomGenerationFailed:
        return "Try again or check system entropy sources."
      case .storageOperationFailed:
        return "Check storage permissions and available space."
      case .serviceError:
        return "Try again later or contact support if the problem persists."
      case .notImplemented:
        return "Contact support for assistance."
      @unknown default:
        return "Try again or contact support if the problem persists."
    }
  }

  /// The severity of this error
  public var severity: ErrorHandlingInterfaces.ErrorSeverity {
    switch wrappedError {
      case .invalidFormat:
        return .warning
      case .incompatibleVersion:
        return .critical
      case .invalidInput:
        return .warning
      case .encryptionFailed:
        return .error
      case .decryptionFailed:
        return .error
      case .randomGenerationFailed:
        return .warning
      case .storageOperationFailed:
        return .error
      case .serviceError:
        return .error
      case .notImplemented:
        return .error
      default:
        return .error
    }
  }
  
  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    context.source.isEmpty ? nil : ErrorHandlingInterfaces.ErrorSource(file: context.source)
  }
  
  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    context.underlyingError
  }

  /// Create a new error with the given context
  public func with(context: ErrorHandlingInterfaces.ErrorContext) -> SecurityProtocolsErrorWrapper {
    var copy = self
    copy.context = context
    return copy
  }

  /// Create a new error with the given source
  public func with(source: ErrorHandlingInterfaces.ErrorSource) -> SecurityProtocolsErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: source.file,
        operation: context.operation,
        details: context.details,
        underlyingError: context.underlyingError
      )
    )
  }
  
  /// Create a new error with the given underlying error
  public func with(underlyingError: Error) -> SecurityProtocolsErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: context.source,
        operation: context.operation,
        details: context.details,
        underlyingError: underlyingError
      )
    )
  }
  
  /// Create a new error with the given operation
  public func with(operation: String) -> SecurityProtocolsErrorWrapper {
    with(
      context: ErrorHandlingInterfaces.ErrorContext(
        source: context.source,
        operation: operation,
        details: context.details,
        underlyingError: context.underlyingError
      )
    )
  }
}

// MARK: - Error Conversion Extensions

extension Error {
  /// Try to convert this error to a SecurityCoreError
  public var asSecurityCoreError: SecurityCoreErrorWrapper? {
    self as? SecurityCoreErrorWrapper ?? (self as? UmbraErrors.GeneralSecurity.Core)
      .map(SecurityCoreErrorWrapper.init)
  }

  /// Try to convert this error to a SecurityXPCError
  public var asSecurityXPCError: SecurityXPCErrorWrapper? {
    self as? SecurityXPCErrorWrapper ?? (self as? UmbraErrors.GeneralSecurity.XPC)
      .map(SecurityXPCErrorWrapper.init)
  }

  /// Try to convert this error to a SecurityProtocolsError
  public var asSecurityProtocolsError: SecurityProtocolsErrorWrapper? {
    self as? SecurityProtocolsErrorWrapper ?? (self as? UmbraErrors.Security.Protocols)
      .map(SecurityProtocolsErrorWrapper.init)
  }
}

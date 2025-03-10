import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

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
      case .authenticationFailed:
        return "AUTHENTICATION_FAILED"
      case .authorizationFailed:
        return "AUTHORIZATION_FAILED"
      case .insufficientPermissions:
        return "INSUFFICIENT_PERMISSIONS"
      case .encryptionFailed:
        return "ENCRYPTION_FAILED"
      case .decryptionFailed:
        return "DECRYPTION_FAILED"
      case .hashingFailed:
        return "HASHING_FAILED"
      case .signatureInvalid:
        return "SIGNATURE_INVALID"
      case .certificateInvalid:
        return "CERTIFICATE_INVALID"
      case .certificateExpired:
        return "CERTIFICATE_EXPIRED"
      case .policyViolation:
        return "POLICY_VIOLATION"
      case .secureConnectionFailed:
        return "SECURE_CONNECTION_FAILED"
      case .secureStorageFailed:
        return "SECURE_STORAGE_FAILED"
      case .dataIntegrityViolation:
        return "DATA_INTEGRITY_VIOLATION"
      case .internalError:
        return "INTERNAL_ERROR"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A human-readable description of the error
  public var errorDescription: String {
    switch wrappedError {
      case let .authenticationFailed(reason):
        return "Authentication failed: \(reason)"
      case let .authorizationFailed(reason):
        return "Authorization failed: \(reason)"
      case let .insufficientPermissions(resource, requiredPermission):
        return "Insufficient permissions to access \(resource). Required: \(requiredPermission)"
      case let .encryptionFailed(reason):
        return "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        return "Decryption failed: \(reason)"
      case let .hashingFailed(reason):
        return "Hashing operation failed: \(reason)"
      case let .signatureInvalid(reason):
        return "Signature verification failed: \(reason)"
      case let .certificateInvalid(reason):
        return "Certificate is invalid: \(reason)"
      case let .certificateExpired(reason):
        return "Certificate has expired: \(reason)"
      case let .policyViolation(policy, reason):
        return "Security policy violation (\(policy)): \(reason)"
      case let .secureConnectionFailed(reason):
        return "Secure connection failed: \(reason)"
      case let .secureStorageFailed(operation, reason):
        return "Secure storage operation \(operation) failed: \(reason)"
      case let .dataIntegrityViolation(reason):
        return "Data integrity violation detected: \(reason)"
      case let .internalError(message):
        return "Internal security error: \(message)"
      @unknown default:
        return "Unknown security error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingInterfaces.ErrorContext {
    .init(
      source: "SecurityCoreErrorWrapper",
      operation: "Unknown",
      details: nil,
      underlyingError: nil
    )
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
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
      case .invalidMessageFormat:
        return "INVALID_MESSAGE_FORMAT"
      case .serviceError:
        return "SERVICE_ERROR"
      case .timeout:
        return "TIMEOUT"
      case .serviceUnavailable:
        return "SERVICE_UNAVAILABLE"
      case .operationCancelled:
        return "OPERATION_CANCELLED"
      case .insufficientPrivileges:
        return "INSUFFICIENT_PRIVILEGES"
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
        return "Failed to connect to XPC service: \(reason)"
      case let .invalidMessageFormat(reason):
        return "Message format is invalid: \(reason)"
      case let .serviceError(code, reason):
        return "XPC service error (code \(code)): \(reason)"
      case let .timeout(operation, timeoutMs):
        return "XPC operation \(operation) timed out after \(timeoutMs)ms"
      case let .serviceUnavailable(serviceName):
        return "XPC service is not available: \(serviceName)"
      case let .operationCancelled(operation):
        return "XPC operation was cancelled: \(operation)"
      case let .insufficientPrivileges(service, requiredPrivilege):
        return "XPC service \(service) has insufficient privileges: requires \(requiredPrivilege)"
      case let .internalError(message):
        return "Internal XPC error: \(message)"
      @unknown default:
        return "Unknown XPC error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingInterfaces.ErrorContext {
    .init(
      source: "SecurityXPCErrorWrapper",
      operation: "Unknown",
      details: nil,
      underlyingError: nil
    )
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
    self
  }

  /// A textual representation of this instance.
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
      case let .missingProtocolImplementation(protocolName):
        return "Required protocol implementation is missing: \(protocolName)"
      case let .invalidFormat(reason):
        return "Data is in an invalid format: \(reason)"
      case let .unsupportedOperation(name):
        return "The requested operation is not supported: \(name)"
      case let .incompatibleVersion(version):
        return "Protocol version is incompatible: \(version)"
      case let .invalidState(state, expectedState):
        return "Protocol in invalid state: current '\(state)', expected '\(expectedState)'"
      case let .internalError(reason):
        return "Internal error within protocol handling: \(reason)"
      @unknown default:
        return "Unknown protocol security error"
    }
  }

  /// Optional source information about where the error occurred
  public var source: ErrorHandlingInterfaces.ErrorSource? {
    nil
  }

  /// Optional underlying error that caused this error
  public var underlyingError: Error? {
    nil
  }

  /// Additional context information about the error
  public var context: ErrorHandlingInterfaces.ErrorContext {
    .init(
      source: "SecurityProtocolsErrorWrapper",
      operation: "Unknown",
      details: nil,
      underlyingError: nil
    )
  }

  /// Creates a new instance of the error with additional context
  public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
    self
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError _: Error) -> Self {
    self
  }

  /// Creates a new instance of the error with source information
  public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
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

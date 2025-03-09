import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Security {
  /// XPC communication errors in the security domain
  public enum XPC: Error, UmbraError, StandardErrorCapabilities {
    /// Connection to XPC service failed
    case connectionFailed(reason: String)
    
    /// XPC message format is invalid
    case invalidMessageFormat(reason: String)
    
    /// XPC service returned an error
    case serviceError(code: Int, reason: String)
    
    /// XPC communication timed out
    case timeout(operation: String, timeoutMs: Int)
    
    /// XPC service is unavailable
    case serviceUnavailable(serviceName: String)
    
    /// XPC operation was cancelled
    case operationCancelled(operation: String)
    
    /// XPC service has insufficient privileges
    case insufficientPrivileges(service: String, requiredPrivilege: String)
    
    /// XPC error with unspecified cause
    case internalError(String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for security XPC errors
    public var domain: String {
      "Security.XPC"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .connectionFailed:
        return "connection_failed"
      case .invalidMessageFormat:
        return "invalid_message_format"
      case .serviceError:
        return "service_error"
      case .timeout:
        return "timeout"
      case .serviceUnavailable:
        return "service_unavailable"
      case .operationCancelled:
        return "operation_cancelled"
      case .insufficientPrivileges:
        return "insufficient_privileges"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .connectionFailed(reason):
        return "XPC connection failed: \(reason)"
      case let .invalidMessageFormat(reason):
        return "Invalid XPC message format: \(reason)"
      case let .serviceError(code, reason):
        return "XPC service error (\(code)): \(reason)"
      case let .timeout(operation, timeoutMs):
        return "XPC operation '\(operation)' timed out after \(timeoutMs)ms"
      case let .serviceUnavailable(serviceName):
        return "XPC service unavailable: \(serviceName)"
      case let .operationCancelled(operation):
        return "XPC operation cancelled: \(operation)"
      case let .insufficientPrivileges(service, requiredPrivilege):
        return "XPC service '\(service)' has insufficient privileges. Required: \(requiredPrivilege)"
      case let .internalError(message):
        return "Internal XPC error: \(message)"
      }
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "xpc_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .connectionFailed(reason):
        return .connectionFailed(reason: reason)
      case let .invalidMessageFormat(reason):
        return .invalidMessageFormat(reason: reason)
      case let .serviceError(code, reason):
        return .serviceError(code: code, reason: reason)
      case let .timeout(operation, timeoutMs):
        return .timeout(operation: operation, timeoutMs: timeoutMs)
      case let .serviceUnavailable(serviceName):
        return .serviceUnavailable(serviceName: serviceName)
      case let .operationCancelled(operation):
        return .operationCancelled(operation: operation)
      case let .insufficientPrivileges(service, requiredPrivilege):
        return .insufficientPrivileges(service: service, requiredPrivilege: requiredPrivilege)
      case let .internalError(message):
        return .internalError(message)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Security.XPC {
  /// Create a connection failed error
  public static func connectionFailed(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .connectionFailed(reason: reason)
  }
  
  /// Create a service error
  public static func serviceError(
    code: Int,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .serviceError(code: code, reason: reason)
  }
  
  /// Create a timeout error
  public static func timeout(
    operation: String,
    timeoutMs: Int = 30000,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .timeout(operation: operation, timeoutMs: timeoutMs)
  }
}

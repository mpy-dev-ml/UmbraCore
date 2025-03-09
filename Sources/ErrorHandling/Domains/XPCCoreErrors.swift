import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.XPC {
  /// Core XPC communication errors
  public enum Core: Error, UmbraError, StandardErrorCapabilities {
    // Connection errors
    /// Failed to establish XPC connection
    case connectionFailed(serviceName: String, reason: String)
    
    /// XPC connection interrupted
    case connectionInterrupted(serviceName: String)
    
    /// XPC connection invalid
    case invalidConnection(serviceName: String, reason: String)
    
    /// XPC service not available
    case serviceUnavailable(serviceName: String)
    
    // Message errors
    /// Failed to send XPC message
    case messageSendFailed(serviceName: String, reason: String)
    
    /// Failed to receive XPC message
    case messageReceiveFailed(serviceName: String, reason: String)
    
    /// XPC message timeout
    case messageTimeout(serviceName: String, timeoutMs: Int)
    
    /// Invalid XPC message format
    case invalidMessageFormat(serviceName: String, reason: String)
    
    // Serialisation errors
    /// Failed to serialise XPC object
    case serialisationFailed(typeName: String, reason: String)
    
    /// Failed to deserialise XPC object
    case deserialisationFailed(typeName: String, reason: String)
    
    // Security errors
    /// XPC security violation
    case securityViolation(serviceName: String, reason: String)
    
    /// Entitlement missing for XPC service
    case entitlementMissing(serviceName: String, entitlement: String)
    
    // Resource errors
    /// XPC service terminated unexpectedly
    case serviceTerminated(serviceName: String, reason: String?)
    
    /// XPC service crashed
    case serviceCrashed(serviceName: String, exitCode: Int?)
    
    /// Resource limits exceeded
    case resourceLimitsExceeded(serviceName: String, resource: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for XPC core errors
    public var domain: String {
      "XPC.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .connectionFailed:
        return "connection_failed"
      case .connectionInterrupted:
        return "connection_interrupted"
      case .invalidConnection:
        return "invalid_connection"
      case .serviceUnavailable:
        return "service_unavailable"
      case .messageSendFailed:
        return "message_send_failed"
      case .messageReceiveFailed:
        return "message_receive_failed"
      case .messageTimeout:
        return "message_timeout"
      case .invalidMessageFormat:
        return "invalid_message_format"
      case .serialisationFailed:
        return "serialisation_failed"
      case .deserialisationFailed:
        return "deserialisation_failed"
      case .securityViolation:
        return "security_violation"
      case .entitlementMissing:
        return "entitlement_missing"
      case .serviceTerminated:
        return "service_terminated"
      case .serviceCrashed:
        return "service_crashed"
      case .resourceLimitsExceeded:
        return "resource_limits_exceeded"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .connectionFailed(serviceName, reason):
        return "Failed to establish XPC connection to service '\(serviceName)': \(reason)"
      case let .connectionInterrupted(serviceName):
        return "XPC connection to service '\(serviceName)' was interrupted"
      case let .invalidConnection(serviceName, reason):
        return "Invalid XPC connection to service '\(serviceName)': \(reason)"
      case let .serviceUnavailable(serviceName):
        return "XPC service '\(serviceName)' is unavailable"
      case let .messageSendFailed(serviceName, reason):
        return "Failed to send XPC message to service '\(serviceName)': \(reason)"
      case let .messageReceiveFailed(serviceName, reason):
        return "Failed to receive XPC message from service '\(serviceName)': \(reason)"
      case let .messageTimeout(serviceName, timeoutMs):
        return "XPC message timeout after \(timeoutMs)ms for service '\(serviceName)'"
      case let .invalidMessageFormat(serviceName, reason):
        return "Invalid XPC message format for service '\(serviceName)': \(reason)"
      case let .serialisationFailed(typeName, reason):
        return "Failed to serialise object of type '\(typeName)' for XPC transport: \(reason)"
      case let .deserialisationFailed(typeName, reason):
        return "Failed to deserialise object of type '\(typeName)' from XPC transport: \(reason)"
      case let .securityViolation(serviceName, reason):
        return "XPC security violation with service '\(serviceName)': \(reason)"
      case let .entitlementMissing(serviceName, entitlement):
        return "Missing entitlement '\(entitlement)' required for XPC service '\(serviceName)'"
      case let .serviceTerminated(serviceName, reason):
        if let reason = reason {
          return "XPC service '\(serviceName)' terminated unexpectedly: \(reason)"
        } else {
          return "XPC service '\(serviceName)' terminated unexpectedly"
        }
      case let .serviceCrashed(serviceName, exitCode):
        if let code = exitCode {
          return "XPC service '\(serviceName)' crashed with exit code \(code)"
        } else {
          return "XPC service '\(serviceName)' crashed"
        }
      case let .resourceLimitsExceeded(serviceName, resource):
        return "Resource limits exceeded for XPC service '\(serviceName)': \(resource)"
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
      case let .connectionFailed(serviceName, reason):
        return .connectionFailed(serviceName: serviceName, reason: reason)
      case let .connectionInterrupted(serviceName):
        return .connectionInterrupted(serviceName: serviceName)
      case let .invalidConnection(serviceName, reason):
        return .invalidConnection(serviceName: serviceName, reason: reason)
      case let .serviceUnavailable(serviceName):
        return .serviceUnavailable(serviceName: serviceName)
      case let .messageSendFailed(serviceName, reason):
        return .messageSendFailed(serviceName: serviceName, reason: reason)
      case let .messageReceiveFailed(serviceName, reason):
        return .messageReceiveFailed(serviceName: serviceName, reason: reason)
      case let .messageTimeout(serviceName, timeoutMs):
        return .messageTimeout(serviceName: serviceName, timeoutMs: timeoutMs)
      case let .invalidMessageFormat(serviceName, reason):
        return .invalidMessageFormat(serviceName: serviceName, reason: reason)
      case let .serialisationFailed(typeName, reason):
        return .serialisationFailed(typeName: typeName, reason: reason)
      case let .deserialisationFailed(typeName, reason):
        return .deserialisationFailed(typeName: typeName, reason: reason)
      case let .securityViolation(serviceName, reason):
        return .securityViolation(serviceName: serviceName, reason: reason)
      case let .entitlementMissing(serviceName, entitlement):
        return .entitlementMissing(serviceName: serviceName, entitlement: entitlement)
      case let .serviceTerminated(serviceName, reason):
        return .serviceTerminated(serviceName: serviceName, reason: reason)
      case let .serviceCrashed(serviceName, exitCode):
        return .serviceCrashed(serviceName: serviceName, exitCode: exitCode)
      case let .resourceLimitsExceeded(serviceName, resource):
        return .resourceLimitsExceeded(serviceName: serviceName, resource: resource)
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

extension UmbraErrors.XPC.Core {
  /// Create an error for a failed XPC connection
  public static func connectionFailed(
    serviceName: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .connectionFailed(serviceName: serviceName, reason: reason)
  }
  
  /// Create an error for an unavailable XPC service
  public static func serviceUnavailable(
    serviceName: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .serviceUnavailable(serviceName: serviceName)
  }
  
  /// Create an error for a failed XPC message send
  public static func messageSendFailed(
    serviceName: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .messageSendFailed(serviceName: serviceName, reason: reason)
  }
  
  /// Create an error for an XPC message timeout
  public static func timeout(
    serviceName: String,
    timeoutMs: Int,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .messageTimeout(serviceName: serviceName, timeoutMs: timeoutMs)
  }
  
  /// Create an error for a security violation
  public static func securityViolation(
    serviceName: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .securityViolation(serviceName: serviceName, reason: reason)
  }
}

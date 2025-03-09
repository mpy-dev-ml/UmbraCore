import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Security {
  /// Protocol implementation errors in the security domain
  public enum Protocols: Error, UmbraError, StandardErrorCapabilities {
    /// A required protocol implementation is missing
    case missingProtocolImplementation(protocolName: String)
    
    /// Data is in an invalid format for the protocol
    case invalidFormat(reason: String)
    
    /// The requested operation is not supported by this protocol
    case unsupportedOperation(name: String)
    
    /// The protocol version is incompatible
    case incompatibleVersion(version: String)
    
    /// The protocol is in an invalid state for the requested operation
    case invalidState(state: String, expectedState: String)
    
    /// An unspecified internal error occurred within the protocol implementation
    case internalError(String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for security protocol errors
    public var domain: String {
      "Security.Protocols"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .missingProtocolImplementation:
        return "missing_protocol_implementation"
      case .invalidFormat:
        return "invalid_format"
      case .unsupportedOperation:
        return "unsupported_operation"
      case .incompatibleVersion:
        return "incompatible_version"
      case .invalidState:
        return "invalid_state"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .missingProtocolImplementation(protocolName):
        return "Missing protocol implementation: \(protocolName)"
      case let .invalidFormat(reason):
        return "Invalid data format for protocol: \(reason)"
      case let .unsupportedOperation(name):
        return "Operation not supported by protocol: \(name)"
      case let .incompatibleVersion(version):
        return "Incompatible protocol version: \(version)"
      case let .invalidState(state, expectedState):
        return "Invalid protocol state: current '\(state)', expected '\(expectedState)'"
      case let .internalError(message):
        return "Internal protocol error: \(message)"
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
        operation: "protocol_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .missingProtocolImplementation(protocolName):
        return .missingProtocolImplementation(protocolName: protocolName)
      case let .invalidFormat(reason):
        return .invalidFormat(reason: reason)
      case let .unsupportedOperation(name):
        return .unsupportedOperation(name: name)
      case let .incompatibleVersion(version):
        return .incompatibleVersion(version: version)
      case let .invalidState(state, expectedState):
        return .invalidState(state: state, expectedState: expectedState)
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

extension UmbraErrors.Security.Protocols {
  /// Create a missing protocol implementation error
  public static func missingImplementation(
    protocolName: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .missingProtocolImplementation(protocolName: protocolName)
  }
  
  /// Create an invalid format error
  public static func invalidFormat(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .invalidFormat(reason: reason)
  }
  
  /// Create an unsupported operation error
  public static func unsupportedOperation(
    name: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .unsupportedOperation(name: name)
  }
  
  /// Create an invalid state error
  public static func invalidState(
    state: String,
    expectedState: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .invalidState(state: state, expectedState: expectedState)
  }
}

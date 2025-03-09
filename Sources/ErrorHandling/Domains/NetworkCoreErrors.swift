import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Network {
  /// Core network errors related to connections, requests, and responses
  public enum Core: Error, UmbraError, StandardErrorCapabilities, NetworkErrors {
    // Connection errors
    /// Connection to remote service failed
    case connectionFailed(reason: String)
    
    /// Remote host is unreachable
    case hostUnreachable(host: String)
    
    /// Remote service is unavailable
    case serviceUnavailable(service: String, reason: String)
    
    /// Operation timed out waiting for response
    case timeout(operation: String, timeoutMs: Int)
    
    /// Network operation was interrupted
    case interrupted(reason: String)
    
    // Request errors
    /// Request contains invalid parameters or format
    case invalidRequest(reason: String)
    
    /// Request was rejected by the server
    case requestFailed(statusCode: Int, reason: String)
    
    /// Request is too large to process
    case requestTooLarge(sizeBytes: Int, maxSizeBytes: Int)
    
    /// Rate limit has been exceeded
    case rateLimitExceeded(limitPerHour: Int, retryAfterMs: Int)
    
    // Response errors
    /// Response format is invalid or unexpected
    case responseInvalid(reason: String)
    
    /// Response data is corrupted
    case dataCorruption(reason: String)
    
    /// Response data is incomplete
    case incompleteData(reason: String, receivedBytes: Int, expectedBytes: Int)
    
    /// Error during transmission
    case transmissionError(reason: String)
    
    /// Generic network error
    case internalError(reason: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for network core errors
    public var domain: String {
      "Network.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .connectionFailed:
        return "connection_failed"
      case .hostUnreachable:
        return "host_unreachable"
      case .serviceUnavailable:
        return "service_unavailable"
      case .timeout:
        return "timeout"
      case .interrupted:
        return "interrupted"
      case .invalidRequest:
        return "invalid_request"
      case .requestFailed:
        return "request_failed"
      case .requestTooLarge:
        return "request_too_large"
      case .rateLimitExceeded:
        return "rate_limit_exceeded"
      case .responseInvalid:
        return "response_invalid"
      case .dataCorruption:
        return "data_corruption"
      case .incompleteData:
        return "incomplete_data"
      case .transmissionError:
        return "transmission_error"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .connectionFailed(reason):
        return "Connection failed: \(reason)"
      case let .hostUnreachable(host):
        return "Host unreachable: \(host)"
      case let .serviceUnavailable(service, reason):
        return "Service '\(service)' unavailable: \(reason)"
      case let .timeout(operation, timeoutMs):
        return "Operation '\(operation)' timed out after \(timeoutMs)ms"
      case let .interrupted(reason):
        return "Network operation interrupted: \(reason)"
      case let .invalidRequest(reason):
        return "Invalid request: \(reason)"
      case let .requestFailed(statusCode, reason):
        return "Request failed with status code \(statusCode): \(reason)"
      case let .requestTooLarge(sizeBytes, maxSizeBytes):
        return "Request too large: \(sizeBytes) bytes (maximum \(maxSizeBytes) bytes)"
      case let .rateLimitExceeded(limitPerHour, retryAfterMs):
        return "Rate limit exceeded (\(limitPerHour) requests per hour). Retry after \(retryAfterMs)ms"
      case let .responseInvalid(reason):
        return "Invalid response: \(reason)"
      case let .dataCorruption(reason):
        return "Data corruption: \(reason)"
      case let .incompleteData(reason, receivedBytes, expectedBytes):
        return "Incomplete data: \(reason) (received \(receivedBytes) of \(expectedBytes) bytes)"
      case let .transmissionError(reason):
        return "Transmission error: \(reason)"
      case let .internalError(reason):
        return "Internal network error: \(reason)"
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
        operation: "network_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .connectionFailed(reason):
        return .connectionFailed(reason: reason)
      case let .hostUnreachable(host):
        return .hostUnreachable(host: host)
      case let .serviceUnavailable(service, reason):
        return .serviceUnavailable(service: service, reason: reason)
      case let .timeout(operation, timeoutMs):
        return .timeout(operation: operation, timeoutMs: timeoutMs)
      case let .interrupted(reason):
        return .interrupted(reason: reason)
      case let .invalidRequest(reason):
        return .invalidRequest(reason: reason)
      case let .requestFailed(statusCode, reason):
        return .requestFailed(statusCode: statusCode, reason: reason)
      case let .requestTooLarge(sizeBytes, maxSizeBytes):
        return .requestTooLarge(sizeBytes: sizeBytes, maxSizeBytes: maxSizeBytes)
      case let .rateLimitExceeded(limitPerHour, retryAfterMs):
        return .rateLimitExceeded(limitPerHour: limitPerHour, retryAfterMs: retryAfterMs)
      case let .responseInvalid(reason):
        return .responseInvalid(reason: reason)
      case let .dataCorruption(reason):
        return .dataCorruption(reason: reason)
      case let .incompleteData(reason, receivedBytes, expectedBytes):
        return .incompleteData(reason: reason, receivedBytes: receivedBytes, expectedBytes: expectedBytes)
      case let .transmissionError(reason):
        return .transmissionError(reason: reason)
      case let .internalError(reason):
        return .internalError(reason: reason)
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
    
    // MARK: - NetworkErrors Protocol
    
    /// Creates an error for a connection failure
    public static func connectionFailed(reason: String) -> Self {
      .connectionFailed(reason: reason)
    }
    
    /// Creates an error for an unreachable host
    public static func hostUnreachable(host: String) -> Self {
      .hostUnreachable(host: host)
    }
    
    /// Creates an error for a failed request
    public static func requestFailed(statusCode: Int, reason: String) -> Self {
      .requestFailed(statusCode: statusCode, reason: reason)
    }
    
    /// Creates an error for an invalid response
    public static func responseInvalid(reason: String) -> Self {
      .responseInvalid(reason: reason)
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Network.Core {
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
  
  /// Create a data corruption error
  public static func dataCorruption(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .dataCorruption(reason: reason)
  }
  
  /// Create a transmission error
  public static func transmission(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .transmissionError(reason: reason)
  }
}

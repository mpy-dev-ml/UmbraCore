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
          "connection_failed"
        case .hostUnreachable:
          "host_unreachable"
        case .serviceUnavailable:
          "service_unavailable"
        case .timeout:
          "timeout"
        case .interrupted:
          "interrupted"
        case .invalidRequest:
          "invalid_request"
        case .requestFailed:
          "request_failed"
        case .requestTooLarge:
          "request_too_large"
        case .rateLimitExceeded:
          "rate_limit_exceeded"
        case .responseInvalid:
          "response_invalid"
        case .dataCorruption:
          "data_corruption"
        case .incompleteData:
          "incomplete_data"
        case .transmissionError:
          "transmission_error"
        case .internalError:
          "internal_error"
      }
    }

    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
        case let .connectionFailed(reason):
          "Connection failed: \(reason)"
        case let .hostUnreachable(host):
          "Host unreachable: \(host)"
        case let .serviceUnavailable(service, reason):
          "Service '\(service)' unavailable: \(reason)"
        case let .timeout(operation, timeoutMs):
          "Operation '\(operation)' timed out after \(timeoutMs)ms"
        case let .interrupted(reason):
          "Network operation interrupted: \(reason)"
        case let .invalidRequest(reason):
          "Invalid request: \(reason)"
        case let .requestFailed(statusCode, reason):
          "Request failed with status code \(statusCode): \(reason)"
        case let .requestTooLarge(sizeBytes, maxSizeBytes):
          "Request too large: \(sizeBytes) bytes (maximum \(maxSizeBytes) bytes)"
        case let .rateLimitExceeded(limitPerHour, retryAfterMs):
          "Rate limit exceeded (\(limitPerHour) requests per hour). Retry after \(retryAfterMs)ms"
        case let .responseInvalid(reason):
          "Invalid response: \(reason)"
        case let .dataCorruption(reason):
          "Data corruption: \(reason)"
        case let .incompleteData(reason, receivedBytes, expectedBytes):
          "Incomplete data: \(reason) (received \(receivedBytes) of \(expectedBytes) bytes)"
        case let .transmissionError(reason):
          "Transmission error: \(reason)"
        case let .internalError(reason):
          "Internal network error: \(reason)"
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
    public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
        case let .connectionFailed(reason):
          .connectionFailed(reason: reason)
        case let .hostUnreachable(host):
          .hostUnreachable(host: host)
        case let .serviceUnavailable(service, reason):
          .serviceUnavailable(service: service, reason: reason)
        case let .timeout(operation, timeoutMs):
          .timeout(operation: operation, timeoutMs: timeoutMs)
        case let .interrupted(reason):
          .interrupted(reason: reason)
        case let .invalidRequest(reason):
          .invalidRequest(reason: reason)
        case let .requestFailed(statusCode, reason):
          .requestFailed(statusCode: statusCode, reason: reason)
        case let .requestTooLarge(sizeBytes, maxSizeBytes):
          .requestTooLarge(sizeBytes: sizeBytes, maxSizeBytes: maxSizeBytes)
        case let .rateLimitExceeded(limitPerHour, retryAfterMs):
          .rateLimitExceeded(limitPerHour: limitPerHour, retryAfterMs: retryAfterMs)
        case let .responseInvalid(reason):
          .responseInvalid(reason: reason)
        case let .dataCorruption(reason):
          .dataCorruption(reason: reason)
        case let .incompleteData(reason, receivedBytes, expectedBytes):
          .incompleteData(
            reason: reason,
            receivedBytes: receivedBytes,
            expectedBytes: expectedBytes
          )
        case let .transmissionError(reason):
          .transmissionError(reason: reason)
        case let .internalError(reason):
          .internalError(reason: reason)
      }
      // In a real implementation, we would attach the context
    }

    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError _: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }

    /// Creates a new instance of the error with source information
    public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }

    // MARK: - NetworkErrors Protocol

    // Note: Factory methods moved to extension below with 'make' prefix
    // to avoid ambiguity with enum cases and to maintain a consistent pattern
    // across the codebase.

    // Required for protocol conformance - do not remove
    public static func makeConnectionFailed(reason: String) -> Self {
      .connectionFailed(reason: reason)
    }

    public static func makeHostUnreachable(host: String) -> Self {
      .hostUnreachable(host: host)
    }

    /// Creates an error for a failed request
    public static func makeRequestFailed(statusCode: Int, reason: String) -> Self {
      .requestFailed(statusCode: statusCode, reason: reason)
    }

    /// Creates an error for an invalid response
    public static func makeResponseInvalid(reason: String) -> Self {
      .responseInvalid(reason: reason)
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Network.Core {
  /// Create a timeout error
  public static func makeTimeout(
    operation: String,
    timeoutMs: Int=30000,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .timeout(operation: operation, timeoutMs: timeoutMs)
  }

  /// Create a data corruption error
  public static func makeDataCorruption(
    reason: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .dataCorruption(reason: reason)
  }

  /// Create a transmission error
  public static func makeTransmission(
    reason: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .transmissionError(reason: reason)
  }
}

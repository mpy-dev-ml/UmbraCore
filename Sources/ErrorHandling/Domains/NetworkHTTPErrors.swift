import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Network {
  /// HTTP-specific network errors
  public enum HTTP: Error, UmbraError, StandardErrorCapabilities {
    // Client errors (4xx)
    /// 400 Bad Request - The server cannot process the request due to client error
    case badRequest(reason: String)
    
    /// 401 Unauthorised - Authentication required for resource access
    case unauthorised(reason: String)
    
    /// 403 Forbidden - Server refuses to authorise the request
    case forbidden(resource: String, reason: String)
    
    /// 404 Not Found - The requested resource could not be found
    case notFound(resource: String)
    
    /// 405 Method Not Allowed - The request method is not supported for the resource
    case methodNotAllowed(method: String, allowedMethods: [String])
    
    /// 408 Request Timeout - The server timed out waiting for the request
    case requestTimeout(timeoutMs: Int)
    
    /// 409 Conflict - The request conflicts with the current state of the resource
    case conflict(resource: String, reason: String)
    
    /// 413 Payload Too Large - The request entity is larger than the server will process
    case payloadTooLarge(sizeBytes: Int, maxSizeBytes: Int)
    
    /// 429 Too Many Requests - The user has sent too many requests in a given time
    case tooManyRequests(retryAfterMs: Int)
    
    // Server errors (5xx)
    /// 500 Internal Server Error - The server encountered an unexpected condition
    case internalServerError(reason: String)
    
    /// 501 Not Implemented - The server does not support the functionality required
    case notImplemented(feature: String)
    
    /// 502 Bad Gateway - The server received an invalid response from an upstream server
    case badGateway(reason: String)
    
    /// 503 Service Unavailable - The server is not ready to handle the request
    case serviceUnavailable(reason: String, retryAfterMs: Int?)
    
    /// 504 Gateway Timeout - The server did not receive a timely response from an upstream server
    case gatewayTimeout(reason: String)
    
    // Other HTTP errors
    /// SSL/TLS error during HTTPS connection
    case secureConnectionFailed(reason: String)
    
    /// Redirect error or too many redirects
    case redirectError(reason: String, redirectCount: Int)
    
    /// Invalid or malformed HTTP headers
    case invalidHeaders(reason: String)
    
    /// Content type mismatch or unsupported content type
    case contentTypeMismatch(expected: String, received: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for HTTP errors
    public var domain: String {
      "Network.HTTP"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .badRequest:
        return "bad_request"
      case .unauthorised:
        return "unauthorised"
      case .forbidden:
        return "forbidden"
      case .notFound:
        return "not_found"
      case .methodNotAllowed:
        return "method_not_allowed"
      case .requestTimeout:
        return "request_timeout"
      case .conflict:
        return "conflict"
      case .payloadTooLarge:
        return "payload_too_large"
      case .tooManyRequests:
        return "too_many_requests"
      case .internalServerError:
        return "internal_server_error"
      case .notImplemented:
        return "not_implemented"
      case .badGateway:
        return "bad_gateway"
      case .serviceUnavailable:
        return "service_unavailable"
      case .gatewayTimeout:
        return "gateway_timeout"
      case .secureConnectionFailed:
        return "secure_connection_failed"
      case .redirectError:
        return "redirect_error"
      case .invalidHeaders:
        return "invalid_headers"
      case .contentTypeMismatch:
        return "content_type_mismatch"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .badRequest(reason):
        return "Bad request (400): \(reason)"
      case let .unauthorised(reason):
        return "Unauthorised (401): \(reason)"
      case let .forbidden(resource, reason):
        return "Forbidden (403): Access to '\(resource)' is forbidden. \(reason)"
      case let .notFound(resource):
        return "Not found (404): Resource '\(resource)' could not be found"
      case let .methodNotAllowed(method, allowedMethods):
        return "Method not allowed (405): '\(method)' not allowed. Allowed methods: \(allowedMethods.joined(separator: ", "))"
      case let .requestTimeout(timeoutMs):
        return "Request timeout (408): Server timed out after \(timeoutMs)ms"
      case let .conflict(resource, reason):
        return "Conflict (409): Resource '\(resource)' has a conflict. \(reason)"
      case let .payloadTooLarge(sizeBytes, maxSizeBytes):
        return "Payload too large (413): \(sizeBytes) bytes (maximum \(maxSizeBytes) bytes)"
      case let .tooManyRequests(retryAfterMs):
        return "Too many requests (429): Retry after \(retryAfterMs)ms"
      case let .internalServerError(reason):
        return "Internal server error (500): \(reason)"
      case let .notImplemented(feature):
        return "Not implemented (501): '\(feature)' is not implemented"
      case let .badGateway(reason):
        return "Bad gateway (502): \(reason)"
      case let .serviceUnavailable(reason, retryAfterMs):
        let retryText = retryAfterMs.map { " Retry after \($0)ms" } ?? ""
        return "Service unavailable (503): \(reason).\(retryText)"
      case let .gatewayTimeout(reason):
        return "Gateway timeout (504): \(reason)"
      case let .secureConnectionFailed(reason):
        return "Secure connection failed: \(reason)"
      case let .redirectError(reason, redirectCount):
        return "Redirect error: \(reason) (\(redirectCount) redirects)"
      case let .invalidHeaders(reason):
        return "Invalid HTTP headers: \(reason)"
      case let .contentTypeMismatch(expected, received):
        return "Content type mismatch: Expected '\(expected)', received '\(received)'"
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
        operation: "http_request",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .badRequest(reason):
        return .badRequest(reason: reason)
      case let .unauthorised(reason):
        return .unauthorised(reason: reason)
      case let .forbidden(resource, reason):
        return .forbidden(resource: resource, reason: reason)
      case let .notFound(resource):
        return .notFound(resource: resource)
      case let .methodNotAllowed(method, allowedMethods):
        return .methodNotAllowed(method: method, allowedMethods: allowedMethods)
      case let .requestTimeout(timeoutMs):
        return .requestTimeout(timeoutMs: timeoutMs)
      case let .conflict(resource, reason):
        return .conflict(resource: resource, reason: reason)
      case let .payloadTooLarge(sizeBytes, maxSizeBytes):
        return .payloadTooLarge(sizeBytes: sizeBytes, maxSizeBytes: maxSizeBytes)
      case let .tooManyRequests(retryAfterMs):
        return .tooManyRequests(retryAfterMs: retryAfterMs)
      case let .internalServerError(reason):
        return .internalServerError(reason: reason)
      case let .notImplemented(feature):
        return .notImplemented(feature: feature)
      case let .badGateway(reason):
        return .badGateway(reason: reason)
      case let .serviceUnavailable(reason, retryAfterMs):
        return .serviceUnavailable(reason: reason, retryAfterMs: retryAfterMs)
      case let .gatewayTimeout(reason):
        return .gatewayTimeout(reason: reason)
      case let .secureConnectionFailed(reason):
        return .secureConnectionFailed(reason: reason)
      case let .redirectError(reason, redirectCount):
        return .redirectError(reason: reason, redirectCount: redirectCount)
      case let .invalidHeaders(reason):
        return .invalidHeaders(reason: reason)
      case let .contentTypeMismatch(expected, received):
        return .contentTypeMismatch(expected: expected, received: received)
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

extension UmbraErrors.Network.HTTP {
  /// Create an error from HTTP status code
  public static func fromStatusCode(
    _ statusCode: Int,
    reason: String,
    resource: String? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self? {
    switch statusCode {
    case 400:
      return .badRequest(reason: reason)
    case 401:
      return .unauthorised(reason: reason)
    case 403:
      return .forbidden(resource: resource ?? "unknown", reason: reason)
    case 404:
      return .notFound(resource: resource ?? "unknown")
    case 408:
      return .requestTimeout(timeoutMs: 30000) // Default timeout
    case 409:
      return .conflict(resource: resource ?? "unknown", reason: reason)
    case 413:
      return .payloadTooLarge(sizeBytes: 0, maxSizeBytes: 0) // Would need actual size info
    case 429:
      return .tooManyRequests(retryAfterMs: 60000) // Default retry after 1 minute
    case 500:
      return .internalServerError(reason: reason)
    case 501:
      return .notImplemented(feature: reason)
    case 502:
      return .badGateway(reason: reason)
    case 503:
      return .serviceUnavailable(reason: reason, retryAfterMs: nil)
    case 504:
      return .gatewayTimeout(reason: reason)
    default:
      return nil // Not a standard HTTP error we handle
    }
  }
  
  /// Create an error for a not found resource
  public static func notFound(
    resource: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .notFound(resource: resource)
  }
  
  /// Create an unauthorised error
  public static func unauthorised(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .unauthorised(reason: reason)
  }
}

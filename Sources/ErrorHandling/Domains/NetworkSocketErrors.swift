import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Network {
  /// Socket-specific network errors
  public enum Socket: Error, UmbraError, StandardErrorCapabilities {
    // Socket connection errors
    /// Failed to create socket
    case socketCreationFailed(reason: String)
    
    /// Failed to bind socket to address
    case bindFailed(address: String, port: Int, reason: String)
    
    /// Failed to listen on socket
    case listenFailed(reason: String)
    
    /// Failed to accept connection
    case acceptFailed(reason: String)
    
    /// Connection refused by remote host
    case connectionRefused(host: String, port: Int)
    
    /// Socket closed unexpectedly
    case socketClosed(reason: String)
    
    // Socket I/O errors
    /// Failed to read from socket
    case readFailed(reason: String)
    
    /// Failed to write to socket
    case writeFailed(reason: String)
    
    /// Socket operation timed out
    case timeout(operation: String, timeoutMs: Int)
    
    /// Socket address already in use
    case addressInUse(address: String, port: Int)
    
    /// Invalid socket option
    case invalidOption(option: String, reason: String)
    
    /// Socket buffer overflow
    case bufferOverflow(bufferSize: Int)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for socket errors
    public var domain: String {
      "Network.Socket"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .socketCreationFailed:
        return "socket_creation_failed"
      case .bindFailed:
        return "bind_failed"
      case .listenFailed:
        return "listen_failed"
      case .acceptFailed:
        return "accept_failed"
      case .connectionRefused:
        return "connection_refused"
      case .socketClosed:
        return "socket_closed"
      case .readFailed:
        return "read_failed"
      case .writeFailed:
        return "write_failed"
      case .timeout:
        return "timeout"
      case .addressInUse:
        return "address_in_use"
      case .invalidOption:
        return "invalid_option"
      case .bufferOverflow:
        return "buffer_overflow"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .socketCreationFailed(reason):
        return "Failed to create socket: \(reason)"
      case let .bindFailed(address, port, reason):
        return "Failed to bind socket to \(address):\(port): \(reason)"
      case let .listenFailed(reason):
        return "Failed to listen on socket: \(reason)"
      case let .acceptFailed(reason):
        return "Failed to accept connection: \(reason)"
      case let .connectionRefused(host, port):
        return "Connection refused by \(host):\(port)"
      case let .socketClosed(reason):
        return "Socket closed unexpectedly: \(reason)"
      case let .readFailed(reason):
        return "Failed to read from socket: \(reason)"
      case let .writeFailed(reason):
        return "Failed to write to socket: \(reason)"
      case let .timeout(operation, timeoutMs):
        return "Socket operation '\(operation)' timed out after \(timeoutMs)ms"
      case let .addressInUse(address, port):
        return "Socket address \(address):\(port) already in use"
      case let .invalidOption(option, reason):
        return "Invalid socket option '\(option)': \(reason)"
      case let .bufferOverflow(bufferSize):
        return "Socket buffer overflow (buffer size: \(bufferSize) bytes)"
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
        operation: "socket_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .socketCreationFailed(reason):
        return .socketCreationFailed(reason: reason)
      case let .bindFailed(address, port, reason):
        return .bindFailed(address: address, port: port, reason: reason)
      case let .listenFailed(reason):
        return .listenFailed(reason: reason)
      case let .acceptFailed(reason):
        return .acceptFailed(reason: reason)
      case let .connectionRefused(host, port):
        return .connectionRefused(host: host, port: port)
      case let .socketClosed(reason):
        return .socketClosed(reason: reason)
      case let .readFailed(reason):
        return .readFailed(reason: reason)
      case let .writeFailed(reason):
        return .writeFailed(reason: reason)
      case let .timeout(operation, timeoutMs):
        return .timeout(operation: operation, timeoutMs: timeoutMs)
      case let .addressInUse(address, port):
        return .addressInUse(address: address, port: port)
      case let .invalidOption(option, reason):
        return .invalidOption(option: option, reason: reason)
      case let .bufferOverflow(bufferSize):
        return .bufferOverflow(bufferSize: bufferSize)
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

extension UmbraErrors.Network.Socket {
  /// Create a connection refused error
  public static func connectionRefused(
    host: String,
    port: Int,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .connectionRefused(host: host, port: port)
  }
  
  /// Create a socket read error
  public static func readError(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .readFailed(reason: reason)
  }
  
  /// Create a socket write error
  public static func writeError(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .writeFailed(reason: reason)
  }
}

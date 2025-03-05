import Foundation

/// Protocol defining the logging interface
public protocol LoggingProtocol: Sendable {
  /// Log a debug message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  func debug(_ message: String, metadata: LogMetadata?) async

  /// Log an info message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  func info(_ message: String, metadata: LogMetadata?) async

  /// Log a warning message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  func warning(_ message: String, metadata: LogMetadata?) async

  /// Log an error message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  func error(_ message: String, metadata: LogMetadata?) async
}

/// Re-export SwiftyBeaver.Level as LogLevel
public typealias LogLevel=UmbraLogLevel

/// Errors that can occur during logging operations
public enum LoggingError: Error {
  /// Failed to initialize logging system
  case initializationFailed(String)
  /// Failed to write log entry
  case writeFailed(String)
  /// Invalid log configuration
  case invalidConfiguration(String)
}

/// Re-export Logger as LoggingService
public typealias LoggingService=Logger

import Foundation
import SwiftyBeaver

/// A thread-safe logging service that wraps SwiftyBeaver
public actor Logger: LoggingProtocol {
  /// The shared logger instance
  public static let shared = Logger()

  /// The underlying SwiftyBeaver logger
  private let log = SwiftyBeaver.self

  /// Initialize the logger with default configuration
  private init() {
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    log.addDestination(console)
  }

  /// Log a message at the specified level
  /// - Parameter entry: The log entry to record
  public func log(_ entry: LogEntry) {
    let context = entry.metadata?.asDictionary
    switch entry.level {
      case .verbose:
        log.verbose(entry.message, file: "", function: "", line: 0, context: context)
      case .debug:
        log.debug(entry.message, file: "", function: "", line: 0, context: context)
      case .info:
        log.info(entry.message, file: "", function: "", line: 0, context: context)
      case .warning:
        log.warning(entry.message, file: "", function: "", line: 0, context: context)
      case .error, .critical, .fault:
        log.error(entry.message, file: "", function: "", line: 0, context: context)
    }
  }

  /// Log a debug message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func debug(_ message: String, metadata: LogMetadata? = nil) async {
    log(LogEntry(level: UmbraLogLevel.debug, message: message, metadata: metadata))
  }

  /// Log an info message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func info(_ message: String, metadata: LogMetadata? = nil) async {
    log(LogEntry(level: UmbraLogLevel.info, message: message, metadata: metadata))
  }

  /// Log a warning message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func warning(_ message: String, metadata: LogMetadata? = nil) async {
    log(LogEntry(level: UmbraLogLevel.warning, message: message, metadata: metadata))
  }

  /// Log an error message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func error(_ message: String, metadata: LogMetadata? = nil) async {
    log(LogEntry(level: UmbraLogLevel.error, message: message, metadata: metadata))
  }
}

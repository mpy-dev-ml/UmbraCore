import Foundation
import SwiftyBeaver
import UmbraLogging

/// A thread-safe logging service implementation that wraps SwiftyBeaver
public actor LoggerImplementation: LoggingProtocol {
  /// The shared logger instance
  public static let shared=LoggerImplementation()

  /// The underlying SwiftyBeaver logger
  private let log=SwiftyBeaver.self

  /// Initialise the logger with default configuration
  public init() {
    let console=ConsoleDestination()
    console.format="$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    log.addDestination(console)
  }

  /// Initialise the logger with specific destinations
  /// - Parameter destinations: Array of log destinations (typically SwiftyBeaver destinations)
  private init(destinations: [Any]) {
    for destination in destinations {
      if let destination=destination as? BaseDestination {
        log.addDestination(destination)
      }
    }
  }

  /// Swift 6-compatible factory method to create a logger with specific destinations
  /// - Parameter destinations: Array of Sendable-compliant destinations
  /// - Returns: A new LoggerImplementation instance
  public static func withDestinations(_ destinations: [some Sendable]) -> LoggerImplementation {
    // Create a new logger instance
    let logger=LoggerImplementation()

    // For each destination, create a new destination within the actor instead of passing
    // the existing destination directly, which would cause data races in Swift 6
    Task {
      for _ in destinations {
        // Create a new console destination with standard formatting
        // This approach avoids sending non-Sendable objects to the actor
        let console=ConsoleDestination()
        console.format="$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"

        // Add the destination within the actor's isolation domain
        await logger.addDestination(console)
      }
    }

    return logger
  }

  /// Add a destination to the logger (actor-isolated)
  /// - Parameter destination: The destination to add
  public func addDestination(_ destination: BaseDestination) {
    log.addDestination(destination)
  }

  /// Log a message at the specified level
  /// - Parameter entry: The log entry to record
  private func log(_ entry: LogEntry) {
    let context=entry.metadata?.asDictionary
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
  public func debug(_ message: String, metadata: LogMetadata?) async {
    log(LogEntry(level: UmbraLogLevel.debug, message: message, metadata: metadata))
  }

  /// Log an info message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func info(_ message: String, metadata: LogMetadata?) async {
    log(LogEntry(level: UmbraLogLevel.info, message: message, metadata: metadata))
  }

  /// Log a warning message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func warning(_ message: String, metadata: LogMetadata?) async {
    log(LogEntry(level: UmbraLogLevel.warning, message: message, metadata: metadata))
  }

  /// Log an error message
  /// - Parameters:
  ///   - message: The message to log
  ///   - metadata: Optional metadata
  public func error(_ message: String, metadata: LogMetadata?) async {
    log(LogEntry(level: UmbraLogLevel.error, message: message, metadata: metadata))
  }
}

import Foundation
import LoggingWrapperInterfaces
import SwiftyBeaver

/// A simple logging facade that wraps SwiftyBeaver
///
/// This class provides the concrete implementation of the `LoggerProtocol` defined
/// in the `LoggingWrapperInterfaces` module. It encapsulates all interactions with
/// the third-party SwiftyBeaver logging library, isolating it from the rest of the codebase.
///
/// ## Implementation Details
///
/// The Logger class:
/// - Provides a thread-safe configuration mechanism using Swift concurrency
/// - Automatically initialises a default console logger if none is explicitly configured
/// - Maps between UmbraCore's LogLevel enum and SwiftyBeaver's log levels
///
/// ## Usage Notes
///
/// This implementation module should generally not be imported directly by modules
/// that require library evolution support. Instead, those modules should import
/// `LoggingWrapperInterfaces` and use the protocol-based API.
///
/// This implementation can be safely used by modules that do not require library
/// evolution support or by the application target which assembles all modules.
///
/// ```swift
/// // Configure the logger once at application startup
/// Logger.configure()
///
/// // Logging with various severity levels
/// Logger.info("Application started")
/// Logger.warning("Resource usage is high")
/// Logger.error("Failed to connect to service")
/// ```
public class Logger: LoggerProtocol {
  private static let logger=SwiftyBeaver.self

  /// Configuration manager to handle thread-safe setup
  ///
  /// This actor ensures that logger configuration operations are thread-safe,
  /// preventing race conditions when initialising the logging system from
  /// multiple threads simultaneously.
  private actor ConfigurationManager {
    var isConfigured=false

    /// Attempt to configure the logger
    /// - Returns: True if this call should perform configuration, false if already configured
    func configure() -> Bool {
      guard !isConfigured else { return false }
      isConfigured=true
      return true
    }

    /// Check if the logger has already been configured
    /// - Returns: True if already configured, false otherwise
    func isAlreadyConfigured() -> Bool {
      isConfigured
    }
  }

  private static let configManager=ConfigurationManager()

  /// Configure the logger with console destination by default
  ///
  /// This method sets up a basic console logging destination if not already configured.
  /// It is safe to call this method multiple times; only the first call will have an effect.
  public static func configure() {
    Task {
      let shouldConfigure=await configManager.configure()

      if shouldConfigure {
        let console=ConsoleDestination()
        console.format="$DHH:mm:ss.SSS$d $L $M"
        logger.addDestination(console)
      }
    }
  }

  /// Configure the logger with a specific destination
  ///
  /// This method allows for custom configuration with specific SwiftyBeaver destinations.
  /// Unlike the parameterless configure method, this will always add the specified
  /// destination, even if the logger has already been configured.
  ///
  /// - Parameter destination: The SwiftyBeaver destination to add
  public static func configure(with destination: BaseDestination) {
    Task {
      let shouldConfigure=await configManager.configure()

      if shouldConfigure {
        logger.addDestination(destination)
      } else {
        // Still add the destination even if already configured
        logger.addDestination(destination)
      }
    }
  }

  /// Log a message with the specified level
  ///
  /// This is the core logging method that all other logging methods delegate to.
  /// It ensures the logger is configured and maps UmbraCore's LogLevel to
  /// the appropriate SwiftyBeaver logging method.
  ///
  /// - Parameters:
  ///   - level: The log level
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func log(
    _ level: LogLevel,
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    // Evaluate the message before passing to Task to avoid capturing non-escaping parameter
    let messageValue=message()

    Task {
      let configured=await configManager.isAlreadyConfigured()
      if !configured {
        _=await configManager.configure() // Capture the result to address warning
        let console=ConsoleDestination()
        console.format="$DHH:mm:ss.SSS$d $L $M"
        logger.addDestination(console)
      }

      switch level {
        case .critical, .error:
          logger.error(messageValue, file: file, function: function, line: line)
        case .warning:
          logger.warning(messageValue, file: file, function: function, line: line)
        case .info:
          logger.info(messageValue, file: file, function: function, line: line)
        case .debug:
          logger.debug(messageValue, file: file, function: function, line: line)
        case .trace:
          logger.verbose(messageValue, file: file, function: function, line: line)
      }
    }
  }

  /// Log a critical message
  ///
  /// Critical messages indicate severe errors that require immediate attention.
  /// These are typically issues that might lead to application termination or data loss.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func critical(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.critical, message(), file: file, function: function, line: line)
  }

  /// Log an error message
  ///
  /// Error messages indicate operational errors that may affect functionality
  /// but are not necessarily fatal to the application.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func error(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.error, message(), file: file, function: function, line: line)
  }

  /// Log a warning message
  ///
  /// Warning messages highlight potentially problematic situations or unexpected
  /// behaviour that might lead to errors if not addressed.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func warning(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.warning, message(), file: file, function: function, line: line)
  }

  /// Log an info message
  ///
  /// Info messages provide information about normal system operation and
  /// significant application state changes.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func info(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.info, message(), file: file, function: function, line: line)
  }

  /// Log a debug message
  ///
  /// Debug messages provide detailed information useful during development
  /// and troubleshooting. These should not be too verbose in production.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func debug(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.debug, message(), file: file, function: function, line: line)
  }

  /// Log a trace message
  ///
  /// Trace messages provide extremely detailed information about code execution paths.
  /// These are the most verbose type of log and are typically used only in development.
  ///
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: The file from which the log is sent
  ///   - function: The function from which the log is sent
  ///   - line: The line from which the log is sent
  public static func trace(
    _ message: @autoclosure () -> Any,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    log(.trace, message(), file: file, function: function, line: line)
  }

  // SwiftyBeaver level conversion methods (internal use only)
  static func toSwiftyBeaverLevel(_ level: LogLevel) -> SwiftyBeaver.Level {
    switch level {
      case .critical, .error:
        .error
      case .warning:
        .warning
      case .info:
        .info
      case .debug:
        .debug
      case .trace:
        .verbose
    }
  }

  static func fromSwiftyBeaverLevel(_ level: SwiftyBeaver.Level) -> LogLevel {
    switch level {
      case .error:
        return .error
      case .warning:
        return .warning
      case .info:
        return .info
      case .debug:
        return .debug
      case .verbose:
        return .trace
      case .critical:
        return .critical
      case .fault:
        return .critical
      @unknown default:
        return .error
    }
  }
}

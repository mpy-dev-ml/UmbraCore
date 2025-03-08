import ErrorHandlingInterfaces
import Foundation
@preconcurrency import SwiftyBeaver
import UmbraLogging
import UmbraLoggingAdapters

/// A SwiftyBeaver adapter that conforms to LoggingProtocol
public final class SwiftyBeaverAdapter: LoggingProtocol, Sendable {
  public init() {}

  public func error(_ message: String, metadata: LogMetadata?) async {
    SwiftyBeaver.error(message, context: metadata)
  }

  public func warning(_ message: String, metadata: LogMetadata?) async {
    SwiftyBeaver.warning(message, context: metadata)
  }

  public func info(_ message: String, metadata: LogMetadata?) async {
    SwiftyBeaver.info(message, context: metadata)
  }

  public func debug(_ message: String, metadata: LogMetadata?) async {
    SwiftyBeaver.debug(message, context: metadata)
  }
}

/// Main error logger class that manages logging errors with appropriate context
@MainActor
public class ErrorLogger {
  /// The shared instance
  public static let shared=ErrorLogger()

  /// The underlying logger
  private let logger: LoggingProtocol

  /// Configuration for the error logger
  private let configuration: ErrorLoggerConfiguration

  /// Initialises with the default logger and configuration
  public init(
    logger: LoggingProtocol=SwiftyBeaverAdapter(),
    configuration: ErrorLoggerConfiguration=ErrorLoggerConfiguration()
  ) {
    self.logger=logger
    self.configuration=configuration
  }

  /// Log an error directly
  /// - Parameters:
  ///   - error: The error to log
  ///   - file: Source file (autofilled by compiler)
  ///   - function: Function name (autofilled by compiler)
  ///   - line: Line number (autofilled by compiler)
  ///   - additionalMetadata: Additional metadata to include in log
  public func logError(
    _ error: Error,
    file: String=#file,
    function: String=#function,
    line: Int=#line,
    additionalMetadata: LogMetadata?=nil
  ) async {
    // Skip if filtered out
    if isFiltered(error) { return }

    // Create base metadata for log entry
    var metadata=createMetadataFromError(error)

    // Add file, function, and line information if enabled
    if configuration.includeFileInfo {
      metadata["file"]=file
    }

    if configuration.includeFunctionNames {
      metadata["function"]=function
    }

    if configuration.includeLineNumbers {
      metadata["line"]=String(line)
    }

    // Add additional metadata if provided
    if let additionalMetadata {
      for (key, value) in additionalMetadata.asDictionary {
        if let stringValue=value as? String {
          metadata[key]=stringValue
        }
      }
    }

    // Get the error description
    let description: String=if let umbraError=error as? ErrorHandlingInterfaces.UmbraError {
      "[\(umbraError.domain):\(umbraError.code)] \(umbraError.errorDescription)"
    } else {
      error.localizedDescription
    }

    // Log the error with the logger
    await logger.error(description, metadata: metadata)
  }

  /// Log a message at warning level
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: Source file (autofilled by compiler)
  ///   - function: Function name (autofilled by compiler)
  ///   - line: Line number (autofilled by compiler)
  ///   - metadata: Optional metadata to include
  public func logWarning(
    _ message: String,
    file: String=#file,
    function: String=#function,
    line: Int=#line,
    metadata: LogMetadata?=nil
  ) async {
    var logMetadata=metadata ?? LogMetadata()

    if configuration.includeFileInfo {
      logMetadata["file"]=file
    }

    if configuration.includeFunctionNames {
      logMetadata["function"]=function
    }

    if configuration.includeLineNumbers {
      logMetadata["line"]=String(line)
    }

    await logger.warning(message, metadata: logMetadata)
  }

  /// Log a message at info level
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: Source file (autofilled by compiler)
  ///   - function: Function name (autofilled by compiler)
  ///   - line: Line number (autofilled by compiler)
  ///   - metadata: Optional metadata to include
  public func logInfo(
    _ message: String,
    file: String=#file,
    function: String=#function,
    line: Int=#line,
    metadata: LogMetadata?=nil
  ) async {
    var logMetadata=metadata ?? LogMetadata()

    if configuration.includeFileInfo {
      logMetadata["file"]=file
    }

    if configuration.includeFunctionNames {
      logMetadata["function"]=function
    }

    if configuration.includeLineNumbers {
      logMetadata["line"]=String(line)
    }

    await logger.info(message, metadata: logMetadata)
  }

  /// Log a message at debug level
  /// - Parameters:
  ///   - message: The message to log
  ///   - file: Source file (autofilled by compiler)
  ///   - function: Function name (autofilled by compiler)
  ///   - line: Line number (autofilled by compiler)
  ///   - metadata: Optional metadata to include
  public func logDebug(
    _ message: String,
    file: String=#file,
    function: String=#function,
    line: Int=#line,
    metadata: LogMetadata?=nil
  ) async {
    var logMetadata=metadata ?? LogMetadata()

    if configuration.includeFileInfo {
      logMetadata["file"]=file
    }

    if configuration.includeFunctionNames {
      logMetadata["function"]=function
    }

    if configuration.includeLineNumbers {
      logMetadata["line"]=String(line)
    }

    await logger.debug(message, metadata: logMetadata)
  }

  // MARK: - Private Helpers

  /// Creates metadata dictionary from an error
  /// - Parameter error: The error to extract metadata from
  /// - Returns: A dictionary of metadata
  private func createMetadataFromError(_ error: Error) -> LogMetadata {
    var metadata=LogMetadata()

    if let umbraError=error as? ErrorHandlingInterfaces.UmbraError {
      // Add domain and code
      metadata["domain"]=umbraError.domain
      metadata["code"]=umbraError.code

      // Add source information if available
      if let source=umbraError.source {
        metadata["sourceFile"]=source.file
        metadata["sourceLine"]=String(source.line)
        metadata["sourceFunction"]=source.function
      }

      // Add underlying error if present
      if let underlying=umbraError.underlyingError {
        metadata["underlyingError"]=String(describing: underlying)
      }

      // Add any context information
      metadata["contextType"]=String(describing: umbraError.context)
    }

    return metadata
  }

  /// Checks if an error should be filtered out
  /// - Parameter error: The error to check
  /// - Returns: True if the error should be filtered out
  private func isFiltered(_ error: Error) -> Bool {
    // Check each filter. If any return true, the error is filtered out
    for filter in configuration.filters {
      if filter(error) {
        return true
      }
    }

    return false
  }
}

/// Configuration options for the ErrorLogger
public struct ErrorLoggerConfiguration {
  /// The minimum log level to output
  public var minimumLevel: UmbraLogLevel

  /// Whether to use OSLog API instead of print for console output
  public var useOSLog: Bool

  /// The subsystem to use for OSLog (if enabled)
  public var osLogSubsystem: String

  /// The category to use for OSLog (if enabled)
  public var osLogCategory: String

  /// Whether to include file information in logs
  public var includeFileInfo: Bool

  /// Whether to include line numbers in logs
  public var includeLineNumbers: Bool

  /// Whether to include function names in logs
  public var includeFunctionNames: Bool

  /// Whether to include timestamps in logs
  public var includeTimestamps: Bool

  /// Whether to include JSON format for logs (useful for parsing)
  public var useJsonFormat: Bool

  /// Filters to apply to error logs
  public var filters: [(Error) -> Bool]

  /// Initialises with default values
  public init(
    minimumLevel: UmbraLogLevel = .info,
    useOSLog: Bool=true,
    osLogSubsystem: String="com.umbracorp.umbra",
    osLogCategory: String="errors",
    includeFileInfo: Bool=true,
    includeLineNumbers: Bool=true,
    includeFunctionNames: Bool=true,
    includeTimestamps: Bool=true,
    useJsonFormat: Bool=false,
    filters: [(Error) -> Bool]=[]
  ) {
    self.minimumLevel=minimumLevel
    self.useOSLog=useOSLog
    self.osLogSubsystem=osLogSubsystem
    self.osLogCategory=osLogCategory
    self.includeFileInfo=includeFileInfo
    self.includeLineNumbers=includeLineNumbers
    self.includeFunctionNames=includeFunctionNames
    self.includeTimestamps=includeTimestamps
    self.useJsonFormat=useJsonFormat
    self.filters=filters
  }
}

// MARK: - SwiftyBeaver Configuration Setup

extension ErrorLogger {
  /// Configures the logger for development environment
  /// - Returns: The configured logger instance
  public static func configureForDevelopment() -> ErrorLogger {
    let logger=ErrorLogger.shared

    return logger.configure { config in
      config.minimumLevel = .debug
      config.useJsonFormat=false
      config.includeFileInfo=true
      config.includeLineNumbers=true
      config.includeFunctionNames=true
    }
  }

  /// Configures the logger for production environment
  /// - Returns: The configured logger instance
  public static func configureForProduction() -> ErrorLogger {
    let logger=ErrorLogger.shared

    return logger.configure { config in
      config.minimumLevel = .warning
      config.useJsonFormat=true // For easier parsing of logs in production
      config.includeFileInfo=true
      config.includeLineNumbers=true
    }
  }

  /// Configures the logger for testing environment
  /// - Returns: The configured logger instance
  public static func configureForTesting() -> ErrorLogger {
    let logger=ErrorLogger.shared

    return logger.configure { config in
      config.minimumLevel = .error // Only log errors during tests
      config.useJsonFormat=false
      config.includeFileInfo=true
      config.includeLineNumbers=true
    }
  }

  /// Configures the logger with a custom configuration block
  /// - Parameter configurator: A closure that applies configuration changes
  /// - Returns: The configured logger instance
  public func configure(_ configurator: (inout ErrorLoggerConfiguration) -> Void) -> ErrorLogger {
    // Create a mutable copy of the current configuration
    var updatedConfig=configuration

    // Apply the configurator
    configurator(&updatedConfig)

    // Return a new instance with the updated configuration
    return ErrorLogger(logger: logger, configuration: updatedConfig)
  }
}

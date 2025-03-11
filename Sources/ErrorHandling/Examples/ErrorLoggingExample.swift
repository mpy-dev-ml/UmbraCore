import ErrorHandlingInterfaces
import Foundation
import LoggingWrapper

/// Example demonstrating the integrated error severity and logging
enum ErrorLoggingExample {

  /// Configures logging for different environments
  static func configureLogging(environment: Environment) async {
    // Get the shared logger instance
    let logger=ErrorLogger.shared

    // Configure based on environment
    switch environment {
      case .development:
        // Development configuration with detailed logging
        let config=ErrorLoggerConfiguration(
          minimumSeverity: .debug, // Show all but trace logs
          useOSLog: true, // Use OSLog for better console integration
          includeFileInfo: true, // Include source file information
          includeLineNumbers: true, // Include line numbers
          includeFunctionNames: true, // Include function names
          useColourOutput: true, // Use coloured output for better readability
          useJsonFormat: false // Human-readable format for development
        )

        // Apply configuration
        logger.configure(with: config)

      case .testing:
        // Testing configuration with focused logging
        let config=ErrorLoggerConfiguration(
          minimumSeverity: .warning, // Only show warnings and errors
          useOSLog: false, // Direct console output
          includeFileInfo: true, // Include source file information
          includeLineNumbers: true, // Include line numbers
          includeFunctionNames: false, // Omit function names
          useColourOutput: false, // No colour to avoid test output issues
          useJsonFormat: false // Human-readable format
        )

        // Apply configuration
        logger.configure(with: config)

      case .production:
        // Production configuration with minimal console output
        let config=ErrorLoggerConfiguration(
          minimumSeverity: .error, // Only show errors
          useOSLog: true, // Use OSLog for better integration
          includeFileInfo: false, // Omit source file for security
          includeLineNumbers: false, // Omit line numbers
          includeFunctionNames: false, // Omit function names
          useColourOutput: false, // No colour
          useJsonFormat: true, // JSON format for easier parsing
          // Add filters for sensitive information
          filters: [
            // Filter out errors with sensitive data
            { error in
              if
                let umbraError=error as? UmbraError,
                umbraError.domain == "Security"
              {
                // Check if error contains PII or credentials
                return umbraError.metadata?["containsPII"] as? Bool == true
              }
              return false
            }
          ]
        )

        // Apply configuration
        logger.configure(with: config)
    }
  }

  /// Example of logging errors with different severity levels
  static func logExampleErrors() async {
    let logger=ErrorLogger.shared

    // Create example errors
    let criticalError=UmbraErrors.Crypto.Core.encryptionFailed(
      algorithm: "AES-256",
      reason: "Invalid key size"
    ).with(context: ErrorContext(
      source: ErrorSource(file: #file, function: #function, line: #line),
      metadata: ["operation": "encrypt", "userInitiated": true]
    ))

    let warningError=UmbraErrors.Resource.File.fileAlreadyExists(
      path: "/Users/documents/report.pdf"
    ).with(context: ErrorContext(
      source: ErrorSource(file: #file, function: #function, line: #line)
    ))

    let infoError=UmbraErrors.Application.Core.configurationMismatch(
      setting: "theme",
      expected: "dark",
      actual: "light"
    )

    // Log errors with explicit severity levels
    await logger.log(criticalError, severity: .critical)
    await logger.log(warningError, severity: .warning)
    await logger.log(infoError, severity: .info)

    // Use convenience methods
    await logger.logError(criticalError)
    await logger.logWarning("Resource conflict detected")
    await logger.logInfo("Configuration updated")
    await logger.logDebug("Processing file...")
  }

  /// Example of how LoggingWrapper levels map to ErrorSeverity
  static func demonstrateSeverityMapping() {
    // Convert LoggingWrapper levels to ErrorSeverity
    let errorLevel=ErrorSeverity.from(loggingWrapperLevel: .error)
    let warningLevel=ErrorSeverity.from(loggingWrapperLevel: .warning)
    let infoLevel=ErrorSeverity.from(loggingWrapperLevel: .info)
    let debugLevel=ErrorSeverity.from(loggingWrapperLevel: .debug)

    // The trace level doesn't exist in ErrorNotificationLevel
    // Using debug instead as fallback
    let traceLevel=ErrorSeverity.from(loggingWrapperLevel: .debug)

    // For demonstration purposes only - manually convert to appropriate LoggingWrapper levels
    // without using the non-existent toLoggingWrapperLevel method
    let criticalToLW=LoggingWrapper.LogLevel.error // Equivalent to ErrorSeverity.critical
    let errorToLW=LoggingWrapper.LogLevel.error // Equivalent to ErrorSeverity.error
    let warningToLW=LoggingWrapper.LogLevel.warning // Equivalent to ErrorSeverity.warning
    let infoToLW=LoggingWrapper.LogLevel.info // Equivalent to ErrorSeverity.info
    let debugToLW=LoggingWrapper.LogLevel.debug // Equivalent to ErrorSeverity.debug
    let traceToLW=LoggingWrapper.LogLevel.debug // No exact equivalent for ErrorSeverity.trace

    // Convert ErrorSeverity to notification levels
    let criticalNotification=ErrorSeverity.critical.toNotificationLevel()
    let errorNotification=ErrorSeverity.error.toNotificationLevel()
    let warningNotification=ErrorSeverity.warning.toNotificationLevel()

    print("LoggingWrapper to ErrorSeverity mappings:")
    print("LoggingWrapper.error -> \(errorLevel)")
    print("LoggingWrapper.warning -> \(warningLevel)")
    print("LoggingWrapper.info -> \(infoLevel)")
    print("LoggingWrapper.debug -> \(debugLevel)")
    print("LoggingWrapper.trace -> \(traceLevel)")

    print("\nErrorSeverity to LoggingWrapper mappings:")
    print("ErrorSeverity.critical -> \(criticalToLW)")
    print("ErrorSeverity.error -> \(errorToLW)")
    print("ErrorSeverity.warning -> \(warningToLW)")
    print("ErrorSeverity.info -> \(infoToLW)")
    print("ErrorSeverity.debug -> \(debugToLW)")
    print("ErrorSeverity.trace -> \(traceToLW)")

    print("\nErrorSeverity to notification level mappings:")
    print("ErrorSeverity.critical -> \(criticalNotification)")
    print("ErrorSeverity.error -> \(errorNotification)")
    print("ErrorSeverity.warning -> \(warningNotification)")
  }

  /// Environment types for configuration
  enum Environment {
    case development
    case testing
    case production
  }
}

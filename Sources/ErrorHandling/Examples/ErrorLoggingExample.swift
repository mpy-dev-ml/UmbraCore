// ErrorLoggingExample.swift
// Examples of using the improved error logging with SwiftyBeaver integration
//
// This file demonstrates how to use the improved error severity and SwiftyBeaver
// integration for consistent error reporting across the UmbraCore framework.

import Foundation
import SwiftyBeaver
import ErrorHandlingInterfaces

/// Example demonstrating the integrated error severity and SwiftyBeaver logging
struct ErrorLoggingExample {
  
  /// Configures SwiftyBeaver for different environments
  static func configureLogging(environment: Environment) async {
    // Get the shared logger instance
    let logger = ErrorLogger.shared
    
    // Configure based on environment
    switch environment {
    case .development:
      // Development configuration with detailed logging
      let config = ErrorLoggerConfiguration(
        minimumSeverity: .debug,             // Show all but trace logs
        useOSLog: true,                      // Use OSLog for better console integration
        includeFileInfo: true,               // Include source file information
        includeLineNumbers: true,            // Include line numbers
        includeFunctionNames: true,          // Include function names
        useColourOutput: true,               // Use coloured output for better readability
        useJsonFormat: false                 // Human-readable format for development
      )
      
      // Apply configuration
      logger.configure(with: config)
      
    case .testing:
      // Testing configuration with focused logging
      let config = ErrorLoggerConfiguration(
        minimumSeverity: .warning,           // Only show warnings and errors
        useOSLog: false,                     // Direct console output
        includeFileInfo: true,               // Include source file information
        includeLineNumbers: true,            // Include line numbers
        includeFunctionNames: false,         // Omit function names
        useColourOutput: false,              // No colour to avoid test output issues
        useJsonFormat: false                 // Human-readable format
      )
      
      // Apply configuration
      logger.configure(with: config)
      
    case .production:
      // Production configuration with minimal console output
      let config = ErrorLoggerConfiguration(
        minimumSeverity: .error,             // Only show errors
        useOSLog: true,                      // Use OSLog for better integration
        includeFileInfo: false,              // Omit source file for security
        includeLineNumbers: false,           // Omit line numbers
        includeFunctionNames: false,         // Omit function names
        useColourOutput: false,              // No colour
        useJsonFormat: true,                 // JSON format for easier parsing
        // Add filters for sensitive information
        filters: [
          // Filter out errors with sensitive data
          { error in
            if let umbraError = error as? UmbraError,
               umbraError.domain == "Security" {
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
    let logger = ErrorLogger.shared
    
    // Create example errors
    let criticalError = UmbraErrors.Crypto.Core.encryptionFailed(
      algorithm: "AES-256",
      reason: "Invalid key size"
    ).with(context: ErrorContext(
      source: ErrorSource(file: #file, function: #function, line: #line),
      metadata: ["operation": "encrypt", "userInitiated": true]
    ))
    
    let warningError = UmbraErrors.Resource.File.fileAlreadyExists(
      path: "/Users/documents/report.pdf"
    ).with(context: ErrorContext(
      source: ErrorSource(file: #file, function: #function, line: #line)
    ))
    
    let infoError = UmbraErrors.Application.Core.configurationMismatch(
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
  
  /// Example of how SwiftyBeaver levels map to ErrorSeverity
  static func demonstrateSeverityMapping() {
    // Convert SwiftyBeaver levels to ErrorSeverity
    let errorLevel = ErrorSeverity.from(swiftyBeaverLevel: .error)
    let warningLevel = ErrorSeverity.from(swiftyBeaverLevel: .warning)
    let infoLevel = ErrorSeverity.from(swiftyBeaverLevel: .info)
    let debugLevel = ErrorSeverity.from(swiftyBeaverLevel: .debug)
    let verboseLevel = ErrorSeverity.from(swiftyBeaverLevel: .verbose)
    
    // Convert ErrorSeverity to SwiftyBeaver levels
    let criticalToSB = ErrorSeverity.critical.toSwiftyBeaverLevel()
    let errorToSB = ErrorSeverity.error.toSwiftyBeaverLevel()
    let warningToSB = ErrorSeverity.warning.toSwiftyBeaverLevel()
    let infoToSB = ErrorSeverity.info.toSwiftyBeaverLevel()
    let debugToSB = ErrorSeverity.debug.toSwiftyBeaverLevel()
    let traceToSB = ErrorSeverity.trace.toSwiftyBeaverLevel()
    
    // Convert ErrorSeverity to notification levels
    let criticalNotification = ErrorSeverity.critical.toNotificationLevel()
    let errorNotification = ErrorSeverity.error.toNotificationLevel()
    let warningNotification = ErrorSeverity.warning.toNotificationLevel()
    
    print("SwiftyBeaver to ErrorSeverity mappings:")
    print("SwiftyBeaver.error -> \(errorLevel)")
    print("SwiftyBeaver.warning -> \(warningLevel)")
    print("SwiftyBeaver.info -> \(infoLevel)")
    print("SwiftyBeaver.debug -> \(debugLevel)")
    print("SwiftyBeaver.verbose -> \(verboseLevel)")
    
    print("\nErrorSeverity to SwiftyBeaver mappings:")
    print("ErrorSeverity.critical -> \(criticalToSB)")
    print("ErrorSeverity.error -> \(errorToSB)")
    print("ErrorSeverity.warning -> \(warningToSB)")
    print("ErrorSeverity.info -> \(infoToSB)")
    print("ErrorSeverity.debug -> \(debugToSB)")
    print("ErrorSeverity.trace -> \(traceToSB)")
    
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

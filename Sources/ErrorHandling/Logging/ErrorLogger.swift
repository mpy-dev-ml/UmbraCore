// ErrorLogger.swift
// SwiftyBeaver-based error logging for the enhanced error handling system
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import UmbraLogging
import UmbraLoggingAdapters

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
    
    /// Whether to write logs to a file
    public var logToFile: Bool
    
    /// Custom file path for file logging (if nil, uses default)
    public var customFilePath: String?
    
    /// Custom log format string
    public var customFormat: String?
    
    /// Whether to include JSON format for logs (useful for parsing)
    public var useJsonFormat: Bool
    
    /// Filter predicates to determine if an error should be logged
    public var filters: [(UmbraError) -> Bool]
    
    /// Initialises with default values
    public init(
        minimumLevel: UmbraLogLevel = .debug,
        useOSLog: Bool = true,
        osLogSubsystem: String = "com.umbracorp.umbra-core",
        osLogCategory: String = "ErrorHandling",
        logToFile: Bool = false,
        customFilePath: String? = nil,
        customFormat: String? = nil,
        useJsonFormat: Bool = false,
        filters: [(UmbraError) -> Bool] = []
    ) {
        self.minimumLevel = minimumLevel
        self.useOSLog = useOSLog
        self.osLogSubsystem = osLogSubsystem
        self.osLogCategory = osLogCategory
        self.logToFile = logToFile
        self.customFilePath = customFilePath
        self.customFormat = customFormat
        self.useJsonFormat = useJsonFormat
        self.filters = filters
    }
}

/// Provides specialised logging functionality for UmbraErrors
public final class ErrorLogger {
    /// The shared instance
    public static let shared = ErrorLogger()
    
    /// The underlying logger implementation
    private let logger: LoggingProtocol
    
    /// The configuration for this logger
    public var configuration: ErrorLoggerConfiguration
    
    /// Initialises with the default logger and configuration
    public init(
        logger: LoggingProtocol = LoggerImplementation.shared,
        configuration: ErrorLoggerConfiguration = ErrorLoggerConfiguration()
    ) {
        self.logger = logger
        self.configuration = configuration
    }
    
    /// Configures the logger with custom settings
    /// - Parameter configure: A closure that modifies the configuration
    /// - Returns: The configured ErrorLogger instance
    public func configure(_ configure: (inout ErrorLoggerConfiguration) -> Void) -> ErrorLogger {
        var config = configuration
        configure(&config)
        configuration = config
        return self
    }
    
    /// Logs an error at error level
    /// - Parameters:
    ///   - error: The error to log
    ///   - additionalMessage: Optional additional message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func logError<E: UmbraError>(
        _ error: E,
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard shouldLog(error, at: .error) else { return }
        
        let metadata = createMetadata(for: error, file: file, function: function, line: line)
        
        let message: String
        if let additionalMessage = additionalMessage {
            message = "\(additionalMessage): \(error.errorDescription)"
        } else {
            message = error.errorDescription
        }
        
        Task {
            await logger.error(message, metadata: metadata)
        }
    }
    
    /// Logs an error at warning level
    /// - Parameters:
    ///   - error: The error to log
    ///   - additionalMessage: Optional additional message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func logWarning<E: UmbraError>(
        _ error: E,
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard shouldLog(error, at: .warning) else { return }
        
        let metadata = createMetadata(for: error, file: file, function: function, line: line)
        
        let message: String
        if let additionalMessage = additionalMessage {
            message = "\(additionalMessage): \(error.errorDescription)"
        } else {
            message = error.errorDescription
        }
        
        Task {
            await logger.warning(message, metadata: metadata)
        }
    }
    
    /// Logs an error at info level
    /// - Parameters:
    ///   - error: The error to log
    ///   - additionalMessage: Optional additional message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func logInfo<E: UmbraError>(
        _ error: E,
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard shouldLog(error, at: .info) else { return }
        
        let metadata = createMetadata(for: error, file: file, function: function, line: line)
        
        let message: String
        if let additionalMessage = additionalMessage {
            message = "\(additionalMessage): \(error.errorDescription)"
        } else {
            message = error.errorDescription
        }
        
        Task {
            await logger.info(message, metadata: metadata)
        }
    }
    
    /// Logs an error at debug level
    /// - Parameters:
    ///   - error: The error to log
    ///   - additionalMessage: Optional additional message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func logDebug<E: UmbraError>(
        _ error: E,
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard shouldLog(error, at: .debug) else { return }
        
        let metadata = createMetadata(for: error, file: file, function: function, line: line)
        
        let message: String
        if let additionalMessage = additionalMessage {
            message = "\(additionalMessage): \(error.errorDescription)"
        } else {
            message = error.errorDescription
        }
        
        Task {
            await logger.debug(message, metadata: metadata)
        }
    }
    
    /// Determines if an error should be logged based on level and filters
    /// - Parameters:
    ///   - error: The error to check
    ///   - level: The log level
    /// - Returns: True if the error should be logged
    private func shouldLog<E: UmbraError>(_ error: E, at level: UmbraLogLevel) -> Bool {
        // Check minimum log level
        guard level.rawValue >= configuration.minimumLevel.rawValue else {
            return false
        }
        
        // Apply filters if any
        if !configuration.filters.isEmpty {
            return configuration.filters.allSatisfy { filter in filter(error) }
        }
        
        return true
    }
    
    /// Creates log metadata from an error
    /// - Parameters:
    ///   - error: The error to create metadata for
    ///   - file: Source file
    ///   - function: Function name
    ///   - line: Line number
    /// - Returns: LogMetadata for the error
    private func createMetadata<E: UmbraError>(
        for error: E,
        file: String,
        function: String,
        line: Int
    ) -> LogMetadata {
        var metadata = LogMetadata()
        
        // Add error details
        metadata.set(string: error.domain, forKey: "error.domain")
        metadata.set(string: error.code, forKey: "error.code")
        
        // Add source information from the error or the calling site
        if let source = error.source {
            metadata.set(string: source.file, forKey: "error.source.file")
            metadata.set(string: String(source.line), forKey: "error.source.line")
            metadata.set(string: source.function, forKey: "error.source.function")
        } else {
            metadata.set(string: file, forKey: "error.source.file")
            metadata.set(string: String(line), forKey: "error.source.line")
            metadata.set(string: function, forKey: "error.source.function")
        }
        
        // Add context information
        let context = error.context
        metadata.set(string: context.source, forKey: "error.context.source")
        if let code = context.code {
            metadata.set(string: code, forKey: "error.context.code")
        }
        
        // Add all context metadata
        for (key, value) in context.metadata {
            metadata.set(string: String(describing: value), forKey: "error.context.\(key)")
        }
        
        // Add underlying error if present
        if let underlyingError = error.underlyingError {
            metadata.set(string: String(describing: type(of: underlyingError)), forKey: "error.underlying.type")
            metadata.set(string: underlyingError.localizedDescription, forKey: "error.underlying.description")
        }
        
        return metadata
    }
}

// MARK: - SwiftyBeaver Configuration Setup

extension ErrorLogger {
    /// Sets up a logger with optimal SwiftyBeaver configuration
    /// - Returns: A configured ErrorLogger
    public static func setupOptimalLogger() -> ErrorLogger {
        let logger = ErrorLogger.shared
        
        return logger.configure { config in
            // Use OSLog in Xcode 15 for better console output
            config.useOSLog = true
            config.osLogSubsystem = "com.umbracorp.umbra-core"
            config.osLogCategory = "ErrorHandling"
            
            // Set minimum level to info for release builds
            #if DEBUG
            config.minimumLevel = .debug
            #else
            config.minimumLevel = .info
            #endif
            
            // Add file logging in release builds
            #if !DEBUG
            config.logToFile = true
            #endif
            
            // Add a filter to exclude certain domains if needed
            config.filters = [
                { error in
                    // Example: don't log certain domains in verbose mode
                    if config.minimumLevel == .debug && error.domain == "NetworkRequests" {
                        return false
                    }
                    return true
                }
            ]
        }
    }
    
    /// Sets up a logger optimised for development
    /// - Returns: A configured ErrorLogger
    public static func setupDevelopmentLogger() -> ErrorLogger {
        let logger = ErrorLogger.shared
        
        return logger.configure { config in
            config.minimumLevel = .debug
            config.useOSLog = true
            config.customFormat = "$DHH:mm:ss.SSS$d [$L] $C$M$c" // Timestamp, level, colored message
        }
    }
    
    /// Sets up a logger optimised for production
    /// - Returns: A configured ErrorLogger
    public static func setupProductionLogger() -> ErrorLogger {
        let logger = ErrorLogger.shared
        
        return logger.configure { config in
            config.minimumLevel = .warning
            config.logToFile = true
            config.useJsonFormat = true // For easier parsing of logs in production
            
            // Only log Critical and Error in production
            config.filters = [
                { error in
                    return error.domain != "Analytics" // Example: filter out analytics errors
                }
            ]
        }
    }
    
    /// Sets up a logger optimised for testing
    /// - Returns: A configured ErrorLogger
    public static func setupTestingLogger() -> ErrorLogger {
        let logger = ErrorLogger.shared
        
        return logger.configure { config in
            config.minimumLevel = .error // Only show errors during testing
            config.useOSLog = false
        }
    }
}

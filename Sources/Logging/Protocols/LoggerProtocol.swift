import Foundation
import Logging

/// Protocol for logging services
@preconcurrency public protocol LoggerProtocol: Sendable {
    /// Get current log level
    var logLevel: Logger.Level { get async }
    
    /// Set current log level
    /// - Parameter level: New log level
    func setLogLevel(_ level: Logger.Level) async
    
    /// Log a message with the specified level and metadata
    /// - Parameters:
    ///   - level: Log level
    ///   - message: Log message
    ///   - metadata: Optional metadata
    ///   - file: Source file
    ///   - function: Source function
    ///   - line: Source line
    func log(
        level: Logger.Level,
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: Int
    ) async
    
    /// Log a debug message
    /// - Parameter message: Message to log
    func debug(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
    
    /// Log an info message
    /// - Parameter message: Message to log
    func info(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
    
    /// Log a notice message
    /// - Parameter message: Message to log
    func notice(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
    
    /// Log a warning message
    /// - Parameter message: Message to log
    func warning(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
    
    /// Log an error message
    /// - Parameter message: Message to log
    func error(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
    
    /// Log a critical message
    /// - Parameter message: Message to log
    func critical(_ message: @autoclosure () -> String, metadata: Logger.Metadata?, file: String, function: String, line: Int) async
}

public extension LoggerProtocol {
    func debug(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .debug, message(), metadata: metadata, file: file, function: function, line: line)
    }
    
    func info(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .info, message(), metadata: metadata, file: file, function: function, line: line)
    }
    
    func notice(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .notice, message(), metadata: metadata, file: file, function: function, line: line)
    }
    
    func warning(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .warning, message(), metadata: metadata, file: file, function: function, line: line)
    }
    
    func error(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .error, message(), metadata: metadata, file: file, function: function, line: line)
    }
    
    func critical(
        _ message: @autoclosure () -> String,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        await log(level: .critical, message(), metadata: metadata, file: file, function: function, line: line)
    }
}

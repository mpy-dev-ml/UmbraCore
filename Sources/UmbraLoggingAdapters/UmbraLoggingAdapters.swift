import Foundation
import UmbraLogging

/// Mock implementation of UmbraLoggingAdapters module for testing purposes
/// This satisfies the #if canImport(UmbraLoggingAdapters) check in UmbraLogging.createLogger()
public enum UmbraLoggingAdapters {
    /// Create a logger suitable for testing
    /// - Returns: A test logger that prints to console
    public static func createLogger() -> LoggingProtocol {
        return TestLogger()
    }
    
    /// Create a logger with specific destinations for testing
    /// - Parameter destinations: Array of log destinations (ignored in this mock)
    /// - Returns: A test logger that prints to console
    public static func createLoggerWithDestinations(_ destinations: [Any]) -> LoggingProtocol {
        return TestLogger()
    }
}

/// A simple test logger implementation
final class TestLogger: LoggingProtocol, @unchecked Sendable {
    func debug(_ message: String, metadata: LogMetadata?) async {
        print("[TEST DEBUG] \(message)")
    }
    
    func info(_ message: String, metadata: LogMetadata?) async {
        print("[TEST INFO] \(message)")
    }
    
    func warning(_ message: String, metadata: LogMetadata?) async {
        print("[TEST WARNING] \(message)")
    }
    
    func error(_ message: String, metadata: LogMetadata?) async {
        print("[TEST ERROR] \(message)")
    }
}

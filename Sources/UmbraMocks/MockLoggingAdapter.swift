import Foundation
import UmbraLogging

// This provides a mock implementation of the UmbraLoggingAdapters module
// for use in tests that depend on UmbraLogging
public enum UmbraLoggingAdapters {
    public static func createLogger() -> LoggingProtocol {
        MockLogger()
    }
    
    public static func createLoggerWithDestinations(_: [Any]) -> LoggingProtocol {
        MockLogger()
    }
}

// Mock implementation of LoggingProtocol for testing
private final class MockLogger: LoggingProtocol, @unchecked Sendable {
    func debug(_ message: String, metadata: LogMetadata?) async {
        print("[MOCK DEBUG] \(message)")
    }
    
    func info(_ message: String, metadata: LogMetadata?) async {
        print("[MOCK INFO] \(message)")
    }
    
    func warning(_ message: String, metadata: LogMetadata?) async {
        print("[MOCK WARNING] \(message)")
    }
    
    func error(_ message: String, metadata: LogMetadata?) async {
        print("[MOCK ERROR] \(message)")
    }
}

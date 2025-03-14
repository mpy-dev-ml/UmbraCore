import Foundation
import UmbraLogging

// This mock implementation provides the UmbraLoggingAdapters functionality needed for tests
public enum UmbraLoggingAdapters {
    public static func createLogger() -> LoggingProtocol {
        return MockLogger()
    }
    
    public static func createLoggerWithDestinations(_ destinations: [Any]) -> LoggingProtocol {
        return MockLogger()
    }
}

// Mock implementation of LoggingProtocol for testing
private final class MockLogger: LoggingProtocol {
    func debug(_ message: String, metadata: LogMetadata?) async {
        print("[DEBUG] \(message)")
    }
    
    func info(_ message: String, metadata: LogMetadata?) async {
        print("[INFO] \(message)")
    }
    
    func warning(_ message: String, metadata: LogMetadata?) async {
        print("[WARNING] \(message)")
    }
    
    func error(_ message: String, metadata: LogMetadata?) async {
        print("[ERROR] \(message)")
    }
}

import Foundation
import Testing
import Logging
@testable import UmbraLogging

@Suite("LoggingService Tests")
final class LoggingServiceTests {
    let testLabel = "TestLogger"
    let testSubsystem = "test.subsystem"
    let testCategory = "test"
    
    @Test("Test logging service initialization")
    func testInitialization() async throws {
        let service = await LoggingService(
            label: testLabel,
            subsystem: testSubsystem,
            category: testCategory,
            logLevel: .debug
        )
        
        let level = await service.logLevel
        #expect(level == .debug)
        
        await MainActor.run { [self] in
            #expect(service.currentLogFileURL.lastPathComponent == "\(testLabel).log")
        }
    }
    
    @Test("Test log level changes")
    func testLogLevelChanges() async throws {
        let service = await LoggingService(
            label: testLabel,
            subsystem: testSubsystem,
            category: testCategory,
            logLevel: .debug
        )
        
        var level = await service.logLevel
        #expect(level == .debug)
        
        await service.setLogLevel(.error)
        level = await service.logLevel
        #expect(level == .error)
    }
    
    @Test("Test log file operations")
    func testLogFileOperations() async throws {
        let service = await LoggingService(
            label: testLabel,
            subsystem: testSubsystem,
            category: testCategory,
            logLevel: .debug
        )
        
        // Log some messages
        await service.info("Test message 1")
        await service.error("Test message 2")
        
        // Give some time for async file operations
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Verify log file exists
        await MainActor.run {
            let fileManager = Foundation.FileManager.default
            #expect(fileManager.fileExists(atPath: service.currentLogFileURL.path))
        }
    }
    
    @Test("Test log entry formatting")
    func testLogEntryFormatting() async throws {
        let entry = LogEntry(
            level: .info,
            message: "Test message",
            metadata: ["key": .string("value")],
            file: "test.swift",
            function: "testFunction",
            line: 42
        )
        
        #expect(entry.formattedMessage == "Test message {key=value}")
        #expect(entry.sourceLocation == "test.swift:42 - testFunction")
        
        // Test JSON serialization
        let jsonData = try entry.toJSON()
        let jsonString = try entry.toJSONString()
        
        #expect(!jsonData.isEmpty)
        #expect(!jsonString.isEmpty)
        #expect(jsonString.contains("Test message"))
        #expect(jsonString.contains("key"))
        #expect(jsonString.contains("value"))
    }
}

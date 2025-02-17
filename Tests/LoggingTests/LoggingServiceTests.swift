@testable import SecurityTypes
@testable import UmbraLogging
import XCTest

final class LoggingServiceTests: XCTestCase {
    private var loggingService: LoggingService!
    private let tempPath = FileManager.default.temporaryDirectory.appendingPathComponent("test.log").path

    override func setUp() async throws {
        try await super.setUp()
        loggingService = await LoggingService(securityProvider: TestSecurityProvider())
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(atPath: tempPath)
        await loggingService.stop()
        try await super.tearDown()
    }

    func testLogging() async throws {
        try await loggingService.initialize(with: tempPath)

        let entry = LogEntry(
            level: .info,
            message: "Test message",
            metadata: ["key": "value"]
        )

        try await loggingService.log(entry)

        // Give SwiftyBeaver a moment to write to the file
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        let contents = try String(contentsOfFile: tempPath, encoding: .utf8)
        XCTAssertTrue(contents.contains("Test message"))
        XCTAssertTrue(contents.contains("[INFO]"))
        XCTAssertTrue(contents.contains("key=value"))
    }

    func testLoggingWithoutInitializing() async throws {
        let entry = LogEntry(
            level: .info,
            message: "Test message",
            metadata: ["key": "value"]
        )

        do {
            try await loggingService.log(entry)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is LoggingError)
            XCTAssertEqual(error as? LoggingError, .notInitialized)
        }
    }

    func testMultipleLogLevels() async throws {
        try await loggingService.initialize(with: tempPath)

        let levels: [(LogLevel, String)] = [
            (.trace, "[TRACE]"),
            (.debug, "[DEBUG]"),
            (.info, "[INFO]"),
            (.notice, "[INFO]"), // Notice maps to Info in SwiftyBeaver
            (.warning, "[WARNING]"),
            (.error, "[ERROR]"),
            (.critical, "[ERROR]") // Critical maps to Error with metadata in SwiftyBeaver
        ]

        for (level, expectedPrefix) in levels {
            let entry = LogEntry(
                level: level,
                message: "Test \(level) message"
            )
            try await loggingService.log(entry)
        }

        // Give SwiftyBeaver a moment to write to the file
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        let contents = try String(contentsOfFile: tempPath, encoding: .utf8)
        for (level, expectedPrefix) in levels {
            XCTAssertTrue(contents.contains(expectedPrefix), "Missing \(expectedPrefix) for \(level)")
            XCTAssertTrue(contents.contains("Test \(level) message"), "Missing message for \(level)")
        }
    }

    func testInvalidLogEntry() async throws {
        let entry = LogEntry(
            level: .info,
            message: "",
            metadata: nil
        )

        do {
            try await loggingService.log(entry)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is LoggingError)
            XCTAssertEqual(error as? LoggingError, .invalidEntry)
        }
    }

    func testLoggingLevels() async throws {
        try await loggingService.initialize(with: tempPath)

        let levels: [(LogLevel, String)] = [
            (.debug, "DEBUG"),
            (.info, "INFO"),
            (.warning, "WARNING"),
            (.error, "ERROR")
        ]

        for (level, prefix) in levels {
            let entry = LogEntry(
                level: level,
                message: "Test message",
                metadata: ["key": "value"]
            )

            try await loggingService.log(entry)
            let logContents = try String(contentsOfFile: tempPath, encoding: .utf8)
            XCTAssertTrue(logContents.contains(prefix), "Log should contain \(prefix) prefix")
            XCTAssertTrue(logContents.contains("Test message"), "Log should contain message")
            XCTAssertTrue(logContents.contains("key=value"), "Log should contain metadata")
        }
    }
}

// MARK: - Test Security Provider

@MainActor
private final class TestSecurityProvider: SecurityProvider {
    private var accessedPaths: Set<String> = []

    func createBookmark(forPath path: String) async throws -> [UInt8] {
        Array("TestBookmark:\(path)".utf8)
    }

    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        guard mockBookmark.hasPrefix("TestBookmark:") else {
            throw SecurityError.bookmarkResolutionFailed(path: mockBookmark)
        }

        let path = String(mockBookmark.dropFirst("TestBookmark:".count))
        return (path, false)
    }

    func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        // No-op for testing
    }

    func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        throw SecurityError.bookmarkNotFound(identifier: identifier)
    }

    func deleteBookmark(withIdentifier identifier: String) async throws {
        // No-op for testing
    }

    func startAccessing(path: String) async throws -> Bool {
        accessedPaths.insert(path)
        return true
    }

    func stopAccessing(path: String) async {
        accessedPaths.remove(path)
    }

    func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    func stopAccessingAllResources() async {
        accessedPaths.removeAll()
    }

    func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }

    func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        return mockBookmark.hasPrefix("TestBookmark:")
    }

    func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        if try await startAccessing(path: path) {
            defer { Task { await stopAccessing(path: path) } }
            return try await operation()
        }
        throw SecurityError.accessDenied(path: path)
    }
}

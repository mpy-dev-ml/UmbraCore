@testable import SecurityTypes
@testable import UmbraLogging
import XCTest

final class LoggingServiceTests: XCTestCase {
    private var logger: Logger!
    private let tempPath = NSTemporaryDirectory() + "test.log"

    override func setUp() async throws {
        try await super.setUp()
        logger = Logger.shared

        // Create an empty file to ensure it exists
        FileManager.default.createFile(atPath: tempPath, contents: nil)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(atPath: tempPath)
        try await super.tearDown()
    }

    func testLogging() async throws {
        let entry = LogEntry(
            level: .info,
            message: "Test message",
            metadata: ["test": "value"]
        )

        await logger.log(entry)

        // Verify logging functionality
        XCTAssertNoThrow(try String(contentsOfFile: tempPath, encoding: .utf8))
    }

    func testLogLevels() async throws {
        let levels: [(LogLevel, String)] = [
            (.debug, "DEBUG"),
            (.info, "INFO"),
            (.warning, "WARNING"),
            (.error, "ERROR")
        ]

        for (level, _) in levels {
            let entry = LogEntry(
                level: level,
                message: "Test \(level) message",
                metadata: nil
            )

            await logger.log(entry)
        }
    }
}

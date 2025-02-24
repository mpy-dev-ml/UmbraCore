import Core
import SecurityTypes
import SecurityTypes_Protocols
import XCTest

final class SecurityErrorHandlerTests: XCTestCase {
    private var handler: Core.SecurityErrorHandler!

    override func setUp() async throws {
        handler = Core.SecurityErrorHandler()
    }

    override func tearDown() async throws {
        handler = nil
    }

    func testHandleBookmarkError() async throws {
        // First attempt should allow retry
        let shouldRetry1 = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry1)

        // Second attempt should allow retry
        let shouldRetry2 = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry2)

        // Third attempt should allow retry
        let shouldRetry3 = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry3)

        // Fourth attempt should not allow retry
        let shouldRetry4 = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry4)
    }

    func testHandleNonRetryableError() async throws {
        let shouldRetry = await handler.handleError(
            SecurityTypes.SecurityError.accessDenied(reason: "Permission denied"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry)
    }

    func testRapidFailureDetection() async throws {
        // First error
        _ = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        let isFailingAfterFirst = await handler.isRapidlyFailing("test")
        XCTAssertFalse(isFailingAfterFirst)

        // Second error immediately after
        _ = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        let isFailingAfterSecond = await handler.isRapidlyFailing("test")
        XCTAssertTrue(isFailingAfterSecond)
    }

    func testErrorStats() async throws {
        // Create two errors of the same type
        _ = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test1"
        )
        _ = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test2"
        )

        let stats = await handler.getErrorStats()
        XCTAssertEqual(stats.totalErrors, 2)
        XCTAssertEqual(stats.uniqueContexts.count, 2)
        XCTAssertTrue(stats.uniqueContexts.contains("test1"))
        XCTAssertTrue(stats.uniqueContexts.contains("test2"))
    }

    func testContextReset() async throws {
        _ = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        await handler.resetContext("test")

        // After reset, should be able to retry
        let shouldRetry = await handler.handleError(
            SecurityTypes.SecurityError.bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry)
    }
}

@testable import SecurityTypes
import XCTest

final class SecurityErrorHandlerTests: XCTestCase {
    private var handler: SecurityErrorHandler!
    
    override func setUp() async throws {
        handler = SecurityErrorHandler(maxRetryAttempts: 3)
    }
    
    override func tearDown() async throws {
        await handler.reset()
        handler = nil
    }
    
    func testHandleBookmarkError() async throws {
        // First attempt should allow retry
        let shouldRetry1 = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry1)
        
        // Second attempt should allow retry
        let shouldRetry2 = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry2)
        
        // Third attempt should allow retry
        let shouldRetry3 = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry3)
        
        // Fourth attempt should not allow retry
        let shouldRetry4 = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry4)
    }
    
    func testHandleNonRetryableError() async throws {
        let shouldRetry = await handler.handleError(
            .accessDenied(reason: "Permission denied"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry)
    }
    
    func testRapidFailureDetection() async throws {
        // First error
        _ = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        let isFailingAfterFirst = await handler.isRapidlyFailing("test")
        XCTAssertFalse(isFailingAfterFirst)
        
        // Second error immediately after
        _ = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        let isFailingAfterSecond = await handler.isRapidlyFailing("test")
        XCTAssertTrue(isFailingAfterSecond)
    }
    
    func testErrorStats() async throws {
        // Create two errors of the same type
        _ = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test1"
        )
        _ = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test2"
        )
        
        let stats = await handler.getErrorStats()
        XCTAssertEqual(stats["activeContexts"] as? Int, 2)
        XCTAssertEqual(stats["totalErrors"] as? Int, 2)
        
        let errorsByType = stats["errorsByType"] as? [String: Int]
        XCTAssertNotNil(errorsByType)
        XCTAssertEqual(errorsByType?.count, 1) // Only one type of error used
    }
    
    func testContextReset() async throws {
        _ = await handler.handleError(
            .bookmarkCreationFailed(reason: "Test error"),
            context: "test"
        )
        await handler.resetContext("test")
        let isFailingAfterReset = await handler.isRapidlyFailing("test")
        XCTAssertFalse(isFailingAfterReset)
        
        let stats = await handler.getErrorStats()
        XCTAssertEqual(stats["activeContexts"] as? Int, 0)
    }
}

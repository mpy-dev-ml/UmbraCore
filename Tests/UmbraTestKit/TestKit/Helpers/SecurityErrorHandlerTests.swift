import Core
import ErrorHandling
import SecurityTypes
import SecurityTypesProtocols
import XCTest

/// Error statistics for reporting
public struct ErrorStats {
    public let totalErrors: Int
    public let uniqueContexts: Set<String>
}

/// Test error type for security error handling tests
public enum SecTestError: Error, CustomStringConvertible, Equatable {
    case invalidInput(String)
    case invalidKey(String)
    case cryptoError(String)
    case invalidData(String)
    case accessDenied(reason: String)
    case itemNotFound(String)
    case invalidSecurityState(reason: String)
    
    public var description: String {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidKey(let message):
            return "Invalid key: \(message)"
        case .cryptoError(let message):
            return "Crypto error: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        case .itemNotFound(let message):
            return "Item not found: \(message)"
        case .invalidSecurityState(let reason):
            return "Invalid security state: \(reason)"
        }
    }
}

/// A simple error handler for security errors
public class SecurityErrorHandler {
    private var errorCounts: [String: Int] = [:]
    private var lastErrorTimes: [String: Date] = [:]
    private let maxRetries = 3
    private let rapidFailureThreshold: TimeInterval = 5.0 // seconds

    public init() {}

    public func handleError(_ error: SecTestError, context: String) -> Bool {
        let key = "\(context):\(error)"
        let currentCount = errorCounts[key] ?? 0
        errorCounts[key] = currentCount + 1
        lastErrorTimes[context] = Date()

        // Allow retries for certain errors
        switch error {
        case .invalidInput, .invalidKey:
            return currentCount < maxRetries
        case .cryptoError, .invalidData, .accessDenied, .itemNotFound, .invalidSecurityState:
            return false
        @unknown default:
            return false
        }
    }

    public func resetErrorCounts() {
        errorCounts.removeAll()
        lastErrorTimes.removeAll()
    }

    public func isRapidlyFailing(_ context: String) -> Bool {
        guard let lastTime = lastErrorTimes[context] else {
            return false
        }

        // Check if we've had multiple errors in a short time period
        let errorCount = errorCounts.filter { $0.key.hasPrefix("\(context):") }.values.reduce(0, +)
        let timeSinceLastError = Date().timeIntervalSince(lastTime)

        return errorCount > 1 && timeSinceLastError < rapidFailureThreshold
    }

    public func getErrorStats() -> ErrorStats {
        let totalErrors = errorCounts.values.reduce(0, +)
        let contexts = Set(errorCounts.keys.compactMap { key -> String? in
            let components = key.split(separator: ":")
            return components.first.map { String($0) }
        })

        return ErrorStats(totalErrors: totalErrors, uniqueContexts: contexts)
    }
}

final class SecurityErrorHandlerTests: XCTestCase {
    private var handler: SecurityErrorHandler!

    override func setUp() async throws {
        handler = SecurityErrorHandler()
    }

    override func tearDown() async throws {
        handler = nil
    }

    func testHandleBookmarkError() async throws {
        // First attempt should allow retry
        let shouldRetry1 = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry1)

        // Second attempt should allow retry
        let shouldRetry2 = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry2)

        // Third attempt should allow retry
        let shouldRetry3 = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        XCTAssertTrue(shouldRetry3)

        // Fourth attempt should not allow retry
        let shouldRetry4 = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry4)
    }

    func testHandleNonRetryableError() async throws {
        let shouldRetry = handler.handleError(
            SecTestError.accessDenied(reason: "Permission denied"),
            context: "test"
        )
        XCTAssertFalse(shouldRetry)
    }

    func testRapidFailureDetection() async throws {
        // First error
        _ = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        let isFailingAfterFirst = handler.isRapidlyFailing("test")
        XCTAssertFalse(isFailingAfterFirst)

        // Second error immediately after
        _ = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        let isFailingAfterSecond = handler.isRapidlyFailing("test")
        XCTAssertTrue(isFailingAfterSecond)
    }

    func testErrorStatsTracking() async throws {
        // Create two errors of the same type
        _ = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test1"
        )
        _ = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test2"
        )

        let stats = handler.getErrorStats()
        XCTAssertEqual(stats.totalErrors, 2)
        XCTAssertEqual(stats.uniqueContexts.count, 2)
        XCTAssertTrue(stats.uniqueContexts.contains("test1"))
        XCTAssertTrue(stats.uniqueContexts.contains("test2"))
    }

    func testReset() async throws {
        // Add some errors
        _ = handler.handleError(
            SecTestError.invalidInput("Test error"),
            context: "test"
        )
        _ = handler.handleError(
            SecTestError.cryptoError("Test error"),
            context: "test"
        )

        // Verify they're there
        var stats = handler.getErrorStats()
        XCTAssertEqual(stats.totalErrors, 2)

        // Reset and verify
        handler.resetErrorCounts()
        stats = handler.getErrorStats()
        XCTAssertEqual(stats.totalErrors, 0)
        XCTAssertEqual(stats.uniqueContexts.count, 0)
    }
}

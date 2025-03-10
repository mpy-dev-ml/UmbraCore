import Core
import SecurityInterfaces
import XCTest
import ErrorHandlingDomains

/// Error statistics for reporting
public struct ErrorStats {
  public let totalErrors: Int
  public let uniqueContexts: Set<String>
}

/// A simple error handler for security errors
public class SecurityErrorHandler {
  private var errorCounts: [String: Int]=[:]
  private var lastErrorTimes: [String: Date]=[:]
  private let maxRetries=3
  private let rapidFailureThreshold: TimeInterval=5.0 // seconds

  public init() {}

  public func handleError(_ error: SecurityInterfaces.SecurityError, context: String) -> Bool {
    let key="\(context):\(error)"
    let currentCount=errorCounts[key] ?? 0
    errorCounts[key]=currentCount + 1
    lastErrorTimes[context]=Date()

    // Allow retries for certain errors
    return currentCount < maxRetries
  }

  public func resetErrorCounts() {
    errorCounts.removeAll()
    lastErrorTimes.removeAll()
  }

  public func getErrorStats() -> ErrorStats {
    let totalErrors=errorCounts.values.reduce(0, +)
    let uniqueContexts=Set(errorCounts.keys.compactMap { key -> String? in
      let components=key.split(separator: ":")
      return components.first.map { String($0) }
    })

    return ErrorStats(totalErrors: totalErrors, uniqueContexts: uniqueContexts)
  }

  public func shouldRetryAfterRapidFailures(for context: String) -> Bool {
    guard let lastTime=lastErrorTimes[context] else {
      return true // No previous errors, allow retry
    }

    let timeSinceLast=Date().timeIntervalSince(lastTime)
    return timeSinceLast > rapidFailureThreshold
  }
}

final class SecurityErrorHandlerTests: XCTestCase {
  private var handler: SecurityErrorHandler!

  override func setUp() async throws {
    handler=SecurityErrorHandler()
  }

  override func tearDown() async throws {
    handler=nil
  }

  func testHandleRetryableError() async throws {
    let shouldRetry=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Permission denied"),
      context: "test"
    )
    XCTAssertTrue(shouldRetry, "First occurrence of retryable error should allow retry")
  }

  func testMaxRetries() async throws {
    // First attempt
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Permission denied"),
      context: "test"
    )

    // Second attempt
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Permission denied"),
      context: "test"
    )

    // Third attempt
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Permission denied"),
      context: "test"
    )

    // Fourth attempt should not retry
    let shouldRetry=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Permission denied"),
      context: "test"
    )
    XCTAssertFalse(shouldRetry, "Should not retry after max retries")
  }

  func testErrorStatsTracking() async throws {
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test1"
    )
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test2"
    )

    let stats=handler.getErrorStats()
    XCTAssertEqual(stats.totalErrors, 2)
    XCTAssertEqual(stats.uniqueContexts.count, 2)
    XCTAssertTrue(stats.uniqueContexts.contains("test1"))
    XCTAssertTrue(stats.uniqueContexts.contains("test2"))
  }

  func testRapidFailureThrottling() async throws {
    // First error now
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test"
    )

    // Verify retries are not throttled initially
    XCTAssertTrue(handler.shouldRetryAfterRapidFailures(for: "test"))

    // Simulate rapid failures by not advancing time
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test"
    )

    // Force a time that's within the rapid failure threshold
    handler.resetErrorCounts()
    XCTAssertTrue(handler.shouldRetryAfterRapidFailures(for: "test"))
  }

  func testContextReset() async throws {
    _=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test"
    )

    // Reset counts
    handler.resetErrorCounts()

    // After reset, should be able to retry
    let shouldRetry=handler.handleError(
      SecurityInterfaces.SecurityError.accessError("Test error"),
      context: "test"
    )
    XCTAssertTrue(shouldRetry)
  }
}

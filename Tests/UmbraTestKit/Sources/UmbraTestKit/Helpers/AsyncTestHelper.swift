import Foundation
import XCTest

/// Helper for async testing
public enum AsyncTestHelper {
    /// Wait for an expectation to be fulfilled
    /// - Parameters:
    ///   - timeout: The timeout in seconds
    ///   - description: A description of what we're waiting for
    ///   - block: The block to execute
    /// - Throws: An error if the expectation is not fulfilled
    public static func wait(
        timeout: TimeInterval,
        description: String,
        block: @escaping (XCTestExpectation) -> Void
    ) throws {
        let expectation = XCTestExpectation(description: description)
        block(expectation)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        if result != .completed {
            throw NSError(
                domain: "AsyncTestHelper",
                code: Int(result.rawValue),
                userInfo: [NSLocalizedDescriptionKey: "Failed to fulfill expectation: \(description)"]
            )
        }
    }
    
    /// Wait for a condition to be true
    /// - Parameters:
    ///   - timeout: The timeout in seconds
    ///   - description: A description of what we're waiting for
    ///   - pollingInterval: The interval in seconds between checks
    ///   - condition: The condition to check
    /// - Throws: An error if the condition is not true within the timeout
    public static func waitForCondition(
        timeout: TimeInterval,
        description: String,
        pollingInterval: TimeInterval = 0.1,
        condition: @escaping () -> Bool
    ) throws {
        let startTime = Date()
        
        while !condition() {
            if Date().timeIntervalSince(startTime) > timeout {
                throw NSError(
                    domain: "AsyncTestHelper",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Condition not met within timeout: \(description)"]
                )
            }
            
            Thread.sleep(forTimeInterval: pollingInterval)
        }
    }
    
    /// Execute a block with a timeout
    /// - Parameters:
    ///   - timeout: The timeout in seconds
    ///   - description: A description of what we're executing
    ///   - block: The block to execute
    /// - Throws: An error if the block does not complete within the timeout
    public static func executeWithTimeout<T: Sendable>(
        timeout: TimeInterval,
        description: String,
        block: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await block()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw NSError(
                    domain: "AsyncTestHelper",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Operation timed out: \(description)"]
                )
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

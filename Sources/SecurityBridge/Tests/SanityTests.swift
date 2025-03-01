// SanityTests.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import SecurityBridge
import SecureBytes
import SecurityProtocolsCore
import Foundation

/// Sanity tests that verify basic test functionality with both sync and async testing
final class SanityTests: XCTestCase {
    
    func testSanity() {
        // A basic sync test to verify test setup works
        XCTAssertTrue(true, "This test should always pass")
    }
    
    func testAsyncSanity() async {
        // A basic async test to verify async testing works
        let result = await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                continuation.resume(returning: true)
            }
        }
        XCTAssertTrue(result, "Async test should pass")
    }
    
    // MARK: - Extended Async Tests
    
    func testAsyncWithTimeout() async {
        // Test with short delay
        let result = await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                continuation.resume(returning: true)
            }
        }
        XCTAssertTrue(result, "Short delay async test should pass")
    }
    
    func testMultipleAsyncCalls() async {
        // Run multiple async operations and verify they all complete
        async let result1 = mockAsyncOperation(delay: 0.1, value: 1)
        async let result2 = mockAsyncOperation(delay: 0.2, value: 2)
        async let result3 = mockAsyncOperation(delay: 0.3, value: 3)
        
        let results = await [result1, result2, result3]
        XCTAssertEqual(results, [1, 2, 3], "All async operations should complete")
    }
    
    func testAsyncTaskGroup() async {
        // Test with TaskGroup
        let sum = await withTaskGroup(of: Int.self) { group in
            for i in 1...5 {
                group.addTask {
                    await self.mockAsyncOperation(delay: 0.05, value: i)
                }
            }
            
            var result = 0
            for await value in group {
                result += value
            }
            return result
        }
        
        XCTAssertEqual(sum, 15, "Task group sum should be 15")
    }
    
    func testConcurrentAccess() async {
        // Test concurrent access to shared resources
        let counter = Counter()
        
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...100 {
                group.addTask {
                    await counter.increment()
                }
            }
        }
        
        // Get the value first and then use it in the assertion to avoid await in autoclosure
        let finalValue = await counter.value
        XCTAssertEqual(finalValue, 100, "Counter should be incremented to 100")
    }
    
    // MARK: - Helper Methods
    
    private func mockAsyncOperation(delay: TimeInterval, value: Int) async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                continuation.resume(returning: value)
            }
        }
    }
}

// Helper actor for testing concurrent access
actor Counter {
    private var count = 0
    
    var value: Int {
        count
    }
    
    func increment() {
        count += 1
    }
}

import Foundation
import XCTest
@testable import SecurityTypes

final class MockSecurityProviderTests: XCTestCase {
    var provider: MockSecurityProvider!
    
    override func setUp() async throws {
        provider = MockSecurityProvider()
    }
    
    override func tearDown() async throws {
        await provider.reset()
        provider = nil
    }
    
    // MARK: - Success Tests
    
    func testBookmarkOperations() async throws {
        let testPath = "/test/path.txt"
        
        // Create bookmark
        let bookmarkData = try await provider.createBookmark(forPath: testPath)
        XCTAssertFalse(bookmarkData.isEmpty)
        
        // Save bookmark
        try await provider.saveBookmark(bookmarkData, withIdentifier: "test1")
        
        // Load bookmark
        let loadedData = try await provider.loadBookmark(withIdentifier: "test1")
        XCTAssertEqual(bookmarkData, loadedData)
        
        // Resolve bookmark
        let (resolvedPath, isStale) = try await provider.resolveBookmark(loadedData)
        XCTAssertEqual(resolvedPath, testPath)
        XCTAssertFalse(isStale)
        
        // Delete bookmark
        try await provider.deleteBookmark(withIdentifier: "test1")
        
        // Verify operations were recorded
        let operations = await provider.getRecordedOperations()
        XCTAssertEqual(operations.count, 5)
        XCTAssertEqual(operations.map { $0.type },
                      ["createBookmark", "saveBookmark", "loadBookmark",
                       "resolveBookmark", "deleteBookmark"])
    }
    
    func testResourceAccess() async throws {
        let testPath = "/test/resource.txt"
        
        // Start accessing
        let accessGranted = try await provider.startAccessing(path: testPath)
        XCTAssertTrue(accessGranted)
        
        // Check access
        let isAccessing = await provider.isAccessing(path: testPath)
        XCTAssertTrue(isAccessing)
        
        // Get accessed paths
        let accessedPaths = await provider.getAccessedPaths()
        XCTAssertEqual(accessedPaths, [testPath])
        
        // Stop accessing
        await provider.stopAccessing(path: testPath)
        
        // Verify access stopped
        let isStillAccessing = await provider.isAccessing(path: testPath)
        XCTAssertFalse(isStillAccessing)
    }
    
    func testSecurityScopedAccess() async throws {
        let testPath = "/test/scoped.txt"
        var accessedDuringOperation = false
        
        // Perform operation with scoped access
        let result: String = try await provider.withSecurityScopedAccess(to: testPath) {
            accessedDuringOperation = await provider.isAccessing(path: testPath)
            return "success"
        }
        
        XCTAssertEqual(result, "success")
        XCTAssertTrue(accessedDuringOperation)
        
        // Verify access was stopped after operation
        let isStillAccessing = await provider.isAccessing(path: testPath)
        XCTAssertFalse(isStillAccessing)
    }
    
    // MARK: - Failure Tests
    
    func testSimulatedFailures() async throws {
        // Configure provider to simulate failures
        await provider.updateConfiguration(.init(simulateSuccess: false))
        
        // Test bookmark creation failure
        do {
            _ = try await provider.createBookmark(forPath: "/test/path")
            XCTFail("Expected error not thrown")
        } catch let error as SecurityError {
            XCTAssertEqual(
                error.errorDescription,
                "Failed to create bookmark for '/test/path': Simulated failure"
            )
        }
        
        // Test access failure
        do {
            _ = try await provider.startAccessing(path: "/test/path")
            XCTFail("Expected error not thrown")
        } catch let error as SecurityError {
            XCTAssertEqual(
                error.errorDescription,
                "Failed to start accessing '/test/path': Simulated failure"
            )
        }
    }
    
    func testConcurrentAccessLimit() async throws {
        let configuration = MockSecurityProvider.Configuration(maxConcurrentAccesses: 2)
        await provider.updateConfiguration(configuration)
        
        // Start accessing two resources (should succeed)
        try await provider.startAccessing(path: "/test/path1")
        try await provider.startAccessing(path: "/test/path2")
        
        // Try to access a third resource (should fail)
        do {
            _ = try await provider.startAccessing(path: "/test/path3")
            XCTFail("Expected error not thrown")
        } catch let error as SecurityError {
            XCTAssertEqual(
                error.errorDescription,
                "Too many concurrent resource accesses (current: 2, maximum: 2)"
            )
        }
    }
    
    // MARK: - Configuration Tests
    
    func testOperationDelay() async throws {
        let delayConfiguration = MockSecurityProvider.Configuration(
            operationDelay: 0.1
        )
        await provider.updateConfiguration(delayConfiguration)
        
        let startTime = Date()
        _ = try await provider.createBookmark(forPath: "/test/path")
        let duration = Date().timeIntervalSince(startTime)
        
        XCTAssertGreaterThanOrEqual(duration, 0.1)
    }
    
    func testOperationTracking() async throws {
        // Disable operation tracking
        let configuration = MockSecurityProvider.Configuration(trackOperations: false)
        await provider.updateConfiguration(configuration)
        
        // Perform some operations
        _ = try await provider.createBookmark(forPath: "/test/path")
        try await provider.startAccessing(path: "/test/path")
        await provider.stopAccessing(path: "/test/path")
        
        // Verify no operations were recorded
        let operations = await provider.getRecordedOperations()
        XCTAssertTrue(operations.isEmpty)
    }
}

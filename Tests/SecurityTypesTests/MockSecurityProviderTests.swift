@testable import SecurityTypes
import XCTest

final class MockSecurityProviderTests: XCTestCase {
    var provider: MockSecurityProvider!

    override func setUp() async throws {
        provider = MockSecurityProvider()
    }

    override func tearDown() async throws {
        provider = nil
    }

    func testBookmarkOperations() async throws {
        let path = "/test/path"
        let identifier = "test-bookmark"

        // Create and save bookmark
        let bookmarkData = try await provider.createBookmark(forPath: path)
        try await provider.saveBookmark(bookmarkData, withIdentifier: identifier)

        // Load and validate bookmark
        let loadedData = try await provider.loadBookmark(withIdentifier: identifier)
        XCTAssertEqual(loadedData, bookmarkData)

        // Resolve bookmark
        let (resolvedPath, isStale) = try await provider.resolveBookmark(loadedData)
        XCTAssertEqual(resolvedPath, path)
        XCTAssertFalse(isStale)

        // Delete bookmark
        try await provider.deleteBookmark(withIdentifier: identifier)

        // Verify deletion
        do {
            _ = try await provider.loadBookmark(withIdentifier: identifier)
            XCTFail("Expected bookmarkNotFound error")
        } catch SecurityError.bookmarkNotFound {
            // Expected error
        }
    }

    func testAccessOperations() async throws {
        let path = "/test/path"

        // Start accessing
        let accessGranted = try await provider.startAccessing(path: path)
        XCTAssertTrue(accessGranted)

        // Check access
        let isAccessing = await provider.isAccessing(path: path)
        XCTAssertTrue(isAccessing)

        // Get accessed paths
        let accessedPaths = await provider.getAccessedPaths()
        XCTAssertTrue(accessedPaths.contains(path))

        // Stop accessing
        await provider.stopAccessing(path: path)
        let isStillAccessing = await provider.isAccessing(path: path)
        XCTAssertFalse(isStillAccessing)
    }

    func testWithSecurityScopedAccess() async throws {
        let path = "/test/path"
        var operationExecuted = false

        try await provider.withSecurityScopedAccess(to: path) {
            operationExecuted = true
            let isAccessing = await provider.isAccessing(path: path)
            XCTAssertTrue(isAccessing)
        }

        XCTAssertTrue(operationExecuted)
        let isStillAccessing = await provider.isAccessing(path: path)
        XCTAssertFalse(isStillAccessing)
    }

    func testStopAccessingAllResources() async throws {
        let paths = ["/test/path1", "/test/path2", "/test/path3"]

        // Start accessing multiple paths
        for path in paths {
            _ = try await provider.startAccessing(path: path)
        }

        // Verify all paths are being accessed
        for path in paths {
            let isAccessing = await provider.isAccessing(path: path)
            XCTAssertTrue(isAccessing)
        }

        // Stop accessing all resources
        await provider.stopAccessingAllResources()

        // Verify no paths are being accessed
        for path in paths {
            let isAccessing = await provider.isAccessing(path: path)
            XCTAssertFalse(isAccessing)
        }

        let accessedPaths = await provider.getAccessedPaths()
        XCTAssertTrue(accessedPaths.isEmpty)
    }
}

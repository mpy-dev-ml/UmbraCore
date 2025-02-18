@testable import SecurityTypes
import XCTest

final class MockSecurityProviderTests: XCTestCase {
    var provider: DefaultSecurityProvider!
    var testFileURL: URL!
    var testFileData: String!

    override func setUp() async throws {
        provider = DefaultSecurityProvider()

        // Create test file
        let tempDir = FileManager.default.temporaryDirectory
        testFileURL = tempDir.appendingPathComponent("test_file.txt")
        testFileData = "Test content"
        try testFileData.write(to: testFileURL, atomically: true, encoding: .utf8)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testFileURL)
        await provider.stopAccessingAllResources()
        provider = nil
    }

    func testBookmarkOperations() async throws {
        // Create bookmark
        let bookmarkData = try await provider.createBookmark(forPath: testFileURL.path)
        XCTAssertFalse(bookmarkData.isEmpty)

        // Resolve bookmark
        let (resolvedPath, isStale) = try await provider.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedPath, testFileURL.path)
        XCTAssertFalse(isStale)
    }

    func testSecurityScopedAccess() async throws {
        // Start accessing
        let success = try await provider.startAccessing(path: testFileURL.path)
        XCTAssertTrue(success)

        let isAccessing = await provider.isAccessing(path: testFileURL.path)
        XCTAssertTrue(isAccessing)

        // Stop accessing
        await provider.stopAccessing(path: testFileURL.path)
        let isStopped = await provider.isAccessing(path: testFileURL.path)
        XCTAssertFalse(isStopped)
    }

    func testBookmarkStorage() async throws {
        // Create and save bookmark
        let identifier = "test_bookmark"
        let bookmarkData = try await provider.createBookmark(forPath: testFileURL.path)
        try await provider.saveBookmark(bookmarkData, withIdentifier: identifier)

        // Load bookmark
        let loadedData = try await provider.loadBookmark(withIdentifier: identifier)
        XCTAssertEqual(loadedData, bookmarkData)

        // Delete bookmark
        try await provider.deleteBookmark(withIdentifier: identifier)

        // Verify deletion
        do {
            _ = try await provider.loadBookmark(withIdentifier: identifier)
            XCTFail("Expected error loading deleted bookmark")
        } catch let error as SecurityError {
            XCTAssertEqual(error.localizedDescription, "Bookmark not found: \(identifier)")
        }
    }

    func testStopAccessingAllResources() async throws {
        // Create test files
        let tempDir = FileManager.default.temporaryDirectory
        let testFile1 = tempDir.appendingPathComponent("test1.txt")
        let testFile2 = tempDir.appendingPathComponent("test2.txt")
        try "Test 1".write(to: testFile1, atomically: true, encoding: .utf8)
        try "Test 2".write(to: testFile2, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: testFile1)
            try? FileManager.default.removeItem(at: testFile2)
        }

        // Start accessing both files
        let success1 = try await provider.startAccessing(path: testFile1.path)
        XCTAssertTrue(success1)
        let success2 = try await provider.startAccessing(path: testFile2.path)
        XCTAssertTrue(success2)

        let paths = await provider.getAccessedPaths()
        XCTAssertEqual(paths.count, 2)
        XCTAssertTrue(paths.contains(testFile1.path))
        XCTAssertTrue(paths.contains(testFile2.path))

        // Stop accessing all
        await provider.stopAccessingAllResources()
        let finalPaths = await provider.getAccessedPaths()
        XCTAssertTrue(finalPaths.isEmpty)
    }

    func testWithSecurityScopedAccess() async throws {
        let content = try await provider.withSecurityScopedAccess(to: testFileURL.path) {
            try String(contentsOf: testFileURL, encoding: .utf8)
        }
        XCTAssertEqual(content, testFileData)
    }
}

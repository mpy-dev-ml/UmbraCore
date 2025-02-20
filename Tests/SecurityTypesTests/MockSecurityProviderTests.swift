@testable import SecurityTypes
import XCTest

/// A mock security provider for testing
actor MockSecurityProvider: SecurityProvider {
    private var bookmarks: [String: Data] = [:]
    private var accessCount: [String: Int] = [:]
    private var shouldFailBookmarkCreation = false
    private var shouldFailAccess = false
    private var accessedPaths: Set<String> = []

    func createBookmark(forPath path: String) async throws -> [UInt8] {
        if shouldFailBookmarkCreation {
            throw SecurityError.bookmarkCreationFailed(reason: "Mock failure")
        }
        
        // Create a simple bookmark data
        let bookmarkData = [UInt8](path.utf8)
        bookmarks[path] = Data(bookmarkData)
        return bookmarkData
    }

    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        if shouldFailAccess {
            throw SecurityError.accessDenied(reason: "Access denied")
        }
        
        // Find the path by matching bookmark data
        if let path = bookmarks.first(where: { $0.value == Data(bookmarkData) })?.key {
            accessCount[path, default: 0] += 1
            return (path: path, isStale: false)
        }
        
        throw SecurityError.bookmarkResolutionFailed(reason: "Invalid bookmark data")
    }

    func startAccessing(path: String) async throws -> Bool {
        if shouldFailAccess {
            throw SecurityError.accessDenied(reason: "Mock access denied")
        }
        accessedPaths.insert(path)
        return true
    }

    func stopAccessing(path: String) async {
        accessedPaths.remove(path)
    }

    func stopAccessingAllResources() async {
        accessedPaths.removeAll()
    }

    func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        if shouldFailAccess {
            throw SecurityError.accessDenied(reason: "Access denied to \(path)")
        }
        
        // Check if we have a bookmark for this path
        if bookmarks[path] == nil {
            throw SecurityError.accessDenied(reason: "No bookmark found for \(path)")
        }
        
        accessedPaths.insert(path)
        defer { accessedPaths.remove(path) }
        return try await operation()
    }

    func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        // Check if this bookmark exists in our storage
        return bookmarks.values.contains(Data(bookmarkData))
    }

    func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }

    func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        if shouldFailAccess {
            throw SecurityError.storageError(reason: "Mock storage failure")
        }
        bookmarks[identifier] = Data(bookmarkData)
    }

    func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let bookmark = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found: \(identifier)")
        }
        return Array(bookmark)
    }

    func storeBookmarkData(_ bookmarkData: [UInt8], forPath path: String) async throws {
        if shouldFailAccess {
            throw SecurityError.storageError(reason: "Mock storage failure")
        }
        bookmarks[path] = Data(bookmarkData)
    }

    func getBookmarkData(forPath path: String) async throws -> [UInt8] {
        guard let bookmark = bookmarks[path] else {
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found: \(path)")
        }
        return Array(bookmark)
    }

    func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    func deleteBookmark(withIdentifier identifier: String) async throws {
        if shouldFailAccess {
            throw SecurityError.storageError(reason: "Mock deletion failure")
        }
        bookmarks.removeValue(forKey: identifier)
    }

    // Test helper methods
    func setBookmarkCreationFailure(_ shouldFail: Bool) {
        shouldFailBookmarkCreation = shouldFail
    }

    func setAccessFailure(_ shouldFail: Bool) {
        shouldFailAccess = shouldFail
    }

    func getAccessCount(for path: String) async -> Int {
        accessCount[path] ?? 0
    }
}

@MainActor
final class MockSecurityProviderTests: XCTestCase {
    private var provider: MockSecurityProvider!

    override func setUp() async throws {
        provider = MockSecurityProvider()
    }

    override func tearDown() async throws {
        provider = nil
    }

    func testSuccessfulBookmarkCreation() async throws {
        let testPath = "/test/path"
        let bookmark = try await provider.createBookmark(forPath: testPath)
        XCTAssertFalse(bookmark.isEmpty)

        let (resolvedPath, isStale) = try await provider.resolveBookmark(bookmark)
        XCTAssertEqual(resolvedPath, testPath)
        XCTAssertFalse(isStale)
    }

    func testFailedBookmarkCreation() async throws {
        let testPath = "/test/path"
        await provider.setBookmarkCreationFailure(true)

        do {
            _ = try await provider.createBookmark(forPath: testPath)
            XCTFail("Expected bookmark creation to fail")
        } catch let error as SecurityError {
            XCTAssertEqual(error, SecurityError.bookmarkCreationFailed(reason: "Mock failure"))
        }
    }

    func testFailedAccess() async throws {
        let testPath = "/test/path"
        let bookmark = try await provider.createBookmark(forPath: testPath)

        await provider.setAccessFailure(true)

        do {
            _ = try await provider.resolveBookmark(bookmark)
            XCTFail("Expected access to fail")
        } catch let error as SecurityError {
            XCTAssertEqual(error, SecurityError.accessDenied(reason: "Access denied"))
        }
    }

    func testAccessCounting() async throws {
        let testPath = "/test/path"
        let bookmark = try await provider.createBookmark(forPath: testPath)

        // First access
        _ = try await provider.resolveBookmark(bookmark)
        let count1 = await provider.getAccessCount(for: testPath)
        XCTAssertEqual(count1, 1)

        // Second access
        _ = try await provider.resolveBookmark(bookmark)
        let count2 = await provider.getAccessCount(for: testPath)
        XCTAssertEqual(count2, 2)
    }

    func testSecurityScopedAccess() async throws {
        let testPath = "/test/path"

        // Test starting access
        let success = try await provider.startAccessing(path: testPath)
        XCTAssertTrue(success)

        let isAccessing = await provider.isAccessing(path: testPath)
        XCTAssertTrue(isAccessing)

        // Test stopping access
        await provider.stopAccessing(path: testPath)
        let isStopped = await provider.isAccessing(path: testPath)
        XCTAssertFalse(isStopped)
    }

    func testWithSecurityScopedAccess() async throws {
        let testPath = "/test/path"
        
        // Create and store a bookmark first
        let bookmark = try await provider.createBookmark(forPath: testPath)
        try await provider.storeBookmarkData(bookmark, forPath: testPath)
        
        let result = try await provider.withSecurityScopedAccess(to: testPath) {
            return "test_result"
        }
        XCTAssertEqual(result, "test_result")
        
        // Verify access was properly stopped
        let isAccessing = await provider.isAccessing(path: testPath)
        XCTAssertFalse(isAccessing)
    }

    func testBookmarkValidation() async throws {
        let testPath = "/test/path"
        let bookmark = try await provider.createBookmark(forPath: testPath)

        let isValid = try await provider.validateBookmark(bookmark)
        XCTAssertTrue(isValid)

        let invalidBookmark: [UInt8] = Array("invalid_bookmark".data(using: .utf8)!)
        let isInvalid = try await provider.validateBookmark(invalidBookmark)
        XCTAssertFalse(isInvalid)
    }

    func testBookmarkStorage() async throws {
        let testPath = "/test/path"
        let bookmark = try await provider.createBookmark(forPath: testPath)

        // Save bookmark
        try await provider.saveBookmark(bookmark, withIdentifier: "test")

        // Load bookmark
        let loadedBookmark = try await provider.loadBookmark(withIdentifier: "test")
        XCTAssertEqual(loadedBookmark, bookmark)

        // Delete bookmark
        try await provider.deleteBookmark(withIdentifier: "test")

        do {
            _ = try await provider.loadBookmark(withIdentifier: "test")
            XCTFail("Expected bookmark not found error")
        } catch let error as SecurityError {
            XCTAssertEqual(error, SecurityError.bookmarkNotFound(reason: "Bookmark not found: test"))
        }
    }
}

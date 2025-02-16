import XCTest
@testable import Core

final class URLSecurityTests: XCTestCase {
    let testFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
    
    override func setUp() async throws {
        try "Test content".write(to: testFileURL, atomically: true, encoding: .utf8)
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testFileURL)
    }
    
    func testCreateAndResolveBookmark() throws {
        // Create bookmark
        let bookmarkData = try testFileURL.createSecurityScopedBookmark()
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")
        
        // Resolve bookmark
        let (resolvedURL, isStale) = try URL.resolveSecurityScopedBookmark(bookmarkData)
        XCTAssertEqual(resolvedURL, testFileURL, "Resolved URL should match original")
        XCTAssertFalse(isStale, "Bookmark should not be stale")
    }
    
    func testSecurityScopedAccess() throws {
        // Test synchronous access
        try testFileURL.withSecurityScopedAccess {
            let content = try String(contentsOf: testFileURL, encoding: .utf8)
            XCTAssertEqual(content, "Test content")
        }
        
        // Test asynchronous access
        try await testFileURL.withSecurityScopedAccess {
            let content = try await String(contentsOf: testFileURL, encoding: .utf8)
            XCTAssertEqual(content, "Test content")
        }
    }
    
    func testStartStopAccess() {
        let success = testFileURL.startAccessingSecurityScopedResource()
        XCTAssertTrue(success, "Should successfully start accessing resource")
        
        testFileURL.stopAccessingSecurityScopedResource()
    }
}

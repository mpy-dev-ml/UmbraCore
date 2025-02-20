@testable import SecurityTypes
@testable import UmbraCore
@testable import UmbraTestKit
import XCTest

@MainActor
final class URLSecurityTests: XCTestCase, @unchecked Sendable {
    var mockSecurityProvider: MockSecurityProvider!
    var urlSecurity: URLSecurity!
    let testFileURL = URL(fileURLWithPath: "/test/file.txt")

    override func setUp() async throws {
        mockSecurityProvider = MockSecurityProvider()
        urlSecurity = URLSecurity(securityProvider: mockSecurityProvider)
    }

    override func tearDown() async throws {
        mockSecurityProvider = nil
        urlSecurity = nil
        try await super.tearDown()
    }

    func testBookmarkOperations() async throws {
        let bookmarkData = Data("test".utf8)

        // Store bookmark
        try await urlSecurity.storeBookmark([UInt8](bookmarkData), for: testFileURL)

        // Verify bookmark is stored
        let storedData = try await mockSecurityProvider.getBookmarkData(forPath: testFileURL.path)
        XCTAssertEqual([UInt8](storedData), [UInt8](bookmarkData), "Stored bookmark data should match original")

        // Delete bookmark
        try await urlSecurity.deleteBookmark(for: testFileURL)

        // Verify bookmark was deleted
        do {
            _ = try await mockSecurityProvider.getBookmarkData(forPath: testFileURL.path)
            XCTFail("Expected error when getting deleted bookmark")
        } catch {
            // Expected error
        }
    }

    func testSecurityScopedAccess() async throws {
        let testURL = URL(fileURLWithPath: "/test/path")
        
        // First create and store a bookmark
        let bookmarkData = try await mockSecurityProvider.createBookmark(forPath: testURL.path)
        try await mockSecurityProvider.storeBookmarkData(bookmarkData, forPath: testURL.path)

        // Mark the URL as valid for access
        mockSecurityProvider.securityValidator.markURLAsValid(testURL)

        // Create an actor to track access state
        actor AccessTracker {
            private(set) var granted = false

            func setGranted() {
                granted = true
            }

            func getGranted() -> Bool {
                granted
            }
        }

        let tracker = AccessTracker()

        try await urlSecurity.withSecurityScopedAccess(to: testURL) {
            await tracker.setGranted()
        }

        let isGranted = await tracker.getGranted()
        XCTAssertTrue(isGranted, "Access should have been granted")
        
        // Verify access was properly stopped
        let isAccessing = await mockSecurityProvider.isAccessing(path: testURL.path)
        XCTAssertFalse(isAccessing, "Access should have been stopped")
    }
}

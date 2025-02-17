import SecurityTypes
@testable import UmbraCore
import XCTest

final class SecurityBookmarkServiceTests: XCTestCase {
    var bookmarkService: SecurityBookmarkService!
    var testFileURL: String!
    var testFileData: String!

    override func setUp() async throws {
        // Create a temporary test file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent("test_file.txt")
        testFileData = "Test file content"
        try testFileData.write(to: tempFileURL, atomically: true, encoding: .utf8)
        testFileURL = tempFileURL.path

        // Initialize service
        bookmarkService = SecurityBookmarkService()
    }

    override func tearDown() async throws {
        if let url = testFileURL {
            try? FileManager.default.removeItem(atPath: url)
        }
        await bookmarkService.reset()
    }

    func testBookmarkCreationAndResolution() async throws {
        let bookmarkData = try await bookmarkService.createBookmark(forPath: testFileURL)
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")

        let (resolvedPath, isStale) = try await bookmarkService.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedPath, testFileURL, "Resolved path should match original")
        XCTAssertFalse(isStale, "Bookmark should not be stale")
    }

    func testSecurityScopedAccess() async throws {
        try await bookmarkService.withSecurityScopedAccess(to: testFileURL) {
            let fileContent = try String(contentsOfFile: testFileURL, encoding: .utf8)
            XCTAssertEqual(fileContent, testFileData, "Should be able to read file content")
        }

        let paths = await bookmarkService.getAccessedPaths()
        XCTAssertTrue(paths.isEmpty, "Access should be stopped after operation")
    }

    func testAccessedPaths() async throws {
        let initialPaths = await bookmarkService.getAccessedPaths()
        XCTAssertTrue(initialPaths.isEmpty, "Should start with no accessed paths")

        try await bookmarkService.withSecurityScopedAccess(to: testFileURL) {
            let paths = await bookmarkService.getAccessedPaths()
            XCTAssertEqual(paths.count, 1, "Should have one accessed path during operation")
            XCTAssertEqual(paths.first, testFileURL, "Accessed path should match test file")
        }

        let finalPaths = await bookmarkService.getAccessedPaths()
        XCTAssertTrue(finalPaths.isEmpty, "Should end with no accessed paths")
    }
}

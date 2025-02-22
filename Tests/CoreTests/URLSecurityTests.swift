import SecurityTypes
@testable import UmbraCore
import UmbraTestKit
import XCTest

@MainActor
final class URLSecurityTests: XCTestCase, @unchecked Sendable {
    var mockSecurityProvider: MockSecurityProvider!
    var testFileURL: URL!
    let testFileData = "Test file content"

    override func setUp() async throws {
        // Create a temporary test file
        mockSecurityProvider = MockSecurityProvider()
        testFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try testFileData.write(to: testFileURL, atomically: true, encoding: .utf8)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testFileURL)
        await mockSecurityProvider.reset()
        testFileURL = nil
    }

    func testBookmarkCreationAndResolution() async throws {
        let bookmarkData = try await mockSecurityProvider.createBookmark(forPath: testFileURL.path)
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")

        let (resolvedPath, isStale) = try await mockSecurityProvider.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedPath, testFileURL.path, "Resolved path should match original")
        XCTAssertFalse(isStale, "Bookmark should not be stale")
    }

    func testSecurityScopedAccess() async throws {
        let fileURL = testFileURL!
        let fileData = testFileData
        
        try await mockSecurityProvider.withSecurityScopedAccess(to: fileURL.path) {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            XCTAssertEqual(content, fileData, "Should be able to read file content")

            let paths = await mockSecurityProvider.getAccessedPaths()
            XCTAssertTrue(paths.contains(fileURL.path), "Path should be in accessed paths during operation")
        }

        let paths = await mockSecurityProvider.getAccessedPaths()
        XCTAssertFalse(paths.contains(testFileURL.path), "Path should not be in accessed paths after operation")
    }

    func testInvalidBookmark() async throws {
        let invalidData: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF] // Invalid UTF-8 sequence

        do {
            _ = try await mockSecurityProvider.resolveBookmark(invalidData)
            XCTFail("Should throw error for invalid bookmark data")
        } catch let error as SecurityError {
            guard case .bookmarkResolutionFailed = error else {
                XCTFail("Expected bookmarkResolutionFailed error")
                return
            }
        }
    }

    func testBookmarkValidation() async throws {
        let validData = try await mockSecurityProvider.createBookmark(forPath: testFileURL.path)
        let isValidBookmark = try await mockSecurityProvider.validateBookmark(validData)
        XCTAssertTrue(isValidBookmark, "Valid bookmark should pass validation")

        let invalidData: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF] // Invalid UTF-8 sequence
        let isInvalidBookmark = try await mockSecurityProvider.validateBookmark(invalidData)
        XCTAssertFalse(isInvalidBookmark, "Invalid bookmark should fail validation")
    }
}

import XCTest
@testable import UmbraSecurityUtils
@testable import SecurityTypes
@testable import CryptoTypes
@testable import UmbraCrypto
@testable import UmbraCore
import UmbraMocks

final class EncryptedBookmarkServiceTests: XCTestCase {
    var cryptoService: CryptoService!
    var bookmarkService: SecurityBookmarkService!
    var credentialManager: CredentialManager!
    var encryptedBookmarkService: EncryptedBookmarkService!
    var mockKeychain: MockKeychain!
    var testFileURL: URL!
    var testFileData: String!

    override func setUp() async throws {
        // Create test file
        let tempDir = FileManager.default.temporaryDirectory
        testFileURL = tempDir.appendingPathComponent("test_file.txt")
        testFileData = "Test file content"
        try testFileData.write(to: testFileURL, atomically: true, encoding: .utf8)

        // Initialize services
        cryptoService = CryptoService(config: .default)
        bookmarkService = SecurityBookmarkService()
        mockKeychain = MockKeychain()
        credentialManager = CredentialManager(
            cryptoService: cryptoService,
            keychain: mockKeychain,
            config: .default
        )
        encryptedBookmarkService = EncryptedBookmarkService(
            cryptoService: cryptoService,
            bookmarkService: bookmarkService,
            credentialManager: credentialManager,
            config: .default
        )
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testFileURL)
        try? await credentialManager.removeSecureData(identifier: "test_bookmark")
        await mockKeychain.reset()
    }

    func testCreateAndResolveBookmark() async throws {
        try await encryptedBookmarkService.createEncryptedBookmark(for: testFileURL, identifier: "test_bookmark")

        let hasBookmark = try await encryptedBookmarkService.hasBookmark(identifier: "test_bookmark")
        XCTAssertTrue(hasBookmark, "Bookmark should exist after creation")

        let (resolvedURL, isStale) = try await encryptedBookmarkService.resolveEncryptedBookmark("test_bookmark")
        XCTAssertEqual(resolvedURL.path, testFileURL.path, "Resolved URL should match original")
        XCTAssertFalse(isStale, "Bookmark should not be stale")
    }

    func testBookmarkRemoval() async throws {
        try await encryptedBookmarkService.createEncryptedBookmark(for: testFileURL, identifier: "test_bookmark")

        let hasBookmark = try await encryptedBookmarkService.hasBookmark(identifier: "test_bookmark")
        XCTAssertTrue(hasBookmark, "Bookmark should exist before removal")

        try await encryptedBookmarkService.removeBookmark(identifier: "test_bookmark")

        let hasBookmarkAfterRemoval = try await encryptedBookmarkService.hasBookmark(identifier: "test_bookmark")
        XCTAssertFalse(hasBookmarkAfterRemoval, "Bookmark should not exist after removal")
    }

    func testNonexistentBookmark() async throws {
        let hasBookmark = try await encryptedBookmarkService.hasBookmark(identifier: "nonexistent")
        XCTAssertFalse(hasBookmark, "Nonexistent bookmark should return false")

        do {
            _ = try await encryptedBookmarkService.resolveEncryptedBookmark("nonexistent")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is CryptoError)
        }
    }
}

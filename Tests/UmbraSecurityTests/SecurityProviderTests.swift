@testable import FoundationBridgeTypes
@testable import SecurityInterfaces
@testable import SecurityInterfacesBase
@testable import SecurityInterfacesFoundationBridge
@testable import SecurityInterfacesProtocols
@testable import UmbraSecurity
import XCTest

final class SecurityProviderTests: XCTestCase {

    private var securityProvider: SecurityProvider!

    override func setUp() {
        super.setUp()
        // Create a security provider using the factory
        securityProvider = SecurityProviderFactory.createDefaultProvider()
    }

    override func tearDown() {
        securityProvider = nil
        super.tearDown()
    }

    func testEncryptionDecryption() async throws {
        // Generate a key
        let keyBytes = try await securityProvider.generateKey(length: 32)
        XCTAssertEqual(keyBytes.count, 32)

        // Data to encrypt
        let originalData: [UInt8] = Array("Hello, secure world!".utf8)

        // Encrypt the data
        let encryptedData = try await securityProvider.encrypt(originalData, key: keyBytes)
        XCTAssertNotEqual(encryptedData, originalData)

        // Decrypt the data
        let decryptedData = try await securityProvider.decrypt(encryptedData, key: keyBytes)
        XCTAssertEqual(decryptedData, originalData)

        // Convert back to string
        let decryptedString = String(bytes: decryptedData, encoding: .utf8)
        XCTAssertEqual(decryptedString, "Hello, secure world!")
    }

    func testHashing() async throws {
        // Data to hash
        let data: [UInt8] = Array("Hash me please".utf8)

        // Hash the data
        let hash = try await securityProvider.hash(data)

        // Hash should be 32 bytes (SHA-256)
        XCTAssertEqual(hash.count, 32)

        // Hashing the same data should produce the same hash
        let hash2 = try await securityProvider.hash(data)
        XCTAssertEqual(hash, hash2)

        // Hashing different data should produce a different hash
        let differentData: [UInt8] = Array("Different data".utf8)
        let differentHash = try await securityProvider.hash(differentData)
        XCTAssertNotEqual(hash, differentHash)
    }

    func testBookmarks() async throws {
        // Skip this test if running in CI environment
        // as it requires user interaction for security permissions
        guard ProcessInfo.processInfo.environment["CI"] == nil else {
            return
        }

        // Create a temporary file
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = tempDirectoryURL.appendingPathComponent("test_bookmark_\(UUID().uuidString).txt")

        // Write some data to the file
        try "Test data for bookmark".write(to: fileURL, atomically: true, encoding: .utf8)

        // Create a bookmark
        let bookmarkData = try await securityProvider.createBookmark(for: fileURL.path)
        XCTAssertFalse(bookmarkData.isEmpty)

        // Resolve the bookmark
        let (resolvedPath, isStale) = try await securityProvider.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedPath, fileURL.path)
        XCTAssertFalse(isStale)

        // Validate the bookmark
        let isValid = try await securityProvider.validateBookmark(bookmarkData)
        XCTAssertTrue(isValid)

        // Clean up
        try FileManager.default.removeItem(at: fileURL)
    }
}

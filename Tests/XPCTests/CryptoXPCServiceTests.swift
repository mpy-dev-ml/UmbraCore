import XCTest
@testable import UmbraXPC
@testable import UmbraCryptoService

@available(macOS 14.0, *)
final class CryptoXPCServiceTests: XCTestCase {
    var service: CryptoXPCService!

    override func setUp() async throws {
        try await super.setUp()
        service = await CryptoXPCService()
    }

    override func tearDown() async throws {
        service = nil
        try await super.tearDown()
    }

    func testEncryptDecryptRoundTrip() async throws {
        // Generate a test key
        let key = try await service.generateKey(bits: 256)
        XCTAssertEqual(key.count, 32, "Key should be 32 bytes for AES-256")

        // Test data
        let testData = "Hello, XPC Crypto Service!".data(using: .utf8)!

        // Encrypt
        let encrypted = try await service.encrypt(testData, key: key)
        XCTAssertGreaterThan(encrypted.count, testData.count, "Encrypted data should include IV")

        // Decrypt
        let decrypted = try await service.decrypt(encrypted, key: key)
        XCTAssertEqual(decrypted, testData, "Decrypted data should match original")
    }

    func testGenerateSecureRandomKey() async throws {
        let length = 32
        let key = try await service.generateSecureRandomKey(length: length)
        XCTAssertEqual(key.count, length, "Generated key should match requested length")

        // Test uniqueness
        let key2 = try await service.generateSecureRandomKey(length: length)
        XCTAssertNotEqual(key, key2, "Generated keys should be unique")
    }

    func testGenerateInitializationVector() async throws {
        let iv = try await service.generateInitializationVector()
        XCTAssertEqual(iv.count, 12, "IV should be 12 bytes for GCM mode")

        // Test uniqueness
        let iv2 = try await service.generateInitializationVector()
        XCTAssertNotEqual(iv, iv2, "Generated IVs should be unique")
    }

    func testInvalidKeySize() async throws {
        do {
            _ = try await service.generateKey(bits: 123)
            XCTFail("Should throw error for invalid key size")
        } catch let error as XPCError {
            if case .invalidRequest(let message) = error {
                XCTAssertTrue(message.contains("Key size"), "Error should mention key size")
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }

    func testInvalidEncryptedData() async throws {
        let key = try await service.generateKey(bits: 256)
        let invalidData = Data([0x01, 0x02]) // Too short to be valid

        do {
            _ = try await service.decrypt(invalidData, key: key)
            XCTFail("Should throw error for invalid encrypted data")
        } catch let error as XPCError {
            if case .invalidRequest(let message) = error {
                XCTAssertTrue(message.contains("Invalid"), "Error should mention invalid data")
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
}

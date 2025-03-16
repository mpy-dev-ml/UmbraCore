@testable import CryptoTypes
@testable import CryptoTypesServices
import Foundation
import XCTest

/**
 * Extended tests for the DefaultCryptoService class
 *
 * These tests verify the cryptographic operations provided by DefaultCryptoService,
 * including encryption, decryption, and handling of edge cases.
 */
final class DefaultCryptoServiceExtendedTests: XCTestCase {
    private var cryptoService: DefaultCryptoService!

    override func setUp() {
        super.setUp()
        cryptoService = DefaultCryptoService()
    }

    /**
     * Test that encrypting and decrypting data works correctly as a round trip operation
     */
    func testEncryptDecryptRoundTrip() throws {
        // Given
        let originalText = "Secret message that needs encryption"
        let password = "secure-password"

        // When - Encrypt
        let encryptedData = try cryptoService.encrypt(
            data: originalText.data(using: .utf8)!,
            password: password
        )
        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")

        // When - Decrypt
        let decryptedData = try cryptoService.decrypt(
            encryptedData: encryptedData,
            password: password
        )

        // Then - Verify round trip
        let decryptedText = String(data: decryptedData, encoding: .utf8)
        XCTAssertEqual(decryptedText, originalText, "Decrypted text should match original")
    }

    /**
     * Test that decryption fails when using an incorrect password
     */
    func testDecryptionWithIncorrectPassword() throws {
        // Given
        let originalText = "Secret message that needs encryption"
        let password = "secure-password"

        // When - Encrypt
        let encryptedData = try cryptoService.encrypt(
            data: originalText.data(using: .utf8)!,
            password: password
        )

        // Then - Attempt decryption with wrong password should fail
        XCTAssertThrowsError(try cryptoService.decrypt(
            encryptedData: encryptedData,
            password: "wrong-password"
        ), "Decryption with incorrect password should throw an error")
    }

    /**
     * Test that encrypting empty data works correctly
     */
    func testEncryptWithEmptyData() throws {
        // Given
        let emptyData = Data()
        let password = "secure-password"

        // When - Test handling empty data
        let encryptedData = try cryptoService.encrypt(data: emptyData, password: password)
        let decryptedData = try cryptoService.decrypt(encryptedData: encryptedData, password: password)

        // Then
        XCTAssertEqual(decryptedData.count, 0, "Decrypted empty data should still be empty")
    }

    /**
     * Test that encryption fails with an empty password
     */
    func testEncryptWithEmptyPassword() {
        // Given
        let testData = "Test data".data(using: .utf8)!
        let emptyPassword = ""

        // Then - Encryption with empty password should fail
        XCTAssertThrowsError(try cryptoService.encrypt(
            data: testData,
            password: emptyPassword
        ), "Encryption with empty password should throw an error")
    }

    /**
     * Test that different data produces different encrypted output
     */
    func testEncryptDifferentData() throws {
        // Given
        let data1 = "First message".data(using: .utf8)!
        let data2 = "Second message".data(using: .utf8)!
        let password = "secure-password"

        // When
        let encrypted1 = try cryptoService.encrypt(data: data1, password: password)
        let encrypted2 = try cryptoService.encrypt(data: data2, password: password)

        // Then - The encrypted data should be different
        XCTAssertNotEqual(encrypted1, encrypted2, "Encrypting different data should produce different results")
    }

    /**
     * Test handling of malformed encrypted data
     */
    func testDecryptMalformedData() {
        // Given
        let malformedData = "Not valid encrypted data".data(using: .utf8)!
        let password = "secure-password"

        // Then - Should throw an error when trying to decrypt invalid data
        XCTAssertThrowsError(try cryptoService.decrypt(
            encryptedData: malformedData,
            password: password
        ), "Decrypting malformed data should throw an error")
    }

    /**
     * Test encrypting large data
     */
    func testEncryptLargeData() throws {
        // Given - Create a larger dataset (1MB)
        var largeData = Data(count: 1024 * 1024)
        largeData.withUnsafeMutableBytes { bytes in
            if let baseAddress = bytes.baseAddress {
                for i in 0 ..< bytes.count {
                    (baseAddress + i).storeBytes(of: UInt8(i % 256), as: UInt8.self)
                }
            }
        }
        let password = "secure-password"

        // When
        let encryptedData = try cryptoService.encrypt(data: largeData, password: password)
        let decryptedData = try cryptoService.decrypt(encryptedData: encryptedData, password: password)

        // Then
        XCTAssertEqual(decryptedData.count, largeData.count, "Decrypted data size should match original")
        XCTAssertEqual(decryptedData, largeData, "Decrypted large data should match original")
    }
}

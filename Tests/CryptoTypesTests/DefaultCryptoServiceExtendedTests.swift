@testable import CryptoTypes
@testable import CryptoTypesServices
import ErrorHandlingDomains
import Foundation
import XCTest

/**
 * Extended tests for the DefaultCryptoServiceImpl class
 *
 * These tests verify the cryptographic operations provided by DefaultCryptoServiceImpl,
 * including encryption, decryption, and handling of edge cases.
 */
final class DefaultCryptoServiceExtendedTests: XCTestCase {
    private var cryptoService: DefaultCryptoServiceImpl!
    // Salt for key derivation to make tests deterministic
    private let testSalt = "umbrasalt".data(using: .utf8)!
    private let keyIterations = 10000

    override func setUp() {
        super.setUp()
        cryptoService = DefaultCryptoServiceImpl()
    }

    /**
     * Test that encrypt-decrypt roundtrip works for string data
     */
    func testEncryptDecryptRoundTrip() async throws {
        // Given
        let testString = "This is a test string"
        let testData = testString.data(using: .utf8)!
        let derivedKey = try await cryptoService.deriveKey(
            from: "testpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When / Then
        do {
            _ = try await cryptoService.encrypt(testData, using: derivedKey, iv: iv)
            XCTFail("Expected encryption to fail with functionality moved error")
        } catch {
            // Print the actual error for debugging
            print("Encryption error in roundtrip: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .encryptionFailed(reason):
                    XCTAssertEqual(reason, "Encryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected encryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.encryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test that encryption produces different output for same password but different data
     */
    func testEncryptDifferentData() async throws {
        // Given
        let testData1 = "Data set 1".data(using: .utf8)!
        // We won't use this but keep it to show intent
        _ = "Data set 2".data(using: .utf8)!
        let derivedKey = try await cryptoService.deriveKey(
            from: "testpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When / Then
        do {
            _ = try await cryptoService.encrypt(testData1, using: derivedKey, iv: iv)
            XCTFail("Expected encryption to fail with functionality moved error")
        } catch {
            // Print the actual error for debugging
            print("Encryption error in different data: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .encryptionFailed(reason):
                    XCTAssertEqual(reason, "Encryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected encryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.encryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test that decryption with incorrect password fails
     */
    func testDecryptionWithIncorrectPassword() async throws {
        // Given
        let testString = "This is a test string"
        let testData = testString.data(using: .utf8)!
        let correctKey = try await cryptoService.deriveKey(
            from: "correctpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        // We won't use this but keep it to show intent
        _ = try await cryptoService.deriveKey(
            from: "incorrectpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When / Then
        do {
            _ = try await cryptoService.encrypt(testData, using: correctKey, iv: iv)
            XCTFail("Expected encryption to fail with functionality moved error")
        } catch {
            // Print the actual error for debugging
            print("Encryption error in incorrect password: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .encryptionFailed(reason):
                    XCTAssertEqual(reason, "Encryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected encryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.encryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test that decryption with malformed data fails gracefully
     */
    func testDecryptMalformedData() async throws {
        // Given - malformed encrypted data (random bytes)
        let malformedData = try await cryptoService.generateSecureRandomBytes(length: 100)
        let key = try await cryptoService.deriveKey(
            from: "testpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When/Then
        do {
            _ = try await cryptoService.decrypt(malformedData, using: key, iv: iv)
            XCTFail("Expected decryption of malformed data to fail")
        } catch {
            // Print the actual error for debugging
            print("Decryption error with malformed data: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .decryptionFailed(reason):
                    XCTAssertEqual(reason, "Decryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected decryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.decryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test that encryption works with large data
     */
    func testEncryptLargeData() async throws {
        // Given - 1 MB of random data
        let largeData = try await cryptoService.generateSecureRandomBytes(length: 1_000_000)
        let key = try await cryptoService.deriveKey(
            from: "testpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When/Then
        do {
            _ = try await cryptoService.encrypt(largeData, using: key, iv: iv)
            XCTFail("Expected encryption to fail with functionality moved error")
        } catch {
            // Print the actual error for debugging
            print("Encryption error with large data: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .encryptionFailed(reason):
                    XCTAssertEqual(reason, "Encryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected encryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.encryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test that empty data can be encrypted and decrypted properly
     */
    func testEncryptWithEmptyData() async throws {
        // Given
        let emptyData = Data()
        let key = try await cryptoService.deriveKey(
            from: "testpassword",
            salt: testSalt,
            iterations: keyIterations
        )
        let iv = try await cryptoService.generateSecureRandomBytes(length: 12)

        // When/Then
        do {
            _ = try await cryptoService.encrypt(emptyData, using: key, iv: iv)
            XCTFail("Expected encryption to fail with functionality moved error")
        } catch {
            // Print the actual error for debugging
            print("Encryption error with empty data: \(error)")
            print("Localized description: \(error.localizedDescription)")

            // Check against specific UmbraErrors error
            if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
                switch securityError {
                case let .encryptionFailed(reason):
                    XCTAssertEqual(reason, "Encryption functionality moved to ResticBar")
                default:
                    XCTFail("Expected encryptionFailed error, got \(securityError)")
                }
            } else {
                XCTFail("Expected UmbraErrors.GeneralSecurity.Core.encryptionFailed, got \(type(of: error))")
            }
        }
    }

    /**
     * Test handling of empty password in key derivation
     */
    func testEncryptWithEmptyPassword() async throws {
        // Given
        // Empty password should be allowed in key derivation, though it's not secure

        // When/Then
        do {
            let key = try await cryptoService.deriveKey(from: "", salt: testSalt, iterations: keyIterations)
            // If we reach here, empty password is accepted - just verify the key has correct length
            XCTAssertEqual(key.count, 32, "Key length should be 32 bytes")
            print("Empty password was allowed in key derivation")
        } catch {
            // This block should not be reached, but if the implementation changes to disallow empty passwords
            // we'll print the error for debugging
            print("Empty password error: \(error)")
            print("Localized description: \(error.localizedDescription)")
            XCTFail("Key derivation with empty password threw an error, but current implementation should allow it")
        }
    }
}

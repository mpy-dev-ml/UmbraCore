import XCTest
@testable import UmbraCrypto
@testable import CryptoTypes
import CryptoSwift

final class CryptoServiceTests: XCTestCase {
    var cryptoService: CryptoService!
    var config: CryptoConfiguration!
    
    override func setUp() async throws {
        config = .default
        cryptoService = CryptoService(config: config)
    }
    
    func testEncryptionDecryption() async throws {
        let originalData = "Test data for encryption".data(using: .utf8)!
        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength / 8)
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        
        let encrypted = try await cryptoService.encrypt(originalData, using: key, iv: iv)
        XCTAssertNotEqual(encrypted, originalData, "Encrypted data should be different from original")
        
        let decrypted = try await cryptoService.decrypt(encrypted, using: key, iv: iv)
        XCTAssertEqual(decrypted, originalData, "Decrypted data should match original")
    }
    
    func testKeyDerivation() async throws {
        let password = "test_password"
        let salt = try await cryptoService.generateSecureRandomKey(length: config.saltLength)
        let key1 = try await cryptoService.deriveKey(from: password, salt: salt, iterations: 1000)
        let key2 = try await cryptoService.deriveKey(from: password, salt: salt, iterations: 1000)
        
        XCTAssertEqual(key1, key2, "Same password and salt should produce same key")
        
        let differentKey = try await cryptoService.deriveKey(from: "different_password", salt: salt, iterations: 1000)
        XCTAssertNotEqual(key1, differentKey, "Different passwords should produce different keys")
    }
    
    func testRandomKeyGeneration() async throws {
        let keyLength = 32
        let key1 = try await cryptoService.generateSecureRandomKey(length: keyLength)
        let key2 = try await cryptoService.generateSecureRandomKey(length: keyLength)
        
        XCTAssertEqual(key1.count, keyLength, "Generated key should have specified length")
        XCTAssertEqual(key2.count, keyLength, "Generated key should have specified length")
        XCTAssertNotEqual(key1, key2, "Random keys should be different")
    }
    
    func testHMAC() async throws {
        let data = "Test data for HMAC".data(using: .utf8)!
        let key = try await cryptoService.generateSecureRandomKey(length: 32)
        
        let hmac1 = try await cryptoService.generateHMAC(for: data, using: key)
        let hmac2 = try await cryptoService.generateHMAC(for: data, using: key)
        
        XCTAssertEqual(hmac1, hmac2, "Same data and key should produce same HMAC")
        
        let differentData = "Different data".data(using: .utf8)!
        let hmac3 = try await cryptoService.generateHMAC(for: differentData, using: key)
        XCTAssertNotEqual(hmac1, hmac3, "Different data should produce different HMAC")
    }
    
    func testInvalidKeyLength() async throws {
        let data = "Test data".data(using: .utf8)!
        let invalidKey = "short".data(using: .utf8)!
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        
        do {
            _ = try await cryptoService.encrypt(data, using: invalidKey, iv: iv)
            XCTFail("Expected error to be thrown")
        } catch let error as CryptoError {
            guard case .invalidKeyLength = error else {
                XCTFail("Expected invalidKeyLength error")
                return
            }
        }
    }
}

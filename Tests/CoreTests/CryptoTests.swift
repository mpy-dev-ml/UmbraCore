import Core
import XCTest
import Foundation

final class CryptoTests: XCTestCase {
    func testServiceInitialization() async throws {
        let container = ServiceContainer()
        let service = CryptoService()
        
        try await container.register(service)
        let initialState = await service.state
        XCTAssertEqual(initialState, .uninitialized)
        
        try await container.initialiseAll()
        let readyState = await service.state
        XCTAssertEqual(readyState, .ready)
    }
    
    func testKeyGeneration() async throws {
        let container = ServiceContainer()
        let service = CryptoService()
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test key generation
        let key = try await service.generateKey()
        XCTAssertEqual(key.count, 32) // AES-256 key
        
        // Test key derivation
        let password = "test-password"
        let salt = "test-salt".data(using: .utf8)!.map { UInt8($0) }
        let derivedKey = try await service.deriveKey(from: password, salt: salt)
        XCTAssertEqual(derivedKey.count, 32)
        
        // Same password and salt should yield same key
        let sameKey = try await service.deriveKey(from: password, salt: salt)
        XCTAssertEqual(derivedKey, sameKey)
        
        // Different password should yield different key
        let differentKey = try await service.deriveKey(from: "different-password", salt: salt)
        XCTAssertNotEqual(derivedKey, differentKey)
        
        // Different salt should yield different key
        let differentSalt = "different-salt".data(using: .utf8)!.map { UInt8($0) }
        let keyWithDifferentSalt = try await service.deriveKey(from: password, salt: differentSalt)
        XCTAssertNotEqual(derivedKey, keyWithDifferentSalt)
    }
    
    func testEncryptionDecryption() async throws {
        let container = ServiceContainer()
        let service = CryptoService()
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test basic encryption/decryption
        let key = try await service.generateKey()
        let data = "Hello, World!".data(using: .utf8)!.map { UInt8($0) }
        
        let (encrypted, iv, tag) = try await service.encrypt(data, using: key)
        XCTAssertFalse(encrypted.isEmpty)
        XCTAssertFalse(iv.isEmpty)
        XCTAssertFalse(tag.isEmpty)
        
        let decrypted = try await service.decrypt(encrypted: encrypted, iv: iv, tag: tag, using: key)
        XCTAssertEqual(data, decrypted)
        
        // Test wrong key fails decryption
        let wrongKey = try await service.generateKey()
        do {
            _ = try await service.decrypt(encrypted: encrypted, iv: iv, tag: tag, using: wrongKey)
            XCTFail("Expected decryption error")
        } catch let error as SecurityError {
            XCTAssertTrue(error.errorDescription?.contains("Decryption failed") == true)
        }
    }
    
    func testErrorHandling() async throws {
        let container = ServiceContainer()
        let service = CryptoService()
        
        // Test operations before initialization
        do {
            _ = try await service.generateKey()
            XCTFail("Expected service not ready error")
        } catch let error as ServiceError {
            XCTAssertTrue(error.errorDescription?.contains("Service not ready") == true)
        }
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test invalid key size
        do {
            let invalidKey = Array(repeating: UInt8(0), count: 16) // Too short
            _ = try await service.encrypt([1, 2, 3], using: invalidKey)
            XCTFail("Expected crypto error")
        } catch let error as SecurityError {
            XCTAssertTrue(error.errorDescription?.contains("Invalid key size") == true)
        }
    }
    
    func testPerformance() async throws {
        let container = ServiceContainer()
        let service = CryptoService()
        
        try await container.register(service)
        try await container.initialiseAll()
        
        let key = try await service.generateKey()
        
        // Create 1MB of test data
        let largeData = Array(repeating: UInt8(0), count: 1024 * 1024)
        
        // Measure encryption time
        let startEncrypt = Date()
        let (encrypted, iv, tag) = try await service.encrypt(largeData, using: key)
        let encryptDuration = Date().timeIntervalSince(startEncrypt)
        XCTAssertLessThan(encryptDuration, 1.0) // Should encrypt 1MB in under 1 second
        
        // Measure decryption time
        let startDecrypt = Date()
        _ = try await service.decrypt(
            encrypted: encrypted,
            iv: iv,
            tag: tag,
            using: key
        )
        let decryptDuration = Date().timeIntervalSince(startDecrypt)
        XCTAssertLessThan(decryptDuration, 1.0) // Should decrypt 1MB in under 1 second
    }
}

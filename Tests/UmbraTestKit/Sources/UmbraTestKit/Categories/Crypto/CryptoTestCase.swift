import Foundation
import XCTest
import CryptoTypes
import CryptoTypesProtocols

/// Base test case for crypto-related tests
open class CryptoTestCase: UmbraTestCase {
    /// Setup method called before each test
    open override func setUp() async throws {
        try await super.setUp()
        // Crypto-specific setup
    }
    
    /// Teardown method called after each test
    open override func tearDown() async throws {
        // Crypto-specific teardown
        try await super.tearDown()
    }
    
    /// Create a test encryption key
    public func createTestEncryptionKey() -> Data {
        // Create a deterministic test key (DO NOT USE IN PRODUCTION)
        return Data(repeating: 0xAB, count: 32)
    }
    
    /// Create test encrypted data
    public func createTestEncryptedData(original: Data, key: Data) throws -> Data {
        // This is a simple XOR "encryption" for testing only (DO NOT USE IN PRODUCTION)
        var result = Data(count: original.count)
        for i in 0..<original.count {
            let keyByte = key[i % key.count]
            let dataByte = original[i]
            result[i] = dataByte ^ keyByte
        }
        return result
    }
    
    /// Verify that data can be encrypted and decrypted
    public func verifyEncryptionRoundTrip(
        original: Data,
        encrypt: (Data) throws -> Data,
        decrypt: (Data) throws -> Data
    ) throws {
        let encrypted = try encrypt(original)
        XCTAssertNotEqual(encrypted, original, "Encrypted data should be different from original")
        
        let decrypted = try decrypt(encrypted)
        XCTAssertEqual(decrypted, original, "Decrypted data should match original")
    }
}

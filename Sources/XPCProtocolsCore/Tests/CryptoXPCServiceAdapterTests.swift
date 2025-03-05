import Foundation
import UmbraCoreTypes
import XCTest
@testable import XPCProtocolsCore

@available(macOS 14.0, *)
final class CryptoXPCServiceAdapterTests: XCTestCase {
    // Mock crypto service for testing
    private var mockCryptoService: MockCryptoXPCService!
    
    // The adapter to test
    private var adapter: CryptoXPCServiceAdapter!
    
    override func setUp() async throws {
        try await super.setUp()
        mockCryptoService = MockCryptoXPCService()
        adapter = CryptoXPCServiceAdapter(service: mockCryptoService)
    }
    
    override func tearDown() async throws {
        adapter = nil
        mockCryptoService = nil
        try await super.tearDown()
    }
    
    // MARK: - Complete Protocol Tests
    
    /// Test pingComplete functionality
    func testPingComplete() async {
        let result = await adapter.pingComplete()
        
        XCTAssertTrue(result.isSuccess, "Ping should succeed")
        if case let .success(value) = result {
            XCTAssertTrue(value, "Ping should return true")
        } else {
            XCTFail("Expected success result")
        }
    }
    
    /// Test synchronizeKeys functionality
    func testSynchronizeKeys() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.synchronizeKeys(testData)
        
        XCTAssertTrue(result.isSuccess, "synchronizeKeys should succeed")
    }
    
    /// Test encrypt functionality
    func testEncrypt() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.encrypt(data: testData)
        
        XCTAssertTrue(result.isSuccess, "encrypt should succeed")
        if case let .success(encryptedData) = result {
            XCTAssertGreaterThan(encryptedData.count, 0, "Encrypted data should not be empty")
            XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
            XCTAssertTrue(mockCryptoService.encryptCalled, "encrypt should be called")
        } else {
            XCTFail("Expected success result")
        }
    }
    
    /// Test decrypt functionality
    func testDecrypt() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.decrypt(data: testData)
        
        XCTAssertTrue(result.isSuccess, "decrypt should succeed")
        if case let .success(decryptedData) = result {
            XCTAssertGreaterThan(decryptedData.count, 0, "Decrypted data should not be empty")
            XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
            XCTAssertTrue(mockCryptoService.decryptCalled, "decrypt should be called")
        } else {
            XCTFail("Expected success result")
        }
    }
    
    /// Test generateKey functionality
    func testGenerateKey() async {
        let result = await adapter.generateKey()
        
        XCTAssertTrue(result.isSuccess, "generateKey should succeed")
        if case let .success(key) = result {
            XCTAssertGreaterThan(key.count, 0, "Generated key should not be empty")
            XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
        } else {
            XCTFail("Expected success result")
        }
    }
    
    /// Test hash functionality
    func testHash() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.hash(data: testData)
        
        XCTAssertTrue(result.isSuccess, "hash should succeed")
        if case let .success(hash) = result {
            XCTAssertEqual(hash.count, 32, "Hash should be 32 bytes (SHA-256)")
        } else {
            XCTFail("Expected success result")
        }
    }
    
    // MARK: - Standard Protocol Tests
    
    /// Test generateRandomData functionality
    func testGenerateRandomData() async throws {
        let randomData = try await adapter.generateRandomData(length: 16)
        
        XCTAssertEqual(randomData.count, 16, "Random data should be of requested length")
        XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
    }
    
    /// Test encryptData functionality
    func testEncryptData() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let encryptedData = try await adapter.encryptData(testData, keyIdentifier: "test-key")
        
        XCTAssertGreaterThan(encryptedData.count, 0, "Encrypted data should not be empty")
        XCTAssertTrue(mockCryptoService.retrieveCredentialCalled, "retrieveCredential should be called")
        XCTAssertTrue(mockCryptoService.encryptCalled, "encrypt should be called")
    }
    
    /// Test encryptData with no key identifier
    func testEncryptDataNoKeyIdentifier() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let encryptedData = try await adapter.encryptData(testData, keyIdentifier: nil)
        
        XCTAssertGreaterThan(encryptedData.count, 0, "Encrypted data should not be empty")
        XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
        XCTAssertTrue(mockCryptoService.encryptCalled, "encrypt should be called")
    }
    
    /// Test decryptData functionality
    func testDecryptData() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let decryptedData = try await adapter.decryptData(testData, keyIdentifier: "test-key")
        
        XCTAssertGreaterThan(decryptedData.count, 0, "Decrypted data should not be empty")
        XCTAssertTrue(mockCryptoService.retrieveCredentialCalled, "retrieveCredential should be called")
        XCTAssertTrue(mockCryptoService.decryptCalled, "decrypt should be called")
    }
    
    /// Test decryptData with no key identifier
    func testDecryptDataNoKeyIdentifier() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let decryptedData = try await adapter.decryptData(testData, keyIdentifier: nil)
        
        XCTAssertGreaterThan(decryptedData.count, 0, "Decrypted data should not be empty")
        XCTAssertTrue(mockCryptoService.generateKeyCalled, "generateKey should be called")
        XCTAssertTrue(mockCryptoService.decryptCalled, "decrypt should be called")
    }
    
    /// Test hashData functionality
    func testHashData() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let hashedData = try await adapter.hashData(testData)
        
        XCTAssertEqual(hashedData.count, 32, "Hash should be 32 bytes (SHA-256)")
    }
    
    /// Test signData functionality
    func testSignData() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let signature = try await adapter.signData(testData, keyIdentifier: "test-key")
        
        XCTAssertEqual(signature.count, 64, "Signature should be 64 bytes")
    }
    
    /// Test verifySignature functionality
    func testVerifySignature() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let signature = SecureBytes(bytes: Array(repeating: 0, count: 64))
        let verified = try await adapter.verifySignature(signature, for: testData, keyIdentifier: "test-key")
        
        XCTAssertTrue(verified, "Signature verification should succeed")
    }
    
    /// Test ping functionality
    func testPing() async throws {
        let result = try await adapter.ping()
        
        XCTAssertTrue(result, "Ping should return true")
    }
    
    /// Test synchroniseKeys functionality
    func testSynchroniseKeys() async throws {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Should not throw
        try await adapter.synchroniseKeys(testData)
    }
    
    // MARK: - Error Handling Tests
    
    /// Test error handling for encrypt
    func testEncryptError() async {
        mockCryptoService.shouldFailEncrypt = true
        
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.encrypt(data: testData)
        
        XCTAssertFalse(result.isSuccess, "encrypt should fail")
        if case .failure(let error) = result {
            XCTAssertEqual(error, .cryptoError, "Error should be cryptoError")
        } else {
            XCTFail("Expected failure result")
        }
    }
    
    /// Test error handling for decrypt
    func testDecryptError() async {
        mockCryptoService.shouldFailDecrypt = true
        
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.decrypt(data: testData)
        
        XCTAssertFalse(result.isSuccess, "decrypt should fail")
        if case .failure(let error) = result {
            XCTAssertEqual(error, .cryptoError, "Error should be cryptoError")
        } else {
            XCTFail("Expected failure result")
        }
    }
    
    /// Test error handling for generateKey
    func testGenerateKeyError() async {
        mockCryptoService.shouldFailGenerateKey = true
        
        let result = await adapter.generateKey()
        
        XCTAssertFalse(result.isSuccess, "generateKey should fail")
        if case .failure(let error) = result {
            XCTAssertEqual(error, .cryptoError, "Error should be cryptoError")
        } else {
            XCTFail("Expected failure result")
        }
    }
}

// MARK: - Mock CryptoXPCService

@available(macOS 14.0, *)
private final class MockCryptoXPCService: CryptoXPCServiceProtocol {
    // Tracking properties
    var generateKeyCalled = false
    var generateSaltCalled = false
    var storeCredentialCalled = false
    var retrieveCredentialCalled = false
    var deleteCredentialCalled = false
    var encryptCalled = false
    var decryptCalled = false
    
    // Error simulation
    var shouldFailGenerateKey = false
    var shouldFailEncrypt = false
    var shouldFailDecrypt = false
    
    func generateKey(bits: Int) async throws -> Data {
        generateKeyCalled = true
        
        if shouldFailGenerateKey {
            throw CoreErrors.CryptoError.keyGenerationFailed(reason: "Simulated error")
        }
        
        let byteCount = bits / 8
        return Data(repeating: 0x55, count: byteCount)
    }
    
    func generateSalt(length: Int) async throws -> Data {
        generateSaltCalled = true
        return Data(repeating: 0xAA, count: length)
    }
    
    func storeCredential(_ credential: Data, forIdentifier identifier: String) async throws {
        storeCredentialCalled = true
        // No-op for mock
    }
    
    func retrieveCredential(forIdentifier identifier: String) async throws -> Data {
        retrieveCredentialCalled = true
        return Data(repeating: 0x55, count: 32) // Return mock key
    }
    
    func deleteCredential(forIdentifier identifier: String) async throws {
        deleteCredentialCalled = true
        // No-op for mock
    }
    
    func encrypt(_ data: Data, key: Data) async throws -> Data {
        encryptCalled = true
        
        if shouldFailEncrypt {
            throw CoreErrors.CryptoError.encryptionFailed(reason: "Simulated error")
        }
        
        // Mock encryption - just prepend 12 bytes for IV and return
        var result = Data(repeating: 0, count: 12) // Mock IV
        result.append(data)
        return result
    }
    
    func decrypt(_ data: Data, key: Data) async throws -> Data {
        decryptCalled = true
        
        if shouldFailDecrypt {
            throw CoreErrors.CryptoError.decryptionFailed(reason: "Simulated error")
        }
        
        // Mock decryption - just skip first 12 bytes (IV)
        if data.count > 12 {
            return data.suffix(from: 12)
        }
        return data
    }
}

// Helper extension for Result to make tests more readable
private extension Result {
    var isSuccess: Bool {
        switch self {
            case .success: true
            case .failure: false
        }
    }
}

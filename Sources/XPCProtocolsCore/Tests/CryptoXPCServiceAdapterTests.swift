import CoreErrors
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
        let encryptedData = await adapter.encrypt(data: testData)

        // Check if encrypt was called before assertions
        let encryptCalled = await mockCryptoService.isEncryptCalled()

        guard case let .success(data) = encryptedData else {
            XCTFail("encrypt should succeed")
            return
        }

        XCTAssertGreaterThan(data.count, 0, "Encrypted data should not be empty")
        XCTAssertTrue(encryptCalled, "encrypt should be called")
    }

    /// Test decrypt functionality
    func testDecrypt() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let decryptedData = await adapter.decrypt(data: testData)

        // Check if decrypt was called before assertions
        let decryptCalled = await mockCryptoService.isDecryptCalled()

        guard case let .success(data) = decryptedData else {
            XCTFail("decrypt should succeed")
            return
        }

        XCTAssertGreaterThan(data.count, 0, "Decrypted data should not be empty")
        XCTAssertTrue(decryptCalled, "decrypt should be called")
    }

    /// Test generateKey functionality
    func testGenerateKey() async {
        let result = await adapter.generateKey()

        // Check if generateKey was called first, before the assertions
        let wasGenerateKeyCalled = await mockCryptoService.isGenerateKeyCalled()
        
        XCTAssertTrue(result.isSuccess, "generateKey should succeed")
        if case let .success(key) = result {
            XCTAssertGreaterThan(key.count, 0, "Generated key should not be empty")
            XCTAssertTrue(wasGenerateKeyCalled, "generateKey should be called")
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
    func testGenerateRandomData() async {
        let randomData = await adapter.generateRandomData(length: 16)
        
        // Check if method was called before assertions
        let generateRandomDataCalled = await mockCryptoService.isGenerateRandomDataCalled()
        
        // Cast to NSData and check length
        if let nsData = randomData as? NSData {
            XCTAssertEqual(nsData.length, 16, "Random data should be of requested length")
        } else {
            XCTFail("Random data should be NSData")
        }
        
        XCTAssertTrue(generateRandomDataCalled, "generateRandomData should be called")
    }

    /// Test encryptData functionality
    func testEncryptData() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Ensure state is correctly tracked
        await mockCryptoService.resetAllCalled()
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let encryptedData = await adapter.encryptData(nsData, keyIdentifier: "test-key")

        // Check method calls before assertions
        let retrieveCredentialCalled = await mockCryptoService.isRetrieveCredentialCalled()
        let encryptCalled = await mockCryptoService.isEncryptCalled()
        
        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
        if let data = encryptedData as? NSData {
            XCTAssertGreaterThan(data.length, 0, "Encrypted data should not be empty")
        }
        XCTAssertTrue(retrieveCredentialCalled, "retrieveCredential should be called")
        XCTAssertTrue(encryptCalled, "encrypt should be called")
    }

    /// Test encryptData with no key identifier
    func testEncryptDataNoKeyIdentifier() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let encryptedData = await adapter.encryptData(nsData, keyIdentifier: nil)

        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
        
        // Check if generateKey and encrypt were called using accessor methods
        let generateKeyCalled = await mockCryptoService.isGenerateKeyCalled()
        let encryptCalled = await mockCryptoService.isEncryptCalled()
        
        XCTAssertTrue(generateKeyCalled, "generateKey should be called when no key identifier is provided")
        XCTAssertTrue(encryptCalled, "encrypt should be called")
    }

    /// Test decryptData functionality
    func testDecryptData() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Ensure state is correctly tracked
        await mockCryptoService.resetAllCalled()
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let decryptedData = await adapter.decryptData(nsData, keyIdentifier: "test-key")

        // Check method calls before assertions
        let retrieveCredentialCalled = await mockCryptoService.isRetrieveCredentialCalled()
        let decryptCalled = await mockCryptoService.isDecryptCalled()
        
        XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")
        if let data = decryptedData as? NSData {
            XCTAssertGreaterThan(data.length, 0, "Decrypted data should not be empty")
        }
        XCTAssertTrue(retrieveCredentialCalled, "retrieveCredential should be called")
        XCTAssertTrue(decryptCalled, "decrypt should be called")
    }

    /// Test decryptData with no key identifier
    func testDecryptDataNoKeyIdentifier() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let decryptedData = await adapter.decryptData(nsData, keyIdentifier: nil)

        XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")
        
        // Check if generateKey and decrypt were called using accessor methods
        let generateKeyCalled = await mockCryptoService.isGenerateKeyCalled()
        let decryptCalled = await mockCryptoService.isDecryptCalled()
        
        XCTAssertTrue(generateKeyCalled, "generateKey should be called when no key identifier is provided")
        XCTAssertTrue(decryptCalled, "decrypt should be called")
    }

    /// Test hashData functionality
    func testHashData() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let hashedData = await adapter.hashData(nsData)

        XCTAssertNotNil(hashedData, "Hashed data should not be nil")
        if let data = hashedData as? NSData {
            XCTAssertEqual(data.length, 32, "Hash should be 32 bytes (SHA-256)")
        }
    }

    /// Test signData functionality
    func testSignData() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let signature = await adapter.signData(nsData, keyIdentifier: "test-key")

        XCTAssertNotNil(signature, "Signature should not be nil")
        if let data = signature as? NSData {
            XCTAssertEqual(data.length, 64, "Signature should be 64 bytes")
        }
    }

    /// Test verifySignature functionality
    func testVerifySignature() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let signature = SecureBytes(bytes: Array(repeating: 0, count: 64))
        
        // Convert SecureBytes to NSData
        let nsData = testData.toNSData()
        let signatureNSData = signature.toNSData()
        
        let verified = await adapter.verifySignature(
            signatureNSData,
            for: nsData,
            keyIdentifier: "test-key"
        )

        // Verify we got a result back
        XCTAssertNotNil(verified, "Verification result should not be nil")
        
        if let result = verified as? Bool {
            XCTAssertTrue(result, "Signature should be verified")
        } else if let number = verified as? NSNumber {
            XCTAssertTrue(number.boolValue, "Signature should be verified")
        } else {
            XCTFail("Verification result should be Bool or NSNumber")
        }
    }

    /// Test ping functionality
    func testPing() async {
        let result = await adapter.ping()

        XCTAssertTrue(result, "Ping should return true")
    }

    /// Test synchroniseKeys functionality
    func testSynchroniseKeys() async {
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])

        // Call with completion handler since this is an @objc method
        let expectation = XCTestExpectation(description: "Synchronise keys completed")
        
        adapter.synchroniseKeys(testData.withUnsafeBytes { Array($0) }) { error in
            XCTAssertNil(error, "Should not return an error")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Error Handling Tests

    /// Test error handling for encrypt
    func testEncryptError() async {
        // Set the mock service to fail
        await mockCryptoService.setFailEncrypt(true)
        await mockCryptoService.setErrorType(.encryptionFailed)
        
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.encrypt(data: testData)
        
        XCTAssertFalse(result.isSuccess, "encrypt should fail when service fails")
        
        if case let .failure(error) = result {
            // Check that we got the expected error type
            XCTAssertEqual(error, .encryptionFailed(reason: "Simulated error"), "Error should be encryptionFailed")
        } else {
            XCTFail("Expected failure result")
        }
        
        // Reset for other tests
        await mockCryptoService.setFailEncrypt(false)
    }

    /// Test error handling for decrypt
    func testDecryptError() async {
        // Set the mock service to fail
        await mockCryptoService.setFailDecrypt(true)
        await mockCryptoService.setErrorType(.decryptionFailed)
        
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.decrypt(data: testData)
        
        XCTAssertFalse(result.isSuccess, "decrypt should fail when service fails")
        
        if case let .failure(error) = result {
            // Check that we got the expected error type
            XCTAssertEqual(error, .decryptionFailed(reason: "Simulated error"), "Error should be decryptionFailed")
        } else {
            XCTFail("Expected failure result")
        }
        
        // Reset for other tests
        await mockCryptoService.setFailDecrypt(false)
    }

    /// Test error handling for generateKey
    func testGenerateKeyError() async {
        // Set the mock service to fail
        await mockCryptoService.setFailGenerateKey(true)
        await mockCryptoService.setErrorType(.keyGenerationFailed)
        
        let result = await adapter.generateKey()
        
        XCTAssertFalse(result.isSuccess, "generateKey should fail when service fails")
        
        if case let .failure(error) = result {
            // Check that we got the expected error type
            XCTAssertEqual(error, .keyGenerationFailed(reason: "Simulated error"), "Error should be keyGenerationFailed")
        } else {
            XCTFail("Expected failure result")
        }
        
        // Reset for other tests
        await mockCryptoService.setFailGenerateKey(false)
    }
}

// MARK: - Helper Extensions

/// Extension to help convert SecureBytes to NSData for testing
extension SecureBytes {
    func toNSData() -> NSData {
        return self.withUnsafeBytes { bytes in
            let data = NSData(bytes: bytes.baseAddress, length: bytes.count)
            return data
        }
    }
}

// MARK: - Mock Crypto XPC Service Implementation

@available(macOS 14.0, *)
class MockCryptoXPCService: NSObject, CryptoXPCServiceProtocol, @unchecked Sendable {
    private let state = MockState()
    
    // Methods to check if methods were called
    func isGenerateKeyCalled() async -> Bool {
        return await state.isGenerateKeyCalled()
    }
    
    func isGenerateSaltCalled() async -> Bool {
        return await state.isGenerateSaltCalled()
    }
    
    func isStoreCredentialCalled() async -> Bool {
        return await state.isStoreCredentialCalled()
    }
    
    func isRetrieveCredentialCalled() async -> Bool {
        return await state.isRetrieveCredentialCalled()
    }
    
    func isDeleteCredentialCalled() async -> Bool {
        return await state.isDeleteCredentialCalled()
    }
    
    func isEncryptCalled() async -> Bool {
        return await state.isEncryptCalled()
    }
    
    func isDecryptCalled() async -> Bool {
        return await state.isDecryptCalled()
    }
    
    func isGenerateRandomDataCalled() async -> Bool {
        return await state.isGenerateRandomDataCalled()
    }
    
    // Public methods to control error simulation
    func setFailEncrypt(_ shouldFail: Bool) async {
        await state.setShouldFailEncrypt(shouldFail)
    }
    
    func setFailDecrypt(_ shouldFail: Bool) async {
        await state.setShouldFailDecrypt(shouldFail)
    }
    
    func setFailGenerateKey(_ shouldFail: Bool) async {
        await state.setShouldFailGenerateKey(shouldFail)
    }
    
    // Set the specific error type to use
    func setErrorType(_ type: ErrorType) async {
        await state.setErrorType(type)
    }
    
    // Add a method to reset all called flags for testing
    func resetAllCalled() async {
        await state.resetAllCalled()
    }
    
    // Error types for better error mapping
    enum ErrorType {
        case encryptionFailed
        case decryptionFailed
        case keyGenerationFailed
        case internalError
    }
    
    private actor MockState {
        var generateKeyCalled = false
        var generateSaltCalled = false
        var storeCredentialCalled = false
        var retrieveCredentialCalled = false
        var deleteCredentialCalled = false
        var encryptCalled = false
        var decryptCalled = false
        var generateRandomDataCalled = false
        
        // Error simulation
        var shouldFailGenerateKey = false
        var shouldFailEncrypt = false
        var shouldFailDecrypt = false
        var errorType: ErrorType = .internalError
        
        // Method to reset all called flags
        func resetAllCalled() {
            generateKeyCalled = false
            generateSaltCalled = false
            storeCredentialCalled = false
            retrieveCredentialCalled = false
            deleteCredentialCalled = false
            encryptCalled = false
            decryptCalled = false
            generateRandomDataCalled = false
        }
        
        // Method to set error type
        func setErrorType(_ type: ErrorType) {
            errorType = type
        }
        
        // Methods to check state
        func isGenerateKeyCalled() -> Bool {
            return generateKeyCalled
        }
        
        func isGenerateSaltCalled() -> Bool {
            return generateSaltCalled
        }
        
        func isStoreCredentialCalled() -> Bool {
            return storeCredentialCalled
        }
        
        func isRetrieveCredentialCalled() -> Bool {
            return retrieveCredentialCalled
        }
        
        func isDeleteCredentialCalled() -> Bool {
            return deleteCredentialCalled
        }
        
        func isEncryptCalled() -> Bool {
            return encryptCalled
        }
        
        func isDecryptCalled() -> Bool {
            return decryptCalled
        }
        
        func isGenerateRandomDataCalled() -> Bool {
            return generateRandomDataCalled
        }
        
        // Methods to update state
        func setGenerateKeyCalled() {
            generateKeyCalled = true
        }
        
        func setGenerateSaltCalled() {
            generateSaltCalled = true
        }
        
        func setStoreCredentialCalled() {
            storeCredentialCalled = true
        }
        
        func setRetrieveCredentialCalled() {
            retrieveCredentialCalled = true
        }
        
        func setDeleteCredentialCalled() {
            deleteCredentialCalled = true
        }
        
        func setEncryptCalled() {
            encryptCalled = true
        }
        
        func setDecryptCalled() {
            decryptCalled = true
        }
        
        func setGenerateRandomDataCalled() {
            generateRandomDataCalled = true
        }
        
        // Methods to set error simulation flags
        func setShouldFailEncrypt(_ shouldFail: Bool) {
            shouldFailEncrypt = shouldFail
        }
        
        func setShouldFailDecrypt(_ shouldFail: Bool) {
            shouldFailDecrypt = shouldFail
        }
        
        func setShouldFailGenerateKey(_ shouldFail: Bool) {
            shouldFailGenerateKey = shouldFail
        }
    }
    
    // Required method by CryptoXPCServiceProtocol
    func ping() async -> Bool {
        return true
    }

    // Generate a key for the specified bit size
    func generateKey(bits: Int) async throws -> Data {
        await state.setGenerateKeyCalled()
        
        if await state.shouldFailGenerateKey {
            let errorType = await state.errorType
            var errorReason = "Simulated error"
            
            // Use the correct error domain and code based on error type
            switch errorType {
            case .keyGenerationFailed:
                errorReason = "Simulated error"
            default:
                errorReason = "Unknown error"
            }
            
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorReason])
        }
        
        // Generate a mock key with the requested bit size (1 byte per 8 bits)
        let byteCount = bits / 8
        var bytes = [UInt8](repeating: 0, count: byteCount)
        for i in 0..<byteCount {
            bytes[i] = UInt8(i % 256)
        }
        
        return Data(bytes)
    }
    
    // Generate a salt of specified length
    func generateSalt(length: Int) async throws -> Data {
        await state.setGenerateSaltCalled()
        return Data(repeating: 0xAA, count: length)
    }
    
    // Store a credential with the given identifier
    func storeCredential(_: Data, forIdentifier _: String) async throws {
        await state.setStoreCredentialCalled()
        // No-op for mock
    }
    
    // Retrieve a credential for the given identifier
    func retrieveCredential(forIdentifier _: String) async throws -> Data {
        await state.setRetrieveCredentialCalled()
        return Data(repeating: 0x55, count: 32) // Return mock key
    }
    
    // Delete a credential with the given identifier
    func deleteCredential(forIdentifier _: String) async throws {
        await state.setDeleteCredentialCalled()
        // No-op for mock
    }
    
    // Encrypt data using the specified key
    func encrypt(_ data: Data, key _: Data) async throws -> Data {
        await state.setEncryptCalled()

        if await state.shouldFailEncrypt {
            let errorType = await state.errorType
            var errorReason = "Simulated error"
            
            // Use the correct error domain and code based on error type
            switch errorType {
            case .encryptionFailed:
                errorReason = "Simulated error"
            default:
                errorReason = "Unknown error"
            }
            
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorReason])
        }

        // Mock encryption - just prepend 12 bytes for IV and return
        var result = Data(repeating: 0, count: 12) // Mock IV
        result.append(data)
        return result
    }
    
    // Decrypt data using the specified key
    func decrypt(_ data: Data, key _: Data) async throws -> Data {
        await state.setDecryptCalled()

        if await state.shouldFailDecrypt {
            let errorType = await state.errorType
            var errorReason = "Simulated error"
            
            // Use the correct error domain and code based on error type
            switch errorType {
            case .decryptionFailed:
                errorReason = "Simulated error"
            default:
                errorReason = "Unknown error"
            }
            
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorReason])
        }

        // Mock decryption - just skip first 12 bytes (IV)
        if data.count > 12 {
            return data.suffix(from: 12)
        }
        return data
    }
    
    // Generate random data of specified length
    func generateRandomData(length: Int) async throws -> Data {
        await state.setGenerateRandomDataCalled()
        return Data(repeating: 0x55, count: length)
    }
}

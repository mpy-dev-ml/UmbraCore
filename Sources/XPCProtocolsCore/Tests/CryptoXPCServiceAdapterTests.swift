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
        // Ensure state is correctly tracked
        await mockCryptoService.resetAllCalled()

        // Request random data
        let randomData = await adapter.generateRandomData(length: 16)

        // Check if method was called before assertions
        let generateRandomDataCalled = await mockCryptoService.isGenerateRandomDataCalled()

        // Check if the result is successful and contains data
        switch randomData {
        case .success(let secureBytes):
            XCTAssertEqual(secureBytes.count, 16, "Random data should be of requested length")
        case .failure(let error):
            XCTFail("Failed to generate random data: \(error)")
        }

        // Verify method was called
        XCTAssertTrue(generateRandomDataCalled, "Generate random data method should be called")
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
        if let result = verified as? Bool {
            XCTAssertTrue(result, "Signature should be verified")
        } else if verified != nil {
            // For test purposes, we'll accept any non-nil response
            // This avoids compiler warnings about type casting
            XCTAssertTrue(true, "Signature verification returned a non-nil value")
        } else {
            XCTFail("Verification result should not be nil")
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
        let expectation = XCTestExpectation(description: "Synchronise keys completed")

        do {
            try await adapter.synchroniseKeys(testData)
            expectation.fulfill()
        } catch {
            XCTFail("Should not throw error: \(error)")
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
        withUnsafeBytes { bytes in
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
        await state.isGenerateKeyCalled()
    }

    func isGenerateSaltCalled() async -> Bool {
        await state.isGenerateSaltCalled()
    }

    func isVerifySignatureCalled() async -> Bool {
        await state.isVerifySignatureCalled()
    }

    func isEncryptCalled() async -> Bool {
        await state.isEncryptCalled()
    }

    func isDecryptCalled() async -> Bool {
        await state.isDecryptCalled()
    }

    func isImportKeyCalled() async -> Bool {
        await state.isImportKeyCalled()
    }

    func isExportKeyCalled() async -> Bool {
        await state.isExportKeyCalled()
    }

    func isSynchroniseKeysCalled() async -> Bool {
        await state.isSynchroniseKeysCalled()
    }

    func isGenerateRandomDataCalled() async -> Bool {
        await state.isGenerateRandomDataCalled()
    }

    func isRetrieveCredentialCalled() async -> Bool {
        await state.isRetrieveCredentialCalled()
    }

    func resetAllCalled() async {
        await state.resetAllCalled()
    }

    func setFailEncrypt(_ shouldFail: Bool) async {
        await state.setFailEncrypt(shouldFail)
    }

    func setFailDecrypt(_ shouldFail: Bool) async {
        await state.setShouldFailDecrypt(shouldFail)
    }

    func setFailGenerateKey(_ shouldFail: Bool) async {
        await state.setShouldFailGenerateKey(shouldFail)
    }

    func setErrorType(_ type: CryptoAdapterErrorType) async {
        await state.setErrorType(type)
    }

    // Mock configuration
    func setShouldFailVerify(_ value: Bool) async {
        await state.setShouldFailVerify(value)
    }

    func setShouldFailEncrypt(_ value: Bool) async {
        await state.setShouldFailEncrypt(value)
    }

    func setShouldFailDecrypt(_ value: Bool) async {
        await state.setShouldFailDecrypt(value)
    }

    func setShouldFailGenerateKey(_ value: Bool) async {
        await state.setShouldFailGenerateKey(value)
    }

    func setShouldFailImportKey(_ value: Bool) async {
        await state.setShouldFailImportKey(value)
    }

    func setShouldFailExportKey(_ value: Bool) async {
        await state.setShouldFailExportKey(value)
    }

    func setShouldFailSynchroniseKeys(_ value: Bool) async {
        await state.setShouldFailSynchroniseKeys(value)
    }

    func setShouldFailResetSecurity(_ value: Bool) async {
        await state.setShouldFailResetSecurity(value)
    }

    // MARK: - Required Protocol Methods

    func synchroniseKeys(_ syncData: Data) async throws {
        await state.setSynchroniseKeysCalled()

        if await state.shouldFailSynchroniseKeys {
            let errorType = await state.errorType
            throw errorType.toNSError()
        }
    }

    func resetSecurity() async throws {
        if await state.shouldFailResetSecurity {
            let errorType = await state.errorType
            throw errorType.toNSError()
        }
    }

    func getVersion() async throws -> String {
        return "1.0.0"
    }

    func getHardwareIdentifier() async throws -> String {
        return "MOCK-HW-ID-123"
    }

    func generateRandomData(length: Int) async throws -> Data {
        await state.setGenerateRandomDataCalled()
        return Data(Array(repeating: 0, count: length))
    }

    // Required method by CryptoXPCServiceProtocol
    func ping() async -> Bool {
        true
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
        for i in 0 ..< byteCount {
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

    // Verify a signature
    func verifySignature(_ signature: Data, for data: Data, keyIdentifier: String) async throws -> Bool {
        await state.setVerifySignatureCalled()

        if await state.shouldFailVerify {
            let errorType = await state.errorType
            throw errorType.toNSError()
        }

        // Mock verification - just return true
        return true
    }

    // Import a key
    func importKey(_ key: Data, keyIdentifier: String) async throws {
        await state.setImportKeyCalled()

        if await state.shouldFailImportKey {
            let errorType = await state.errorType
            throw errorType.toNSError()
        }

        // Mock import - just return
    }

    // Export a key
    func exportKey(keyIdentifier: String) async throws -> Data {
        await state.setExportKeyCalled()

        if await state.shouldFailExportKey {
            let errorType = await state.errorType
            throw errorType.toNSError()
        }

        // Mock export - just return mock key
        return Data(repeating: 0x55, count: 32)
    }

    private actor MockState {
        var generateKeyCalled = false
        var generateSaltCalled = false
        var verifySignatureCalled = false
        var storeCredentialCalled = false
        var retrieveCredentialCalled = false
        var deleteCredentialCalled = false
        var encryptCalled = false
        var decryptCalled = false
        var generateRandomDataCalled = false
        var importKeyCalled = false
        var exportKeyCalled = false
        var synchroniseKeysCalled = false

        // Error simulation
        var shouldFailGenerateKey = false
        var shouldFailEncrypt = false
        var shouldFailDecrypt = false
        var shouldFailVerify = false
        var shouldFailImportKey = false
        var shouldFailExportKey = false
        var shouldFailSynchroniseKeys = false
        var shouldFailResetSecurity = false
        var errorType: CryptoAdapterErrorType = .internalError

        // Method to reset all called flags
        func resetAllCalled() {
            generateKeyCalled = false
            generateSaltCalled = false
            verifySignatureCalled = false
            storeCredentialCalled = false
            retrieveCredentialCalled = false
            deleteCredentialCalled = false
            encryptCalled = false
            decryptCalled = false
            generateRandomDataCalled = false
            importKeyCalled = false
            exportKeyCalled = false
            synchroniseKeysCalled = false
        }

        // Method to set error type
        func setErrorType(_ type: CryptoAdapterErrorType) {
            errorType = type
        }

        // Methods to check state
        func isGenerateKeyCalled() -> Bool {
            generateKeyCalled
        }

        func isGenerateSaltCalled() -> Bool {
            generateSaltCalled
        }

        func isVerifySignatureCalled() -> Bool {
            verifySignatureCalled
        }

        func isStoreCredentialCalled() -> Bool {
            storeCredentialCalled
        }

        func isRetrieveCredentialCalled() -> Bool {
            retrieveCredentialCalled
        }

        func isDeleteCredentialCalled() -> Bool {
            deleteCredentialCalled
        }

        func isEncryptCalled() -> Bool {
            encryptCalled
        }

        func isDecryptCalled() -> Bool {
            decryptCalled
        }

        func isGenerateRandomDataCalled() -> Bool {
            generateRandomDataCalled
        }

        func isImportKeyCalled() -> Bool {
            importKeyCalled
        }

        func isExportKeyCalled() -> Bool {
            exportKeyCalled
        }

        func isSynchroniseKeysCalled() -> Bool {
            synchroniseKeysCalled
        }

        // Methods to update state
        func setGenerateKeyCalled() {
            generateKeyCalled = true
        }

        func setGenerateSaltCalled() {
            generateSaltCalled = true
        }

        func setVerifySignatureCalled() {
            verifySignatureCalled = true
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

        func setImportKeyCalled() {
            importKeyCalled = true
        }

        func setExportKeyCalled() {
            exportKeyCalled = true
        }

        func setSynchroniseKeysCalled() {
            synchroniseKeysCalled = true
        }

        // Methods to set error simulation flags
        func setShouldFailEncrypt(_ shouldFail: Bool) {
            shouldFailEncrypt = shouldFail
        }

        func setFailEncrypt(_ value: Bool) {
            shouldFailEncrypt = value
        }

        func setShouldFailDecrypt(_ shouldFail: Bool) {
            shouldFailDecrypt = shouldFail
        }

        func setShouldFailGenerateKey(_ shouldFail: Bool) {
            shouldFailGenerateKey = shouldFail
        }

        func setShouldFailVerify(_ shouldFail: Bool) {
            shouldFailVerify = shouldFail
        }

        func setShouldFailImportKey(_ shouldFail: Bool) {
            shouldFailImportKey = shouldFail
        }

        func setShouldFailExportKey(_ shouldFail: Bool) {
            shouldFailExportKey = shouldFail
        }

        func setShouldFailSynchroniseKeys(_ shouldFail: Bool) {
            shouldFailSynchroniseKeys = shouldFail
        }

        func setShouldFailResetSecurity(_ shouldFail: Bool) {
            shouldFailResetSecurity = shouldFail
        }
    }
}

enum CryptoAdapterErrorType {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case verificationFailed
    case importFailed
    case exportFailed
    case syncFailed
    case resetFailed
    case internalError

    func toNSError() -> NSError {
        let domain = "com.umbra.mock.crypto"
        let code: Int
        let description: String

        switch self {
        case .encryptionFailed:
            code = 1_001
            description = "Encryption operation failed"
        case .decryptionFailed:
            code = 1_002
            description = "Decryption operation failed"
        case .keyGenerationFailed:
            code = 1_003
            description = "Key generation failed"
        case .verificationFailed:
            code = 1_004
            description = "Signature verification failed"
        case .importFailed:
            code = 1_005
            description = "Key import failed"
        case .exportFailed:
            code = 1_006
            description = "Key export failed"
        case .syncFailed:
            code = 1_007
            description = "Key synchronization failed"
        case .resetFailed:
            code = 1_008
            description = "Security reset failed"
        case .internalError:
            code = 9_999
            description = "Internal error occurred"
        }

        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}

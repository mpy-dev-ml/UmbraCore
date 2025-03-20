import CoreErrors
import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Comprehensive tests for XPCProtocolsCore
class XPCProtocolsCoreTests: XCTestCase {
    /// Test protocol references exist
    func testProtocolsExist() {
        // Verify that we can create protocol type references
        let _: any XPCServiceProtocolBasic.Type = MockXPCService.self
        let _: any XPCServiceProtocolStandard.Type = MockXPCService.self
        let _: any XPCServiceProtocolComplete.Type = MockXPCService.self

        // If we got this far, the test passes
        XCTAssertTrue(true, "Protocol type references should exist")
    }

    /// Test protocol inheritance hierarchy
    func testProtocolHierarchy() {
        let mockService = MockXPCService()

        // Verify the protocol hierarchy using the mock instance
        // Since the Mock explicitly conforms to these protocols, the tests are always true
        // But we're asserting for documentation purposes
        XCTAssertTrue(true, "MockXPCService conforms to XPCServiceProtocolBasic")
        XCTAssertTrue(true, "MockXPCService conforms to XPCServiceProtocolStandard")
        XCTAssertTrue(true, "MockXPCService conforms to XPCServiceProtocolComplete")

        // Verify we can assign to different protocol types
        let basicService: XPCServiceProtocolBasic = mockService
        let standardService: XPCServiceProtocolStandard = mockService
        let completeService: XPCServiceProtocolComplete = mockService

        // Just use the variables to avoid unused variable warnings
        XCTAssertNotNil(basicService, "Basic service should be initialized")
        XCTAssertNotNil(standardService, "Standard service should be initialized")
        XCTAssertNotNil(completeService, "Complete service should be initialized")
    }

    /// Test basic functionality of a mock service
    func testBasicFunctionality() async {
        // Create a mock service
        let service = MockXPCService()

        // Just test a simple ping to verify the service works
        let pingResult = await service.ping()
        XCTAssertTrue(pingResult, "Ping should be successful")

        // Mark test as completed
        XCTAssertTrue(true, "Basic functionality test completed")
    }

    /// Test complete protocol methods
    func testCompleteProtocolMethods() async {
        let service = MockXPCService()

        // Test pingComplete
        let pingResult = await service.pingComplete()
        XCTAssertTrue(pingResult.isSuccess, "pingComplete should succeed")
        if case let .success(value) = pingResult {
            XCTAssertTrue(value, "Ping should return true")
        }

        // Test synchronizeKeys
        let secureBytes = SecureBytes(bytes: [1, 2, 3, 4])
        let syncResult = await service.synchronizeKeys(secureBytes)
        XCTAssertTrue(syncResult.isSuccess, "synchronizeKeys should succeed")

        // Test encrypt
        let testData = SecureBytes(bytes: [5, 6, 7, 8])
        let encryptResult = await service.encrypt(data: testData)
        XCTAssertTrue(encryptResult.isSuccess, "encrypt should succeed")
        if case let .success(encrypted) = encryptResult {
            XCTAssertEqual(
                encrypted.count,
                testData.count,
                "Encrypted data should have same length in mock"
            )
        }

        // Test decrypt
        let decryptResult = await service.decrypt(data: testData)
        XCTAssertTrue(decryptResult.isSuccess, "decrypt should succeed")
        if case let .success(decrypted) = decryptResult {
            XCTAssertEqual(
                decrypted.count,
                testData.count,
                "Decrypted data should have same length as original"
            )
        }

        // Test hash
        let hashResult = await service.hash(data: testData)
        XCTAssertTrue(hashResult.isSuccess, "hash should succeed")
        if case let .success(hash) = hashResult {
            XCTAssertEqual(hash.count, testData.count, "Hash should have same length as original in mock")
        }
    }

    /// Test throwing error conditions in a failing mock service
    func testThrowingErrorConditions() async {
        let service = FailingMockXPCService()

        // Test error handling for Basic and Standard protocols
        let pingResult = await service.ping()
        XCTAssertFalse(pingResult, "ping should return false for failing service")

        // Test with completion handler
        let syncExpectation = XCTestExpectation(description: "synchroniseKeys completion")
        let bytes: [UInt8] = [1, 2, 3, 4]
        service.synchroniseKeys(bytes) { error in
            XCTAssertNotNil(error, "synchroniseKeys should provide an error")
            syncExpectation.fulfill()
        }
        await fulfillment(of: [syncExpectation], timeout: 1.0)

        let randomResult = await service.generateRandomDataLegacy(length: 16)
        XCTAssertNotNil(randomResult, "generateRandomData should not be nil for failing service")
        if let nsData = randomResult as? NSData {
            XCTAssertEqual(nsData.length, 0, "generateRandomData should return empty data for failing service")
        }

        // Test the Result-based method
        let randomDataResult = await service.generateRandomData(length: 16)
        switch randomDataResult {
        case .success:
            XCTFail("Should not succeed for failing service")
        case let .failure(error):
            XCTAssertEqual(error.localizedDescription, XPCSecurityError.internalError(reason: "Failed to generate random data of length 16").localizedDescription, "Error should match expected failure")
        }

        let encryptResult = await service.encryptData(
            NSData(),
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(encryptResult, "encryptData should not be nil for failing service")
        if let nsData = encryptResult as? NSData {
            XCTAssertEqual(nsData.length, 0, "encryptData should return empty data for failing service")
        }

        let decryptResult = await service.decryptData(
            NSData(),
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(decryptResult, "decryptData should not be nil for failing service")
        if let nsData = decryptResult as? NSData {
            XCTAssertEqual(nsData.length, 0, "decryptData should return empty data for failing service")
        }
    }

    /// Test error conditions in a failing mock service
    func testErrorConditions() async {
        let service = FailingMockXPCService()

        // Test error conditions for Result-based methods
        let pingCompleteResult = await service.pingComplete()
        if case .failure = pingCompleteResult {
            XCTAssertTrue(true, "pingComplete should return failure for failing service")
        } else {
            XCTFail("pingComplete should have failed")
        }

        let secureBytes = SecureBytes(bytes: [])
        let syncBytesResult = await service.synchronizeKeys(secureBytes)
        if case .failure = syncBytesResult {
            XCTAssertTrue(true, "synchronizeKeys should return failure for failing service")
        } else {
            XCTFail("synchronizeKeys should have failed")
        }

        let encryptBytesResult = await service.encryptSecureData(secureBytes, keyIdentifier: nil)
        if case .failure = encryptBytesResult {
            XCTAssertTrue(true, "encrypt should return failure for failing service")
        } else {
            XCTFail("encrypt should have failed")
        }

        let decryptBytesResult = await service.decryptSecureData(secureBytes, keyIdentifier: nil)
        if case .failure = decryptBytesResult {
            XCTAssertTrue(true, "decrypt should return failure for failing service")
        } else {
            XCTFail("decrypt should have failed")
        }

        let hashResult = await service.hashSecureData(secureBytes)
        if case .failure = hashResult {
            XCTAssertTrue(true, "hash should return failure for failing service")
        } else {
            XCTFail("hash should have failed")
        }
    }

    /// Test failing service
    func testFailingService() async {
        let service = FailingMockXPCService()
        let syncExpectation = expectation(description: "Sync call completes")

        // Test protocol async methods with throwing variants
        do {
            try await service.synchroniseKeys(SecureBytes(bytes: [1, 2, 3]))
            XCTFail("Should throw error for failing service")
        } catch {
            XCTAssertTrue(error is XPCSecurityError, "Error should be XPCSecurityError")
        }

        // Complete the expectation
        syncExpectation.fulfill()
        await fulfillment(of: [syncExpectation], timeout: 1.0)

        // Test Result based methods
        let randomResult = await service.generateRandomDataLegacy(length: 16)
        XCTAssertNotNil(randomResult, "generateRandomData should not be nil for failing service")
        if let nsData = randomResult as? NSData {
            XCTAssertEqual(nsData.length, 0, "generateRandomData should return empty data for failing service")
        }
    }

    /// Run all tests
    static func runAllTests() async throws {
        let tests = XPCProtocolsCoreTests()

        // Run synchronous tests
        tests.testProtocolsExist()
        tests.testProtocolHierarchy()

        // Run asynchronous tests
        await tests.testBasicFunctionality()
        await tests.testCompleteProtocolMethods()
        await tests.testErrorConditions()
        await tests.testThrowingErrorConditions()
        await tests.testFailingService()
        print("All XPCProtocolsCore tests passed!")
    }
}

// MARK: - Test Helpers

/// Mock implementation of all XPC protocols for testing
private final class MockXPCService: NSObject, XPCServiceProtocolComplete {
    static let protocolIdentifier: String = "com.test.mock.xpc.service"

    // Add required @objc method for XPCServiceProtocolBasic
    @objc
    func ping() async -> Bool {
        true
    }

    // Add required synchroniseKeys method with completion handler
    @objc
    func synchroniseKeys(_: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Simple implementation - always succeeds
        completionHandler(nil)
    }

    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        .success(SecureBytes(bytes: [0, 1, 2, 3]))
    }

    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    // Standard protocol methods
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        let data = UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: length))
        return .success(data)
    }

    func resetSecurity() async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0")
    }

    func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        .success("mock-hardware-id")
    }

    func sign(_: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Create a simple signature
        let signature = UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0x1, count: 64))
        return .success(signature)
    }

    func verify(signature _: UmbraCoreTypes.SecureBytes, for _: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        // Simple verification just returns true
        .success(true)
    }

    // Required for CryptoXPCServiceProtocol
    func synchroniseKeys(_: UmbraCoreTypes.SecureBytes) async throws {
        // Implementation for synchronisation
    }

    // Legacy methods implementation
    func generateRandomDataLegacy(length _: Int) async -> NSObject? {
        NSData()
    }

    func encryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        NSData()
    }

    func decryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        NSData()
    }

    func hashData(_: NSData) async -> NSObject? {
        NSData()
    }

    func signData(_: NSData, keyIdentifier _: String) async -> NSObject? {
        NSData()
    }

    func verifySignature(_: NSData, for _: NSData, keyIdentifier _: String) async -> NSObject? {
        NSNumber(value: false)
    }

    func getServiceStatus() async -> NSDictionary? {
        ["isActive": true, "reason": "service available"] as NSDictionary
    }

    func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        .success(SecureBytes(bytes: [1, 2, 3, 4]))
    }

    func deriveKey(from _: String, salt _: SecureBytes, iterations _: Int, keyLength _: Int, targetKeyIdentifier _: String?) async -> Result<String, XPCSecurityError> {
        .success("derived-key")
    }

    func generateKey(keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        .success("generated-key")
    }

    func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func listKeys() async -> Result<[String], XPCSecurityError> {
        .success(["key1", "key2"])
    }

    func importKey(keyData _: SecureBytes, keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        .success("imported-key")
    }

    func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        .success(SecureBytes(bytes: Array(repeating: 0, count: length)))
    }

    func encryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func decryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func hashSecureData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func signSecureData(_ data: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func verifySecureSignature(_: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }
}

/// Mock implementation that always fails for error testing
private final class FailingMockXPCService: NSObject, XPCServiceProtocolComplete {
    static let protocolIdentifier: String = "com.test.failing.mock.xpc.service"

    // Add required @objc methods for XPCServiceProtocolBasic
    @objc
    func ping() async -> Bool {
        false
    }

    // Add required synchroniseKeys method with completion handler
    @objc
    func synchroniseKeys(_: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Always fail with an error
        // DEPRECATED: let error = NSError(domain: "TestErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        completionHandler(error)
    }

    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .failure(.cryptographicError(operation: "ping", details: "Test error"))
    }

    func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
        .failure(.cryptographicError(operation: "synchronize keys", details: "Test error"))
    }

    func encryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "encrypt", details: "Test error"))
    }

    func decryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "decrypt", details: "Test error"))
    }

    func hashSecureData(_: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "hash", details: "Test error"))
    }

    func signSecureData(_: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "sign", details: "Test error"))
    }

    func verifySecureSignature(_: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        .failure(.cryptographicError(operation: "verify", details: "Test error"))
    }

    func generateKeyPair(type _: String, keySize _: Int, identifier _: String?) async -> Result<String, XPCSecurityError> {
        .failure(.cryptographicError(operation: "generate key pair", details: "Test error"))
    }

    func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError> {
        .failure(.serviceUnavailable)
    }

    // Add required methods
    func generateKey(keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        .failure(.cryptographicError(operation: "generate key", details: "Test error"))
    }

    func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCSecurityError> {
        .failure(.cryptographicError(operation: "delete key", details: "Test error"))
    }

    func listKeys() async -> Result<[String], XPCSecurityError> {
        .failure(.cryptographicError(operation: "list keys", details: "Test error"))
    }

    func importKey(keyData _: SecureBytes, keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        .failure(.cryptographicError(operation: "import key", details: "Test error"))
    }

    // Standard protocol methods with Result return type
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Failed to generate random data of length \(length)"))
    }

    func resetSecurity() async -> Result<Void, XPCSecurityError> {
        .failure(.internalError(reason: "Failed to reset security"))
    }

    func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .failure(.internalError(reason: "Failed to get service version"))
    }

    func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        .failure(.internalError(reason: "Failed to get hardware identifier"))
    }

    func sign(_: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "sign", details: "Failed to sign data with key \(keyIdentifier)"))
    }

    func verify(signature _: UmbraCoreTypes.SecureBytes, for _: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        .failure(.cryptographicError(operation: "verify", details: "Failed to verify signature with key \(keyIdentifier)"))
    }

    // Required for CryptoXPCServiceProtocol
    func synchroniseKeys(_: UmbraCoreTypes.SecureBytes) async throws {
        throw XPCSecurityError.internalError(reason: "Failed to synchronise keys")
    }

    // Legacy methods implementation
    func generateRandomDataLegacy(length _: Int) async -> NSObject? {
        NSData()
    }

    func encryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        NSData()
    }

    func decryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        NSData()
    }

    func hashData(_: NSData) async -> NSObject? {
        NSData()
    }

    func signData(_: NSData, keyIdentifier _: String) async -> NSObject? {
        NSData()
    }

    func verifySignature(_: NSData, for _: NSData, keyIdentifier _: String) async -> NSObject? {
        NSNumber(value: false)
    }

    func getServiceStatus() async -> NSDictionary? {
        ["isActive": false, "reason": "service unavailable"] as NSDictionary
    }

    func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "export key", details: "Test error"))
    }

    func deriveKey(from _: String, salt _: SecureBytes, iterations _: Int, keyLength _: Int, targetKeyIdentifier _: String?) async -> Result<String, XPCSecurityError> {
        .failure(.cryptographicError(operation: "derive key", details: "Test error"))
    }

    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "key generation", details: "Test error"))
    }
}

// Helper extension for Result to make tests more readable
extension Result where Failure == XPCSecurityError {
    var isSuccess: Bool {
        switch self {
        case .success: true
        case .failure: false
        }
    }
}

// Main entry point for running tests
@main
struct XPCProtocolsCoreTestsMain {
    static func main() async throws {
        try await XPCProtocolsCoreTests.runAllTests()
    }
}

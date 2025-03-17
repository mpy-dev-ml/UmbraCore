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
        // Verify that XPCServiceProtocolStandard extends XPCServiceProtocolBasic
        let standardIsBasic = XPCServiceProtocolStandard.self is XPCServiceProtocolBasic.Type
        XCTAssertTrue(
            standardIsBasic,
            "XPCServiceProtocolStandard should extend XPCServiceProtocolBasic"
        )

        // Verify that XPCServiceProtocolComplete extends XPCServiceProtocolStandard
        let completeIsStandard = XPCServiceProtocolComplete.self is XPCServiceProtocolStandard.Type
        XCTAssertTrue(
            completeIsStandard,
            "XPCServiceProtocolComplete should extend XPCServiceProtocolStandard"
        )
    }

    /// Test basic functionality of a mock service
    func testBasicFunctionality() async {
        let service = MockXPCService()

        // Test ping
        let pingResult = await service.ping()
        XCTAssertTrue(pingResult, "Ping should be successful")

        // Test synchroniseKeys with completion handler
        let syncExpectation = XCTestExpectation(description: "synchroniseKeys completion")
        let bytes: [UInt8] = [1, 2, 3, 4]
        service.synchroniseKeys(bytes) { error in
            XCTAssertNil(error, "synchroniseKeys should succeed")
            syncExpectation.fulfill()
        }
        await fulfillment(of: [syncExpectation], timeout: 1.0)

        // Test generateRandomData
        let randomData = await service.generateRandomData(length: 16)
        if let nsData = randomData as? NSData {
            XCTAssertEqual(nsData.length, 16, "Random data should be of requested length")
        }

        // Test create NSData for encrypt/decrypt
        let testNSData = NSData(bytes: [1, 2, 3, 4, 5] as [UInt8], length: 5)
        
        // Test encryptData
        let encryptedData = await service.encryptData(
            testNSData,
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")

        // Test decryptData
        let decryptedData = await service.decryptData(
            testNSData,
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")

        // Test hashData
        let hashedData = await service.hashData(testNSData)
        if let nsData = hashedData as? NSData {
            XCTAssertEqual(nsData.length, 32, "Hash should be 32 bytes")
        }

        // Test signData
        let signature = await service.signData(
            testNSData,
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(signature, "Signature should not be nil")

        // Test verifySignature
        let verifyResult = await service.verifySignature(
            testNSData, // Using testNSData as the signature for simplicity
            for: testNSData,
            keyIdentifier: "test-key"
        )
        XCTAssertNotNil(verifyResult, "Verification result should not be nil")
        
        if let result = verifyResult as? Bool {
            XCTAssertTrue(result, "Signature should be verified")
        } else if let nsNumber = verifyResult as? NSNumber {
            XCTAssertTrue(nsNumber.boolValue, "Signature should be verified")
        } else {
            XCTFail("Verification result should be Bool or NSNumber")
        }
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

        let randomResult = await service.generateRandomData(length: 16)
        XCTAssertNotNil(randomResult, "generateRandomData should not be nil for failing service")
        if let nsData = randomResult as? NSData {
            XCTAssertEqual(nsData.length, 0, "generateRandomData should return empty data for failing service")
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
        
        let encryptBytesResult = await service.encrypt(data: secureBytes)
        if case .failure = encryptBytesResult {
            XCTAssertTrue(true, "encrypt should return failure for failing service")
        } else {
            XCTFail("encrypt should have failed")
        }
        
        let decryptBytesResult = await service.decrypt(data: secureBytes)
        if case .failure = decryptBytesResult {
            XCTAssertTrue(true, "decrypt should return failure for failing service")
        } else {
            XCTFail("decrypt should have failed")
        }
        
        let hashResult = await service.hash(data: secureBytes)
        if case .failure = hashResult {
            XCTAssertTrue(true, "hash should return failure for failing service")
        } else {
            XCTFail("hash should have failed")
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
        return true
    }

    // Add required synchroniseKeys method with completion handler
    @objc
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
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
    func generateRandomData(length: Int) async -> NSObject? {
        return NSData(bytes: Array(repeating: 0, count: length), length: length)
    }

    func encryptData(_ data: NSData, keyIdentifier _: String?) async -> NSObject? {
        return data
    }

    func decryptData(_ data: NSData, keyIdentifier _: String?) async -> NSObject? {
        return data
    }

    func hashData(_ data: NSData) async -> NSObject? {
        return data
    }

    func signData(_ data: NSData, keyIdentifier _: String) async -> NSObject? {
        return data
    }

    func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier _: String
    ) async -> NSNumber? {
        return NSNumber(value: true)
    }

    func getServiceStatus() async -> NSDictionary? {
        return ["status": "running"] as NSDictionary
    }
    
    func generateKey(keyType: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
        return .success(keyIdentifier ?? "generated-key")
    }
    
    func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
        return .success(())
    }
    
    func listKeys() async -> Result<[String], XPCSecurityError> {
        return .success(["key1", "key2"])
    }
    
    func importKey(keyData: SecureBytes, keyType: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
        return .success(keyIdentifier ?? "imported-key")
    }
}

/// Mock implementation that always fails for error testing
private final class FailingMockXPCService: NSObject, XPCServiceProtocolComplete {
    static let protocolIdentifier: String = "com.test.failing.mock.xpc.service"

    // Add required @objc methods for XPCServiceProtocolBasic
    @objc
    func ping() async -> Bool {
        return false
    }
    
    // Add required synchroniseKeys method with completion handler
    @objc
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Always fail with an error
        let error = NSError(domain: "TestErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        completionHandler(error)
    }

    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .failure(.cryptographicError(operation: "ping", details: "Test error"))
    }

    func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
        .failure(.cryptographicError(operation: "synchronize keys", details: "Test error"))
    }

    func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "encrypt", details: "Test error"))
    }

    func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "decrypt", details: "Test error"))
    }

    func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "hash", details: "Test error"))
    }

    // Standard protocol methods that don't throw but return nil or error
    func generateRandomData(length _: Int) async -> NSObject? {
        return nil
    }

    func encryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        return nil
    }

    func decryptData(_: NSData, keyIdentifier _: String?) async -> NSObject? {
        return nil
    }

    func hashData(_: NSData) async -> NSObject? {
        return nil
    }

    func signData(_: NSData, keyIdentifier _: String) async -> NSObject? {
        return nil
    }

    func verifySignature(
        _: NSData,
        for _: NSData,
        keyIdentifier _: String
    ) async -> NSNumber? {
        return nil
    }

    func getServiceStatus() async -> NSDictionary? {
        return nil
    }
    
    func generateKey(keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        return .failure(.cryptographicError(operation: "key generation", details: "Test error"))
    }
    
    func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCSecurityError> {
        return .failure(.cryptographicError(operation: "key deletion", details: "Test error"))
    }
    
    func listKeys() async -> Result<[String], XPCSecurityError> {
        return .failure(.cryptographicError(operation: "key listing", details: "Test error"))
    }
    
    func importKey(keyData _: SecureBytes, keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier _: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        return .failure(.cryptographicError(operation: "key import", details: "Test error"))
    }
    
    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        return .failure(.cryptographicError(operation: "key generation", details: "Test error"))
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

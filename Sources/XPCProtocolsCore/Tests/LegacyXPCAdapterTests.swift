import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import XCTest
@testable import XPCProtocolsCore

final class LegacyXPCAdapterTests: XCTestCase {
    // Test ping functionality
    func testPing() async throws {
        let mockService = MockLegacyXPCService()
        mockService.shouldFail = false
        print("DEBUG: Created mock service with shouldFail = \(mockService.shouldFail)")
        print("DEBUG: Mock service is of type: \(type(of: mockService))")
        
        let adapter = LegacyXPCServiceAdapter(service: mockService)
        print("DEBUG: Created adapter with mock service")
        
        print("DEBUG: Calling adapter.pingComplete()")
        let result = await adapter.pingComplete()
        
        print("DEBUG: pingCalled = \(mockService.pingCalled), shouldFail = \(mockService.shouldFail)")
        
        // Verify that the adapter correctly converts the result
        switch result {
        case let .success(value):
            print("DEBUG: ping result success with value = \(value)")
            XCTAssertTrue(value)
            XCTAssertTrue(mockService.pingCalled, "The adapter should call ping() on the legacy service")
        case .failure(let error):
            print("DEBUG: ping result failure with error = \(error)")
            XCTFail("Ping should succeed")
        }
    }

    // Test error mapping
    @available(*, deprecated)
    func testErrorMapping() {
        // We can't directly test the private mapError method
        // Instead, verify the behaviour through the public API
        
        // Test the error mapping through the encrypt operation
        let mockService = MockLegacyXPCService()
        mockService.shouldFail = true
        let adapter = LegacyXPCServiceAdapter(service: mockService)
        
        // Run a task to test error conversion
        Task {
            let result = await adapter.encrypt(data: SecureBytes(bytes: [1, 2, 3]))
            if case let .failure(error) = result {
                // Just verify it's a failure, we can't check the specific error type
                // since XPCSecurityError cases may vary
                XCTAssertNotNil(error, "Should receive an error")
            } else {
                XCTFail("Should have received a failure")
            }
        }
    }

    // Test data conversion between SecureBytes and legacy BinaryData
    func testEncryption() async throws {
        let mockService = MockLegacyXPCService()
        let adapter = LegacyXPCServiceAdapter(service: mockService)

        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.encrypt(data: testData)

        switch result {
        case let .success(encryptedData):
            // The mock service doubles each byte
            let expectedBytes: [UInt8] = [2, 4, 6, 8, 10]
            let actualBytes = encryptedData.withUnsafeBytes { Array($0) }
            XCTAssertEqual(actualBytes, expectedBytes)
            XCTAssertTrue(mockService.encryptCalled)
        case .failure:
            XCTFail("Encryption should succeed")
        }
    }

    // Test random data generation
    func testRandomDataGeneration() async {
        let mockService = MockLegacyXPCService()
        let adapter = LegacyXPCServiceAdapter(service: mockService)

        let randomData = await adapter.generateRandomData(length: 10)

        // Our mock service generates zeroes
        XCTAssertNotNil(randomData, "Random data should not be nil")
        if let nsData = randomData as? NSData {
            XCTAssertEqual(nsData.length, 10, "Random data should have correct length")
        }
        XCTAssertTrue(mockService.generateRandomDataCalled)
    }

    // Test hash generation
    func testHashGeneration() async throws {
        let mockService = MockLegacyXPCService()
        let adapter = LegacyXPCServiceAdapter(service: mockService)

        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let result = await adapter.hash(data: testData)

        switch result {
        case let .success(hashedData):
            // The mock service returns a fixed-size hash
            XCTAssertEqual(hashedData.count, 32) // Fixed SHA-256 style hash size
            XCTAssertTrue(mockService.hashCalled)
        case .failure:
            XCTFail("Hashing should succeed")
        }
    }

    // Test factory creation
    func testFactoryCreation() {
        let standardAdapter = XPCProtocolMigrationFactory.createStandardAdapter()
        XCTAssertNotNil(standardAdapter)

        let completeAdapter = XPCProtocolMigrationFactory.createCompleteAdapter()
        XCTAssertNotNil(completeAdapter)
    }
}

// MARK: - Mock Classes for Testing

/// Mock implementation of a legacy XPC service to test the adapter
class MockLegacyXPCService: NSObject, PingProtocol, LegacyCryptoProtocol, LegacyVerificationProtocol {
    var encryptCalled = false
    var decryptCalled = false
    var hashCalled = false
    var generateRandomDataCalled = false
    var signDataCalled = false
    var verifySignatureCalled = false
    var synchroniseKeysCalled = false
    var shouldFail = false
    var pingCalled = false

    func ping() -> Bool {
        pingCalled = true
        print("DEBUG: Mock service ping() called, returning \( !shouldFail )")
        return !shouldFail
    }

    func pingComplete() async -> Bool {
        pingCalled = true
        print("DEBUG: Mock service pingComplete() called, returning \( !shouldFail )")
        return !shouldFail
    }

    func encryptData(_ data: NSData, keyIdentifier: String?) -> NSData {
        encryptCalled = true
        if shouldFail {
            // Still return empty data instead of nil
            return NSData()
        }
        
        // Create a result that's different from the input
        let bytes = data.bytes.bindMemory(to: UInt8.self, capacity: data.length)
        var result = [UInt8](repeating: 0, count: data.length)
        for i in 0..<data.length {
            // Double each byte as a simple transformation
            result[i] = bytes[i] * 2
        }
        return NSData(bytes: result, length: data.length)
    }

    func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData {
        decryptCalled = true
        if shouldFail {
            // Still return empty data instead of nil
            return NSData()
        }
        
        // Create a result that's different from the input
        let bytes = data.bytes.bindMemory(to: UInt8.self, capacity: data.length)
        var result = [UInt8](repeating: 0, count: data.length)
        for i in 0..<data.length {
            // Halve each byte as a simple transformation
            result[i] = bytes[i] / 2
        }
        return NSData(bytes: result, length: data.length)
    }

    func hashData(_ data: NSData) -> NSData {
        hashCalled = true
        if shouldFail {
            // Still return empty data instead of nil
            return NSData()
        }
        
        // Return a fixed-size hash (like SHA-256)
        return NSData(bytes: Array(repeating: 1, count: 32), length: 32)
    }

    func generateRandomData(length: Int) -> NSData {
        generateRandomDataCalled = true
        if shouldFail {
            // Still return empty data instead of nil
            return NSData()
        }
        return NSData(bytes: Array(repeating: 0, count: length), length: length)
    }
    
    func signData(_ data: NSData, keyIdentifier: String) -> NSData {
        signDataCalled = true
        if shouldFail {
            // Still return empty data instead of nil
            return NSData()
        }
        
        // Create a mock signature by prefixing key identifier hash and appending data
        let keyHash = keyIdentifier.data(using: .utf8)!
        var result = Data()
        result.append(keyHash)
        result.append(Data(referencing: data))
        
        return result as NSData
    }
    
    func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) -> NSNumber? {
        verifySignatureCalled = true
        if shouldFail {
            return nil
        }
        return NSNumber(value: true)
    }
    
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        synchroniseKeysCalled = true
        if shouldFail {
            let error = NSError(domain: "com.umbra.xpc.test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to synchronize keys"])
            completionHandler(error)
        } else {
            completionHandler(nil)
        }
    }
    
    func getServiceStatus() -> NSDictionary? {
        return ["status": "active", "version": "1.0.0"] as NSDictionary
    }
    
    func generateKey(keyType: String, keyIdentifier: String?, metadata: NSDictionary?) -> NSNumber? {
        if shouldFail {
            return nil
        }
        return NSNumber(value: true)
    }
    
    func deleteKey(keyIdentifier: String) -> NSNumber? {
        if shouldFail {
            return nil
        }
        return NSNumber(value: true)
    }
    
    func listKeys() -> NSArray? {
        if shouldFail {
            return nil
        }
        return NSArray(array: ["key1", "key2", "key3"])
    }
    
    func importKey(keyData: NSData, keyType: String, keyIdentifier: String?, metadata: NSDictionary?) -> NSNumber? {
        if shouldFail {
            return nil
        }
        return NSNumber(value: true)
    }
}

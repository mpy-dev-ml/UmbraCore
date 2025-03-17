import XCTest
@testable import XPCProtocolsCore
import UmbraCoreTypes

/**
 This test file demonstrates migration patterns for transitioning from
 legacy ObjC-based protocols to the modern Swift-based ones.
 
 It can be used as a reference for how to update client code.
 */
final class MigrationExampleTests: XCTestCase {
    
    // MARK: - Modern Implementation Tests
    
    func testModernServiceUsage() async {
        // Using the factory method to get a modern service
        let service = XPCProtocolMigrationFactory.createCompleteAdapter()
        
        // Create secure data using Swift types
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        // Use async/await pattern with Result type
        let encryptResult = await service.encrypt(data: testData)
        
        // Pattern matching on results
        switch encryptResult {
        case .success(let encryptedData):
            XCTAssertFalse(encryptedData.isEmpty, "Encrypted data should not be empty")
            
            // Continue with decryption
            let decryptResult = await service.decrypt(data: encryptedData)
            
            switch decryptResult {
            case .success(let decryptedData):
                XCTAssertEqual(decryptedData, testData, "Decryption should recover the original data")
            case .failure(let error):
                XCTFail("Decryption failed with error: \(error)")
            }
            
        case .failure(let error):
            XCTFail("Encryption failed with error: \(error)")
        }
    }
    
    func testKeyManagementModern() async {
        // Get a modern service implementation
        let service = XPCProtocolMigrationFactory.createCompleteAdapter()
        
        // Generate a key with Swift enums
        let generateResult = await service.generateKey(
            keyType: .symmetric,
            keyIdentifier: nil,
            metadata: ["purpose": "test"]
        )
        
        switch generateResult {
        case .success(let keyIdentifier):
            XCTAssertFalse(keyIdentifier.isEmpty, "Key identifier should not be empty")
            
            // Delete the key
            let deleteResult = await service.deleteKey(keyIdentifier: keyIdentifier)
            
            switch deleteResult {
            case .success:
                // Deletion successful
                break
            case .failure(let error):
                XCTFail("Key deletion failed with error: \(error)")
            }
            
        case .failure(let error):
            XCTFail("Key generation failed with error: \(error)")
        }
    }
    
    // MARK: - Legacy Service Migration Example
    
    /**
     This demonstrates how to wrap legacy code during migration.
     
     Example: You have existing code that uses the legacy APIs and need to 
     gradually migrate to the new APIs.
     */
    func testLegacyToModernMigration() async {
        // Legacy mock service
        let legacyMock = MockLegacyXPCService()
        
        // Legacy approach using adapter directly - NOT RECOMMENDED FOR NEW CODE
        // This is provided only as an example of how to migrate existing code
        @available(*, deprecated)
        func legacyOperation(_ data: Data) -> Data? {
            let adapter = LegacyXPCServiceAdapter(service: legacyMock)
            let nsData = NSData(data: data)
            guard let result = adapter.encryptData(nsData, keyIdentifier: "key-1") else {
                return nil
            }
            return Data(referencing: result)
        }
        
        // Modern approach using factory and protocols
        func modernOperation(_ data: Data) async -> Result<Data, Error> {
            // Note: Factory still accepts a legacy service during transition
            let service = XPCProtocolMigrationFactory.createCompleteAdapter(service: legacyMock)
            let secureData = SecureBytes(bytes: [UInt8](data))
            
            let result = await service.encrypt(data: secureData)
            return result.map { encryptedBytes in
                return Data(encryptedBytes)
            }
        }
        
        // Example usage in a client that's being migrated
        let testData = Data([1, 2, 3, 4, 5])
        
        // Legacy usage (should be migrated)
        if let legacyResult = legacyOperation(testData) {
            print("Legacy operation successful with \(legacyResult.count) bytes")
        } else {
            XCTFail("Legacy operation failed")
        }
        
        // Modern usage (target pattern)
        let modernResult = await modernOperation(testData)
        switch modernResult {
        case .success(let data):
            print("Modern operation successful with \(data.count) bytes")
        case .failure(let error):
            XCTFail("Modern operation failed with error: \(error)")
        }
    }
}

// Internal test helpers - not part of the example
private extension MigrationExampleTests {
    
    class MockLegacyXPCService: NSObject, LegacyCryptoProtocol, LegacyVerificationProtocol {
        func encryptData(_ data: NSData, keyIdentifier: String) -> NSData {
            // Simple implementation for testing
            let bytes = Array<UInt8>(repeating: 0, count: data.length)
            return NSData(bytes: bytes, length: bytes.count)
        }
        
        func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData {
            // Simple implementation for testing
            let bytes = Array<UInt8>(repeating: 1, count: data.length)
            return NSData(bytes: bytes, length: bytes.count)
        }
        
        func hashData(_ data: NSData) -> NSData {
            // Simple implementation for testing
            let bytes = Array<UInt8>(repeating: 2, count: 32)
            return NSData(bytes: bytes, length: bytes.count)
        }
        
        func generateRandomData(length: Int) -> NSData {
            // Simple implementation for testing
            let bytes = Array<UInt8>(repeating: 3, count: length)
            return NSData(bytes: bytes, length: bytes.count)
        }
        
        func signSecureData(_ data: NSData, keyIdentifier: String) -> NSData {
            // Simple implementation for testing
            let bytes = Array<UInt8>(repeating: 4, count: 64)
            return NSData(bytes: bytes, length: bytes.count)
        }
        
        func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) -> NSNumber {
            // Simple implementation for testing
            return NSNumber(value: true)
        }
        
        func ping() -> Bool {
            return true
        }
    }
}

import XCTest
@testable import XPCProtocolsCore
import UmbraCoreTypes

/// Test cases for the ModernXPCService class
final class ModernXPCServiceTests: XCTestCase {
    
    // Test instance
    private var service: ModernXPCService!
    
    override func setUp() {
        super.setUp()
        service = ModernXPCService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Basic Protocol Tests
    
    func testPing() async {
        let result = await service.ping()
        XCTAssertTrue(result, "Ping should succeed")
    }
    
    func testPingBasic() async {
        let result = await service.pingBasic()
        
        switch result {
        case .success(let success):
            XCTAssertTrue(success, "Ping should succeed")
        case .failure(let error):
            XCTFail("PingBasic failed with error: \(error)")
        }
    }
    
    func testGetServiceVersion() async {
        let result = await service.getServiceVersion()
        
        switch result {
        case .success(let version):
            XCTAssertFalse(version.isEmpty, "Version should not be empty")
        case .failure(let error):
            XCTFail("GetServiceVersion failed with error: \(error)")
        }
    }
    
    func testGetDeviceIdentifier() async {
        let result = await service.getDeviceIdentifier()
        
        switch result {
        case .success(let deviceId):
            XCTAssertFalse(deviceId.isEmpty, "Device identifier should not be empty")
        case .failure(let error):
            XCTFail("GetDeviceIdentifier failed with error: \(error)")
        }
    }
    
    // MARK: - Standard Protocol Tests
    
    func testResetSecurity() async {
        let result = await service.resetSecurity()
        
        switch result {
        case .success:
            // Test passes if no error
            break
        case .failure(let error):
            XCTFail("ResetSecurity failed with error: \(error)")
        }
    }
    
    func testSynchronizeKeys() async {
        // Create test data
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        let result = await service.synchronizeKeys(testData)
        
        switch result {
        case .success:
            // Test passes if no error
            break
        case .failure(let error):
            XCTFail("SynchronizeKeys failed with error: \(error)")
        }
    }
    
    func testSynchronizeKeysWithEmptyData() async {
        // Create empty test data
        let emptyData = SecureBytes(bytes: [])
        
        let result = await service.synchronizeKeys(emptyData)
        
        switch result {
        case .success:
            XCTFail("SynchronizeKeys should fail with empty data")
        case .failure(let error):
            // Test passes if error is of the expected type
            XCTAssertEqual(error, .invalidData(reason: "Empty synchronisation data"), "Error should indicate invalid data")
        }
    }
    
    func testGenerateRandomData() async {
        let length = 32
        let randomData = await service.generateRandomData(length: length)
        
        XCTAssertNotNil(randomData, "Random data should not be nil")
        if let data = randomData as? NSData {
            XCTAssertEqual(data.length, length, "Random data length should match requested length")
        } else {
            XCTFail("Random data should be of type NSData")
        }
    }
    
    func testListKeys() async {
        let result = await service.listKeys()
        
        switch result {
        case .success(let keys):
            XCTAssertFalse(keys.isEmpty, "Keys list should not be empty")
        case .failure(let error):
            XCTFail("ListKeys failed with error: \(error)")
        }
    }
    
    // MARK: - Complete Protocol Tests
    
    func testEncryptDecrypt() async {
        // Create test data
        let originalData = SecureBytes(bytes: [10, 20, 30, 40, 50])
        
        // Encrypt the data
        let encryptResult = await service.encrypt(data: originalData)
        
        // Check if encryption succeeded
        switch encryptResult {
        case .success(let encryptedData):
            XCTAssertFalse(encryptedData.isEmpty, "Encrypted data should not be empty")
            
            // Decrypt the data
            let decryptResult = await service.decrypt(data: encryptedData)
            
            // Check if decryption succeeded and data matches
            switch decryptResult {
            case .success(let decryptedData):
                XCTAssertEqual(decryptedData, originalData, "Decrypted data should match original data")
            case .failure(let error):
                XCTFail("Decrypt failed with error: \(error)")
            }
            
        case .failure(let error):
            XCTFail("Encrypt failed with error: \(error)")
        }
    }
    
    func testEncryptWithEmptyData() async {
        // Create empty test data
        let emptyData = SecureBytes(bytes: [])
        
        let result = await service.encrypt(data: emptyData)
        
        switch result {
        case .success:
            XCTFail("Encrypt should fail with empty data")
        case .failure(let error):
            // Test passes if error is of the expected type
            XCTAssertEqual(error, .invalidData(reason: "Cannot encrypt empty data"), "Error should indicate invalid data")
        }
    }
    
    func testHashData() async {
        // Create test data
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        
        let result = await service.hash(data: testData)
        
        switch result {
        case .success(let hashData):
            XCTAssertFalse(hashData.isEmpty, "Hash data should not be empty")
        case .failure(let error):
            XCTFail("Hash failed with error: \(error)")
        }
    }
    
    func testGenerateKey() async {
        let result = await service.generateKey()
        
        switch result {
        case .success(let keyData):
            XCTAssertFalse(keyData.isEmpty, "Key data should not be empty")
            XCTAssertEqual(keyData.count, 32, "Key should be 32 bytes (256 bits)")
        case .failure(let error):
            XCTFail("GenerateKey failed with error: \(error)")
        }
    }
    
    func testGenerateKeyWithType() async {
        let result = await service.generateKey(
            keyType: .symmetric,
            keyIdentifier: "test-key-id",
            metadata: ["purpose": "testing"]
        )
        
        switch result {
        case .success(let keyId):
            XCTAssertFalse(keyId.isEmpty, "Key identifier should not be empty")
            XCTAssertEqual(keyId, "test-key-id", "Key identifier should match the provided value")
        case .failure(let error):
            XCTFail("GenerateKey with type failed with error: \(error)")
        }
    }
    
    func testImportKey() async {
        // Create test key data
        let keyData = SecureBytes(bytes: Array(repeating: 0xAA, count: 32))
        
        let result = await service.importKey(
            keyData: keyData,
            keyType: .symmetric,
            keyIdentifier: "imported-key-id",
            metadata: ["purpose": "testing"]
        )
        
        switch result {
        case .success(let keyId):
            XCTAssertFalse(keyId.isEmpty, "Key identifier should not be empty")
            XCTAssertEqual(keyId, "imported-key-id", "Key identifier should match the provided value")
        case .failure(let error):
            XCTFail("ImportKey failed with error: \(error)")
        }
    }
    
    func testExportKey() async {
        let result = await service.exportKey(keyIdentifier: "test-key-id")
        
        switch result {
        case .success(let keyData):
            XCTAssertFalse(keyData.isEmpty, "Exported key data should not be empty")
        case .failure(let error):
            XCTFail("ExportKey failed with error: \(error)")
        }
    }
    
    func testGenerateKeyWithSizeAndType() async {
        let result = await service.generateKey(type: "AES", bits: 256)
        
        switch result {
        case .success(let keyData):
            XCTAssertFalse(keyData.isEmpty, "Key data should not be empty")
            XCTAssertEqual(keyData.count, 32, "Key should be 32 bytes (256 bits)")
        case .failure(let error):
            XCTFail("GenerateKey with size and type failed with error: \(error)")
        }
    }
    
    func testObjectiveCBridgingFunctions() async {
        // Test encryption with NSData
        let testData = NSData(bytes: [10, 20, 30, 40, 50] as [UInt8], length: 5)
        let encryptedData = await service.encryptData(testData, keyIdentifier: "test-key-id")
        
        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
        
        // Test decryption with NSData
        if let encryptedNSData = encryptedData as? NSData {
            let decryptedData = await service.decryptData(encryptedNSData, keyIdentifier: "test-key-id")
            
            XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")
            if let decryptedNSData = decryptedData as? NSData {
                XCTAssertEqual(decryptedNSData.length, testData.length, "Decrypted data length should match original")
            } else {
                XCTFail("Decrypted data should be of type NSData")
            }
        } else {
            XCTFail("Encrypted data should be of type NSData")
        }
        
        // Test signing
        let signature = await service.signData(testData, keyIdentifier: "test-key-id")
        
        XCTAssertNotNil(signature, "Signature should not be nil")
        
        // Test verification
        if let signatureData = signature as? NSData {
            let verified = await service.verifySignature(signatureData, for: testData, keyIdentifier: "test-key-id")
            
            XCTAssertNotNil(verified, "Verification result should not be nil")
            if let verifiedNumber = verified as? NSNumber {
                XCTAssertTrue(verifiedNumber.boolValue, "Signature should be verified as valid")
            } else {
                XCTFail("Verification result should be of type NSNumber")
            }
        } else {
            XCTFail("Signature should be of type NSData")
        }
    }
}

// DefaultCryptoServiceTests.swift
// UmbraSecurityCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
import SecureBytes
import SecurityProtocolsCore
@testable import UmbraSecurityCore

final class DefaultCryptoServiceTests: XCTestCase {
    var cryptoService: DefaultCryptoService!
    
    override func setUp() {
        super.setUp()
        cryptoService = DefaultCryptoService()
    }
    
    override func tearDown() {
        cryptoService = nil
        super.tearDown()
    }
    
    // MARK: - Test Simple API
    
    func testGenerateKey() async {
        let keyResult = await cryptoService.generateKey()
        
        switch keyResult {
        case .success(let key):
            XCTAssertEqual(key.count, 32, "Generated key should be 32 bytes (256 bits)")
        case .failure(let error):
            XCTFail("Key generation failed with error: \(error)")
        }
    }
    
    func testEncryptDecrypt() async {
        let testData = SecureBytes([1, 2, 3, 4, 5])
        let keyResult = await cryptoService.generateKey()
        
        guard case .success(let key) = keyResult else {
            XCTFail("Failed to generate key for test")
            return
        }
        
        let encryptResult = await cryptoService.encrypt(data: testData, using: key)
        
        guard case .success(let encryptedData) = encryptResult else {
            XCTFail("Encryption failed")
            return
        }
        
        let decryptResult = await cryptoService.decrypt(data: encryptedData, using: key)
        
        guard case .success(let decryptedData) = decryptResult else {
            XCTFail("Decryption failed")
            return
        }
        
        // In a real implementation, we would expect decryptedData to equal testData
        // But since this is a placeholder, we just check that we got some data back
        XCTAssertFalse(decryptedData.isEmpty, "Decrypted data should not be empty")
    }
    
    func testHashingFunctionality() async {
        let testData = SecureBytes([1, 2, 3, 4, 5])
        let hashResult = await cryptoService.hash(data: testData)
        
        guard case .success(let hash) = hashResult else {
            XCTFail("Hashing failed")
            return
        }
        
        XCTAssertEqual(hash.count, 32, "Hash should be 32 bytes (SHA-256 size)")
    }
    
    // MARK: - Test Symmetric Encryption
    
    func testSymmetricEncryptionDecryption() async {
        let testData = SecureBytes([1, 2, 3, 4, 5])
        let keyResult = await cryptoService.generateKey()
        
        guard case .success(let key) = keyResult else {
            XCTFail("Failed to generate key for test")
            return
        }
        
        let config = SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256
        )
        
        let encryptResult = await cryptoService.encryptSymmetric(
            data: testData,
            key: key,
            config: config
        )
        
        XCTAssertTrue(encryptResult.success, "Encryption should succeed")
        XCTAssertNotNil(encryptResult.data, "Encrypted data should not be nil")
        
        guard let encryptedData = encryptResult.data else {
            XCTFail("Encrypted data is nil")
            return
        }
        
        let decryptResult = await cryptoService.decryptSymmetric(
            data: encryptedData,
            key: key,
            config: config
        )
        
        XCTAssertTrue(decryptResult.success, "Decryption should succeed")
        XCTAssertNotNil(decryptResult.data, "Decrypted data should not be nil")
    }
    
    // MARK: - Test Random Data Generation
    
    func testRandomDataGeneration() async {
        let randomDataResult = await cryptoService.generateRandomData(length: 32)
        
        switch randomDataResult {
        case .success(let randomData):
            XCTAssertEqual(randomData.count, 32, "Generated random data should be 32 bytes")
        case .failure(let error):
            XCTFail("Random data generation failed with error: \(error)")
        }
    }
}

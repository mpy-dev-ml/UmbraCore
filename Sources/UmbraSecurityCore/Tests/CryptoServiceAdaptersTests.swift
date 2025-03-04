// CryptoServiceAdaptersTests.swift
// UmbraSecurityCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
import SecurityProtocolsCore
import UmbraCoreTypes
@testable import UmbraSecurityCore

final class CryptoServiceAdaptersTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    /// Helper function for async assertions
    func assertAsync<T: Equatable>(_ expression1: @autoclosure () async -> T, 
                                  _ expression2: @autoclosure () -> T, 
                                  _ message: @autoclosure () -> String = "",
                                  file: StaticString = #filePath, 
                                  line: UInt = #line) async {
        let value = await expression1()
        XCTAssertEqual(value, expression2(), message(), file: file, line: line)
    }
    
    // MARK: - MockCryptoService
    
    /// A mock crypto service for testing adapters
    private final class MockCryptoService: @unchecked Sendable, CryptoServiceProtocol {
        // Using simple atomics for test state since XCTest doesn't work well with async properties
        private var encryptCalled = false
        private var decryptCalled = false
        private var hashCalled = false
        private var generateKeyCalled = false
        private var verifyCalled = false
        private var generateRandomDataCalled = false
        private var encryptSymmetricCalled = false
        private var decryptSymmetricCalled = false
        private var encryptAsymmetricCalled = false
        private var decryptAsymmetricCalled = false
        private var hashWithConfigCalled = false
        
        // Thread-safe access to state with a serial queue
        private let stateQueue = DispatchQueue(label: "com.umbracore.mockcryptoservice", qos: .userInitiated)
        
        // Results for mocking
        let mockEncryptResult: Result<SecureBytes, SecurityError>
        let mockDecryptResult: Result<SecureBytes, SecurityError>
        let mockHashResult: Result<SecureBytes, SecurityError>
        let mockGenerateKeyResult: Result<SecureBytes, SecurityError>
        let mockVerifyResult: Bool
        let mockGenerateRandomDataResult: Result<SecureBytes, SecurityError>
        let mockSecurityResult: SecurityResultDTO
        
        init(
            mockEncryptResult: Result<SecureBytes, SecurityError> = .success(SecureBytes([0x01, 0x02, 0x03])),
            mockDecryptResult: Result<SecureBytes, SecurityError> = .success(SecureBytes([0x04, 0x05, 0x06])),
            mockHashResult: Result<SecureBytes, SecurityError> = .success(SecureBytes([0x07, 0x08, 0x09])),
            mockGenerateKeyResult: Result<SecureBytes, SecurityError> = .success(SecureBytes([0x0A, 0x0B, 0x0C])),
            mockVerifyResult: Bool = true,
            mockGenerateRandomDataResult: Result<SecureBytes, SecurityError> = .success(SecureBytes([0x10, 0x11, 0x12])),
            mockSecurityResult: SecurityResultDTO = SecurityResultDTO(data: SecureBytes([0x13, 0x14, 0x15]))
        ) {
            self.mockEncryptResult = mockEncryptResult
            self.mockDecryptResult = mockDecryptResult
            self.mockHashResult = mockHashResult
            self.mockGenerateKeyResult = mockGenerateKeyResult
            self.mockVerifyResult = mockVerifyResult
            self.mockGenerateRandomDataResult = mockGenerateRandomDataResult
            self.mockSecurityResult = mockSecurityResult
        }
        
        // MARK: - State getters (sync for XCTest compatibility)
        
        func getEncryptCalled() -> Bool {
            stateQueue.sync { encryptCalled }
        }
        
        func getDecryptCalled() -> Bool {
            stateQueue.sync { decryptCalled }
        }
        
        func getHashCalled() -> Bool {
            stateQueue.sync { hashCalled }
        }
        
        func getGenerateKeyCalled() -> Bool {
            stateQueue.sync { generateKeyCalled }
        }
        
        func getVerifyCalled() -> Bool {
            stateQueue.sync { verifyCalled }
        }
        
        func getGenerateRandomDataCalled() -> Bool {
            stateQueue.sync { generateRandomDataCalled }
        }
        
        func getEncryptSymmetricCalled() -> Bool {
            stateQueue.sync { encryptSymmetricCalled }
        }
        
        func getDecryptSymmetricCalled() -> Bool {
            stateQueue.sync { decryptSymmetricCalled }
        }
        
        func getEncryptAsymmetricCalled() -> Bool {
            stateQueue.sync { encryptAsymmetricCalled }
        }
        
        func getDecryptAsymmetricCalled() -> Bool {
            stateQueue.sync { decryptAsymmetricCalled }
        }
        
        func getHashWithConfigCalled() -> Bool {
            stateQueue.sync { hashWithConfigCalled }
        }
        
        // MARK: - CryptoServiceProtocol Implementation
        
        func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
            stateQueue.sync { encryptCalled = true }
            return mockEncryptResult
        }
        
        func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
            stateQueue.sync { decryptCalled = true }
            return mockDecryptResult
        }
        
        func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
            stateQueue.sync { hashCalled = true }
            return mockHashResult
        }
        
        func generateKey() async -> Result<SecureBytes, SecurityError> {
            stateQueue.sync { generateKeyCalled = true }
            return mockGenerateKeyResult
        }
        
        func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
            stateQueue.sync { verifyCalled = true }
            return mockVerifyResult
        }
        
        func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
            stateQueue.sync { generateRandomDataCalled = true }
            return mockGenerateRandomDataResult
        }
        
        func encryptSymmetric(data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
            stateQueue.sync { encryptSymmetricCalled = true }
            return mockSecurityResult
        }
        
        func decryptSymmetric(data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
            stateQueue.sync { decryptSymmetricCalled = true }
            return mockSecurityResult
        }
        
        func encryptAsymmetric(data: SecureBytes, publicKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
            stateQueue.sync { encryptAsymmetricCalled = true }
            return mockSecurityResult
        }
        
        func decryptAsymmetric(data: SecureBytes, privateKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
            stateQueue.sync { decryptAsymmetricCalled = true }
            return mockSecurityResult
        }
        
        func hash(data: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
            stateQueue.sync { hashWithConfigCalled = true }
            return mockSecurityResult
        }
    }
    
    // MARK: - Tests for AnyCryptoService
    
    func testAnyCryptoServiceWrapping() async {
        // Create mock
        let mockService = MockCryptoService()
        
        // Wrap in type-erased wrapper
        let anyService = AnyCryptoService(mockService)
        
        // Test that calls are forwarded correctly
        _ = await anyService.encrypt(data: SecureBytes([0x01]), using: SecureBytes([0x02]))
        await assertAsync(mockService.getEncryptCalled(), true, "Encrypt should be called on the underlying service")
        
        _ = await anyService.decrypt(data: SecureBytes([0x03]), using: SecureBytes([0x04]))
        await assertAsync(mockService.getDecryptCalled(), true, "Decrypt should be called on the underlying service")
        
        _ = await anyService.hash(data: SecureBytes([0x05]))
        await assertAsync(mockService.getHashCalled(), true, "Hash should be called on the underlying service")
        
        _ = await anyService.generateKey()
        await assertAsync(mockService.getGenerateKeyCalled(), true, "GenerateKey should be called on the underlying service")
        
        _ = await anyService.verify(data: SecureBytes([0x06]), against: SecureBytes([0x07]))
        await assertAsync(mockService.getVerifyCalled(), true, "Verify should be called on the underlying service")
        
        _ = await anyService.generateRandomData(length: 10)
        await assertAsync(mockService.getGenerateRandomDataCalled(), true, "GenerateRandomData should be called on the underlying service")
        
        _ = await anyService.encryptSymmetric(
            data: SecureBytes([0x08]), 
            key: SecureBytes([0x09]), 
            config: SecurityConfigDTO(algorithm: "AES", keySizeInBits: 256)
        )
        await assertAsync(mockService.getEncryptSymmetricCalled(), true, "EncryptSymmetric should be called on the underlying service")
    }
    
    // MARK: - Tests for CryptoServiceTypeAdapter
    
    func testCryptoServiceTypeAdapter() async {
        // Define mock results
        let expectedEncryptResult = SecureBytes([0x01, 0x02, 0x03])
        let expectedDecryptResult = SecureBytes([0x04, 0x05, 0x06])
        
        // Create mock with the expected results
        let mockService = MockCryptoService(
            mockEncryptResult: .success(expectedEncryptResult),
            mockDecryptResult: .success(expectedDecryptResult)
        )
        
        // Create adapter with identity transformations
        let adapter = CryptoServiceTypeAdapter(adaptee: mockService)
        
        // Test that basic functionality works with identity transformations
        let encryptResult = await adapter.encrypt(data: SecureBytes([0x01]), using: SecureBytes([0x02]))
        await assertAsync(mockService.getEncryptCalled(), true, "Encrypt should be called on the underlying service")
        
        if case .success(let encryptData) = encryptResult {
            XCTAssertEqual(encryptData, expectedEncryptResult, "Encryption result should match expected value")
        } else {
            XCTFail("Encryption should succeed")
        }
        
        let decryptResult = await adapter.decrypt(data: SecureBytes([0x03]), using: SecureBytes([0x04]))
        await assertAsync(mockService.getDecryptCalled(), true, "Decrypt should be called on the underlying service")
        
        if case .success(let decryptData) = decryptResult {
            XCTAssertEqual(decryptData, expectedDecryptResult, "Decryption result should match expected value")
        } else {
            XCTFail("Decryption should succeed")
        }
    }
    
    func testCryptoServiceTypeAdapterWithTransformations() async {
        // Create mock
        let mockService = MockCryptoService()
        
        // Define transformations that triple the size of input data and double output data
        let transformations = CryptoServiceTypeAdapter<MockCryptoService>.Transformations(
            transformInputData: { @Sendable originalData in
                var newData = [UInt8]()
                for byte in originalData.unsafeBytes {
                    newData.append(contentsOf: [byte, byte, byte])
                }
                return SecureBytes(newData)
            },
            transformOutputData: { @Sendable originalData in
                var newData = [UInt8]()
                for byte in originalData.unsafeBytes {
                    newData.append(contentsOf: [byte, byte])
                }
                return SecureBytes(newData)
            }
        )
        
        // Create adapter with the transformations
        let adapter = CryptoServiceTypeAdapter(adaptee: mockService, transformations: transformations)
        
        // Test with simple input
        let inputData = SecureBytes([0x01, 0x02])
        let encryptResult = await adapter.encrypt(data: inputData, using: SecureBytes([0x03]))
        
        // The mock returns SecureBytes([0x01, 0x02, 0x03]), and our transformation doubles that
        if case .success(let outputData) = encryptResult {
            XCTAssertEqual(outputData.count, 6, "Output should be 6 bytes (3 bytes doubled)")
            XCTAssertEqual(outputData.unsafeBytes, [0x01, 0x01, 0x02, 0x02, 0x03, 0x03], "Output transformation should double each byte")
        } else {
            XCTFail("Encryption should succeed")
        }
    }
}

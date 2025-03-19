import ErrorHandlingDomains
import Foundation
@testable import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

// MARK: - Result Extension

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: true
        case .failure: false
        }
    }

    var isFailure: Bool {
        !isSuccess
    }
}

/// Adapter class to adapt MockFoundationXPCSecurityService to FoundationCryptoService protocol
private final class MockCryptoServiceAdapter: FoundationCryptoServiceImpl, @unchecked Sendable {
    private let mockXPCService: MockFoundationXPCSecurityService

    init(mockXPCService: MockFoundationXPCSecurityService) {
        self.mockXPCService = mockXPCService
    }

    func encrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        await withCheckedContinuation { continuation in
            mockXPCService.encrypt(data: data, key: key) { data, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else if let data {
                    continuation.resume(returning: .success(data))
                } else {
                    continuation.resume(returning: .failure(NSError(
                        domain: "com.umbracore.mock",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    )))
                }
            }
        }
    }

    func decrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        await withCheckedContinuation { continuation in
            mockXPCService.decrypt(data: data, key: key) { data, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else if let data {
                    continuation.resume(returning: .success(data))
                } else {
                    continuation.resume(returning: .failure(NSError(
                        domain: "com.umbracore.mock",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    )))
                }
            }
        }
    }

    func generateKey() async -> Result<Data, Error> {
        await withCheckedContinuation { continuation in
            mockXPCService.generateKey(bits: 256) { data, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else if let data {
                    continuation.resume(returning: .success(data))
                } else {
                    continuation.resume(returning: .failure(NSError(
                        domain: "com.umbracore.mock",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    )))
                }
            }
        }
    }

    func hash(data: Data) async -> Result<Data, Error> {
        await withCheckedContinuation { continuation in
            // Use the XPC hash method which properly sets hashDataToReturn
            mockXPCService
                .hashDataXPC(
                    data: data,
                    algorithm: "SHA-256",
                    optionsJson: "{}"
                ) { data, code, errorMessage in
                    if let code, code.intValue != 0 {
                        let error = NSError(
                            domain: "com.umbracore.security",
                            code: code.intValue,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Hash operation failed"]
                        )
                        continuation.resume(returning: .failure(error))
                    } else if let data {
                        continuation.resume(returning: .success(data))
                    } else {
                        let error = NSError(
                            domain: "com.umbracore.security",
                            code: 500,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }

    func generateRandomData(length: Int) async -> Result<Data, Error> {
        await withCheckedContinuation { continuation in
            mockXPCService.generateRandomData(length: length) { data, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else if let data {
                    continuation.resume(returning: .success(data))
                } else {
                    continuation.resume(returning: .failure(NSError(
                        domain: "com.umbracore.security",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    )))
                }
            }
        }
    }

    func verify(data _: Data, against _: Data) async -> Bool {
        // This should respect the shouldFail flag from the mock service
        if mockXPCService.shouldFail {
            return false
        }

        // Use the verificationResult from the mock service
        return mockXPCService.verificationResult
    }

    // MARK: - Extended Methods Implementation

    func encryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        await withCheckedContinuation { continuation in
            // Convert options dictionary to JSON string for XPC compatibility
            let optionsJson = (try? JSONSerialization.data(withJSONObject: options, options: []))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

            mockXPCService.encryptSymmetricXPC(
                data: data,
                key: key,
                algorithm: algorithm,
                keySizeInBits: keySizeInBits,
                iv: iv,
                aad: aad,
                optionsJson: optionsJson
            ) { data, code, errorMessage in
                if let code, code.intValue != 0 {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: code.intValue,
                        errorMessage: errorMessage ?? "Encryption failed"
                    ))
                } else if let data {
                    continuation.resume(returning: FoundationSecurityResult(data: data))
                } else {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: 500,
                        errorMessage: "Unknown error"
                    ))
                }
            }
        }
    }

    func decryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        await withCheckedContinuation { continuation in
            // Convert options dictionary to JSON string for XPC compatibility
            let optionsJson = (try? JSONSerialization.data(withJSONObject: options, options: []))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

            mockXPCService.decryptSymmetricXPC(
                data: data,
                key: key,
                algorithm: algorithm,
                keySizeInBits: keySizeInBits,
                iv: iv,
                aad: aad,
                optionsJson: optionsJson
            ) { data, code, errorMessage in
                if let code, code.intValue != 0 {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: code.intValue,
                        errorMessage: errorMessage ?? "Decryption failed"
                    ))
                } else if let data {
                    continuation.resume(returning: FoundationSecurityResult(data: data))
                } else {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: 500,
                        errorMessage: "Unknown error"
                    ))
                }
            }
        }
    }

    func encryptAsymmetric(
        data: Data,
        publicKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        await withCheckedContinuation { continuation in
            // Convert options dictionary to JSON string for XPC compatibility
            let optionsJson = (try? JSONSerialization.data(withJSONObject: options, options: []))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

            mockXPCService.encryptAsymmetricXPC(
                data: data,
                publicKey: publicKey,
                algorithm: algorithm,
                keySizeInBits: keySizeInBits,
                optionsJson: optionsJson
            ) { data, code, errorMessage in
                if let code, code.intValue != 0 {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: code.intValue,
                        errorMessage: errorMessage ?? "Asymmetric encryption failed"
                    ))
                } else if let data {
                    continuation.resume(returning: FoundationSecurityResult(data: data))
                } else {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: 500,
                        errorMessage: "Unknown error"
                    ))
                }
            }
        }
    }

    func decryptAsymmetric(
        data: Data,
        privateKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        await withCheckedContinuation { continuation in
            // Convert options dictionary to JSON string for XPC compatibility
            let optionsJson = (try? JSONSerialization.data(withJSONObject: options, options: []))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

            mockXPCService.decryptAsymmetricXPC(
                data: data,
                privateKey: privateKey,
                algorithm: algorithm,
                keySizeInBits: keySizeInBits,
                optionsJson: optionsJson
            ) { data, code, errorMessage in
                if let code, code.intValue != 0 {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: code.intValue,
                        errorMessage: errorMessage ?? "Asymmetric decryption failed"
                    ))
                } else if let data {
                    continuation.resume(returning: FoundationSecurityResult(data: data))
                } else {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: 500,
                        errorMessage: "Unknown error"
                    ))
                }
            }
        }
    }

    func hash(
        data: Data,
        algorithm: String,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        await withCheckedContinuation { continuation in
            // Convert options dictionary to JSON string for XPC compatibility
            let optionsJson = (try? JSONSerialization.data(withJSONObject: options, options: []))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

            mockXPCService.hashDataXPC(
                data: data,
                algorithm: algorithm,
                optionsJson: optionsJson
            ) { data, code, errorMessage in
                if let code, code.intValue != 0 {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: code.intValue,
                        errorMessage: errorMessage ?? "Hashing failed"
                    ))
                } else if let data {
                    continuation.resume(returning: FoundationSecurityResult(data: data))
                } else {
                    continuation.resume(returning: FoundationSecurityResult(
                        errorCode: 500,
                        errorMessage: "Unknown error"
                    ))
                }
            }
        }
    }
}

final class CryptoServiceAdapterTests: XCTestCase {
    // MARK: - Properties

    private var mockXPCService: MockFoundationXPCSecurityService!
    private var mockCryptoService: MockCryptoServiceAdapter!
    private var adapter: CryptoServiceAdapter!

    // MARK: - Setup and Teardown

    override func setUp() async throws {
        try await super.setUp()
        mockXPCService = MockFoundationXPCSecurityService()
        mockCryptoService = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        adapter = CryptoServiceAdapter(implementation: mockCryptoService)
    }

    override func tearDown() async throws {
        adapter = nil
        mockCryptoService = nil
        mockXPCService = nil
        try await super.tearDown()
    }

    func resetMockService() async {
        // Create a new instance to reset all state
        mockXPCService = MockFoundationXPCSecurityService()
        mockCryptoService = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        adapter = CryptoServiceAdapter(implementation: mockCryptoService)
    }

    // MARK: - Basic Encryption Tests

    func testEncrypt() async throws {
        // Arrange
        let inputData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let key = SecureBytes(bytes: [10, 20, 30, 40, 50])
        mockXPCService.encryptedDataToReturn = Data([100, 110, 120, 130, 140])

        // Act
        let result = await adapter.encrypt(data: inputData, using: key)

        // Assert
        XCTAssertTrue(result.isSuccess)
        if case let .success(encrypted) = result {
            var encryptedBytes = [UInt8]()
            encrypted.withUnsafeBytes { buffer in
                encryptedBytes = Array(buffer)
            }
            XCTAssertEqual(encryptedBytes, [100, 110, 120, 130, 140])
        } else {
            XCTFail("Expected successful encryption")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("encrypt"))
    }

    func testEncryptFailure() async throws {
        // Arrange
        let inputData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        let key = SecureBytes(bytes: [10, 20, 30, 40, 50])
        mockXPCService.shouldFail = true

        // Act
        let result = await adapter.encrypt(data: inputData, using: key)

        // Assert
        XCTAssertTrue(result.isFailure)
        if case let .failure(error) = result {
            // We don't need to test the error type since CryptoServiceAdapter.mapError
            // guarantees that all errors are converted to SecurityError
            // Just verify we got an error with a descriptive message
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have a description")
        } else {
            XCTFail("Expected encryption failure")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("encrypt"))
    }

    // MARK: - Basic Decryption Tests

    func testDecrypt() async throws {
        // Arrange
        let encryptedData = SecureBytes(bytes: [100, 110, 120, 130, 140])
        let key = SecureBytes(bytes: [10, 20, 30, 40, 50])
        mockXPCService.decryptedDataToReturn = Data([1, 2, 3, 4, 5])

        // Act
        let result = await adapter.decrypt(data: encryptedData, using: key)

        // Assert
        XCTAssertTrue(result.isSuccess)
        if case let .success(decrypted) = result {
            var decryptedBytes = [UInt8]()
            decrypted.withUnsafeBytes { buffer in
                decryptedBytes = Array(buffer)
            }
            XCTAssertEqual(decryptedBytes, [1, 2, 3, 4, 5])
        } else {
            XCTFail("Expected successful decryption")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("decrypt"))
    }

    func testDecryptFailure() async throws {
        // Arrange
        let encryptedData = SecureBytes(bytes: [100, 110, 120, 130, 140])
        let key = SecureBytes(bytes: [10, 20, 30, 40, 50])
        mockXPCService.shouldFail = true

        // Act
        let result = await adapter.decrypt(data: encryptedData, using: key)

        // Assert
        XCTAssertTrue(result.isFailure)
        if case let .failure(error) = result {
            // We don't need to test the error type since CryptoServiceAdapter.mapError
            // guarantees that all errors are converted to SecurityError
            // Just verify we got an error with a descriptive message
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have a description")
        } else {
            XCTFail("Expected decryption failure")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("decrypt"))
    }

    // MARK: - Key Generation Test

    func testGenerateKey() async throws {
        // Arrange
        let expectedKey = Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        mockXPCService.keyDataToReturn = expectedKey

        // Act
        let result = await adapter.generateKey()

        // Assert
        XCTAssertTrue(result.isSuccess)
        if case let .success(key) = result {
            var keyBytes = [UInt8]()
            key.withUnsafeBytes { buffer in
                keyBytes = Array(buffer)
            }
            XCTAssertEqual(keyBytes, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        } else {
            XCTFail("Expected successful key generation")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("generateKey(bits: 256)"))
    }

    func testGenerateKeyFailure() async throws {
        // Arrange
        mockXPCService.shouldFail = true

        // Act
        let result = await adapter.generateKey()

        // Assert
        XCTAssertTrue(result.isFailure)
        if case let .failure(error) = result {
            // We don't need to test the error type since CryptoServiceAdapter.mapError
            // guarantees that all errors are converted to SecurityError
            // Just verify we got an error with a descriptive message
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have a description")
        } else {
            XCTFail("Expected key generation failure")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("generateKey(bits: 256)"))
    }

    // MARK: - Hashing Tests

    func testHashingWithSimpleDataFails() async {
        // Arrange
        mockXPCService.shouldFail = true
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        let inputData = "test data".data(using: .utf8)!

        // Act
        let result = await adapter.hash(
            data: inputData,
            algorithm: "SHA-256",
            options: [:]
        )

        // Assert
        XCTAssertFalse(result.success)
        XCTAssertNil(result.data)
        XCTAssertNotNil(result.errorCode)
    }

    func testHashingWithSimpleDataSucceeds() async {
        // Arrange
        mockXPCService.shouldFail = false
        mockXPCService.hashDataToReturn = "mocked hash".data(using: .utf8)!
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        let inputData = "test data".data(using: .utf8)!

        // Act
        let result = await adapter.hash(
            data: inputData,
            algorithm: "SHA-256",
            options: [:]
        )

        // Assert
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.data, mockXPCService.hashDataToReturn)
    }

    func testVerificationReturnsFalseWhenServiceShouldFail() async {
        // Arrange
        mockXPCService.shouldFail = true
        mockXPCService.verificationResult = true // This should be overridden by shouldFail
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        let data = "test data".data(using: .utf8)!
        let hash = "hash".data(using: .utf8)!

        // Act
        let result = await adapter.verify(data: data, against: hash)

        // Assert
        XCTAssertFalse(result)
    }

    func testVerificationReturnsResultFromService() async {
        // Arrange
        mockXPCService.shouldFail = false
        mockXPCService.verificationResult = true
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)
        let data = "test data".data(using: .utf8)!
        let hash = "hash".data(using: .utf8)!

        // Act
        let result = await adapter.verify(data: data, against: hash)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - Symmetric Encryption Tests

    func testSymmetricEncryption() async {
        // Arrange
        let plaintext = "test data".data(using: .utf8)!
        let key = Data(repeating: 0, count: 32)
        mockXPCService.encryptedDataToReturn = "encrypted".data(using: .utf8)!
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)

        // Act
        let result = await adapter.encryptSymmetric(
            data: plaintext,
            key: key,
            algorithm: "AES-GCM",
            keySizeInBits: 256,
            iv: nil,
            aad: nil,
            options: [:]
        )

        // Assert
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.data, mockXPCService.encryptedDataToReturn)
    }

    func testSymmetricDecryption() async {
        // Arrange
        let ciphertext = "encrypted".data(using: .utf8)!
        let key = Data(repeating: 0, count: 32)
        mockXPCService.decryptedDataToReturn = "test data".data(using: .utf8)!
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)

        // Act
        let result = await adapter.decryptSymmetric(
            data: ciphertext,
            key: key,
            algorithm: "AES-GCM",
            keySizeInBits: 256,
            iv: nil,
            aad: nil,
            options: [:]
        )

        // Assert
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.data, mockXPCService.decryptedDataToReturn)
    }

    func testAsymmetricEncryption() async {
        // Arrange
        let plaintext = "test data".data(using: .utf8)!
        let publicKey = Data(repeating: 1, count: 128)
        mockXPCService.encryptedDataToReturn = "encrypted".data(using: .utf8)!
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)

        // Act
        let result = await adapter.encryptAsymmetric(
            data: plaintext,
            publicKey: publicKey,
            algorithm: "RSA",
            keySizeInBits: 2_048,
            options: [:]
        )

        // Assert
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.data, mockXPCService.encryptedDataToReturn)
    }

    func testAsymmetricDecryption() async {
        // Arrange
        let ciphertext = "encrypted".data(using: .utf8)!
        let privateKey = Data(repeating: 2, count: 256)
        mockXPCService.decryptedDataToReturn = "test data".data(using: .utf8)!
        let adapter = MockCryptoServiceAdapter(mockXPCService: mockXPCService)

        // Act
        let result = await adapter.decryptAsymmetric(
            data: ciphertext,
            privateKey: privateKey,
            algorithm: "RSA",
            keySizeInBits: 2_048,
            options: [:]
        )

        // Assert
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.data, mockXPCService.decryptedDataToReturn)
    }

    // MARK: - Random Data Generation Tests

    func testGenerateRandomData() async throws {
        // Arrange
        let expectedLength = 32
        let expectedData = Data(repeating: 42, count: expectedLength)
        mockXPCService.randomDataToReturn = expectedData

        // Act
        let result = await adapter.generateRandomData(length: expectedLength)

        // Assert
        XCTAssertTrue(result.isSuccess)
        if case let .success(randomData) = result {
            XCTAssertEqual(randomData.count, expectedLength)
            var dataBytes = [UInt8]()
            randomData.withUnsafeBytes { buffer in
                dataBytes = Array(buffer)
            }
            XCTAssertEqual(dataBytes, [UInt8](repeating: 42, count: expectedLength))
        } else {
            XCTFail("Expected successful random data generation")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("generateRandomData(\(expectedLength))"))
    }

    func testGenerateRandomDataFailure() async throws {
        // Arrange
        let requestedLength = 64
        mockXPCService.shouldFail = true

        // Act
        let result = await adapter.generateRandomData(length: requestedLength)

        // Assert
        XCTAssertTrue(result.isFailure)
        if case let .failure(error) = result {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have a description")
        } else {
            XCTFail("Expected random data generation failure")
        }

        let methodCalls = mockXPCService.methodCalls
        XCTAssertTrue(methodCalls.contains("generateRandomData(\(requestedLength))"))
    }

    func testGenerateRandomDataDefaultGeneration() async throws {
        // Arrange
        let requestedLength = 16
        mockXPCService.randomDataToReturn = nil // Force default generation

        // Act
        let result = await adapter.generateRandomData(length: requestedLength)

        // Assert
        XCTAssertTrue(result.isSuccess)
        if case let .success(randomData) = result {
            XCTAssertEqual(randomData.count, requestedLength)

            // Default generation should produce sequential bytes
            let expectedBytes = (0 ..< requestedLength).map { UInt8($0 % 256) }
            var dataBytes = [UInt8]()
            randomData.withUnsafeBytes { buffer in
                dataBytes = Array(buffer)
            }
            XCTAssertEqual(dataBytes, expectedBytes)
        } else {
            XCTFail("Expected successful random data generation")
        }
    }
}

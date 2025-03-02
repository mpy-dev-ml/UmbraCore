import CryptoSwiftFoundationIndependent
import SecureBytes
import SecurityImplementation
import SecurityProtocolsCore
import XCTest

// Mock storage for testing using actor for thread safety
private actor MockSecureStorageActor {
    private var storage: [String: SecureBytes] = [:]

    func storeData(_ data: SecureBytes, identifier: String) -> KeyStorageResult {
        storage[identifier] = data
        return .success
    }

    func retrieveData(identifier: String) -> KeyRetrievalResult {
        guard let data = storage[identifier] else {
            return .failure(.keyNotFound)
        }
        return .success(data)
    }

    func deleteData(identifier: String) -> KeyDeletionResult {
        if storage.removeValue(forKey: identifier) != nil {
            return .success
        }
        return .failure(.keyNotFound)
    }
}

// Wrapper class that conforms to SecureStorageProtocol
private final class MockSecureStorage: SecureStorageProtocol, Sendable {
    private let actor = MockSecureStorageActor()

    func storeSecurely(data: SecureBytes, identifier: String) async -> KeyStorageResult {
        await actor.storeData(data, identifier: identifier)
    }

    func retrieveSecurely(identifier: String) async -> KeyRetrievalResult {
        await actor.retrieveData(identifier: identifier)
    }

    func deleteSecurely(identifier: String) async -> KeyDeletionResult {
        await actor.deleteData(identifier: identifier)
    }
}

final class SecurityProviderTests: XCTestCase {

    private var securityProvider: SecurityProviderImpl!
    private var cryptoService: CryptoServiceImpl!

    override func setUp() {
        super.setUp()
        cryptoService = CryptoServiceImpl()
        securityProvider = SecurityProviderImpl(
            cryptoService: cryptoService,
            keyManager: KeyManagementImpl(secureStorage: MockSecureStorage())
        )
    }

    override func tearDown() {
        securityProvider = nil
        cryptoService = nil
        super.tearDown()
    }

    // MARK: - Symmetric Encryption Tests

    func testSymmetricEncryption() async {
        // Create encryption config
        let config = SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256
        )

        // Perform encryption
        let result = await securityProvider.performSecureOperation(
            operation: .symmetricEncryption,
            config: config
        )

        XCTAssertTrue(result.success, "Encryption should succeed")
        XCTAssertNotNil(result.data, "Encryption should return data")

        // We would normally verify the ciphertext and decrypt it,
        // but in this implementation we can't easily get the key and IV
        // that were used internally
    }

    // MARK: - Random Data Generation Tests

    func testRandomDataGeneration() async {
        // Create config for random data generation
        let config = SecurityConfigDTO(
            algorithm: "SecureRandom",
            keySizeInBits: 32  // Request 32 bytes of random data
        )

        // Perform random generation operation
        let result = await securityProvider.performSecureOperation(
            operation: .randomGeneration,
            config: config
        )

        XCTAssertTrue(result.success, "Random data generation should succeed")

        guard let randomData = result.data else {
            XCTFail("Random data generation should return data")
            return
        }

        // Generate a second set of random data to verify uniqueness
        let result2 = await securityProvider.performSecureOperation(
            operation: .randomGeneration,
            config: config
        )

        XCTAssertTrue(result2.success, "Second random data generation should succeed")

        guard let randomData2 = result2.data else {
            XCTFail("Second random data generation should return data")
            return
        }

        // Verify the two random data sets are different (extremely low probability they would be equal)
        XCTAssertNotEqual(randomData, randomData2)
    }

    // MARK: - Hashing Tests

    func testHashing() async {
        // Create test data
        let data = SecureBytes(Array("Data to be hashed".utf8))

        // Create config for SHA-256 hashing
        let config = SecurityConfigDTO(
            algorithm: "SHA-256",
            keySizeInBits: 0  // Not applicable for hashing
        )

        // Perform hashing operation with provided data
        let result = await cryptoService.hash(data: data, config: config)

        XCTAssertTrue(result.success, "Hashing should succeed")

        guard let hash = result.data else {
            XCTFail("Hashing should return data")
            return
        }

        // Verify hash has correct length for SHA-256 (32 bytes)
        XCTAssertEqual(hash.count, 32)

        // Verify same data produces same hash
        let repeatResult = await cryptoService.hash(data: data, config: config)

        XCTAssertTrue(repeatResult.success, "Repeat hashing should succeed")

        guard let repeatHash = repeatResult.data else {
            XCTFail("Repeat hashing should return data")
            return
        }

        // Verify hash consistency
        XCTAssertEqual(hash, repeatHash)
    }

    // MARK: - Unsupported Operations Tests

    func testUnsupportedOperations() async {
        // Create config
        let config = SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256
        )

        // List of operations that are not yet implemented
        let unsupportedOperations: [SecurityOperation] = [
            .asymmetricEncryption,
            .asymmetricDecryption,
            .signatureGeneration,
            .signatureVerification
        ]

        // Verify each operation properly reports as unsupported
        for operation in unsupportedOperations {
            let result = await securityProvider.performSecureOperation(
                operation: operation,
                config: config
            )

            XCTAssertFalse(result.success, "Operation \(operation) should report as unsupported")
            XCTAssertNotNil(result.errorMessage, "Error message should be provided")
        }
    }
}

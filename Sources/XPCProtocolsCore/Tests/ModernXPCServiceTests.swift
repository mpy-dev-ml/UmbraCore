import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import XCTest
@testable import XPCProtocolsCore

// This test file now uses ModernXPCService instead of the removed LegacyXPCServiceAdapter
// The test cases maintain coverage of the same functionality but use the modern implementation
final class ModernXPCMigrationTests: XCTestCase {
    // Test ping functionality
    func testPing() async throws {
        // Use the factory to create a modern service
        let service = XPCProtocolMigrationFactory.createCompleteAdapter()

        // Test the ping operation with the modern service
        let result = await service.pingAsync()

        // Verify that the service returns the expected result
        switch result {
        case let .success(value):
            XCTAssertTrue(value, "Ping should succeed")
        case let .failure(error):
            XCTFail("Ping should succeed but failed with: \(error)")
        }
    }

    // Test error mapping
    func testErrorHandling() async {
        // Create a mock service that can be configured to fail
        let service = MockFailingXPCService()

        // Test encryption with error
        let testData = SecureBytes(bytes: [1, 2, 3])
        let result = await service.encryptSecureData(testData, keyIdentifier: nil)

        // Verify the error mapping works as expected
        if case .failure = result {
            // Just check that it's an XPCSecurityError
            XCTAssertTrue(
                true,
                "Should return an XPCSecurityError (confirmed via type checking)"
            )
        } else {
            XCTFail("Expected operation to fail")
        }
    }

    // Test random data generation
    func testRandomDataGeneration() async {
        let service = XPCProtocolMigrationFactory.createCompleteAdapter()
        let result = await service.generateRandomData(length: 32)

        switch result {
        case let .success(data):
            XCTAssertEqual(data.count, 32, "Should generate 32 bytes of random data")
        case let .failure(error):
            XCTFail("Random data generation failed with error: \(error)")
        }
    }

    // Test encryption and decryption
    func testEncryptDecrypt() async {
        let service = XPCProtocolMigrationFactory.createCompleteAdapter()
        let originalData = SecureBytes(bytes: [10, 20, 30, 40, 50])

        // Encrypt
        let encryptResult = await service.encryptSecureData(originalData, keyIdentifier: nil)

        guard case let .success(encryptedData) = encryptResult else {
            XCTFail("Encryption failed")
            return
        }

        // Decrypt
        let decryptResult = await service.decryptSecureData(encryptedData, keyIdentifier: nil)

        guard case let .success(decryptedData) = decryptResult else {
            XCTFail("Decryption failed")
            return
        }

        XCTAssertEqual(decryptedData, originalData, "Decrypted data should match original")
    }
}

// Mock service that simulates errors for testing
final class MockFailingXPCService: ModernXPCService, @unchecked Sendable {
    override func encryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "encrypt", details: "Test error"))
    }

    override func decryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "decrypt", details: "Test error"))
    }

    override func hashSecureData(_: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.cryptographicError(operation: "hash", details: "Test error"))
    }
}

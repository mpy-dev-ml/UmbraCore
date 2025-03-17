import UmbraCoreTypes
import XCTest
@testable import XPCProtocolsCore

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
        let encryptResult = await service.encryptSecureData(testData, keyIdentifier: nil)

        // Pattern matching on results
        switch encryptResult {
        case let .success(encryptedData):
            XCTAssertFalse(encryptedData.isEmpty, "Encrypted data should not be empty")

            // Continue with decryption
            let decryptResult = await service.decryptSecureData(encryptedData, keyIdentifier: nil)

            switch decryptResult {
            case let .success(decryptedData):
                XCTAssertEqual(decryptedData, testData, "Decryption should recover the original data")
            case let .failure(error):
                XCTFail("Decryption failed with error: \(error)")
            }

        case let .failure(error):
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
        case let .success(keyIdentifier):
            XCTAssertFalse(keyIdentifier.isEmpty, "Key identifier should not be empty")

            // Delete the key
            let deleteResult = await service.deleteKey(keyIdentifier: keyIdentifier)

            switch deleteResult {
            case .success:
                // Deletion successful
                break
            case let .failure(error):
                XCTFail("Key deletion failed with error: \(error)")
            }

        case let .failure(error):
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
        // Legacy approach (simulated) - NOT RECOMMENDED FOR NEW CODE
        // This would have used the legacy adapter in the past
        func legacyOperation(_: Data) -> Data? {
            // Create dummy encrypted data for testing
            Data([20, 40, 60, 80, 100])
        }

        // Modern approach using factory and protocols
        func modernOperation(_ data: Data) async -> Result<Data, Error> {
            let service = XPCProtocolMigrationFactory.createCompleteAdapter()
            let secureData = SecureBytes(bytes: [UInt8](data))

            let result = await service.encryptSecureData(secureData, keyIdentifier: nil)
            // Convert XPCSecurityError to Error to match the function return type
            return result.mapError { error in
                error as Error
            }.map { encryptedBytes in
                Data(XPCProtocolMigrationFactory.convertSecureBytesToData(encryptedBytes))
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
        case let .success(data):
            print("Modern operation successful with \(data.count) bytes")
        case let .failure(error):
            XCTFail("Modern operation failed with error: \(error)")
        }
    }
}

// Internal test helpers - not part of the example
private extension MigrationExampleTests {
    class MockModernXPCService: NSObject, XPCServiceProtocolComplete, @unchecked Sendable {
        static let protocolIdentifier: String = "mock.modern.service"

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

        func verifySignature(_: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
            .success(true)
        }

        func pingComplete() async -> Result<Bool, XPCSecurityError> {
            .success(true)
        }

        func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
            .success(())
        }

        func generateKeyPair(type _: String, keySize _: Int, identifier: String?) async -> Result<String, XPCSecurityError> {
            .success(identifier ?? "generated-key-id")
        }

        func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError> {
            .success(XPCServiceStatus(isActive: true, version: "1.0", serviceType: "Mock Service", additionalInfo: [:]))
        }

        func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
            .success(SecureBytes(bytes: Array(repeating: UInt8(0), count: length)))
        }

        func generateKey(keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
            .success(keyIdentifier ?? "generated-key-id")
        }

        func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCSecurityError> {
            .success(())
        }

        func listKeys() async -> Result<[String], XPCSecurityError> {
            .success(["key1", "key2"])
        }

        func importKey(keyData _: SecureBytes, keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
            .success(keyIdentifier ?? "imported-key-id")
        }

        func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
            .success(SecureBytes())
        }

        func deriveKey(from _: String, salt _: SecureBytes, iterations _: Int, keyLength _: Int, targetKeyIdentifier: String?) async -> Result<String, XPCSecurityError> {
            .success(targetKeyIdentifier ?? "derived-key-id")
        }

        @objc
        func ping() async -> Bool {
            true
        }

        @objc
        func synchroniseKeys(_: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
            completionHandler(nil)
        }

        // For backward compatibility with tests
        func encryptData(_ data: NSData, keyIdentifier _: String) -> NSData {
            // Simple implementation for testing
            let bytes = [UInt8](repeating: 0, count: data.length)
            return NSData(bytes: bytes, length: bytes.count)
        }

        func decryptData(_ data: NSData, keyIdentifier _: String?) -> NSData {
            // Simple implementation for testing
            let bytes = [UInt8](repeating: 1, count: data.length)
            return NSData(bytes: bytes, length: bytes.count)
        }

        func hashData(_: NSData) -> NSData {
            // Simple implementation for testing
            let bytes = [UInt8](repeating: 2, count: 32)
            return NSData(bytes: bytes, length: bytes.count)
        }

        func generateRandomData(length: Int) -> NSData {
            // Simple implementation for testing
            let bytes = [UInt8](repeating: 3, count: length)
            return NSData(bytes: bytes, length: bytes.count)
        }

        func signSecureData(_: NSData, keyIdentifier _: String) -> NSData {
            // Simple implementation for testing
            let bytes = [UInt8](repeating: 4, count: 64)
            return NSData(bytes: bytes, length: bytes.count)
        }

        func verifySignature(_: NSData, for _: NSData, keyIdentifier _: String) -> NSNumber {
            // Simple implementation for testing
            NSNumber(value: true)
        }
    }
}

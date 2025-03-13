import CoreErrors

// import SecurityInterfaces  // Temporarily commented out to fix build issues
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import UmbraCoreTypes // Using SecureBytes from UmbraCoreTypes, not the standalone module
import XCTest
@testable import XPCProtocolsCore

/// Tests that verify deprecated protocol warnings
class DeprecationWarningTests: XCTestCase {
    /// Test that demonstrates using the deprecated protocols
    /// This test intentionally uses deprecated APIs to verify they work during migration
    /// but will generate compiler warnings.
    #if !DISABLE_DEPRECATION_TESTS
        func testDeprecatedProtocolStillFunctional() async throws {
            // Create a service using the legacy protocol
            let legacyService = LegacyService()

            // Try the basic operations
            let result = try await legacyService.encrypt(data: SecurityInterfacesProtocols.BinaryData([
                1,
                2,
                3,
                4,
            ]))
            XCTAssertEqual(result.bytes.count, 4, "Encryption should work with legacy service")

            // Create an adapter to use the legacy service with new protocols
            let adapter = CryptoXPCServiceAdapter(service: legacyService)

            // Test the adapter with the new protocol methods
            let secureBytes = UmbraCoreTypes.SecureBytes(bytes: [5, 6, 7, 8])
            let encryptResult = await adapter.encrypt(data: secureBytes)

            XCTAssertTrue(encryptResult.isSuccess, "Adapter should successfully encrypt data")

            // Verify the migrated service works
            let migratedService = MigratedService()
            let migratedResult = try await migratedService.encryptData(secureBytes, keyIdentifier: nil)
            XCTAssertEqual(migratedResult.count, 4, "Migrated service should work correctly")
        }
    #endif

    /// Test that demonstrates the recommended approach with new protocols
    func testModernProtocolUsage() async throws {
        // Create a service using the new protocols
        let modernService = ModernService()

        // Use the standardized protocols
        let secureBytes = UmbraCoreTypes.SecureBytes(bytes: [1, 2, 3, 4])
        let encryptedData = try await modernService.encryptData(secureBytes, keyIdentifier: "test-key")

        XCTAssertEqual(encryptedData.count, 4, "Encryption should work with modern service")

        // Try the result-based API
        let encryptResult = await modernService.encrypt(data: secureBytes)
        XCTAssertTrue(encryptResult.isSuccess, "Result-based API should succeed")
    }
}

// MARK: - Test Implementations

/// Legacy service implementation that will trigger deprecation warnings
@available(*, deprecated, message: "For testing purposes only")
private class LegacyService: SecurityInterfacesProtocols.XPCServiceProtocol {
    func encrypt(
        data: SecurityInterfacesProtocols
            .BinaryData
    ) async throws -> SecurityInterfacesProtocols.BinaryData {
        data // Mock implementation
    }

    func decrypt(
        data: SecurityInterfacesProtocols
            .BinaryData
    ) async throws -> SecurityInterfacesProtocols.BinaryData {
        data // Mock implementation
    }
}

/// This demonstrates conforming to CryptoXPCServiceProtocol for the adapter
extension LegacyService: CryptoXPCServiceProtocol {
    func generateKey(bits _: Int) async throws -> Data {
        Data(count: 4) // Mock implementation
    }

    func encrypt(_ data: Data, key _: Data) async throws -> Data {
        data // Mock implementation
    }

    func decrypt(_ data: Data, key _: Data) async throws -> Data {
        data // Mock implementation
    }

    func retrieveCredential(forIdentifier _: String) async throws -> Data {
        Data(count: 4) // Mock implementation
    }
}

/// A service that has been migrated to the new protocols
private class MigratedService: XPCServiceProtocolStandard {
    func generateRandomData(length: Int) async throws -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: length))
    }

    func encryptData(
        _ data: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String?
    ) async throws -> UmbraCoreTypes.SecureBytes {
        data // Mock implementation
    }

    func decryptData(
        _ data: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String?
    ) async throws -> UmbraCoreTypes.SecureBytes {
        data // Mock implementation
    }

    func hashData(_ data: UmbraCoreTypes.SecureBytes) async throws -> UmbraCoreTypes.SecureBytes {
        data // Mock implementation
    }

    func signData(
        _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String
    ) async throws -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 64))
    }

    func verifySignature(
        _: UmbraCoreTypes.SecureBytes,
        for _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String
    ) async throws -> Bool {
        true
    }
}

/// A modern service using the new protocols directly
private class ModernService: XPCServiceProtocolComplete {
    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func synchronizeKeys(_: UmbraCoreTypes.SecureBytes) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func encrypt(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func decrypt(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateKey() async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 32)))
    }

    func hash(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateRandomData(length: Int) async throws -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: length))
    }

    func encryptData(
        _ data: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String?
    ) async throws -> UmbraCoreTypes.SecureBytes {
        data
    }

    func decryptData(
        _ data: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String?
    ) async throws -> UmbraCoreTypes.SecureBytes {
        data
    }

    func hashData(_ data: UmbraCoreTypes.SecureBytes) async throws -> UmbraCoreTypes.SecureBytes {
        data
    }

    func signData(
        _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String
    ) async throws -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 64))
    }

    func verifySignature(
        _: UmbraCoreTypes.SecureBytes,
        for _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String
    ) async throws -> Bool {
        true
    }
}

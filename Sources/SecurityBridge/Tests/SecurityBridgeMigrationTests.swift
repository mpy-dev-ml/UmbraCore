import CoreTypesInterfaces
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import FoundationBridgeTypes
// DEPRECATED: import SecurityBridge
import SecurityBridgeProtocolAdapters
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

// Protocol definition for ServiceProtocolBasic used in tests
protocol ServiceProtocolBasic {
    static var protocolIdentifier: String { get }

    func ping() async -> Result<Bool, UmbraErrors.Security.Protocols>
    func synchronizeKeys(_ keys: SecureBytes) async -> Result<Void, UmbraErrors.Security.Protocols>
    func generateRandomData(length: Int) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>
}

// DEPRECATED: // DEPRECATED: final class SecurityBridgeMigrationTests: XCTestCase {
    // MARK: - XPCServiceBridge Tests

    func testXPCServiceBridgeProtocolIdentifier() {
        XCTAssertEqual(
            // DEPRECATED: CoreTypesToFoundationBridgeAdapter.protocolIdentifier,
            "com.umbra.xpc.service.adapter.coretypes.bridge"
        )
    }

    func testCoreToBridgeAdapter() throws {
        let mockXPCService = MockXPCServiceProtocolBasic()
        // DEPRECATED: let adapter = CoreTypesToFoundationBridgeAdapter(wrapping: mockXPCService)

        let expectation = XCTestExpectation(description: "Ping response received")
        // DEPRECATED: adapter.pingFoundation { success, error in
            XCTAssertTrue(success)
            // DEPRECATED: XCTAssertNil(error)
            expectation.fulfill()
        }

        // DEPRECATED: wait(for: [expectation], timeout: 1.0)
    }

    func testBridgeToCoreAdapter() async {
        let mockFoundationService = MockFoundationXPCService()
        // DEPRECATED: let adapter = FoundationToCoreTypesAdapter(wrapping: mockFoundationService)

        let result = await adapter.ping()
        switch result {
        case let .success(value):
            XCTAssertTrue(value)
        case .failure:
            XCTFail("Should have succeeded")
        }
    }

    // MARK: - SecurityProvider Tests

    func testSecurityProviderAdapterEncryptionDecryption() async throws {
        // DEPRECATED: let mockBridge = MockSecurityProviderBridge()
        let adapter = SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

        // Create test data using SecureBytes instead of legacy BinaryData
        let testData = SecureBytes(bytes: [1, 2, 3, 4, 5])
        // Not used directly in its SecureBytes form - only binaryKey is used
        _ = SecureBytes(bytes: [10, 20, 30, 40, 50])

        // Convert SecureBytes to BinaryData for the adapter
        let binaryData = CoreTypesInterfaces.BinaryData(bytes: [1, 2, 3, 4, 5])
        let binaryKey = CoreTypesInterfaces.BinaryData(bytes: [10, 20, 30, 40, 50])

        // Test with adapter using BinaryData
        let encryptResult = try await adapter.encrypt(binaryData, key: binaryKey)
        // Extract bytes from BinaryData using rawBytes
        let encryptedBytes = Array(encryptResult.rawBytes)

        var testDataBytes = [UInt8]()
        testData.withUnsafeBytes { buffer in
            testDataBytes = Array(buffer.map(\.self))
        }

        XCTAssertNotEqual(encryptedBytes, testDataBytes)

        // Convert back to BinaryData for decryption
        let encryptedBinaryData = CoreTypesInterfaces.BinaryData(bytes: encryptedBytes)
        let decryptResult = try await adapter.decrypt(encryptedBinaryData, key: binaryKey)
        // Extract bytes from BinaryData using rawBytes
        let decryptedBytes = Array(decryptResult.rawBytes)

        XCTAssertEqual(decryptedBytes, testDataBytes)
    }

    func testSecurityProviderAdapterGenerateRandomData() async throws {
        // DEPRECATED: let mockBridge = MockSecurityProviderBridge()
        let adapter = SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

        // Test the generateKey method with the required length parameter
        let keyResult = try await adapter.generateKey(length: 32)
        XCTAssertEqual(keyResult.count, 32) // Default key size
    }
}

// MARK: - Test Mocks

private class MockXPCServiceProtocolBasic: ServiceProtocolBasic,
    @unchecked Sendable
{
    static var protocolIdentifier: String = "mock.protocol"

    func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
        .success(true)
    }

    func synchronizeKeys(_: SecureBytes) async -> Result<Void, UmbraErrors.Security.Protocols> {
        .success(())
    }

    func generateRandomData(length: Int) async
        -> Result<SecureBytes, UmbraErrors.Security.Protocols>
    {
        var bytes = [UInt8]()
        // DEPRECATED: for i in 0 ..< length {
            bytes.append(UInt8(i % 256))
        }
        return .success(SecureBytes(bytes: bytes))
    }
}

private class MockFoundationXPCService: NSObject, @unchecked Sendable {
    func pingFoundation(completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func synchronizeKeys(_: Data, completion: @escaping (Error?) -> Void) {
        // DEPRECATED: completion(nil) // No error means success
    }
}

private class CoreTypesToFoundationBridgeAdapter: NSObject {
    private let service: ServiceProtocolBasic

    init(wrapping service: ServiceProtocolBasic) {
        self.service = service
        super.init()
    }

    static var protocolIdentifier: String {
        "com.umbra.xpc.service.adapter.coretypes.bridge"
    }

    func pingFoundation(completion: @escaping (Bool, Error?) -> Void) {
        Task {
            let result = await service.ping()
            switch result {
            case let .success(value):
                completion(value, nil)
            // DEPRECATED: case let .failure(error):
                // DEPRECATED: completion(false, error)
            }
        }
    }
}

private class FoundationToCoreTypesAdapter: ServiceProtocolBasic {
    private let service: MockFoundationXPCService

    init(wrapping service: MockFoundationXPCService) {
        self.service = service
    }

    static var protocolIdentifier: String {
        "com.umbra.xpc.service.adapter.foundation.bridge"
    }

    func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
        await withCheckedContinuation { continuation in
            // DEPRECATED: service.pingFoundation { success, error in
                // DEPRECATED: if let error {
                    // DEPRECATED: continuation.resume(returning: .failure(.internalError(error.localizedDescription)))
                } else {
                    continuation.resume(returning: .success(success))
                }
            }
        }
    }

    func synchronizeKeys(_ keys: SecureBytes) async -> Result<Void, UmbraErrors.Security.Protocols> {
        await withCheckedContinuation { continuation in
            var keyData = Data()
            keys.withUnsafeBytes { buffer in
                keyData = Data(buffer)
            }

            // DEPRECATED: service.synchronizeKeys(keyData) { error in
                // DEPRECATED: if let error {
                    // DEPRECATED: continuation.resume(returning: .failure(.internalError(error.localizedDescription)))
                } else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }

    func generateRandomData(length: Int) async
        -> Result<SecureBytes, UmbraErrors.Security.Protocols>
    {
        var bytes = [UInt8]()
        // DEPRECATED: for i in 0 ..< length {
            bytes.append(UInt8(i % 256))
        }
        return .success(SecureBytes(bytes: bytes))
    }
}

/// Add mock implementation of MockSecurityProviderBridge to replace the previous incomplete version
private final class MockSecurityProviderBridge: SecurityBridgeProtocolAdapters
    .SecurityProviderBridge
{
    // Add required protocol identifier
    static var protocolIdentifier: String = "mock.security.provider.bridge"

    func encrypt(
        // DEPRECATED: _ data: FoundationBridgeTypes.DataBridge,
        // DEPRECATED: key _: FoundationBridgeTypes.DataBridge
    // DEPRECATED: ) async throws -> FoundationBridgeTypes.DataBridge {
        var dataBytes: [UInt8] = []
        dataBytes = data.bytes
        let encryptedData = Array(dataBytes.reversed())
        // DEPRECATED: return FoundationBridgeTypes.DataBridge(encryptedData)
    }

    func decrypt(
        // DEPRECATED: _ data: FoundationBridgeTypes.DataBridge,
        // DEPRECATED: key _: FoundationBridgeTypes.DataBridge
    // DEPRECATED: ) async throws -> FoundationBridgeTypes.DataBridge {
        var dataBytes: [UInt8] = []
        dataBytes = data.bytes
        let decryptedData = Array(dataBytes.reversed())
        // DEPRECATED: return FoundationBridgeTypes.DataBridge(decryptedData)
    }

    // DEPRECATED: func generateKey(sizeInBytes: Int) async throws -> FoundationBridgeTypes.DataBridge {
        let keyData = Array((0 ..< sizeInBytes).map { UInt8($0 % 256) })
        // DEPRECATED: return FoundationBridgeTypes.DataBridge(keyData)
    }

    // DEPRECATED: func hash(_ data: FoundationBridgeTypes.DataBridge) async throws -> FoundationBridgeTypes
        // DEPRECATED: .DataBridge
    {
        var hashedData: [UInt8] = []
        hashedData = data.bytes
        // DEPRECATED: return FoundationBridgeTypes.DataBridge(hashedData)
    }
}

import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A mock implementation of XPCServiceProtocolStandard for testing purposes
/// Replaces the deprecated DummyXPCService
@available(macOS 14.0, *)
public final class MockXPCService: XPCServiceProtocolStandard {
    public init() {}

    public static var protocolIdentifier: String {
        "com.umbra.test.xpc.service"
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        true
    }

    public func synchroniseKeys(_: SecureBytes) async throws {
        // Mock implementation that does nothing
    }

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        let statusDict: [String: Any] = [
            "name": "MockXPCService",
            "version": "1.0.0",
            "status": "operational",
            "uptime": 3600,
        ]

        return .success(statusDict)
    }

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        // DEPRECATED: for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    /// Generate random data for cryptographic operations
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or XPCProtocolsCore.SecurityError on failure
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Generate predictable "random" data for tests
        var bytes = [UInt8](repeating: 0, count: length)
        // DEPRECATED: for i in 0 ..< length {
            bytes[i] = UInt8((i % 256))
        }
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        .success("1.0.0")
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        .success("MOCK-HARDWARE-ID")
    }

    public func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        // Mock implementation that does nothing
        .success(())
    }

    public func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError> {
        .success(["mock-key-1", "mock-key-2"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        let info: [String: Any] = [
            "id": keyId,
            "type": "symmetric",
            "created": Date(),
        ]
        return .success(info)
    }

    public func deleteKey(keyId _: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
        // Mock implementation that always succeeds
        .success(())
    }

    public func importKey(
        _: SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        let id = keyIdentifier ?? "mock-imported-key-\(UUID().uuidString)"
        return .success(id)
    }

    public func exportKey(
        keyIdentifier _: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCProtocolsCore.SecurityError> {
        // For testing, create mock key data
        return .success((SecureBytes(bytes: Array(repeating: 0x42, count: 32)), .symmetric))
    }

    public func encryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Simple mock implementation - just return the data
        .success(data)
    }

    public func decryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Simple mock implementation - just return the data
        .success(data)
    }

    public func sign(_: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Return dummy signature
        let signature = SecureBytes(bytes: Array(repeating: 0x55, count: 64))
        return .success(signature)
    }

    // DEPRECATED: public func verify(signature _: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Always verify successfully in mock
        .success(true)
    }

    public func getSecurityStatus() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        .success(["status": "secure"])
    }

    // The following methods were removed due to unsupported types in XPCProtocolTypeDefs
    // Public API should be extended properly once these types are defined
    /*
     public func getSupportedKeyTypes() async -> Result<[XPCProtocolTypeDefs.KeyType], XPCProtocolsCore.SecurityError> {
         return .success([.symmetric, .asymmetric])
     }

     public func getSupportedEncryptionAlgorithms() async -> Result<[XPCProtocolTypeDefs.EncryptionAlgorithm], XPCProtocolsCore.SecurityError> {
         return .success([.aes256])
     }

     public func getSupportedSignatureAlgorithms() async -> Result<[XPCProtocolTypeDefs.SignatureAlgorithm], XPCProtocolsCore.SecurityError> {
         return .success([.ed25519])
     }
     */
}

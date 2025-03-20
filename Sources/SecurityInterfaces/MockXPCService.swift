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

    public func status() async -> Result<[String: Any], XPCSecurityError> {
        let statusDict: [String: Any] = [
            "name": "MockXPCService",
            "version": "1.0.0",
            "status": "operational",
            "uptime": 3600,
        ]

        return .success(statusDict)
    }

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCSecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    /// Generate random data for cryptographic operations
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or XPCSecurityError on failure
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Generate predictable "random" data for tests
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0 ..< length {
            bytes[i] = UInt8((i * 3) % 256)
        }
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0")
    }

    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        let hardwareId = "MOCK-HARDWARE-ID-\(UUID().uuidString)"
        return .success(hardwareId)
    }

    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // Simple mock implementation that always succeeds
        .success(())
    }

    public func listKeys() async -> Result<[String], XPCSecurityError> {
        .success(["test-key-1", "test-key-2"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: Any], XPCSecurityError> {
        let keyInfo: [String: Any] = [
            "id": keyId,
            "type": "symmetric",
            "created": Date().timeIntervalSince1970,
        ]
        return .success(keyInfo)
    }

    public func deleteKey(keyId _: String) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    public func importKey(
        keyData _: SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        .success(keyIdentifier ?? "generated-key-id")
    }

    public func exportKey(
        keyIdentifier _: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCSecurityError> {
        let mockKeyData = SecureBytes(bytes: Array(repeating: UInt8(42), count: 32))
        return .success((mockKeyData, .symmetric))
    }

    public func encryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Just create a copy of the data for testing
        let bytes = data.withUnsafeBytes { Array($0) }
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Just create a copy of the data for testing
        let bytes = data.withUnsafeBytes { Array($0) }
        return .success(SecureBytes(bytes: bytes))
    }

    public func sign(_: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        // Create a mock signature
        let mockSignature = SecureBytes(bytes: Array(repeating: UInt8(0x55), count: 64))
        return .success(mockSignature)
    }

    public func verify(signature _: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        // Always verify successfully in this mock
        .success(true)
    }

    public func getSecurityStatus() async -> Result<[String: Any], XPCSecurityError> {
        let status: [String: Any] = [
            "securityEnabled": true,
            "hardwareSecurity": true,
            "softwareSecurity": true,
        ]
        return .success(status)
    }

    // The following methods were removed due to unsupported types in XPCProtocolTypeDefs
    // Public API should be extended properly once these types are defined
    /*
     public func getSupportedKeyTypes() async -> Result<[XPCProtocolTypeDefs.KeyType], XPCSecurityError> {
         return .success([.symmetric, .asymmetric])
     }

     public func getSupportedEncryptionAlgorithms() async -> Result<[XPCProtocolTypeDefs.EncryptionAlgorithm], XPCSecurityError> {
         return .success([.aesGcm, .chachaPoly])
     }

     public func getSupportedSignatureAlgorithms() async -> Result<[XPCProtocolTypeDefs.SignatureAlgorithm], XPCSecurityError> {
         return .success([.ecdsa, .eddsa])
     }
     */
}

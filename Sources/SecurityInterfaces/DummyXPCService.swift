import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A dummy implementation of XPCServiceProtocolStandard for testing purposes
@available(macOS 14.0, *)
public final class DummyXPCService: XPCServiceProtocolStandard {
    public init() {}

    public static var protocolIdentifier: String {
        "com.umbra.test.xpc.service"
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        true
    }

    public func getStatus() async -> XPCProtocolTypeDefs.ServiceStatusInfo {
        XPCProtocolTypeDefs.ServiceStatusInfo(
            status: XPCProtocolTypeDefs.ServiceStatus.operational.rawValue,
            details: "Test service is operational",
            protocolVersion: "1.0"
        )
    }

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        let statusDict: [String: Any] = [
            "status": "active",
            "version": "1.0.0",
        ]
        return .success(statusDict)
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        let hardwareId = "TEST-HARDWARE-ID-\(UUID().uuidString)"
        return .success(hardwareId)
    }

    public func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        // Simple dummy implementation that always succeeds
        .success(())
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Generate predictable "random" data for tests
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0 ..< length {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(SecureBytes(bytes: bytes))
    }

    public func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError> {
        .success(["test-key-1", "test-key-2"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
        let info: [String: AnyObject] = [
            "id": keyId as NSString,
            "type": "symmetric" as NSString,
            "status": "active" as NSString,
        ]
        return .success(info)
    }

    public func deleteKey(keyId _: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
        .success(())
    }

    public func encryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // For testing, create a new SecureBytes with a marker at the end
        let marker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]

        // Copy the original data
        var bytes = [UInt8]()
        for i in 0 ..< data.count {
            do {
                try bytes.append(data.byte(at: i))
            } catch {
                return .failure(.cryptographicError(operation: "encryption", details: "Error accessing data bytes"))
            }
        }

        // Add the marker
        bytes.append(contentsOf: marker)

        // Create result
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Simple dummy implementation
        .success(data)
    }

    public func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Create a dummy signature
        let signature = "SIGNATURE-\(keyIdentifier ?? "default")-\(data.count)".data(using: .utf8)!
        return .success(SecureBytes(data: signature))
    }

    public func verify(signature _: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Always return true for verification in dummy implementation
        .success(true)
    }

    public func pingStandard() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        .success(true)
    }

    public func resetSecurityData() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        .success(())
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        .success("1.0.0-test")
    }

    public func getSupportedEncryptionAlgorithms() async -> Result<[String], XPCProtocolsCore.SecurityError> {
        .success(["aes-gcm", "chacha20-poly1305"])
    }

    public func getSupportedSignatureAlgorithms() async -> Result<[String], XPCProtocolsCore.SecurityError> {
        .success(["rsa-pss", "ecdsa-p256", "ed25519"])
    }

    /// Import a key into the service
    /// - Parameters:
    ///   - keyData: Key data
    ///   - keyType: Key type
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata
    /// - Returns: Key identifier on success
    public func importKey(
        keyData _: SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        // For testing, just use the provided ID or generate one
        let id = keyIdentifier ?? "imported-key-\(UUID().uuidString)"
        return .success(id)
    }

    /// Generate a new key
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata for the key
    /// - Returns: Key identifier on success
    public func generateKey(
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        // For testing, just use the provided ID or generate one
        let id = keyIdentifier ?? "generated-key-\(UUID().uuidString)"
        return .success(id)
    }

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier of the key to delete
    /// - Returns: Success or error
    public func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
        .success(())
    }

    /// Export a key
    /// - Parameters:
    ///   - keyIdentifier: Identifier of the key to export
    ///   - format: Format to export the key in
    /// - Returns: Key data as SecureBytes
    public func exportKey(
        keyIdentifier: String,
        format _: XPCProtocolTypeDefs.KeyFormat
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // For testing, create dummy key data
        let keyBytes = Array("DUMMY-KEY-DATA-\(keyIdentifier)".utf8)
        return .success(SecureBytes(bytes: keyBytes))
    }

    /// Export a key with type information
    /// - Parameter keyIdentifier: Identifier of the key to export
    /// - Returns: Key data and type
    public func exportKey(
        keyIdentifier: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCProtocolsCore.SecurityError> {
        // For testing, create dummy key data
        let keyBytes = Array("DUMMY-KEY-DATA-\(keyIdentifier)".utf8)
        return .success((SecureBytes(bytes: keyBytes), .symmetric))
    }

    // MARK: - Protocol Synchronisation

    public func synchroniseKeys(_: SecureBytes) async throws {
        // Simple implementation that always succeeds
        // No-op since this is a dummy implementation
    }
}

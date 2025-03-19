import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A basic implementation of the XPC service protocol for testing and demo purposes
/// Deprecated: Use MockXPCService instead
@available(*, deprecated, message: "Use MockXPCService instead")
@available(macOS 14.0, *)
public final class DummyXPCService: XPCServiceProtocolStandard {
    public init() {}

    public static var protocolIdentifier: String {
        "com.umbra.test.dummy.xpc"
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

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCSecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    public func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async throws {
        // Dummy implementation, does nothing
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: Any], XPCSecurityError> {
        let statusDict: [String: Any] = [
            "status": "active",
            "version": "1.0.0"
        ]
        return .success(statusDict)
    }

    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        let hardwareId = "TEST-HARDWARE-ID-\(UUID().uuidString)"
        return .success(hardwareId)
    }

    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // Simple dummy implementation that always succeeds
        .success(())
    }
    
    /// Get the service version
    /// - Returns: Result with version string on success or XPCSecurityError on failure
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0")
    }

    /// Generate random data for cryptographic operations
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or XPCSecurityError on failure
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Generate random data for testing purposes
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0 ..< length {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    public func listKeys() async -> Result<[String], XPCSecurityError> {
        .success(["test-key-1", "test-key-2"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: Any], XPCSecurityError> {
        let info: [String: Any] = [
            "id": keyId,
            "type": "symmetric",
            "status": "active"
        ]
        return .success(info)
    }

    public func deleteKey(keyId _: String) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    public func encryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // For testing, create a new SecureBytes with a marker at the end
        let marker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]

        // Copy the original data
        var bytes = [UInt8]()
        for i in 0 ..< data.count {
            do {
                try bytes.append(data.byte(at: i))
            } catch {
                return .failure(XPCSecurityError.encryptionFailed(reason: "Error accessing data bytes"))
            }
        }

        // Add the marker
        bytes.append(contentsOf: marker)

        // Create result
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSecureData(_ data: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Simple dummy implementation
        .success(data)
    }

    public func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        // Create a dummy signature
        let signatureString = "SIGNATURE-\(keyIdentifier)-\(data.count)"
        let signatureData = signatureString.data(using: .utf8)!
        return .success(SecureBytes(bytes: [UInt8](signatureData)))
    }

    public func verify(signature _: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        // Always return true for verification in dummy implementation
        .success(true)
    }

    public func resetSecurityData() async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    public func importKey(
        keyData _: SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // For testing, just use the provided ID or generate one
        let id = keyIdentifier ?? "imported-key-\(UUID().uuidString)"
        return .success(id)
    }

    public func exportKey(
        keyIdentifier: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCSecurityError> {
        // For testing, create dummy key data
        let keyBytes = Array("DUMMY-KEY-DATA-\(keyIdentifier)".utf8)
        return .success((SecureBytes(bytes: keyBytes), .symmetric))
    }
}

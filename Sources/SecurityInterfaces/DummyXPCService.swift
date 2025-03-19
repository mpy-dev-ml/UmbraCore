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

    public func generateRandomBytes(count: Int) async -> Result<Data, SecurityInterfacesError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: AnyObject], SecurityInterfacesError> {
        let statusDict: [String: AnyObject] = [
            "status": "active" as NSString,
            "version": "1.0.0" as NSString,
        ]
        return .success(statusDict)
    }

    public func getHardwareIdentifier() async -> Result<String, SecurityInterfacesError> {
        let hardwareId = "TEST-HARDWARE-ID-\(UUID().uuidString)"
        return .success(hardwareId)
    }

    public func resetSecurity() async -> Result<Void, SecurityInterfacesError> {
        // Simple dummy implementation that always succeeds
        return .success(())
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Generate predictable "random" data for tests
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0 ..< length {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(SecureBytes(bytes: bytes))
    }

    public func listKeys() async -> Result<[String], SecurityInterfacesError> {
        return .success(["test-key-1", "test-key-2"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfacesError> {
        let info: [String: AnyObject] = [
            "id": keyId as NSString,
            "type": "symmetric" as NSString,
            "status": "active" as NSString,
        ]
        return .success(info)
    }

    public func deleteKey(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        return .success(())
    }

    public func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, SecurityInterfacesError> {
        // For testing, create a new SecureBytes with a marker at the end
        let marker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]

        // Copy the original data
        var bytes = [UInt8]()
        for i in 0 ..< data.count {
            do {
                try bytes.append(data.byte(at: i))
            } catch {
                return .failure(SecurityInterfacesError.encryptionFailed(reason: "Error accessing data bytes"))
            }
        }

        // Add the marker
        bytes.append(contentsOf: marker)

        // Create result
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Simple dummy implementation
        return .success(data)
    }

    public func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Create a dummy signature
        let signatureString = "SIGNATURE-\(keyIdentifier)-\(data.count)"
        let signatureData = signatureString.data(using: .utf8)!
        return .success(SecureBytes(bytes: [UInt8](signatureData)))
    }

    public func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        // Always return true for verification in dummy implementation
        return .success(true)
    }

    public func resetSecurityData() async -> Result<Void, SecurityInterfacesError> {
        return .success(())
    }

    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        // For testing, just use the provided ID or generate one
        let id = keyIdentifier ?? "imported-key-\(UUID().uuidString)"
        return .success(id)
    }

    public func exportKey(
        keyIdentifier: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), SecurityInterfacesError> {
        // For testing, create dummy key data
        let keyBytes = Array("DUMMY-KEY-DATA-\(keyIdentifier)".utf8)
        return .success((SecureBytes(bytes: keyBytes), .symmetric))
    }
}

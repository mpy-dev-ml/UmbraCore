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

    public func resetSecurityData() async -> Result<Void, SecurityInterfacesError> {
        return .success(())
    }

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        let result = await generateRandomBytes(count: length)
        switch result {
        case let .success(data):
            return .success(UmbraCoreTypes.SecureBytes(data: data))
        case let .failure(error):
            return .failure(error)
        }
    }

    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Just return the data unchanged for testing
        return .success(data)
    }

    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Just return the data unchanged for testing
        return .success(data)
    }

    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Return some mock signature
        let mockSignature = Data([0x01, 0x02, 0x03, 0x04])
        return .success(UmbraCoreTypes.SecureBytes(data: mockSignature))
    }

    public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        return .success(true)
    }

    public func importKey(
        keyData: UmbraCoreTypes.SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        let identifier = keyIdentifier ?? "generated-\(UUID().uuidString)"
        return .success(identifier)
    }

    public func listKeys() async -> Result<[String], SecurityInterfacesError> {
        return .success(["key1", "key2", "key3"])
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfacesError> {
        let info: [String: AnyObject] = [
            "type": "symmetric" as NSString,
            "created": Date() as NSDate,
            "id": keyId as NSString
        ]
        return .success(info)
    }

    public func deleteKey(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        return .success(())
    }

    public func exportKey(keyIdentifier: String) async -> Result<(UmbraCoreTypes.SecureBytes, XPCProtocolTypeDefs.KeyType), SecurityInterfacesError> {
        // Return some mock key data
        let mockKeyData = Data([0x10, 0x20, 0x30, 0x40])
        return .success((UmbraCoreTypes.SecureBytes(data: mockKeyData), .symmetric))
    }

    public func resetSecurity() async -> Result<Void, SecurityInterfacesError> {
        return .success(())
    }
}

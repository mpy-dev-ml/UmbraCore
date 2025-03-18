import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A mock implementation of XPCServiceProtocolStandard for testing purposes
/// Replaces the deprecated DummyXPCService
@available(macOS 14.0, *)
public final class MockXPCService: XPCProtocolsCore.XPCServiceProtocolStandard {
    public init() {}

    public static var protocolIdentifier: String {
        return "com.umbra.test.xpc.service"
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        return true
    }

    public func getStatus() async -> XPCProtocolTypeDefs.ServiceStatusInfo {
        return XPCProtocolTypeDefs.ServiceStatusInfo(
            status: XPCProtocolTypeDefs.ServiceStatus.operational.rawValue,
            details: "Test service is operational",
            protocolVersion: "1.0"
        )
    }

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0..<count {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return .success(Data(bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        let statusDict: [String: Any] = [
            "status": "active",
            "version": "1.0.0"
        ]
        return .success(statusDict)
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        let hardwareId = "TEST-HARDWARE-ID-\(UUID().uuidString)"
        return .success(hardwareId)
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        return .success("1.0.0-test")
    }

    public func generateRandomData(length: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        return await generateRandomBytes(count: length)
    }

    public func synchroniseKeys(_ keys: [String: Data]) async -> Result<[String: Data], XPCProtocolsCore.SecurityError> {
        // Just return the keys unchanged for testing
        return .success(keys)
    }

    public func storeSecureData(key: String, data: Data) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        return .success(true)
    }

    public func retrieveSecureData(key: String) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Return some mock data
        let mockData = "MockSecureData-\(key)".data(using: .utf8) ?? Data()
        return .success(mockData)
    }

    public func deleteSecureData(key: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        return .success(true)
    }

    public func encryptSecureData(_ data: Data, keyIdentifier: String) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Just return the data unchanged for testing
        return .success(data)
    }

    public func decryptSecureData(_ data: Data, keyIdentifier: String) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Just return the data unchanged for testing
        return .success(data)
    }

    public func sign(_ data: Data, keyIdentifier: String) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Return some mock signature
        let mockSignature = Data([0x01, 0x02, 0x03, 0x04])
        return .success(mockSignature)
    }

    public func verify(signature: Data, for data: Data, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        return .success(true)
    }

    public func importKey(
        _ keyData: Data,
        keyType: String,
        keyIdentifier: String?,
        metadata: [String: Any]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        let identifier = keyIdentifier ?? "generated-\(UUID().uuidString)"
        return .success(identifier)
    }

    public func exportKey(
        _ keyIdentifier: String,
        format: String
    ) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Return some mock key data
        let mockKeyData = Data([0x10, 0x20, 0x30, 0x40])
        return .success(mockKeyData)
    }

    public func deleteKey(_ keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        return .success(true)
    }
}

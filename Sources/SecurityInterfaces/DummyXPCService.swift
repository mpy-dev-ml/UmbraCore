import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A dummy implementation of XPCServiceProtocolStandard for testing purposes
public final class DummyXPCService: XPCServiceProtocolStandard {
  public init() {}

  public static var protocolIdentifier: String {
    "com.umbra.test.xpc.service"
  }

  public func status() async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
    let statusDict: [String: AnyObject]=[
      "status": "active" as NSString,
      "version": "1.0.0" as NSString,
      "service": "TestService" as NSString
    ]
    return .success(statusDict)
  }

  public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
    let hardwareId="TEST-HARDWARE-ID-\(UUID().uuidString)"
    return .success(hardwareId)
  }

  public func resetSecurityData() async -> Result<Void, XPCProtocolsCore.SecurityError> {
    .success(())
  }

  public func generateRandomBytes(count: Int) async
  -> Result<Data, XPCProtocolsCore.SecurityError> {
    var bytes=[UInt8](repeating: 0, count: count)
    // Fill with predictable "random" data for tests
    for i in 0..<count {
      bytes[i]=UInt8(i % 256)
    }
    return .success(Data(bytes))
  }

  public func importKey(
    keyData _: SecureBytes,
    keyType _: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata _: [String: String]?
  ) async -> Result<String, XPCProtocolsCore.SecurityError> {
    let id=keyIdentifier ?? "test-key-\(UUID().uuidString)"
    return .success(id)
  }

  public func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError> {
    .success(["test-key-1", "test-key-2"])
  }

  public func getKeyInfo(keyId: String) async
  -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
    let info: [String: AnyObject]=[
      "id": keyId as NSString,
      "type": "symmetric" as NSString,
      "created": NSDate()
    ]
    return .success(info)
  }

  public func deleteKey(keyId _: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
    .success(())
  }
}

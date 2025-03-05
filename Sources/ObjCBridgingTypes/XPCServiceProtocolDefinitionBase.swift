import CoreTypes
import XPCProtocolsCore
import UmbraCoreTypes
/// Protocol defining the base XPC service interface with completion handlers - minimal version
/// without Foundation dependencies
/// This protocol is deprecated. Use XPCServiceProtocolBasic from XPCProtocolsCore instead.
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
public protocol XPCServiceProtocolDefinitionBase {
  /// Base method to test connectivity
  func ping(completion: @escaping (Bool, Error?) -> Void)

  /// Reset all security data
  func resetSecurityData(completion: @escaping (Error?) -> Void)
}

/// Extension for XPCServiceProtocolDefinitionBase providing conversion to modern protocol
extension XPCServiceProtocolDefinitionBase {
  /// Convert this legacy protocol implementation to a modern XPCServiceProtocolBasic
  /// - Returns: An adapter that conforms to XPCServiceProtocolBasic
  public func asModernProtocol() -> XPCServiceProtocolBasic {
    DefinitionBaseToModernAdapter(wrapping: self)
  }
}

/// Private adapter class that converts XPCServiceProtocolDefinitionBase to XPCServiceProtocolBasic
private class DefinitionBaseToModernAdapter: XPCServiceProtocolStandardBasic {
  private let legacyService: XPCServiceProtocolStandardDefinitionBase
  
  init(wrapping service: XPCServiceProtocolStandardDefinitionBase) {
    self.legacyService = service
  }
  
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.definition.adapter.modern"
  }
  
  public func ping() async -> Result<Bool, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      legacyService.ping { success, error in
        if let error = error {
          continuation.resume(returning: .failure(.general))
        } else {
          continuation.resume(returning: .success(success))
        }
      }
    }
  }
  
  public func synchronizeKeys(_ data: SecureBytes) async -> Result<Void, XPCSecurityError> {
    // Use the resetSecurityData as an approximation since the legacy protocol
    // doesn't have a direct equivalent
    await withCheckedContinuation { continuation in
      legacyService.resetSecurityData { error in
        if let error = error {
          continuation.resume(returning: .failure(.general))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }
  
  public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
    // Legacy protocol doesn't support this, so return a not implemented error
    .failure(.notImplemented)
  }
}

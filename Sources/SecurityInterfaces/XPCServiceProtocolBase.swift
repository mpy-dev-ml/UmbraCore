import UmbraCoreTypes
import XPCProtocolsCore
import CoreTypes

/// Protocol defining the core XPC service interface without Foundation dependencies
/// @deprecated Use XPCProtocolsCore.XPCServiceProtocolBasic instead
@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
public protocol XPCServiceProtocolBase: Sendable {
  /// Base method to test connectivity
  func ping() async -> Result<Bool, XPCSecurityError>
  
  /// Reset all security data
  func resetSecurityData() async -> Result<Void, XPCSecurityError>

  /// Get the XPC service version
  func getVersion() async -> Result<String, XPCSecurityError>
  
  /// Get the host identifier
  func getHostIdentifier() async -> Result<String, XPCSecurityError>
  
  /// Synchronize keys between services
  /// - Parameter syncData: The key synchronization data as bytes
  func synchroniseKeys(_ syncData: [UInt8]) async -> Result<Void, XPCSecurityError>
}

/// Extension providing adapter methods to help with migration
extension XPCServiceProtocolBase {
  /// Convert a protocol implementation to the newer XPCServiceProtocolBasic
  /// This helps bridge between old and new protocol implementations during the migration
  public func asXPCServiceProtocolBasic() -> XPCServiceProtocolBasic {
    XPCLegacyAdapter(legacy: self)
  }
}

/// Private adapter to convert between protocols
private struct XPCLegacyAdapter: XPCServiceProtocolBasic {
  private let legacy: XPCServiceProtocolBase
  
  init(legacy: XPCServiceProtocolBase) {
    self.legacy = legacy
  }
  
  func ping() async throws -> Bool {
    let result = await legacy.ping()
    switch result {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
  
  func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async -> Result<Void, XPCSecurityError> {
    await legacy.synchroniseKeys(Array(syncData.bytes))
  }
}

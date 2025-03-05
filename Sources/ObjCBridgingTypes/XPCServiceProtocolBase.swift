import CoreTypes
import XPCProtocolsCore
import UmbraCoreTypes
/// Base protocol for XPC service communication - minimal version without Foundation dependencies
/// @available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
public protocol XPCServiceProtocolBase {
  /// Base method to test connectivity
  func ping(completion: @escaping (Bool, Error?) -> Void)

  /// Reset all security data
  func resetSecurityData(completion: @escaping (Error?) -> Void)
}

/// Extension providing shared functionality for XPC service protocols
extension XPCServiceProtocolBase {
  /// Default protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.protocol.base"
  }
}

/// Factory for creating XPCServiceProtocolBasic adapters from XPCServiceProtocolBase implementations
public enum XPCServiceProtocolAdapter {
  /// Create a modern XPCServiceProtocolBasic from a legacy XPCServiceProtocolBase
  /// - Parameter legacyService: The legacy service to adapt
  /// - Returns: An adapter conforming to XPCServiceProtocolBasic
  public static func createModernAdapter(from legacyService: XPCServiceProtocolStandardBase) -> XPCServiceProtocolBasic {
    LegacyToModernXPCAdapter(wrapping: legacyService)
  }
  
  /// Private adapter implementation
  private class LegacyToModernXPCAdapter: XPCServiceProtocolStandardBasic {
    private let legacyService: XPCServiceProtocolStandardBase
    
    init(wrapping service: XPCServiceProtocolStandardBase) {
      self.legacyService = service
    }
    
    public static var protocolIdentifier: String {
      "com.umbra.xpc.service.protocol.adapter.modern"
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
}

import CoreErrors
import CoreTypes
import UmbraCoreTypes
import XPCProtocolsCore

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

/// Factory for creating XPCServiceProtocolBasic adapters from XPCServiceProtocolBase
/// implementations
public enum XPCServiceProtocolAdapter {
  /// Create a modern XPCServiceProtocolBasic from a legacy XPCServiceProtocolBase
  /// - Parameter legacyService: The legacy service to adapt
  /// - Returns: An adapter conforming to XPCServiceProtocolBasic
  public static func createModernAdapter(from legacyService: XPCServiceProtocolBase)
  -> XPCServiceProtocolBasic {
    LegacyToModernXPCAdapter(wrapping: legacyService)
  }

  /// Private adapter implementation
  private class LegacyToModernXPCAdapter: XPCServiceProtocolBasic {
    private let legacyService: XPCServiceProtocolBase

    init(wrapping service: XPCServiceProtocolBase) {
      legacyService=service
    }

    public static var protocolIdentifier: String {
      "com.umbra.xpc.service.protocol.adapter.modern"
    }

    public func ping() async -> Result<Bool, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        legacyService.ping { success, error in
          if let error {
            continuation.resume(returning: .failure(.cryptoError))
          } else {
            continuation.resume(returning: .success(success))
          }
        }
      }
    }

    public func synchroniseKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
      // Use the resetSecurityData as an approximation since the legacy protocol
      // doesn't have a direct equivalent
      await withCheckedContinuation { continuation in
        legacyService.resetSecurityData { error in
          if let error {
            continuation.resume(returning: .failure(.cryptoError))
          } else {
            continuation.resume(returning: .success(()))
          }
        }
      }
    }
  }
}

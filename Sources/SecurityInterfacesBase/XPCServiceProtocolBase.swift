import SecurityInterfacesProtocols
import XPCProtocolsCore
import UmbraCoreTypes

/// Re-export the protocol from SecurityInterfacesProtocols
@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
public typealias XPCServiceProtocolBase = SecurityInterfacesProtocols.XPCServiceProtocolBase

/// Re-export SecureBytes from SecurityInterfacesProtocols
@available(*, deprecated, message: "Use UmbraCoreTypes.SecureBytes instead")
public typealias SecureBytes = SecurityInterfacesProtocols.SecureBytes

/// Custom error for security interfaces that doesn't require Foundation
@available(*, deprecated, message: "Use UmbraCoreTypes.CoreErrors instead")
public enum XPCServiceProtocolBaseError: Error, Sendable {
  case implementationMissing(String)
}

/// Extension for XPCServiceProtocolBase to provide security-specific functionality
@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
extension SecurityInterfacesProtocols.XPCServiceProtocolBase {
  /// Implementation for synchronising keys with byte array
  func synchroniseKeys(_ syncData: [UInt8]) async throws {
    // Convert bytes to SecureBytes
    let binaryData = SecurityInterfacesProtocols.SecureBytes(syncData)
    return try await synchroniseKeys(binaryData)
  }

  /// Default implementation of protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.base"
  }

  /// Default implementation of ping
  public func ping() async -> Result<Bool, XPCSecurityError> {
    return .success(true)
  }
}

import CoreTypes
import XPCProtocolsCore

/// Binary data representation without Foundation dependencies
@available(*, deprecated, message: "Use UmbraCoreTypes.SecureBytes instead")
public struct SecureBytes: Sendable {
  /// Raw byte array
  public let bytes: [UInt8]

  /// Create a new SecureBytes instance from a byte array
  public init(_ bytes: [UInt8]) {
    self.bytes=bytes
  }

  /// Create an empty SecureBytes instance
  public init() {
    bytes=[]
  }
}

/// Custom error for security interfaces that doesn't require Foundation
@available(*, deprecated, message: "Use UmbraCoreTypes.CoreErrors instead")
public enum SecurityProtocolError: Error, Sendable {
  case implementationMissing(String)
}

/// Protocol defining the base XPC service interface without Foundation dependencies
@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
public protocol XPCServiceProtocolBase: Sendable {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Test connectivity
  func ping() async -> Result<Bool
, XPCSecurityError>
  /// Synchronize keys across processes
  /// - Parameter syncData: The key data to synchronize
  func synchroniseKeys(_ syncData: SecureBytes) async throws
}

/// Default implementation for XPCServiceProtocolBase
@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
extension XPCServiceProtocolBase {
  /// Default protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.protocol.base"
  }
}

import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol for security-specific XPC services
/// This extends the base protocol with security-specific methods
@available(
  *,
  deprecated,
  message: "Use XPCProtocolsCore.XPCServiceProtocolStandard or XPCServiceProtocolComplete instead"
)
public protocol XPCServiceProtocol: XPCProtocolsCore.XPCServiceProtocolBasic {
  /// Encrypt data using the service
  /// - Parameter data: The data to encrypt
  /// - Returns: The encrypted data
  func encrypt(data: UmbraCoreTypes.SecureBytes) async
    -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.XPCSecurityError>

  /// Decrypt data using the service
  /// - Parameter data: The data to decrypt
  /// - Returns: The decrypted data
  func decrypt(data: UmbraCoreTypes.SecureBytes) async
    -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.XPCSecurityError>
}

/// Extension providing default implementations for the protocol
@available(
  *,
  deprecated,
  message: "Use XPCProtocolsCore.XPCServiceProtocolStandard or XPCServiceProtocolComplete instead"
)
extension XPCServiceProtocol {
  /// Default implementation of encrypt
  public func encrypt(
    data: UmbraCoreTypes
      .SecureBytes
  ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.XPCSecurityError> {
    // This is just a placeholder implementation
    // In a real implementation, you would implement actual encryption
    .success(data)
  }

  /// Default implementation of decrypt
  public func decrypt(
    data: UmbraCoreTypes
      .SecureBytes
  ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.XPCSecurityError> {
    // This is just a placeholder implementation
    // In a real implementation, you would implement actual decryption
    .success(data)
  }
}

/// Adapter that implements XPCProtocolsCore.XPCServiceProtocolBasic from
/// XPCServiceProtocol
@available(*, deprecated, message: "Use XPCProtocolsCore.LegacyXPCServiceAdapter instead")
public struct XPCServiceAdapter: XPCProtocolsCore.XPCServiceProtocolBasic {
  private let service: any XPCServiceProtocol

  /// Create a new adapter wrapping an XPCServiceProtocol implementation
  public init(wrapping service: any XPCServiceProtocol) {
    self.service=service
  }

  /// Protocol identifier from the wrapped service
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter"
  }

  /// Implement ping using the wrapped service
  public func ping() async -> Result<Bool, XPCProtocolsCore.XPCSecurityError> {
    await service.ping()
  }

  /// Implement synchronizeKeys using the wrapped service
  public func synchronizeKeys(
    _ data: UmbraCoreTypes
      .SecureBytes
  ) async -> Result<Void, XPCProtocolsCore.XPCSecurityError> {
    await service.synchronizeKeys(data)
  }
}

// Foundation-free adapter for XPC services
// Provides a bridge between Foundation-dependent and Foundation-free implementations
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol for Foundation-based XPC service interfaces
/// Use this to define what we expect from Foundation-based XPC implementations
public protocol FoundationBasedXPCService: Sendable {
  func ping() async -> Result<Bool, XPCSecurityError>
  func synchroniseKeys(_ data: Any) async -> Result<Void, XPCSecurityError>
}

/// Adapter that implements XPCServiceProtocolStandard from any FoundationBasedXPCService
public final class XPCServiceAdapter: XPCServiceProtocolStandard {
  private let service: any FoundationBasedXPCService

  /// Create a new adapter wrapping a Foundation-based service implementation
  public init(wrapping service: any FoundationBasedXPCService) {
    self.service = service
  }

  /// Implement ping method
  public func ping() async -> Result<Bool, XPCSecurityError> {
    return await service.ping()
  }

  /// Implement synchronizeKeys with SecureBytes
  public func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
    // Convert SecureBytes to [UInt8] array for compatibility
    var byteArray = [UInt8]()
    syncData.withUnsafeBytes { buffer in
      byteArray = Array(buffer)
    }

    // Pass the byte array to the service
    return await service.synchroniseKeys(byteArray)
  }

  // Implement required methods with not implemented error

  public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented)
  }

  public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented)
  }

  public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented)
  }

  public func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented)
  }

  /// Protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter"
  }
}

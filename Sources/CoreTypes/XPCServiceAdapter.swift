// Foundation-free adapter for XPC services
// Provides a bridge between Foundation-dependent and Foundation-free implementations
import SecurityProtocolsCore
import UmbraCoreTypes

/// Protocol for Foundation-based XPC service interfaces
/// Use this to define what we expect from Foundation-based XPC implementations
public protocol FoundationBasedXPCService: Sendable {
  func ping() async throws -> Bool
  func synchroniseKeys(_ data: Any) async throws
}

/// Adapter that implements XPCServiceProtocolCore from any FoundationBasedXPCService
public final class XPCServiceAdapter: XPCServiceProtocolCore {
  private let service: any FoundationBasedXPCService

  /// Create a new adapter wrapping a Foundation-based service implementation
  public init(wrapping service: any FoundationBasedXPCService) {
    self.service=service
  }

  /// Implement ping method
  public func ping() async -> Result<Bool, SecurityError> {
    do {
      let result=try await service.ping()
      return .success(result)
    } catch {
      return .failure(.serviceError(code: -1, reason: "XPC service ping failed"))
    }
  }

  /// Implement synchronizeKeys with SecureBytes
  public func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, SecurityError> {
    do {
      // Pass the binary data as the raw bytes
      try await service.synchroniseKeys(syncData.unsafeBytes)
      return .success(())
    } catch {
      return .failure(.serviceError(code: -1, reason: "XPC service key synchronization failed"))
    }
  }

  // Implement required methods with not implemented error

  public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    .failure(.notImplemented)
  }

  public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    .failure(.notImplemented)
  }

  public func generateKey() async -> Result<SecureBytes, SecurityError> {
    .failure(.notImplemented)
  }

  public func hash(data _: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    .failure(.notImplemented)
  }

  /// Protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter"
  }
}

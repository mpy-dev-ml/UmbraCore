import SecurityProtocolsCore
import UmbraCoreTypes
import ErrorHandlingDomains

/// Base protocol defining core security operations that don't require Foundation
/// @Warning: This protocol is maintained for backward compatibility only.
/// New code should use SecurityProtocolsCore.SecurityProviderProtocol instead.
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderProtocol instead"
)
public protocol SecurityProviderBase {
  /// Reset all security data
  func resetSecurityData() async -> Result<Void, SecurityError>

  /// Get the host identifier
  func getHostIdentifier() async -> Result<String, SecurityError>

  /// Register a client application
  /// - Parameter bundleIdentifier: The bundle identifier of the client application
  func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityError>

  /// Request key rotation
  /// - Parameter keyId: The ID of the key to rotate
  func requestKeyRotation(keyId: String) async -> Result<Void, SecurityError>

  /// Notify about a potentially compromised key
  /// - Parameter keyId: The ID of the compromised key
  func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityError>
}

/// Extension to provide adapters between the legacy and new protocols
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderProtocol instead"
)
extension SecurityProviderBase {
  /// Create a modern protocol adapter from this legacy protocol
  /// - Returns: An object conforming to SecurityProviderProtocol that delegates to this object
  public func asModernProvider() -> any SecurityProviderProtocol {
    SecurityProviderBaseAdapter(provider: self)
  }
}

/// Adapter that implements SecurityProviderProtocol from SecurityProviderBase
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderProtocol directly instead"
)
private struct SecurityProviderBaseAdapter: SecurityProviderProtocol {
  private let provider: any SecurityProviderBase

  init(provider: any SecurityProviderBase) {
    self.provider=provider
  }

  func resetSecurityData() async -> Result<Void, SecurityError> {
    await provider.resetSecurityData()
  }

  func getHostIdentifier() async -> Result<String, SecurityError> {
    await provider.getHostIdentifier()
  }

  func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityError> {
    await provider.registerClient(bundleIdentifier: bundleIdentifier)
  }

  func requestKeyRotation(keyId: String) async -> Result<Void, SecurityError> {
    await provider.requestKeyRotation(keyId: keyId)
  }

  func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityError> {
    await provider.notifyKeyCompromise(keyId: keyId)
  }
}

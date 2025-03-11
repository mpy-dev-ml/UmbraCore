import ErrorHandlingDomains
import SecurityProtocolsCore
import UmbraCoreTypes

/// Base protocol defining core security operations that don't require Foundation
/// @Warning: This protocol is maintained for backward compatibility only.
/// New code should use SecurityProtocolsCore.SecurityProviderProtocol instead.
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderProtocol instead"
)
public protocol SecurityProviderBase: Sendable {
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
  public func asModernProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol {
    SecurityProviderBaseAdapter(provider: self)
  }
}

/// Adapter that implements SecurityProviderProtocol from SecurityProviderBase
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderProtocol directly instead"
)
private struct SecurityProviderBaseAdapter: SecurityProtocolsCore.SecurityProviderProtocol {
  private let provider: any SecurityProviderBase

  // MARK: - Required Properties for SecurityProtocolsCore.SecurityProviderProtocol

  public var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
    // Create and return a dummy crypto service
    DummyCryptoService()
  }

  public var keyManager: SecurityProtocolsCore.KeyManagementProtocol {
    // Create and return a dummy key manager
    DummyKeyManager()
  }

  init(provider: any SecurityProviderBase) {
    self.provider = provider
  }

  // MARK: - Required Methods for SecurityProtocolsCore.SecurityProviderProtocol

  public func performSecureOperation(
    operation: SecurityProtocolsCore.SecurityOperation,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    // Default implementation that returns a dummy result
    return SecurityProtocolsCore.SecurityResultDTO(success: true)
  }

  public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
    // Create a default config with the required algorithm and key size parameters
    SecurityProtocolsCore.SecurityConfigDTO(
      algorithm: "AES",
      keySizeInBits: 256,
      options: options as? [String: String] ?? [:]
    )
  }

  // MARK: - Methods from SecurityProviderBase

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

// MARK: - Helper Classes for Adapter

/// Simple implementation of CryptoServiceProtocol for use in the adapter
private final class DummyCryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
  // MARK: - Required methods from CryptoServiceProtocol
  
  func generateKey() async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
  }
  
  func hash(data: UmbraCoreTypes.SecureBytes) async 
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Generate a dummy hash
    return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
  }
  
  func verify(data: UmbraCoreTypes.SecureBytes, against hash: UmbraCoreTypes.SecureBytes) async
    -> Result<Bool, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Always verify as true
    return .success(true)
  }
  
  func encryptSymmetric(
    data: UmbraCoreTypes.SecureBytes,
    key: UmbraCoreTypes.SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(data)
  }
  
  func decryptSymmetric(
    data: UmbraCoreTypes.SecureBytes,
    key: UmbraCoreTypes.SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(data)
  }
  
  func encryptAsymmetric(
    data: UmbraCoreTypes.SecureBytes,
    publicKey: UmbraCoreTypes.SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(data)
  }
  
  func decryptAsymmetric(
    data: UmbraCoreTypes.SecureBytes,
    privateKey: UmbraCoreTypes.SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(data)
  }
  
  func hash(
    data: UmbraCoreTypes.SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
  }
  
  // MARK: - Additional methods
  
  func encrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async 
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Simple mock implementation
    return .success(data)
  }
  
  func decrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async 
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Simple mock implementation
    return .success(data)
  }
  
  func sign(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async 
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Generate a dummy signature
    return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 64)))
  }
  
  func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async 
    -> Result<Bool, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Always verify as true
    return .success(true)
  }
  
  func mac(data: UmbraCoreTypes.SecureBytes, key: UmbraCoreTypes.SecureBytes) async 
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Generate a dummy MAC
    return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
  }
  
  func generateRandomData(length: Int) async
    -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    let bytes = [UInt8](repeating: 0, count: length)
    return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
  }
  
  // Legacy methods with DTO responses
  
  func encryptSymmetric(
    data: UmbraCoreTypes.SecureBytes,
    key _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
  }
  
  func decryptSymmetric(
    data: UmbraCoreTypes.SecureBytes,
    key _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
  }
  
  func encryptAsymmetric(
    data: UmbraCoreTypes.SecureBytes,
    publicKey _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
  }
  
  func decryptAsymmetric(
    data: UmbraCoreTypes.SecureBytes,
    privateKey _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
  }
  
  func hash(
    data: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let hashBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32))
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: hashBytes)
  }
  
  func mac(
    data: UmbraCoreTypes.SecureBytes,
    key _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let macBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32))
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: macBytes)
  }
  
  func sign(
    data: UmbraCoreTypes.SecureBytes,
    privateKey _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let signatureBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 64))
    return SecurityProtocolsCore.SecurityResultDTO(success: true, data: signatureBytes)
  }
  
  func verify(
    signature: UmbraCoreTypes.SecureBytes,
    data: UmbraCoreTypes.SecureBytes,
    publicKey _: UmbraCoreTypes.SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    // Use a valid constructor and return the result as a Boolean value
    return SecurityProtocolsCore.SecurityResultDTO(success: true)
  }
}

/// Simple implementation of KeyManagementProtocol for use in the adapter
private final class DummyKeyManager: SecurityProtocolsCore.KeyManagementProtocol {
  func generateKey(
    type _: String,
    size: Int
  ) async -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: size / 8)))
  }

  func storeKey(
    _: UmbraCoreTypes.SecureBytes,
    withIdentifier _: String
  ) async -> Result<Void, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success(())
  }

  func retrieveKey(withIdentifier _: String) async
  -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
  }

  func deleteKey(withIdentifier _: String) async
  -> Result<Void, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success(())
  }

  func rotateKey(withIdentifier _: String, dataToReencrypt: UmbraCoreTypes.SecureBytes? = nil
  ) async -> Result<(
    newKey: UmbraCoreTypes.SecureBytes,
    reencryptedData: UmbraCoreTypes.SecureBytes?
  ), ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success((
      newKey: UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)),
      reencryptedData: dataToReencrypt
    ))
  }

  func listKeyIdentifiers() async -> Result<[String], ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Dummy implementation
    .success(["key1", "key2", "key3"])
  }
}

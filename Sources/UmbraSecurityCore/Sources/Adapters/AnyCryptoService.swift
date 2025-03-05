import SecurityProtocolsCore
import UmbraCoreTypes

/// Type-erased wrapper for CryptoServiceProtocol
/// This allows for cleaner interfaces without exposing implementation details
public final class AnyCryptoService: CryptoServiceProtocol {
  // MARK: - Private Properties

  private let _encrypt: @Sendable (SecureBytes, SecureBytes) async -> Result<
    SecureBytes,
    SecurityError
  >
  private let _decrypt: @Sendable (SecureBytes, SecureBytes) async -> Result<
    SecureBytes,
    SecurityError
  >
  private let _hash: @Sendable (SecureBytes) async -> Result<SecureBytes, SecurityError>
  private let _generateKey: @Sendable () async -> Result<SecureBytes, SecurityError>
  private let _generateRandomData: @Sendable (Int) async -> Result<SecureBytes, SecurityError>

  // New required methods
  private let _verify: @Sendable (SecureBytes, SecureBytes) async -> Bool
  private let _encryptSymmetric: @Sendable (SecureBytes, SecureBytes, SecurityConfigDTO) async
    -> SecurityResultDTO
  private let _decryptSymmetric: @Sendable (SecureBytes, SecureBytes, SecurityConfigDTO) async
    -> SecurityResultDTO
  private let _encryptAsymmetric: @Sendable (SecureBytes, SecureBytes, SecurityConfigDTO) async
    -> SecurityResultDTO
  private let _decryptAsymmetric: @Sendable (SecureBytes, SecureBytes, SecurityConfigDTO) async
    -> SecurityResultDTO
  private let _hashWithConfig: @Sendable (SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO

  // MARK: - Initialization

  /// Create a type-erased crypto service from an existing implementation
  /// - Parameter service: The crypto service to wrap
  public init(_ service: some CryptoServiceProtocol) {
    _encrypt=service.encrypt
    _decrypt=service.decrypt
    _hash=service.hash
    _generateKey=service.generateKey
    _generateRandomData=service.generateRandomData

    // New property initializations
    _verify=service.verify
    _encryptSymmetric=service.encryptSymmetric
    _decryptSymmetric=service.decryptSymmetric
    _encryptAsymmetric=service.encryptAsymmetric
    _decryptAsymmetric=service.decryptAsymmetric
    _hashWithConfig=service.hash
  }

  // MARK: - CryptoServiceProtocol Implementation

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    await _encrypt(data, key)
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    await _decrypt(data, key)
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    await _hash(data)
  }

  public func generateKey() async -> Result<SecureBytes, SecurityError> {
    await _generateKey()
  }

  public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    await _generateRandomData(length)
  }

  // New method implementations

  public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    await _verify(data, hash)
  }

  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await _encryptSymmetric(data, key, config)
  }

  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await _decryptSymmetric(data, key, config)
  }

  public func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await _encryptAsymmetric(data, publicKey, config)
  }

  public func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await _decryptAsymmetric(data, privateKey, config)
  }

  public func hash(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await _hashWithConfig(data, config)
  }
}

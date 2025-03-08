import UmbraCoreTypes
import ErrorHandling

/// Most complete protocol for XPC services including all cryptographic functions
/// This protocol is typically implemented by crypto service providers
public protocol XPCServiceProtocolComplete: XPCServiceProtocolStandard {
  /// Protocol identifier used for service discovery and protocol negotiation
  static var protocolIdentifier: String { get }

  /// Test connectivity with the XPC service
  /// - Returns: Boolean indicating whether the service is responsive
  func pingComplete() async -> Result<Bool, XPCSecurityError>

  /// Synchronise encryption keys across processes
  /// - Parameter syncData: Key synchronisation data
  /// - Returns: Success or a descriptive error
  func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError>

  /// Encrypt data using the service's encryption implementation
  /// - Parameter data: Data to encrypt
  /// - Returns: Encrypted data or error
  func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

  /// Decrypt data using the service's decryption implementation
  /// - Parameter data: Data to decrypt
  /// - Returns: Decrypted data or error
  func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

  /// Generate a cryptographic key using the service
  /// - Returns: Generated key or error
  func generateKey() async -> Result<SecureBytes, XPCSecurityError>

  /// Generate a cryptographic key of specific type and bits
  /// - Parameters:
  ///   - type: Type of key to generate
  ///   - bits: Key size in bits
  /// - Returns: The generated key data
  func generateKey(type: KeyType, bits: Int) async -> Result<SecureBytes, XPCSecurityError>

  /// Hash data using the service's hashing implementation
  /// - Parameter data: Data to hash
  /// - Returns: Hash value or error
  func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

  /// Export a key in secure format
  /// - Parameter keyIdentifier: Key to export
  /// - Returns: Secure data containing exported key
  func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError>

  /// Import a previously exported key
  /// - Parameters:
  ///   - keyData: Key data to import
  ///   - identifier: Optional identifier to assign
  /// - Returns: Key identifier for the imported key
  func importKey(_ keyData: SecureBytes, identifier: String?) async
    -> Result<String, XPCSecurityError>
}

// MARK: - Default Implementations

extension XPCServiceProtocolComplete {
  /// Default protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.protocol.complete"
  }

  /// Default ping implementation - always successful in the base protocol
  public func pingComplete() async -> Result<Bool, XPCSecurityError> {
    .success(true)
  }

  /// Default implementation that returns a not implemented error
  public func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
    .failure(.notImplemented(reason: "Key synchronisation not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Encryption not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Decryption not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Key generation not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func generateKey(
    type _: KeyType,
    bits _: Int
  ) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Key generation with parameters not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Hashing not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.notImplemented(reason: "Key export not implemented"))
  }

  /// Default implementation that returns a not implemented error
  public func importKey(
    _: SecureBytes,
    identifier _: String?
  ) async -> Result<String, XPCSecurityError> {
    .failure(.notImplemented(reason: "Key import not implemented"))
  }

  /// Bridge method to implement XPCServiceProtocolBasic.ping() using pingComplete()
  public func ping() async -> Result<Bool, XPCSecurityError> {
    await pingComplete()
  }

  /// Bridge method to implement XPCServiceProtocolBasic.synchroniseKeys() using synchronizeKeys()
  public func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
    await synchronizeKeys(syncData)
  }
}

import UmbraCoreTypes

/// Extended XPC service protocol that builds upon the base protocol
/// by adding additional security operations
public protocol XPCServiceProtocolStandard: XPCServiceProtocolBasic {
  /// Generate random data of the specified length
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Random data
  func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError>
  /// Encrypt data using the service's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - keyIdentifier: Optional key identifier to use
  /// - Returns: Encrypted data
  func encryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError>
  /// Decrypt data using the service's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - keyIdentifier: Optional key identifier to use
  /// - Returns: Decrypted data
  func decryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError>
  /// Hash data using the service's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash result
  func hashData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>
  /// Sign data using the service's signing mechanism
  /// - Parameters:
  ///   - data: Data to sign
  ///   - keyIdentifier: Key identifier to use for signing
  /// - Returns: Signature data
  func signData(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError>
  /// Verify signature for data
  /// - Parameters:
  ///   - signature: Signature to verify
  ///   - data: Original data
  ///   - keyIdentifier: Key identifier to use for verification
  /// - Returns: True if signature is valid
  func verifySignature(
    _ signature: SecureBytes,
    for data: SecureBytes,
    keyIdentifier: String
  ) async throws -> Bool
}

/// Protocol for security service that manages secure storage operations
public protocol SecureStorageServiceProtocol: Sendable {
  /// Store data securely
  /// - Parameters:
  ///   - data: Data to store
  ///   - identifier: Unique identifier for the data
  ///   - metadata: Optional metadata to associate with the data
  func storeSecurely(
    _ data: SecureBytes,
    identifier: String,
    metadata: [String: String]?
  ) async throws

  /// Retrieve securely stored data
  /// - Parameter identifier: Unique identifier for the data
  /// - Returns: The securely stored data
  func retrieveSecurely(identifier: String) async -> Result<SecureBytes, XPCSecurityError>
  /// Delete securely stored data
  /// - Parameter identifier: Unique identifier for the data
  func deleteSecurely(identifier: String) async throws

  /// List all secure storage identifiers
  /// - Returns: Array of identifiers
  func listIdentifiers() async -> Result<[String], XPCSecurityError>
  /// Get metadata for secure storage item
  /// - Parameter identifier: Unique identifier for the data
  /// - Returns: Associated metadata
  func getMetadata(for identifier: String) async -> Result<[String: String]?, XPCSecurityError>
}

/// Protocol for security service that provides key management
public protocol KeyManagementServiceProtocol: Sendable {
  /// Generate a new key
  /// - Parameters:
  ///   - keyType: Type of key to generate
  ///   - keyIdentifier: Optional identifier for the key
  ///   - metadata: Optional metadata to associate with the key
  /// - Returns: Identifier for the generated key
  func generateKey(
    keyType: KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async throws -> String

  /// Delete a key
  /// - Parameter keyIdentifier: Identifier for the key to delete
  func deleteKey(keyIdentifier: String) async throws

  /// List all key identifiers
  /// - Returns: Array of key identifiers
  func listKeyIdentifiers() async -> Result<[String], XPCSecurityError>
  /// Get metadata for a key
  /// - Parameter keyIdentifier: Identifier for the key
  /// - Returns: Associated metadata
  func getKeyMetadata(for keyIdentifier: String) async -> Result<[String: String]?, XPCSecurityError>
}

/// Key types supported by the security service
public enum KeyType: String, Sendable {
  case symmetric
  case asymmetric
  case hmac
}

/// Comprehensive security service protocol that combines multiple security capabilities
public protocol ComprehensiveSecurityServiceProtocol: XPCServiceProtocolStandard, SecureStorageServiceProtocol, KeyManagementServiceProtocol {
  /// Get the service version
  func getServiceVersion() async -> Result<String, XPCSecurityError>
  /// Get the service status
  func getServiceStatus() async -> Result<ServiceStatus, XPCSecurityError>
}

/// Status of the security service
public enum ServiceStatus: String, Sendable {
  case operational
  case degraded
  case maintenance
  case offline
}

/// Factory protocol for creating security service instances
public protocol SecurityServiceFactoryProtocol: Sendable {
  /// Create a basic XPC service
  func createXPCService() -> XPCServiceProtocolBasic

  /// Create an extended XPC service
  func createExtendedXPCService() -> XPCServiceProtocolStandard

  /// Create a secure storage service
  func createSecureStorageService() -> SecureStorageServiceProtocol

  /// Create a key management service
  func createKeyManagementService() -> KeyManagementServiceProtocol

  /// Create a comprehensive security service
  func createComprehensiveSecurityService() -> ComprehensiveSecurityServiceProtocol
}

import CoreErrors
import Foundation
import UmbraCoreTypes

/// Extended XPC service protocol that builds upon the base protocol
/// by adding additional security operations
@objc
public protocol XPCServiceProtocolStandard: XPCServiceProtocolBasic {
  /// Generate random data of the specified length
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Random data
  @objc
  func generateRandomData(length: Int) async -> NSObject?

  /// Encrypt data using the service's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - keyIdentifier: Optional key identifier to use
  /// - Returns: Encrypted data
  @objc
  func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?

  /// Decrypt data using the service's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - keyIdentifier: Optional key identifier to use
  /// - Returns: Decrypted data
  @objc
  func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?

  /// Hash data using the service's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash result
  @objc
  func hashData(_ data: NSData) async -> NSObject?

  /// Sign data using the service's signing mechanism
  /// - Parameters:
  ///   - data: Data to sign
  ///   - keyIdentifier: Key identifier to use for signing
  /// - Returns: Signature data
  @objc
  func signData(_ data: NSData, keyIdentifier: String) async -> NSObject?

  /// Verify signature for data
  /// - Parameters:
  ///   - signature: Signature to verify
  ///   - data: Original data
  ///   - keyIdentifier: Key identifier to use for verification
  /// - Returns: True if signature is valid, or error
  @objc
  func verifySignature(
    _ signature: NSData,
    for data: NSData,
    keyIdentifier: String
  ) async -> NSObject?
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
  ) async -> Result<Void, XPCSecurityError>

  /// Retrieve securely stored data
  /// - Parameter identifier: Unique identifier for the data
  /// - Returns: The securely stored data
  func retrieveSecurely(identifier: String) async -> Result<SecureBytes, XPCSecurityError>
  /// Delete securely stored data
  /// - Parameter identifier: Unique identifier for the data
  func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError>

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
  ) async -> Result<String, XPCSecurityError>

  /// Delete a key
  /// - Parameter keyIdentifier: Identifier for the key to delete
  func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError>

  /// List all key identifiers
  /// - Returns: Array of key identifiers
  func listKeyIdentifiers() async -> Result<[String], XPCSecurityError>
  /// Get metadata for a key
  /// - Parameter keyIdentifier: Identifier for the key
  /// - Returns: Associated metadata
  func getKeyMetadata(for keyIdentifier: String) async
    -> Result<[String: String]?, XPCSecurityError>
}

/// Key types supported by the security service
public enum KeyType: String, Sendable {
  case symmetric
  case asymmetric
  case hmac
}

/// Comprehensive security service protocol that combines multiple security capabilities
public protocol ComprehensiveSecurityServiceProtocol: XPCServiceProtocolStandard,
SecureStorageServiceProtocol, KeyManagementServiceProtocol {
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

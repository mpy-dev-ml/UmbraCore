/**
 # UmbraCore Cryptographic Service
 
 The CryptoService provides core cryptographic operations for the UmbraCore security framework.
 It implements the CryptoServiceProtocol and delegates to specialised service components for:
 - Symmetric encryption/decryption
 - Asymmetric encryption/decryption
 - Cryptographic hashing and MAC generation
 - Key generation and management
 
 ## Architecture
 
 This implementation follows a modular architecture where each cryptographic concern
 is handled by a dedicated component:
 
 1. SymmetricCrypto - Handles symmetric encryption operations (AES-GCM)
 2. AsymmetricCrypto - Handles asymmetric encryption (currently using a placeholder implementation)
 3. HashingService - Provides hash functions and MAC generation/verification
 4. KeyManagementService - Handles key generation and random data
 
 ## Security Considerations
 
 * **Development Status**: This module contains proof-of-concept implementations that are NOT
   suitable for production use without further review and enhancement.
 * **Cryptographic Strength**: The symmetric encryption uses AES-GCM with 256-bit keys,
   which is considered strong by current standards. The asymmetric encryption implementation
   is currently a placeholder and must be replaced with a proper RSA or ECC implementation.
 * **Memory Safety**: Sensitive cryptographic materials are stored in SecureBytes containers
   which provide basic memory protections, but these protections are not comprehensive.
 * **Side-Channel Attacks**: The current implementation doesn't include mitigations for
   timing attacks, power analysis, or other side-channel vulnerabilities.
 */

import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// Implementation of the CryptoServiceProtocol.
///
/// This is the main entry point for cryptographic operations.
/// It delegates to specialised services for different types of operations.
public final class CryptoService: CryptoServiceProtocol, Sendable {
  // MARK: - Properties
  
  /// Service for symmetric encryption operations
  private let symmetricCrypto: SymmetricCrypto
  
  /// Service for asymmetric encryption operations
  private let asymmetricCrypto: AsymmetricCrypto
  
  /// Service for hashing operations
  private let hashingService: HashingService
  
  /// Service for key management operations
  private let keyManagementService: KeyManagementService
  
  // MARK: - Initialisation
  
  /// Initialise with default implementations of all services
  public nonisolated init() {
    self.symmetricCrypto = SymmetricCrypto()
    self.asymmetricCrypto = AsymmetricCrypto()
    self.hashingService = HashingService()
    self.keyManagementService = KeyManagementService()
  }
  
  /// Initialise with custom implementations of all services
  /// - Parameters:
  ///   - symmetricCrypto: Service for symmetric encryption
  ///   - asymmetricCrypto: Service for asymmetric encryption
  ///   - hashingService: Service for hashing
  ///   - keyManagementService: Service for key management
  public nonisolated init(
    symmetricCrypto: SymmetricCrypto,
    asymmetricCrypto: AsymmetricCrypto,
    hashingService: HashingService,
    keyManagementService: KeyManagementService
  ) {
    self.symmetricCrypto = symmetricCrypto
    self.asymmetricCrypto = asymmetricCrypto
    self.hashingService = hashingService
    self.keyManagementService = keyManagementService
  }
  
  // MARK: - Basic CryptoServiceProtocol Methods
  
  /// Encrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data or error
  public func encrypt(
    data: SecureBytes, 
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await symmetricCrypto.encrypt(data: data, using: key)
  }
  
  /// Decrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data or error
  public func decrypt(
    data: SecureBytes, 
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await symmetricCrypto.decrypt(data: data, using: key)
  }
  
  /// Generate a cryptographic key suitable for encryption/decryption
  /// - Returns: A new cryptographic key or error
  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await keyManagementService.generateRandomData(length: 32)
  }
  
  /// Hash the provided data
  /// - Parameter data: Data to hash
  /// - Returns: Hash value or error
  public func hash(
    data: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await hashingService.hash(data: data)
  }
  
  /// Verify data against a hash
  /// - Parameters:
  ///   - data: Data to verify
  ///   - hash: Hash to verify against
  /// - Returns: True if hash matches, false otherwise
  public func verify(
    data: SecureBytes, 
    against hash: SecureBytes
  ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
    let computedHashResult = await hashingService.hash(data: data)
    
    switch computedHashResult {
    case .success(let computedHash):
      return .success(computedHash.secureCompare(with: hash))
      
    case .failure(let error):
      return .failure(error)
    }
  }
  
  /// Generate random data of the specified length
  /// - Parameter length: Length of random data to generate in bytes
  /// - Returns: Random data or error
  public func generateRandomData(
    length: Int
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await keyManagementService.generateRandomData(length: length)
  }
  
  // MARK: - Symmetric Encryption with Configuration
  
  /// Encrypt data using symmetric encryption with configuration options
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration options
  /// - Returns: Encrypted data or error
  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // In a more complete implementation, we would extract configuration options
    // such as algorithm, mode, padding, etc. from the config object
    return await symmetricCrypto.encrypt(data: data, using: key)
  }
  
  /// Decrypt data using symmetric encryption with configuration options
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration options
  /// - Returns: Decrypted data or error
  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // In a more complete implementation, we would extract configuration options
    // such as algorithm, mode, padding, etc. from the config object
    return await symmetricCrypto.decrypt(data: data, using: key)
  }
  
  // MARK: - Asymmetric Encryption with Configuration
  
  /// Encrypt data using asymmetric encryption with configuration options
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - publicKey: Public key for encryption
  ///   - config: Configuration options
  /// - Returns: Encrypted data or error
  public func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await asymmetricCrypto.encryptAsymmetric(
      data: data, 
      publicKey: publicKey, 
      config: config
    )
  }
  
  /// Decrypt data using asymmetric encryption with configuration options
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - privateKey: Private key for decryption
  ///   - config: Configuration options
  /// - Returns: Decrypted data or error
  public func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await asymmetricCrypto.decryptAsymmetric(
      data: data, 
      privateKey: privateKey, 
      config: config
    )
  }
  
  // MARK: - Hashing with Configuration
  
  /// Hash data with configuration options
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Configuration options
  /// - Returns: Hash value or error
  public func hash(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // In a more complete implementation, we would extract configuration options
    // such as algorithm from the config object
    return await hashingService.hash(data: data)
  }
}

// MARK: - SecurityProvider API Extensions

extension CryptoService {
  /// Encrypt data using symmetric encryption (SecurityResultDTO version)
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration parameters
  /// - Returns: A security result containing the encrypted data or error information
  public func encryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await encryptSymmetric(data: data, key: key, config: config)
    switch result {
    case .success(let encryptedData):
      return SecurityResultDTO(data: encryptedData)
    case .failure(let error):
      return SecurityResultDTO.failure(error: error)
    }
  }
  
  /// Decrypt data using symmetric encryption (SecurityResultDTO version)
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration parameters
  /// - Returns: A security result containing the decrypted data or error information
  public func decryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await decryptSymmetric(data: data, key: key, config: config)
    switch result {
    case .success(let decryptedData):
      return SecurityResultDTO(data: decryptedData)
    case .failure(let error):
      return SecurityResultDTO.failure(error: error)
    }
  }
  
  /// Hash data with configuration parameters (SecurityResultDTO version)
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Configuration parameters
  /// - Returns: A security result containing the hash value or error information
  public func hashDTO(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await hash(data: data, config: config)
    switch result {
    case .success(let hashValue):
      return SecurityResultDTO(data: hashValue)
    case .failure(let error):
      return SecurityResultDTO.failure(error: error)
    }
  }
}

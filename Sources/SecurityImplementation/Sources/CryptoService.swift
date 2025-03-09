/**
 # UmbraCore Crypto Service
 
 This file provides a concrete implementation of the CryptoServiceProtocol
 that serves as a facade for specialized cryptographic services.
 
 ## Design Pattern
 
 This class follows the Facade design pattern, providing a simplified interface for
 cryptographic operations by coordinating between specialized components:
 
 * CryptoServiceCore: Core coordinator between different cryptographic services
 * SymmetricCrypto: Handles symmetric encryption and decryption
 * HashingService: Handles hashing operations
 
 ## Security Considerations
 
 * All cryptographic operations use secure algorithms with proper parameters
 * Sensitive data is stored in SecureBytes containers to protect memory
 * Errors are reported with appropriate context but without sensitive details
 * Cryptographic operations follow relevant standards and best practices
 */

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreErrors
import ErrorHandlingDomains

/// Implementation of the CryptoServiceProtocol that coordinates between specialized
/// cryptographic service components.
public final class CryptoService: CryptoServiceProtocol {
  // MARK: - Properties
  
  /// Core implementation that coordinates between specialized services
  private let serviceCore: CryptoServiceCore
  
  // MARK: - Initialisation
  
  /// Creates a new CryptoService with default configuration
  public init() {
    self.serviceCore = CryptoServiceCore()
  }
  
  /// Creates a new CryptoService with a custom service core (for testing)
  /// - Parameter serviceCore: The custom service core to use
  init(serviceCore: CryptoServiceCore) {
    self.serviceCore = serviceCore
  }
  
  // MARK: - Basic CryptoServiceProtocol Implementation
  
  /// Encrypts binary data using the provided key.
  /// - Parameters:
  ///   - data: The data to encrypt as `SecureBytes`.
  ///   - key: The encryption key as `SecureBytes`.
  /// - Returns: The encrypted data as `SecureBytes` or an error.
  public func encrypt(data: SecureBytes, using key: SecureBytes) async
    -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Use the default AES-GCM algorithm
    let config = SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
    let result = await encryptSymmetricDTO(data: data, key: key, config: config)
    
    if result.success, let encryptedData = result.data {
      return .success(encryptedData)
    } else {
      return .failure(.encryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }

  /// Decrypts binary data using the provided key.
  /// - Parameters:
  ///   - data: The encrypted data as `SecureBytes`.
  ///   - key: The decryption key as `SecureBytes`.
  /// - Returns: The decrypted data as `SecureBytes` or an error.
  public func decrypt(data: SecureBytes, using key: SecureBytes) async
    -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Use the default AES-GCM algorithm
    let config = SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
    let result = await decryptSymmetricDTO(data: data, key: key, config: config)
    
    if result.success, let decryptedData = result.data {
      return .success(decryptedData)
    } else {
      return .failure(.decryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }

  /// Generates a cryptographic key suitable for encryption/decryption operations.
  /// - Returns: A new cryptographic key as `SecureBytes` or an error.
  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Generate a 256-bit AES key by default
    let config = SecurityConfigDTO(algorithm: "AES", keySizeInBits: 256)
    let result = await generateKeyDTO(config: config)
    
    if result.success, let key = result.data {
      return .success(key)
    } else {
      return .failure(.serviceError(code: result.errorCode ?? -1, reason: result.errorMessage ?? "Unknown error"))
    }
  }

  /// Hashes the provided data using a cryptographically strong algorithm.
  /// - Parameter data: The data to hash as `SecureBytes`.
  /// - Returns: The resulting hash as `SecureBytes` or an error.
  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Use SHA-256 by default
    let config = SecurityConfigDTO(algorithm: "SHA-256", keySizeInBits: 256)
    let result = await hashDTO(data: data, config: config)
    
    if result.success, let hash = result.data {
      return .success(hash)
    } else {
      return .failure(.serviceError(code: result.errorCode ?? -1, reason: result.errorMessage ?? "Unknown error"))
    }
  }

  /// Verifies the integrity of data against a known hash.
  /// - Parameters:
  ///   - data: The data to verify as `SecureBytes`.
  ///   - hash: The expected hash value as `SecureBytes`.
  /// - Returns: Boolean indicating whether the hash matches.
  public func verify(data: SecureBytes, against hash: SecureBytes) async
    -> Result<Bool, UmbraErrors.Security.Protocols> {
    // Hash the data
    let hashResult = await self.hash(data: data)
    
    switch hashResult {
    case .success(let computedHash):
      // Compare the computed hash with the provided hash
      let match = computedHash == hash
      return .success(match)
    case .failure(let error):
      return .failure(error)
    }
  }
  
  // MARK: - Extended Cryptographic Operations
  
  /// Generate a cryptographic key with the specified configuration
  /// - Parameter config: Configuration for key generation
  /// - Returns: The generated key or error information
  public func generateKeyDTO(config: SecurityConfigDTO) async -> SecurityResultDTO {
    return await serviceCore.generateKey(config: config)
  }
  
  // MARK: - Symmetric Operations
  
  /// Encrypt data using symmetric encryption with the specified configuration
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Encryption configuration
  /// - Returns: Encrypted data or error information
  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO = SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result = await encryptSymmetricDTO(data: data, key: key, config: config)
    
    if result.success, let encryptedData = result.data {
      return .success(encryptedData)
    } else {
      return .failure(.encryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  /// Decrypt data using symmetric encryption with the specified configuration
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Decryption configuration
  /// - Returns: Decrypted data or error information
  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO = SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result = await decryptSymmetricDTO(data: data, key: key, config: config)
    
    if result.success, let decryptedData = result.data {
      return .success(decryptedData)
    } else {
      return .failure(.decryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  // MARK: - Extended CryptoServiceProtocol Methods
  
  /// Encrypts data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - publicKey: Public key to use for encryption
  ///   - config: Configuration options
  /// - Returns: Result containing encrypted data or error
  public func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result = await encryptAsymmetricDTO(data: data, publicKey: publicKey, config: config)
    
    if result.success, let encryptedData = result.data {
      return .success(encryptedData)
    } else {
      return .failure(.encryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  /// Decrypts data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - privateKey: Private key to use for decryption
  ///   - config: Configuration options
  /// - Returns: Result containing decrypted data or error
  public func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result = await decryptAsymmetricDTO(data: data, privateKey: privateKey, config: config)
    
    if result.success, let decryptedData = result.data {
      return .success(decryptedData)
    } else {
      return .failure(.decryptionFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  /// Hashes data with specific configuration
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Configuration options including algorithm selection
  /// - Returns: Result containing hash or error
  public func hash(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result = await hashDTO(data: data, config: config)
    
    if result.success, let hash = result.data {
      return .success(hash)
    } else {
      return .failure(.serviceError(code: result.errorCode ?? -1, reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  /// Generates cryptographically secure random data
  /// - Parameter length: The length of random data to generate in bytes
  /// - Returns: Result containing random data or error
  public func generateRandomData(length: Int) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let config = SecurityConfigDTO(
      algorithm: "Random",
      keySizeInBits: length * 8
    )
    
    let result = await serviceCore.generateRandomData(length: length, config: config)
    
    if result.success, let randomData = result.data {
      return .success(randomData)
    } else {
      return .failure(.randomGenerationFailed(reason: result.errorMessage ?? "Unknown error"))
    }
  }
  
  // MARK: - CryptoServiceProtocol Implementation
  
  /**
   Encrypt data using symmetric encryption.
   
   - Parameters:
     - data: The data to encrypt
     - key: The encryption key
     - config: Configuration options for the encryption
   - Returns: A result containing the encrypted data or an error
   
   This method uses the configuration's algorithm and any provided initialization vector.
   If no IV is provided, one will be generated automatically and returned with the result.
   
   ## Supported Algorithms
   
   * "AES-GCM" (default): AES encryption with Galois/Counter Mode
   * "AES-CBC": AES encryption with Cipher Block Chaining Mode
   
   ## Error Cases
   
   * Invalid algorithm
   * Invalid key length for the selected algorithm
   * Encryption failure due to invalid parameters or internal error
   */
  public func encryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    return await serviceCore.encryptSymmetric(data: data, key: key, config: config)
  }
  
  /**
   Decrypt data using symmetric encryption.
   
   - Parameters:
     - data: The encrypted data to decrypt
     - key: The decryption key
     - config: Configuration options for the decryption
   - Returns: A result containing the decrypted data or an error
   
   This method uses the configuration's algorithm and requires a matching initialization vector
   to the one used during encryption.
   
   ## Supported Algorithms
   
   * "AES-GCM" (default): AES encryption with Galois/Counter Mode
   * "AES-CBC": AES encryption with Cipher Block Chaining Mode
   
   ## Error Cases
   
   * Invalid algorithm
   * Invalid key length for the selected algorithm
   * Missing or invalid initialization vector
   * Authentication failure (for authenticated encryption modes like GCM)
   * Decryption failure due to corrupted data or internal error
   */
  public func decryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    return await serviceCore.decryptSymmetric(data: data, key: key, config: config)
  }
  
  /**
   Hash data using the specified algorithm.
   
   - Parameters:
     - data: The data to hash
     - config: Configuration options for the hashing operation
   - Returns: A result containing the hash value or an error
   
   ## Supported Algorithms
   
   * "SHA-256" (default): SHA-2 with 256-bit digest
   * "SHA-512": SHA-2 with 512-bit digest
   * "SHA3-256": SHA-3 with 256-bit digest
   * "SHA3-512": SHA-3 with 512-bit digest
   
   ## Error Cases
   
   * Invalid algorithm
   * Hashing failure due to internal error
   */
  public func hashDTO(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    return await serviceCore.hash(data: data, config: config)
  }
  
  /**
   Encrypt data using asymmetric encryption.
   
   - Parameters:
     - data: The data to encrypt
     - publicKey: The public key to use for encryption
     - config: Configuration options for the encryption
   - Returns: A result containing the encrypted data or an error
   
   This method uses the configuration's algorithm and any provided parameters.
   
   ## Supported Algorithms
   
   * "RSA-OAEP" (default): RSA encryption with OAEP padding
   * "RSA-PKCS1": RSA encryption with PKCS#1 padding
   
   ## Error Cases
   
   * Invalid algorithm
   * Invalid key length for the selected algorithm
   * Encryption failure due to invalid parameters or internal error
   */
  public func encryptAsymmetricDTO(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    return await serviceCore.encryptAsymmetric(data: data, publicKey: publicKey, config: config)
  }
  
  /**
   Decrypt data using asymmetric encryption.
   
   - Parameters:
     - data: The encrypted data to decrypt
     - privateKey: The private key to use for decryption
     - config: Configuration options for the decryption
   - Returns: A result containing the decrypted data or an error
   
   This method uses the configuration's algorithm and requires a matching private key
   to the one used during encryption.
   
   ## Supported Algorithms
   
   * "RSA-OAEP" (default): RSA encryption with OAEP padding
   * "RSA-PKCS1": RSA encryption with PKCS#1 padding
   
   ## Error Cases
   
   * Invalid algorithm
   * Invalid key length for the selected algorithm
   * Decryption failure due to corrupted data or internal error
   */
  public func decryptAsymmetricDTO(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    return await serviceCore.decryptAsymmetric(data: data, privateKey: privateKey, config: config)
  }
}

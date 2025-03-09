/**
 # CryptoServiceCore
 
 Provides core cryptographic service implementation that coordinates between specialised
 services. It delegates operations to the appropriate specialised components while
 providing a simplified interface to callers.
 
 ## Responsibilities
 
 * Route cryptographic operations to the appropriate specialised service
 * Provide a simplified interface for common operations
 * Handle error normalisation
 */

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import ErrorHandlingDomains

/// Core service provider for cryptographic operations that coordinates specialised
/// services. It delegates operations to the appropriate specialised components while
/// providing a simplified interface to callers.
final class CryptoServiceCore: CryptoServiceProtocol, Sendable {
  // MARK: - Properties
  
  /// Service for symmetric encryption operations
  private let symmetricCrypto: SymmetricCrypto
  
  /// Service for asymmetric encryption operations
  private let asymmetricCrypto: AsymmetricCrypto
  
  /// Service for hashing operations
  private let hashingService: HashingService
  
  /// Service for key generation
  private let keyGenerator: KeyGenerator
  
  // MARK: - Initialisation
  
  /// Creates a new crypto service coordinator
  init(
    symmetricCrypto: SymmetricCrypto = SymmetricCrypto(),
    asymmetricCrypto: AsymmetricCrypto = AsymmetricCrypto(),
    hashingService: HashingService = HashingService(),
    keyGenerator: KeyGenerator = KeyGenerator()
  ) {
    self.symmetricCrypto = symmetricCrypto
    self.asymmetricCrypto = asymmetricCrypto
    self.hashingService = hashingService
    self.keyGenerator = keyGenerator
  }
  
  // MARK: - CryptoServiceProtocol Implementation
  
  /// Encrypt data using the provided key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data or error
  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Use the symmetric crypto service with default configuration
    return await symmetricCrypto.encrypt(data: data, using: key)
  }
  
  /// Decrypt data using the provided key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data or error
  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Use the symmetric crypto service with default configuration
    return await symmetricCrypto.decrypt(data: data, using: key)
  }
  
  // MARK: - Extended API
  
  /// Encrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration for the encryption
  /// - Returns: Result of the encryption operation
  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await symmetricCrypto.encryptSymmetric(data: data, key: key, config: config)
    
    switch result {
    case .success(let encryptedData):
      return SecurityResultDTO(data: encryptedData)
    case .failure(let error):
      return SecurityResultDTO(
        success: false,
        errorCode: 500,
        errorMessage: "Encryption failed: \(error.localizedDescription)"
      )
    }
  }
  
  /// Decrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration for the decryption
  /// - Returns: Result of the decryption operation
  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await symmetricCrypto.decryptSymmetric(data: data, key: key, config: config)
    
    switch result {
    case .success(let decryptedData):
      return SecurityResultDTO(data: decryptedData)
    case .failure(let error):
      return SecurityResultDTO(
        success: false,
        errorCode: 500,
        errorMessage: "Decryption failed: \(error.localizedDescription)"
      )
    }
  }
  
  /// Hash data using the specified algorithm
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Hashing configuration
  /// - Returns: Result of the hashing operation
  public func hashData(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await hashingService.hash(data: data, config: config)
    
    switch result {
    case .success(let hashedData):
      return SecurityResultDTO(data: hashedData)
    case .failure(let error):
      return SecurityResultDTO(
        success: false,
        errorCode: 500,
        errorMessage: "Hashing failed: \(error.localizedDescription)"
      )
    }
  }
  
  /// Encrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - publicKey: Public key for encryption
  ///   - config: Encryption configuration
  /// - Returns: Result of the encryption operation
  func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await asymmetricCrypto.encrypt(
      data: data,
      publicKey: publicKey,
      algorithm: config.algorithm
    )
    
    // The encrypt method already returns a SecurityResultDTO
    return result
  }
  
  /// Decrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - privateKey: Private key for decryption
  ///   - config: Decryption configuration
  /// - Returns: Result of the decryption operation
  func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    let result = await asymmetricCrypto.decrypt(
      data: data,
      privateKey: privateKey,
      algorithm: config.algorithm
    )
    
    // The decrypt method already returns a SecurityResultDTO
    return result
  }
  
  /// Generate key using the specified configuration
  /// - Parameter config: Key generation configuration
  /// - Returns: Generated key or error
  func deriveKey(
    data: SecureBytes,
    salt: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // In a real implementation, we would use a KeyDerivationService
    // For now, use the CryptoWrapper directly to derive a key
    
    do {
      let derivedKey = try CryptoWrapper.pbkdf2(
        password: data,
        salt: salt,
        iterations: config.iterations ?? 10000,
        keyLength: config.keySizeInBits / 8
      )
      
      return SecurityResultDTO(data: derivedKey)
    } catch {
      return SecurityResultDTO(
        success: false,
        errorCode: 500,
        errorMessage: "Key derivation failed: \(error.localizedDescription)"
      )
    }
  }
}

/**
 # UmbraCore Security Utilities

 Provides utility methods for common security operations like encryption, decryption,
 and key derivation using standardised interfaces and error handling.

 ## Responsibilities

 * Symmetric encryption/decryption operations with standardised result formats
 * Key derivation functions
 * Security configuration validation
 * Error normalisation
 */

import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// Protocol defining the interface for security utility operations
public protocol SecurityUtilsProtocol: Sendable {
  /// Encrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration for the encryption
  /// - Returns: Result of the encryption operation
  func encryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO

  /// Decrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration for the decryption
  /// - Returns: Result of the decryption operation
  func decryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO

  /// Encrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration for the encryption
  /// - Returns: Result of the encryption operation
  func encryptAsymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO

  /// Decrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration for the decryption
  /// - Returns: Result of the decryption operation
  func decryptAsymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO

  /// Generate a cryptographic hash of the input data
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Configuration for the hashing operation
  /// - Returns: Result of the hashing operation
  func hashDataDTO(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO

  /// Derive a key from input data
  /// - Parameters:
  ///   - data: Input data for key derivation
  ///   - salt: Salt value to use in derivation
  ///   - config: Configuration for the key derivation
  /// - Returns: Result of the key derivation operation
  func deriveKeyDTO(
    data: SecureBytes,
    salt: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO
}

/// Provides utility methods for security operations
public final class SecurityUtils: SecurityUtilsProtocol {

  // MARK: - Properties

  /// The crypto service for performing cryptographic operations
  private let cryptoService: CryptoServiceProtocol

  // MARK: - Initialisation

  /// Creates a new security utilities service
  public init(cryptoService: CryptoServiceProtocol=CryptoServiceCore()) {
    self.cryptoService=cryptoService
  }

  // MARK: - SecurityUtilsProtocol Implementation

  /// Encrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration for the encryption
  /// - Returns: Result of the encryption operation
  public func encryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.encryptSymmetric(
      data: data,
      key: key,
      config: config
    )
  }

  /// Decrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration for the decryption
  /// - Returns: Result of the decryption operation
  public func decryptSymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.decryptSymmetric(
      data: data,
      key: key,
      config: config
    )
  }

  /// Encrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - config: Configuration for the encryption
  /// - Returns: Result of the encryption operation
  public func encryptAsymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.encryptAsymmetric(
      data: data,
      key: key,
      config: config
    )
  }

  /// Decrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - config: Configuration for the decryption
  /// - Returns: Result of the decryption operation
  public func decryptAsymmetricDTO(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.decryptAsymmetric(
      data: data,
      key: key,
      config: config
    )
  }

  /// Generate a cryptographic hash of the input data
  /// - Parameters:
  ///   - data: Data to hash
  ///   - config: Configuration for the hashing operation
  /// - Returns: Result of the hashing operation
  public func hashDataDTO(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.hashData(
      data: data,
      config: config
    )
  }

  /// Derive a key from input data
  /// - Parameters:
  ///   - data: Input data for key derivation
  ///   - salt: Salt value to use in derivation
  ///   - config: Configuration for the key derivation
  /// - Returns: Result of the key derivation operation
  public func deriveKeyDTO(
    data: SecureBytes,
    salt: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await cryptoService.deriveKey(
      data: data,
      salt: salt,
      config: config
    )
  }
}

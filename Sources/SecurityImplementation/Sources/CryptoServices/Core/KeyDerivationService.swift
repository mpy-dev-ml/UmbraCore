/**
 # Key Derivation Service
 
 Provides key derivation functionality for the cryptographic services.
 
 ## Responsibilities
 
 * Generate cryptographic keys with appropriate security properties
 * Derive keys from passwords or other input material
 * Generate secure random data
 */

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import ErrorHandlingDomains

/// Service for cryptographic key derivation and generation
final class KeyDerivationService: Sendable {
  
  // MARK: - Properties
  
  /// CryptoWrapper for low-level cryptographic operations
  private let cryptoWrapper: CryptoWrapper
  
  // MARK: - Initialisation
  
  /// Creates a new key derivation service
  init(cryptoWrapper: CryptoWrapper = CryptoWrapper()) {
    self.cryptoWrapper = cryptoWrapper
  }
  
  // MARK: - Public Methods
  
  /// Generate a cryptographic key
  /// - Parameters:
  ///   - bits: Size of the key in bits
  ///   - keyType: Type of key to generate
  ///   - purpose: Purpose for which the key will be used
  /// - Returns: The generated key or an error
  func generateKey(
    bits: Int,
    keyType: KeyType,
    purpose: KeyPurpose
  ) async throws -> SecureBytes {
    // Validate key size
    guard bits > 0 else {
      throw CryptoError.invalidKeySize(bits)
    }
    
    // Generate key based on type
    switch keyType {
    case .aes:
      return try generateAESKey(bits: bits)
    case .rsa:
      return try generateRSAKey(bits: bits)
    case .hmac:
      return try generateHMACKey(bits: bits)
    case .ec:
      return try generateECKey(bits: bits)
    }
  }
  
  /// Generate random data
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Random data or an error
  func generateRandomData(length: Int) async throws -> SecureBytes {
    guard length > 0 else {
      throw CryptoError.invalidLength(length)
    }
    
    // Use system-provided secure random generation
    var bytes = [UInt8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
    
    if status == errSecSuccess {
      return SecureBytes(bytes: bytes)
    } else {
      throw CryptoError.randomDataGenerationError("Failed to generate secure random bytes")
    }
  }
  
  // MARK: - Private Methods
  
  /// Generate an AES key
  /// - Parameter bits: Key size in bits
  /// - Returns: The generated key
  private func generateAESKey(bits: Int) throws -> SecureBytes {
    // AES keys must be 128, 192, or 256 bits
    guard [128, 192, 256].contains(bits) else {
      throw CryptoError.invalidKeySize(bits)
    }
    
    // Generate random key of appropriate size
    var bytes = [UInt8](repeating: 0, count: bits / 8)
    let status = SecRandomCopyBytes(kSecRandomDefault, bits / 8, &bytes)
    
    if status == errSecSuccess {
      return SecureBytes(bytes: bytes)
    } else {
      throw CryptoError.keyGenerationError("Failed to generate AES key")
    }
  }
  
  /// Generate an RSA key
  /// - Parameter bits: Key size in bits
  /// - Returns: The generated key
  private func generateRSAKey(bits: Int) throws -> SecureBytes {
    // RSA keys should be at least 2048 bits
    guard bits >= 2048 else {
      throw CryptoError.invalidKeySize(bits)
    }
    
    // In a real implementation, this would generate a proper RSA key
    // For the demo, just return some random bytes
    return try generateRandomData(length: bits / 8)
  }
  
  /// Generate an EC key
  /// - Parameter bits: Key size in bits
  /// - Returns: The generated key
  private func generateECKey(bits: Int) throws -> SecureBytes {
    // EC key sizes are typically 256, 384, or 521 bits
    guard [256, 384, 521].contains(bits) else {
      throw CryptoError.invalidKeySize(bits)
    }
    
    // In a real implementation, this would generate a proper EC key
    // For the demo, just return some random bytes
    return try generateRandomData(length: bits / 8)
  }
  
  /// Generate an HMAC key
  /// - Parameter bits: Key size in bits
  /// - Returns: The generated key
  private func generateHMACKey(bits: Int) throws -> SecureBytes {
    // HMAC keys can be of any size, but should be at least 128 bits
    guard bits >= 128 else {
      throw CryptoError.invalidKeySize(bits)
    }
    
    // Generate random key of appropriate size
    return try generateRandomData(length: bits / 8)
  }
}

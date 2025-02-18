import Foundation

/// Service for cryptographic operations
public protocol CryptoService: Sendable {
    /// Generate a secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key data
    /// - Throws: CryptoError if key generation fails
    func generateSecureRandomKey(length: Int) async throws -> Data
    
    /// Generate secure random bytes
    /// - Parameter length: Length of the bytes to generate
    /// - Returns: Generated random bytes
    /// - Throws: CryptoError if generation fails
    func generateSecureRandomBytes(length: Int) async throws -> Data
    
    /// Encrypt data using a key and initialization vector
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - iv: Initialization vector
    /// - Returns: Encrypted data
    /// - Throws: CryptoError if encryption fails
    func encrypt(_ data: Data, withKey key: Data, iv: Data) async throws -> Data
    
    /// Decrypt data using a key and initialization vector
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    ///   - iv: Initialization vector
    /// - Returns: Decrypted data
    /// - Throws: CryptoError if decryption fails
    func decrypt(_ data: Data, withKey key: Data, iv: Data) async throws -> Data
}

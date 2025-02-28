import CoreTypes

/// Protocol for security operations that don't depend on Foundation
/// This is the absolute minimal interface to break circular dependencies
public protocol SecurityProviderCore {
    /// Encrypt binary data
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: Error if encryption fails
    func encryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData
    
    /// Decrypt binary data
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: Error if decryption fails
    func decryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData
    
    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    /// - Throws: Error if key generation fails
    func generateBinaryKey(length: Int) async throws -> CoreTypes.BinaryData
    
    /// Hash binary data
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: Error if hashing fails
    func hashBinary(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData
}

/// Factory protocol for creating security providers without any dependencies
public protocol SecurityProviderFactoryCore {
    /// Create a security provider that works with binary data
    /// - Returns: A security provider that can encrypt, decrypt, and hash binary data
    func createSecurityProvider() -> any SecurityProviderCore
}

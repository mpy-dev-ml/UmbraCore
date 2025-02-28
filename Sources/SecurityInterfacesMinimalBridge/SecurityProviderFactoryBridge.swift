import CoreTypes

/// Factory protocol for creating security providers without Foundation dependencies
/// This protocol acts as a bridge between modules that would otherwise have circular dependencies
public protocol SecurityProviderFactoryBridge {
    /// Create a security provider that works with binary data
    /// - Returns: A security provider that can encrypt, decrypt, and hash binary data
    func createBinarySecurityProvider() -> any SecurityProviderMinimalBridge
}

/// Protocol for security operations that don't depend on Foundation
public protocol SecurityProviderMinimalBridge {
    /// Encrypt binary data
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: Error if encryption fails
    func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    /// Decrypt binary data
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: Error if decryption fails
    func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    /// - Throws: Error if key generation fails
    func generateKey(length: Int) async throws -> CoreTypes.BinaryData

    /// Hash binary data
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: Error if hashing fails
    func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData
}

import CoreTypes

/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: SecurityProviderBase {
    // MARK: - Security Operations

    /// Encrypt data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8]

    /// Decrypt data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8]

    /// Generate a secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    /// - Throws: SecurityError if key generation fails
    func generateKey(length: Int) async throws -> [UInt8]

    /// Hash data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash value
    /// - Throws: SecurityError if hashing fails
    func hash(_ data: [UInt8]) async throws -> [UInt8]
}

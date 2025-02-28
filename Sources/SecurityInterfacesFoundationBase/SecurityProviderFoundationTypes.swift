import CoreTypes
import Foundation
import SecurityInterfacesFoundationCore
import SecurityObjCProtocols

/// Protocol defining Foundation-dependent security operations
/// This implementation is in a minimal module to break circular dependencies
@objc public protocol SecurityProviderFoundationImpl: NSObjectProtocol, SecurityProviderObjCImpl {
    // MARK: - Foundation Data Methods

    /// Encrypt NSData using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    @objc func encryptData(_ data: NSData, key: NSData) async throws -> NSData

    /// Decrypt NSData using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    @objc func decryptData(_ data: NSData, key: NSData) async throws -> NSData

    /// Generate a cryptographically secure random key as NSData
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as NSData
    /// - Throws: SecurityError if key generation fails
    @objc func generateDataKey(length: Int) async throws -> NSData

    /// Hash NSData using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: SecurityError if hashing fails
    @objc func hashData(_ data: NSData) async throws -> NSData

    // MARK: - Bookmark Methods

    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    @objc func createBookmark(for url: URL) async throws -> NSData

    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: URL and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    @objc func resolveBookmark(_ bookmarkData: NSData) async throws -> (url: URL, isStale: Bool)

    /// Validate a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: True if the bookmark is valid
    /// - Throws: SecurityError if bookmark validation fails
    @objc func validateBookmark(_ bookmarkData: NSData) async throws -> Bool
}

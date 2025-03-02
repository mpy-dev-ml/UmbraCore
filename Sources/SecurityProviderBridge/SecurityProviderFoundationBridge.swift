// SecurityProviderFoundationBridge.swift
// SecurityProviderBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import CoreTypes
import SecurityProtocolsCore

/// Protocol defining non-Foundation security operations
/// This bridge protocol helps break circular dependencies between Foundation and SecurityInterfaces
public protocol SecurityProviderFoundationBridge: Sendable {
    // MARK: - Binary Data Methods

    /// Encrypt binary data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    /// Decrypt binary data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as BinaryData
    /// - Throws: SecurityError if key generation fails
    func generateKey(length: Int) async throws -> CoreTypes.BinaryData

    /// Generate cryptographically secure random data
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Generated random data
    /// - Throws: SecurityError if random data generation fails
    func generateRandomData(length: Int) async throws -> CoreTypes.BinaryData

    /// Hash binary data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data
    /// - Throws: SecurityError if hashing fails
    func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    // MARK: - Resource Access

    /// Create a bookmark for the given URL string
    /// - Parameter urlString: URL string to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(for urlString: String) async throws -> CoreTypes.BinaryData

    /// Resolve a bookmark to a URL string
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL string and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (urlString: String, isStale: Bool)
    
    /// Validate a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if the bookmark is valid, false otherwise
    /// - Throws: SecurityError if bookmark validation fails
    func validateBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool
}

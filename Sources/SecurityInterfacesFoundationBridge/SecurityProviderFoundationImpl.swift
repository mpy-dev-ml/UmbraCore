import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import SecurityObjCProtocols
import SecurityInterfacesFoundationBase

/// This adapter class bridges between the Foundation-dependent implementation and the Foundation-free interfaces
public final class SecurityProviderFoundationAdapter {
    private let impl: any SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl

    public init(impl: any SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl) {
        self.impl = impl
    }

    // MARK: - Foundation Data Methods

    /// Encrypt Foundation.Data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    public func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        return try await impl.encryptData(data, key: key)
    }

    /// Decrypt Foundation.Data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    public func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        return try await impl.decryptData(data, key: key)
    }

    /// Generate a cryptographically secure random key as Foundation.Data
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as Foundation.Data
    /// - Throws: SecurityError if key generation fails
    public func generateDataKey(length: Int) async throws -> Foundation.Data {
        return try await impl.generateDataKey(length: length)
    }

    /// Hash Foundation.Data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: SecurityError if hashing fails
    public func hashData(_ data: Foundation.Data) async throws -> Foundation.Data {
        return try await impl.hashData(data)
    }

    // MARK: - Bookmark Methods

    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        return try await impl.createBookmark(for: url)
    }

    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: URL and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        return try await impl.resolveBookmark(bookmarkData)
    }

    /// Validate a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: True if the bookmark is valid
    /// - Throws: SecurityError if bookmark validation fails
    public func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
        return try await impl.validateBookmark(bookmarkData)
    }

    // MARK: - Bridge Methods

    /// Encrypt binary data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    public func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let encryptedData = try await impl.encryptData(Data(data.bytes), key: Data(key.bytes))
        return CoreTypes.BinaryData(Array(encryptedData))
    }

    /// Decrypt binary data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    public func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let decryptedData = try await impl.decryptData(Data(data.bytes), key: Data(key.bytes))
        return CoreTypes.BinaryData(Array(decryptedData))
    }

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as BinaryData
    /// - Throws: SecurityError if key generation fails
    public func generateKey(length: Int) async throws -> CoreTypes.BinaryData {
        let keyData = try await impl.generateDataKey(length: length)
        return CoreTypes.BinaryData(Array(keyData))
    }

    /// Hash binary data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: SecurityError if hashing fails
    public func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let hashedData = try await impl.hashData(Data(data.bytes))
        return CoreTypes.BinaryData(Array(hashedData))
    }
}

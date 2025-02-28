import CoreTypes
import Foundation
import ObjCBridgingTypesFoundation
import SecurityInterfacesBase
import SecurityInterfacesProtocols

/// Adapter class to bridge between Foundation-dependent and non-Foundation security provider implementations
@available(macOS 10.15, *)
@preconcurrency
public final class SecurityProviderBridgeAdapter: @unchecked Sendable {
    private let foundationImpl: any SecurityProviderFoundationImpl

    /// Initialize with a Foundation implementation
    /// - Parameter foundationImpl: The Foundation-dependent implementation
    public init(foundationImpl: any SecurityProviderFoundationImpl) {
        self.foundationImpl = foundationImpl
    }

    /// Convert to a non-Foundation SecurityProviderFoundation implementation
    /// - Returns: A SecurityProviderFoundation implementation that doesn't depend on Foundation
    public func asSecurityProviderFoundation() -> any SecurityProviderFoundationBridge {
        return SecurityProviderFoundationBridgeImpl(adapter: self)
    }

    // MARK: - Foundation to CoreTypes Conversion Methods

    /// Encrypt binary data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    public func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let nsData = DataConverter.convertToNSData(fromBytes: data.bytes)
        let nsKey = DataConverter.convertToNSData(fromBytes: key.bytes)

        let encryptedData = try await foundationImpl.encryptData(nsData as Data, key: nsKey as Data)
        let nsEncryptedData = encryptedData as NSData
        return CoreTypes.BinaryData(DataConverter.convertToBytes(fromNSData: nsEncryptedData))
    }

    /// Decrypt binary data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    public func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let nsData = DataConverter.convertToNSData(fromBytes: data.bytes)
        let nsKey = DataConverter.convertToNSData(fromBytes: key.bytes)

        let decryptedData = try await foundationImpl.decryptData(nsData as Data, key: nsKey as Data)
        let nsDecryptedData = decryptedData as NSData
        return CoreTypes.BinaryData(DataConverter.convertToBytes(fromNSData: nsDecryptedData))
    }

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as BinaryData
    /// - Throws: SecurityError if key generation fails
    public func generateKey(length: Int) async throws -> CoreTypes.BinaryData {
        let keyData = try await foundationImpl.generateDataKey(length: length)
        let nsKeyData = keyData as NSData
        return CoreTypes.BinaryData(DataConverter.convertToBytes(fromNSData: nsKeyData))
    }

    /// Hash binary data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data
    /// - Throws: SecurityError if hashing fails
    public func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        let nsData = DataConverter.convertToNSData(fromBytes: data.bytes)

        let hashedData = try await foundationImpl.hashData(nsData as Data)
        let nsHashedData = hashedData as NSData
        return CoreTypes.BinaryData(DataConverter.convertToBytes(fromNSData: nsHashedData))
    }

    /// Create a security-scoped resource bookmark
    /// - Parameter identifier: String identifier for the resource (typically a file path)
    /// - Returns: Resource bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createResourceBookmark(for identifier: String) async throws -> CoreTypes.BinaryData {
        guard let url = URL(string: identifier) else {
            throw NSError(domain: "SecurityProviderBridgeAdapter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])
        }

        let bookmarkData = try await foundationImpl.createBookmark(for: url)
        let nsBookmarkData = bookmarkData as NSData
        return CoreTypes.BinaryData(DataConverter.convertToBytes(fromNSData: nsBookmarkData))
    }

    /// Resolve a previously created security-scoped resource bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved identifier and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (identifier: String, isStale: Bool) {
        let nsData = DataConverter.convertToNSData(fromBytes: bookmarkData.bytes)

        let (url, isStale) = try await foundationImpl.resolveBookmark(nsData as Data)
        return (identifier: url.absoluteString, isStale: isStale)
    }

    /// Validate a resource bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: SecurityError if validation fails
    public func validateResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool {
        let nsData = DataConverter.convertToNSData(fromBytes: bookmarkData.bytes)
        return try await foundationImpl.validateBookmark(nsData as Data)
    }
}

/// Private implementation of SecurityProviderFoundationBridge that uses the adapter
private final class SecurityProviderFoundationBridgeImpl: SecurityProviderFoundationBridge {
    private let adapter: SecurityProviderBridgeAdapter

    init(adapter: SecurityProviderBridgeAdapter) {
        self.adapter = adapter
    }

    func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        return try await adapter.encrypt(data, key: key)
    }

    func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        return try await adapter.decrypt(data, key: key)
    }

    func generateKey(length: Int) async throws -> CoreTypes.BinaryData {
        return try await adapter.generateKey(length: length)
    }

    func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        return try await adapter.hash(data)
    }

    func createResourceBookmark(for identifier: String) async throws -> CoreTypes.BinaryData {
        return try await adapter.createResourceBookmark(for: identifier)
    }

    func resolveResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (identifier: String, isStale: Bool) {
        return try await adapter.resolveResourceBookmark(bookmarkData)
    }

    func validateResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool {
        return try await adapter.validateResourceBookmark(bookmarkData)
    }
}

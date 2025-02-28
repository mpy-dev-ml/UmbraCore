import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityInterfacesBase
import SecurityInterfacesProtocols

/// Protocol defining Foundation-dependent security operations
/// This implementation is in the SecurityInterfacesFoundationBridge module to break circular dependencies
@objc public protocol SecurityProviderFoundationImpl: NSObjectProtocol {
    // MARK: - Foundation Data Methods

    /// Encrypt Foundation.Data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    @objc func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data

    /// Decrypt Foundation.Data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    @objc func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data

    /// Generate a cryptographically secure random key as Foundation.Data
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as Foundation.Data
    /// - Throws: SecurityError if key generation fails
    @objc func generateDataKey(length: Int) async throws -> Foundation.Data

    /// Hash Foundation.Data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data as Foundation.Data
    /// - Throws: SecurityError if hashing fails
    @objc func hashData(_ data: Foundation.Data) async throws -> Foundation.Data

    // MARK: - Bookmark Management

    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: SecurityError if bookmark creation fails
    @objc func createBookmark(for url: URL) async throws -> Data

    /// Resolve a previously created security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    @objc func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool)

    /// Validate a bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: SecurityError if validation fails
    @objc func validateBookmark(_ bookmarkData: Data) async throws -> Bool
}

/// Extension to provide default implementations for SecurityProviderFoundationImpl
public extension SecurityProviderFoundationImpl {
    // Default implementations can be added here if needed
}

/// Adapter class to convert between Foundation types and bridge types
@available(macOS 10.15, *)
public final class SecurityProviderFoundationAdapter {
    private let impl: any SecurityProviderFoundationImpl

    public init(impl: any SecurityProviderFoundationImpl) {
        self.impl = impl
    }

    // MARK: - Conversion Methods

    /// Convert DataBridge to Foundation.Data
    private func toFoundationData(_ dataBridge: DataBridge) -> Foundation.Data {
        return Foundation.Data(dataBridge.bytes)
    }

    /// Convert Foundation.Data to DataBridge
    private func toDataBridge(_ data: Foundation.Data) -> DataBridge {
        var bytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &bytes, count: data.count)
        return DataBridge(bytes)
    }

    /// Convert URLBridge to Foundation.URL
    private func toFoundationURL(_ urlBridge: URLBridge) -> URL? {
        return URL(string: urlBridge.stringValue)
    }

    /// Convert Foundation.URL to URLBridge
    private func toURLBridge(_ url: URL) -> URLBridge {
        return URLBridge(string: url.absoluteString)!
    }

    // MARK: - Bridge Methods

    /// Encrypt data using the provider's encryption mechanism
    public func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        let foundationData = toFoundationData(data)
        let foundationKey = toFoundationData(key)

        let encryptedData = try await impl.encryptData(foundationData, key: foundationKey)
        return toDataBridge(encryptedData)
    }

    /// Decrypt data using the provider's decryption mechanism
    public func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        let foundationData = toFoundationData(data)
        let foundationKey = toFoundationData(key)

        let decryptedData = try await impl.decryptData(foundationData, key: foundationKey)
        return toDataBridge(decryptedData)
    }

    /// Generate a cryptographically secure random key
    public func generateKey(length: Int) async throws -> DataBridge {
        let keyData = try await impl.generateDataKey(length: length)
        return toDataBridge(keyData)
    }

    /// Hash data using the provider's hashing mechanism
    public func hash(_ data: DataBridge) async throws -> DataBridge {
        let foundationData = toFoundationData(data)

        let hashedData = try await impl.hashData(foundationData)
        return toDataBridge(hashedData)
    }

    /// Create a security-scoped bookmark for a URL
    public func createBookmark(for urlString: String) async throws -> DataBridge {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SecurityProviderFoundationAdapter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])
        }

        let bookmarkData = try await impl.createBookmark(for: url)
        return toDataBridge(bookmarkData)
    }

    /// Resolve a previously created security-scoped bookmark
    public func resolveBookmark(_ bookmarkData: DataBridge) async throws -> (urlString: String, isStale: Bool) {
        let foundationData = toFoundationData(bookmarkData)

        let (url, isStale) = try await impl.resolveBookmark(foundationData)
        return (urlString: url.absoluteString, isStale: isStale)
    }

    /// Validate a bookmark to ensure it's still valid
    public func validateBookmark(_ bookmarkData: DataBridge) async throws -> Bool {
        let foundationData = toFoundationData(bookmarkData)
        return try await impl.validateBookmark(foundationData)
    }
}

import CoreTypes
import Foundation
import ObjCBridgingTypesFoundation
import SecureBytes
import SecurityProviderBridge
import SecurityProtocolsCore

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
    public func encrypt(_ data: SecureBytes, key: SecureBytes) async throws -> SecureBytes {
        let nsData = DataConverter.convertToNSData(fromBytes: data.unsafeBytes)
        let nsKey = DataConverter.convertToNSData(fromBytes: key.unsafeBytes)

        let encryptedData = try await foundationImpl.encryptData(nsData as Data, key: nsKey as Data)
        return SecureBytes(Array(encryptedData))
    }

    /// Decrypt binary data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    public func decrypt(_ data: SecureBytes, key: SecureBytes) async throws -> SecureBytes {
        let nsData = DataConverter.convertToNSData(fromBytes: data.unsafeBytes)
        let nsKey = DataConverter.convertToNSData(fromBytes: key.unsafeBytes)

        let decryptedData = try await foundationImpl.decryptData(nsData as Data, key: nsKey as Data)
        return SecureBytes(Array(decryptedData))
    }

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as SecureBytes
    /// - Throws: SecurityError if key generation fails
    public func generateKey(length: Int) async throws -> SecureBytes {
        let keyData = try await foundationImpl.generateDataKey(length: length)
        return SecureBytes(Array(keyData))
    }

    /// Hash binary data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data
    /// - Throws: SecurityError if hashing fails
    public func hash(_ data: SecureBytes) async throws -> SecureBytes {
        let nsData = DataConverter.convertToNSData(fromBytes: data.unsafeBytes)

        let hashedData = try await foundationImpl.hashData(nsData as Data)
        return SecureBytes(Array(hashedData))
    }

    /// Create a security-scoped resource bookmark
    /// - Parameter identifier: String identifier for the resource (typically a file path)
    /// - Returns: Resource bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createResourceBookmark(for identifier: String) async throws -> SecureBytes {
        guard let url = URL(string: identifier) else {
            throw SecurityError.internalError("Invalid URL string: \(identifier)")
        }

        let bookmarkData = try await foundationImpl.createBookmark(for: url)
        return SecureBytes(Array(bookmarkData))
    }

    /// Resolve a previously created security-scoped resource bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved identifier and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveResourceBookmark(_ bookmarkData: SecureBytes) async throws -> (identifier: String, isStale: Bool) {
        let nsData = DataConverter.convertToNSData(fromBytes: bookmarkData.unsafeBytes)

        let (url, isStale) = try await foundationImpl.resolveBookmark(nsData as Data)
        return (identifier: url.absoluteString, isStale: isStale)
    }

    /// Validate a resource bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: SecurityError if validation fails
    public func validateResourceBookmark(_ bookmarkData: SecureBytes) async throws -> Bool {
        let nsData = DataConverter.convertToNSData(fromBytes: bookmarkData.unsafeBytes)
        return try await foundationImpl.validateBookmark(nsData as Data)
    }
}

/// Private implementation of SecurityProviderFoundationBridge that uses the adapter
private final class SecurityProviderFoundationBridgeImpl: SecurityProviderFoundationBridge {
    private let adapter: SecurityProviderBridgeAdapter

    init(adapter: SecurityProviderBridgeAdapter) {
        self.adapter = adapter
    }

    func encrypt(_ data: SecureBytes, key: SecureBytes) async throws -> SecureBytes {
        return try await adapter.encrypt(data, key: key)
    }

    func decrypt(_ data: SecureBytes, key: SecureBytes) async throws -> SecureBytes {
        return try await adapter.decrypt(data, key: key)
    }

    func generateKey(length: Int) async throws -> SecureBytes {
        return try await adapter.generateKey(length: length)
    }
    
    func generateRandomData(length: Int) async throws -> SecureBytes {
        return try await adapter.generateKey(length: length)
    }

    func hash(_ data: SecureBytes) async throws -> SecureBytes {
        return try await adapter.hash(data)
    }

    func createBookmark(for urlString: String) async throws -> SecureBytes {
        return try await adapter.createResourceBookmark(for: urlString)
    }

    func resolveBookmark(_ bookmarkData: SecureBytes) async throws -> (urlString: String, isStale: Bool) {
        let result = try await adapter.resolveResourceBookmark(bookmarkData)
        return (urlString: result.identifier, isStale: result.isStale)
    }

    func validateBookmark(_ bookmarkData: SecureBytes) async throws -> Bool {
        return try await adapter.validateResourceBookmark(bookmarkData)
    }
}

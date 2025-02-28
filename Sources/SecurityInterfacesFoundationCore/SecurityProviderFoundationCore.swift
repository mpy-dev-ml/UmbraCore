import CoreTypes
import FoundationBridgeTypes

/// Error type for security operations that doesn't require Foundation
public enum SecurityProviderCoreError: Error, Sendable {
    case conversionFailed
    case operationNotSupported
    case securityError
    case unknown
}

/// Core protocol defining security operations without Foundation dependencies
/// This implementation is in a minimal module to break circular dependencies
public protocol SecurityProviderCore: Sendable {
    // MARK: - Core Data Methods

    /// Encrypt data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityProviderCoreError if encryption fails
    func encryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

    /// Decrypt data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityProviderCoreError if decryption fails
    func decryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

    /// Generate a random encryption key
    /// - Returns: Generated key
    /// - Throws: SecurityProviderCoreError if key generation fails
    func generateKey() async throws -> DataBridge

    /// Create a security-scoped bookmark for a URL
    /// - Parameter urlString: URL to create a bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityProviderCoreError if bookmark creation fails
    func createBookmark(_ urlString: String) async throws -> [UInt8]

    /// Resolve a security-scoped bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: URL string
    /// - Throws: SecurityProviderCoreError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) throws -> String

    /// Start accessing a security-scoped resource
    /// - Parameter urlString: URL of the resource to access
    /// - Returns: Whether access was successfully started
    /// - Throws: SecurityProviderCoreError if access fails
    func startAccessingSecurityScopedResource(_ urlString: String) throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter urlString: URL of the resource to stop accessing
    func stopAccessingSecurityScopedResource(_ urlString: String)
}

import CoreTypes
import FoundationBridgeTypes

/// Minimal protocol for security operations with no Foundation dependencies
/// This protocol is designed to break circular dependencies
public protocol SecurityProviderMinimal {
    /// Encrypt data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt as raw bytes
    ///   - key: Encryption key as raw bytes
    /// - Returns: Encrypted data as raw bytes
    /// - Throws: SecurityError if encryption fails
    func encryptDataMinimal(_ data: [UInt8], key: [UInt8]) throws -> [UInt8]

    /// Decrypt data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt as raw bytes
    ///   - key: Decryption key as raw bytes
    /// - Returns: Decrypted data as raw bytes
    /// - Throws: SecurityError if decryption fails
    func decryptDataMinimal(_ data: [UInt8], key: [UInt8]) throws -> [UInt8]

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as raw bytes
    /// - Throws: SecurityError if key generation fails
    func generateKeyMinimal(length: Int) throws -> [UInt8]

    /// Create a security-scoped bookmark for a URL
    /// - Parameter urlPath: String path to the URL
    /// - Returns: Bookmark data as raw bytes
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmarkMinimal(for urlPath: String) throws -> [UInt8]

    /// Resolve a security-scoped bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data as raw bytes
    /// - Returns: URL path as string
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmarkMinimal(_ bookmarkData: [UInt8]) throws -> String

    /// Start accessing a security-scoped resource
    /// - Parameter urlPath: String path to the URL
    /// - Returns: True if access was started successfully
    /// - Throws: SecurityError if access couldn't be started
    func startAccessingSecurityScopedResourceMinimal(_ urlPath: String) throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter urlPath: String path to the URL
    func stopAccessingSecurityScopedResourceMinimal(_ urlPath: String)
}

/// Minimal error type for security operations
public enum SecurityProviderMinimalError: Int, Error {
    case conversionFailed
    case operationNotSupported
    case securityError
    case unknown
}

/// Minimal bridge protocol for security operations
/// This protocol is designed to break circular dependencies
public protocol SecurityProviderBridge: Sendable {
    /// Encrypt data using the provider's encryption mechanism
    func encrypt(_ data: FoundationBridgeTypes.DataBridge, key: FoundationBridgeTypes.DataBridge) async throws -> FoundationBridgeTypes.DataBridge

    /// Decrypt data using the provider's decryption mechanism
    func decrypt(_ data: FoundationBridgeTypes.DataBridge, key: FoundationBridgeTypes.DataBridge) async throws -> FoundationBridgeTypes.DataBridge

    /// Generate a cryptographically secure random key
    func generateKey(length: Int) async throws -> FoundationBridgeTypes.DataBridge

    /// Hash data using the provider's hashing mechanism
    func hash(_ data: FoundationBridgeTypes.DataBridge) async throws -> FoundationBridgeTypes.DataBridge

    /// Create a security-scoped bookmark for a URL
    func createBookmark(for path: String) async throws -> FoundationBridgeTypes.DataBridge

    /// Resolve a security-scoped bookmark to a URL
    func resolveBookmark(_ bookmarkData: FoundationBridgeTypes.DataBridge) async throws -> (String, Bool)

    /// Validate a security-scoped bookmark
    func validateBookmark(_ bookmarkData: FoundationBridgeTypes.DataBridge) async throws -> Bool
}

import CoreTypes
import SecurityInterfacesBase
import SecurityInterfacesProtocols

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

    /// Hash binary data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data
    /// - Throws: SecurityError if hashing fails
    func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

    // MARK: - Resource Access

    /// Create a security-scoped resource identifier
    /// - Parameter identifier: String identifier for the resource
    /// - Returns: Resource bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    func createResourceBookmark(for identifier: String) async throws -> CoreTypes.BinaryData

    /// Resolve a previously created security-scoped resource bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved identifier and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (identifier: String, isStale: Bool)

    /// Validate a resource bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: SecurityError if validation fails
    func validateResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool
}

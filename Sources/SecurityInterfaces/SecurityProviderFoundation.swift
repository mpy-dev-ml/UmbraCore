import CoreTypes
import Foundation
import SecurityInterfacesCore

/// Protocol defining Foundation-dependent security operations
public protocol SecurityProviderFoundation: SecurityProvider {
    // MARK: - Foundation Data Methods

    /// Encrypt Foundation.Data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data

    /// Decrypt Foundation.Data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data

    /// Generate a cryptographically secure random key as Foundation.Data
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as Foundation.Data
    /// - Throws: SecurityError if key generation fails
    func generateDataKey(length: Int) async throws -> Foundation.Data

    /// Hash Foundation.Data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data as Foundation.Data
    /// - Throws: SecurityError if hashing fails
    func hashData(_ data: Foundation.Data) async throws -> Foundation.Data

    // MARK: - Bookmark Management

    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(for url: URL) async throws -> Data

    /// Resolve a previously created security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool)

    /// Validate a bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: Boolean indicating if the bookmark is valid
    /// - Throws: SecurityError if validation fails
    func validateBookmark(_ bookmarkData: Data) async throws -> Bool

    // MARK: - Resource Access Control

    /// Start accessing a security-scoped resource
    /// - Parameter url: URL to the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails or is denied
    func startAccessing(url: URL) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL to the resource to stop accessing
    func stopAccessing(url: URL) async

    /// Stop accessing all security-scoped resources
    func stopAccessingAllResources() async

    /// Check if a URL is currently being accessed
    /// - Parameter url: URL to check
    /// - Returns: Boolean indicating if the URL is being accessed
    func isAccessing(url: URL) async -> Bool

    /// Get all URLs currently being accessed
    /// - Returns: Set of URLs being accessed
    func getAccessedUrls() async -> Set<URL>

    // MARK: - Keychain Operations

    /// Store data in the keychain
    /// - Parameters:
    ///   - data: Data to store
    ///   - service: Service identifier
    ///   - account: Account identifier
    /// - Throws: SecurityError if keychain operation fails
    func storeInKeychain(data: Data, service: String, account: String) async throws

    /// Retrieve data from the keychain
    /// - Parameters:
    ///   - service: Service identifier
    ///   - account: Account identifier
    /// - Returns: Retrieved data
    /// - Throws: SecurityError if keychain operation fails
    func retrieveFromKeychain(service: String, account: String) async throws -> Data

    /// Delete data from the keychain
    /// - Parameters:
    ///   - service: Service identifier
    ///   - account: Account identifier
    /// - Throws: SecurityError if keychain operation fails
    func deleteFromKeychain(service: String, account: String) async throws
}

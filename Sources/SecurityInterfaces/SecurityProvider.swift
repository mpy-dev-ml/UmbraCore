import CoreTypes
import Foundation

/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: SecurityProviderBase {
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

    // MARK: - Resource Access Control

    /// Start accessing a security-scoped resource
    /// - Parameter url: URL to the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails or is denied
    func startAccessing(url: URL) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL to the resource to stop accessing
    /// - Note: This method should be called in a defer block after startAccessing
    func stopAccessing(url: URL) async

    /// Stop accessing all security-scoped resources
    /// - Note: This is typically called during cleanup or when the app is terminating
    func stopAccessingAllResources() async

    /// Check if a URL is currently being accessed
    /// - Parameter url: URL to check
    /// - Returns: Boolean indicating if the URL is being accessed
    func isAccessing(url: URL) async -> Bool

    /// Get all URLs currently being accessed
    /// - Returns: Set of URLs being accessed
    func getAccessedUrls() async -> Set<URL>

    // MARK: - Bookmark Validation

    /// Validate a bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: Boolean indicating if the bookmark is valid
    /// - Throws: SecurityError if validation fails
    func validateBookmark(_ bookmarkData: Data) async throws -> Bool

    // MARK: - Bookmark Persistence

    /// Save a bookmark with an identifier
    /// - Parameters:
    ///   - bookmarkData: Bookmark data to save
    ///   - identifier: Identifier to associate with the bookmark
    /// - Throws: SecurityError if saving fails
    func saveBookmark(_ bookmarkData: Data, withIdentifier identifier: String) async throws

    /// Load a bookmark by identifier
    /// - Parameter identifier: Identifier of the bookmark to load
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if loading fails or bookmark not found
    func loadBookmark(withIdentifier identifier: String) async throws -> Data

    /// Delete a bookmark by identifier
    /// - Parameter identifier: Identifier of the bookmark to delete
    /// - Throws: SecurityError if deletion fails
    func deleteBookmark(withIdentifier identifier: String) async throws

    // MARK: - Foundation-dependent APIs

    /// Store credentials securely
    /// - Parameters:
    ///   - data: Data to store
    ///   - account: Account identifier
    ///   - service: Service identifier
    ///   - metadata: Optional metadata associated with the credentials
    /// - Returns: String identifier for the stored credentials
    func storeCredential(
        data: Data,
        account: String,
        service: String,
        metadata: [String: String]?
    ) async throws -> String

    /// Load credentials
    /// - Parameters:
    ///   - account: Account identifier
    ///   - service: Service identifier
    /// - Returns: The stored credential data
    func loadCredential(
        account: String,
        service: String
    ) async throws -> Data

    /// Load credentials with associated metadata
    /// - Parameters:
    ///   - account: Account identifier
    ///   - service: Service identifier
    /// - Returns: Tuple containing credential data and optional metadata
    func loadCredentialWithMetadata(
        account: String,
        service: String
    ) async throws -> (Data, [String: String]?)

    /// Generate random bytes
    /// - Parameter length: Number of random bytes to generate
    /// - Returns: Data containing random bytes
    func generateRandomBytes(length: Int) async throws -> Data
}

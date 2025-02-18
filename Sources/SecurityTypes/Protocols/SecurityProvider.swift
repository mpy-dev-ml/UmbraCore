/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: Sendable {
    // MARK: - Bookmark Management

    /// Create a security-scoped bookmark for a URL
    /// - Parameter path: File system path to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(forPath path: String) async throws -> [UInt8]

    /// Resolve a previously created security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved path and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

    // MARK: - Resource Access Control

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails or is denied
    func startAccessing(path: String) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource to stop accessing
    /// - Note: This method should be called in a defer block after startAccessing
    func stopAccessing(path: String) async

    /// Stop accessing all security-scoped resources
    /// - Note: This is typically called during cleanup or when the app is terminating
    func stopAccessingAllResources() async

    // MARK: - Scoped Access Operations

    /// Perform an operation with security-scoped resource access
    /// - Parameters:
    ///   - path: Path to the resource to access
    ///   - operation: Operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    /// - Note: This method handles starting and stopping access automatically
    func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T

    // MARK: - Bookmark Persistence

    /// Save a bookmark to persistent storage
    /// - Parameters:
    ///   - bookmarkData: Bookmark data to save
    ///   - identifier: Unique identifier for the bookmark
    /// - Throws: SecurityError if saving fails
    func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws

    /// Load a bookmark from persistent storage
    /// - Parameter identifier: Identifier of the bookmark to load
    /// - Returns: The stored bookmark data
    /// - Throws: SecurityError if loading fails or bookmark not found
    func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8]

    /// Delete a bookmark from persistent storage
    /// - Parameter identifier: Identifier of the bookmark to delete
    /// - Throws: SecurityError if deletion fails
    func deleteBookmark(withIdentifier identifier: String) async throws

    // MARK: - Status and Validation

    /// Check if a path is currently being accessed
    /// - Parameter path: Path to check
    /// - Returns: True if the path is currently being accessed
    func isAccessing(path: String) async -> Bool

    /// Validate a bookmark's data
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if the bookmark data is valid
    /// - Throws: SecurityError if validation fails
    func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool

    /// Get all currently accessed resource paths
    /// - Returns: Set of paths that are currently being accessed
    func getAccessedPaths() async -> Set<String>
}

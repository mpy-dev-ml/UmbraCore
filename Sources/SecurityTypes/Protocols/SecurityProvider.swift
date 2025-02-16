import Foundation

/// Protocol defining security-related operations
public protocol SecurityProvider: Sendable {
    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(for url: URL) async throws -> Data
    
    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Resolved URL
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: Data) async throws -> URL
    
    /// Start accessing a security-scoped resource
    /// - Parameter url: URL of the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails
    func startAccessing(_ url: URL) async throws -> Bool
    
    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL of the resource to stop accessing
    func stopAccessing(_ url: URL) async
    
    /// Perform an operation with security-scoped resource access
    /// - Parameters:
    ///   - url: URL of the resource to access
    ///   - operation: Operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    func withSecurityScopedAccess<T>(
        to url: URL,
        perform operation: () async throws -> T
    ) async throws -> T
    
    /// Stop accessing all security-scoped resources
    func stopAccessingAllResources() async
}

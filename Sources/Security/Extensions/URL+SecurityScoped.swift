import Foundation

/// Extension to URL for security-scoped bookmark operations
public extension URL {
    /// Create a security-scoped bookmark for this URL
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    func createSecurityScopedBookmark() throws -> Data {
        try bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
    
    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    static func resolveSecurityScopedBookmark(_ bookmarkData: Data) throws -> (URL, Bool) {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        return (url, isStale)
    }
    
    /// Start accessing this security-scoped resource
    /// - Returns: True if access was granted, false otherwise
    @discardableResult
    func startSecurityScopedAccess() -> Bool {
        startAccessingSecurityScopedResource()
    }
    
    /// Stop accessing this security-scoped resource
    func stopSecurityScopedAccess() {
        stopAccessingSecurityScopedResource()
    }
    
    /// Perform an operation with security-scoped resource access
    /// - Parameter operation: Operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    func withSecurityScopedAccess<T>(perform operation: () throws -> T) throws -> T {
        guard startSecurityScopedAccess() else {
            throw SecurityError.accessDenied(url: self)
        }
        defer { stopSecurityScopedAccess() }
        return try operation()
    }
    
    /// Perform an async operation with security-scoped resource access
    /// - Parameter operation: Async operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    func withSecurityScopedAccess<T>(perform operation: () async throws -> T) async throws -> T {
        guard startSecurityScopedAccess() else {
            throw SecurityError.accessDenied(url: self)
        }
        defer { stopSecurityScopedAccess() }
        return try await operation()
    }
}

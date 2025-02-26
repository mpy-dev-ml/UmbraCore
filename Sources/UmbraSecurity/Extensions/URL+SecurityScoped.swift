import Foundation
import SecurityInterfaces

/// Extension to URL for security-scoped bookmark operations
extension URL {
    /// Create a security-scoped bookmark for this URL
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func us_createSecurityScopedBookmark() async throws -> Data {
        let path = self.path
        do {
            return try bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            throw SecurityError.bookmarkError("Failed to create bookmark for: \(path)")
        }
    }

    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public static func us_resolveSecurityScopedBookmark(_ bookmarkData: Data) async throws -> (URL, Bool) {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return (url, isStale)
        } catch {
            throw SecurityError.bookmarkError("Failed to resolve bookmark")
        }
    }

    /// Start accessing a security-scoped resource
    /// - Returns: True if access was granted
    public func us_startAccessingSecurityScopedResource() -> Bool {
        startAccessingSecurityScopedResource()
    }

    /// Stop accessing a security-scoped resource
    public func us_stopAccessingSecurityScopedResource() {
        stopAccessingSecurityScopedResource()
    }

    /// Perform an operation with security-scoped access to this URL
    /// - Parameter operation: Operation to perform with access
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    public func us_withSecurityScopedAccess<T>(perform operation: () async throws -> T) async throws -> T {
        guard us_startAccessingSecurityScopedResource() else {
            throw SecurityError.accessError("Failed to access: \(path)")
        }
        defer { us_stopAccessingSecurityScopedResource() }
        
        return try await operation()
    }
}

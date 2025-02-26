import Foundation
import SecurityTypes

/// Extension to URL for security-scoped bookmark operations
extension URL {
    /// Create a security-scoped bookmark for this URL
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createSecurityScopedBookmark() async throws -> Data {
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
    public static func resolveSecurityScopedBookmark(_ bookmarkData: Data) async throws -> (URL, Bool) {
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
    public func startSecurityScopedAccess() -> Bool {
        startAccessingSecurityScopedResource()
    }

    /// Stop accessing a security-scoped resource
    public func stopSecurityScopedAccess() {
        stopAccessingSecurityScopedResource()
    }

    /// Perform an operation with security-scoped access
    /// - Parameter operation: Operation to perform while URL is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails
    public func withSecurityScopedAccess<T>(perform operation: () async throws -> T) async throws -> T {
        guard startSecurityScopedAccess() else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }
        defer { stopSecurityScopedAccess() }
        return try await operation()
    }
}

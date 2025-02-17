import Foundation
import SecurityTypes

/// Extension to URL for security-scoped bookmark operations
extension URL {
    /// Create a security-scoped bookmark for this URL
    /// - Returns: The bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createSecurityScopedBookmark() throws -> Data {
        do {
            let data = try bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return data
        } catch {
            throw SecurityError.bookmarkCreationFailed(path: path)
        }
    }

    /// Resolve a security-scoped bookmark to a URL
    /// - Parameter bookmarkData: The bookmark data to resolve
    /// - Returns: A tuple containing the resolved URL and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public static func resolveSecurityScopedBookmark(_ bookmarkData: Data) throws -> (url: URL, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                            options: .withSecurityScope,
                            relativeTo: nil,
                            bookmarkDataIsStale: &isStale)
            return (url, isStale)
        } catch {
            throw SecurityError.bookmarkResolutionFailed(path: "Unknown")
        }
    }

    /// Start accessing a security-scoped resource
    /// - Returns: true if access was granted, false otherwise
    public func startSecurityScopedAccess() -> Bool {
        startAccessingSecurityScopedResource()
    }

    /// Stop accessing a security-scoped resource
    public func stopSecurityScopedAccess() {
        stopAccessingSecurityScopedResource()
    }

    /// Perform an operation with security-scoped access to this URL
    /// - Parameter operation: The operation to perform while the resource is accessible
    /// - Returns: The result of the operation
    /// - Throws: SecurityError if access is denied, or any error thrown by the operation
    public func withSecurityScopedAccess<T>(perform operation: () async throws -> T) async throws -> T {
        guard startSecurityScopedAccess() else {
            throw SecurityError.accessDenied(path: path)
        }
        defer { stopSecurityScopedAccess() }
        return try await operation()
    }
}

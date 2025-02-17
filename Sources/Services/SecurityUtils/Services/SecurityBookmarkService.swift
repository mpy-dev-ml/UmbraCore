import Foundation
import SecurityTypes

/// Service for managing security bookmarks and access to security-scoped resources
public actor SecurityBookmarkService {
    private let urlProvider: URLProvider
    private var accessedPaths: Set<String>

    /// Initialize a new security bookmark service
    /// - Parameter urlProvider: Provider for URL operations
    public init(urlProvider: URLProvider = PathURLProvider()) {
        self.urlProvider = urlProvider
        self.accessedPaths = []
    }

    /// Create a bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        let bookmarkBytes = try await urlProvider.createBookmark(forPath: url.path)
        return Data(bookmarkBytes)
    }

    /// Resolve a bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        let result = try await urlProvider.resolveBookmark(Array(bookmarkData))
        return (url: URL(fileURLWithPath: result.path), isStale: result.isStale)
    }

    /// Perform an operation with security-scoped access to a URL
    /// - Parameters:
    ///   - url: URL to access
    ///   - operation: Operation to perform while URL is accessible
    /// - Throws: SecurityError if access cannot be started
    public func withSecurityScopedAccess<T>(to url: URL, operation: () async throws -> T) async throws -> T {
        guard try await urlProvider.startAccessing(path: url.path) else {
            throw SecurityError.accessDenied(path: url.path)
        }

        accessedPaths.insert(url.path)
        defer {
            Task {
                await urlProvider.stopAccessing(path: url.path)
                accessedPaths.remove(url.path)
            }
        }

        return try await operation()
    }

    /// Get all paths currently being accessed
    /// - Returns: Array of paths currently being accessed
    public func getAccessedPaths() -> [String] {
        Array(accessedPaths)
    }
}

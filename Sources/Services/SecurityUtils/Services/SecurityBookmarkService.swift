import Foundation
import SecurityTypes

/// Service for managing security-scoped bookmarks
public actor SecurityBookmarkService {
    private let urlProvider: URLProvider
    private var activeResources: Set<URL>

    /// Initialize a new security bookmark service
    /// - Parameter urlProvider: Provider for URL operations
    public init(urlProvider: URLProvider = PathURLProvider()) {
        self.urlProvider = urlProvider
        self.activeResources = []
    }

    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        // Ensure we have a file URL
        let fileURL = url.isFileURL ? url : URL(fileURLWithPath: url.path)

        // Start accessing the resource before creating bookmark
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(url.path)")
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }

        // Create bookmark
        let bookmarkData = try fileURL.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        return bookmarkData
    }

    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        return (url, isStale)
    }

    /// Perform an operation with security-scoped access to a URL
    /// - Parameters:
    ///   - url: URL to access
    ///   - operation: Operation to perform while URL is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails
    public func withSecurityScopedAccess<T: Sendable>(
        to url: URL,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        // Ensure we have a file URL
        let fileURL = url.isFileURL ? url : URL(fileURLWithPath: url.path)

        // Start accessing the resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(url.path)")
        }

        // Track the active resource
        activeResources.insert(fileURL)

        defer {
            fileURL.stopAccessingSecurityScopedResource()
            activeResources.remove(fileURL)
        }

        return try await operation()
    }

    /// Stop accessing all security-scoped resources
    public func stopAccessingAllResources() {
        for url in activeResources {
            url.stopAccessingSecurityScopedResource()
        }
        activeResources.removeAll()
    }
}

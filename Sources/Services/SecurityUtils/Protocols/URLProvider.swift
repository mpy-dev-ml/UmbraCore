import Foundation
import SecurityTypes

/// Protocol for URL-based operations
public protocol URLProvider: Sendable {
    /// Create a bookmark for a path
    /// - Parameter path: Path to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(forPath path: String) async throws -> Data

    /// Resolve a bookmark to a path
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved path and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

    /// Start accessing a path
    /// - Parameter path: Path to access
    /// - Returns: True if access was granted
    /// - Throws: SecurityError if access fails
    func startAccessing(path: String) async throws -> Bool

    /// Stop accessing a path
    /// - Parameter path: Path to stop accessing
    func stopAccessing(path: String) async

    /// Checks if a path is currently being accessed
    /// - Parameter path: The path to check
    /// - Returns: True if the path is being accessed, false otherwise
    func isAccessing(path: String) async -> Bool

    /// Gets all paths currently being accessed
    /// - Returns: Array of paths currently being accessed
    func getAccessedPaths() async -> [String]
}

/// Default implementation of URLProvider using Foundation
public actor PathURLProvider: URLProvider {
    public init() {}

    public func createBookmark(forPath path: String) async throws -> Data {
        guard let url = URL(string: path) else {
            throw SecurityError.invalidData(reason: "Invalid path: \(path)")
        }

        return try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: Data(bookmarkData),
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        return (url.path, isStale)
    }

    public func startAccessing(path: String) async throws -> Bool {
        guard let url = URL(string: path) else {
            throw SecurityError.invalidData(reason: "Invalid path: \(path)")
        }

        if url.startAccessingSecurityScopedResource() {
            return true
        } else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }
    }

    public func stopAccessing(path: String) async {
        guard let url = URL(string: path) else { return }
        url.stopAccessingSecurityScopedResource()
    }

    public func isAccessing(path: String) async -> Bool {
        // Check if the path exists and is readable
        guard let url = URL(string: path) else { return false }
        return url.startAccessingSecurityScopedResource()
    }

    public func getAccessedPaths() async -> [String] {
        // For now, just return an empty array
        []
    }
}

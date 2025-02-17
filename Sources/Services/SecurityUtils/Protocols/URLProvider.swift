import Darwin.POSIX
import SecurityTypes

/// Protocol for providing path-based security operations
public protocol URLProvider: Sendable {
    /// Creates bookmark data for a path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: The bookmark data as bytes
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(forPath path: String) async throws -> [UInt8]

    /// Resolves bookmark data to a path
    /// - Parameter bookmarkData: The bookmark data to resolve
    /// - Returns: A tuple containing the resolved path and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

    /// Starts security-scoped access to a path
    /// - Parameter path: The path to access
    /// - Returns: True if access was granted, false otherwise
    /// - Throws: SecurityError if access cannot be started
    func startAccessing(path: String) async throws -> Bool

    /// Stops security-scoped access to a path
    /// - Parameter path: The path to stop accessing
    func stopAccessing(path: String) async

    /// Checks if a path is currently being accessed
    /// - Parameter path: The path to check
    /// - Returns: True if the path is being accessed, false otherwise
    func isAccessing(path: String) async -> Bool

    /// Gets all paths currently being accessed
    /// - Returns: Array of paths currently being accessed
    func getAccessedPaths() async -> [String]
}

/// Default implementation for paths
public struct PathURLProvider: URLProvider {
    /// Initialize a new path provider
    public init() {}

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        // For now, just use the path bytes as a bookmark
        Array(path.utf8)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        // For now, just convert bytes back to path
        let path = String(decoding: bookmarkData, as: UTF8.self)
        return (path, false)
    }

    public func startAccessing(path: String) async throws -> Bool {
        // Check if the path exists and is readable
        var statInfo = stat()
        if lstat(path, &statInfo) == 0 {
            return true
        } else {
            throw SecurityError.accessDenied(path: path)
        }
    }

    public func stopAccessing(path: String) async {
        // No-op for now
    }

    public func isAccessing(path: String) async -> Bool {
        // Check if the path exists and is readable
        var statInfo = stat()
        return lstat(path, &statInfo) == 0
    }

    public func getAccessedPaths() async -> [String] {
        // For now, just return an empty array
        []
    }
}

import Foundation
import SecurityTypes
import UmbraSecurityUtils

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService: SecurityProvider {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()

    private let bookmarkService: SecurityBookmarkService
    private var activeSecurityScopedResources: Set<String>
    private var bookmarks: [String: [UInt8]] = [:]

    /// Initialize a new SecurityService instance
    private init() {
        self.bookmarkService = SecurityBookmarkService(urlProvider: PathURLProvider())
        self.activeSecurityScopedResources = []
    }

    // MARK: - SecurityProvider Protocol

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let bookmarkData = try await bookmarkService.createBookmark(for: URL(fileURLWithPath: path))
        return Array(bookmarkData)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let result = try await bookmarkService.resolveBookmark(Data(bookmarkData))
        return (result.url.path, result.isStale)
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        let success = try await bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            return true
        }
        return success
    }

    public func stopAccessing(path: String) async {
        activeSecurityScopedResources.remove(path)
    }

    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            await stopAccessing(path: path)
        }
        activeSecurityScopedResources.removeAll()
    }

    public func isAccessing(path: String) async -> Bool {
        activeSecurityScopedResources.contains(path)
    }

    public func getAccessedPaths() async -> Set<String> {
        activeSecurityScopedResources
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        do {
            let (_, isStale) = try await resolveBookmark(bookmarkData)
            return !isStale
        } catch {
            return false
        }
    }

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let data = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(path: identifier)
        }
        return data
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        bookmarks.removeValue(forKey: identifier)
    }

    // MARK: - Convenience Methods

    /// Create a bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        try await bookmarkService.createBookmark(for: url)
    }

    /// Resolve a bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> (URL, Bool) {
        let result = try await bookmarkService.resolveBookmark(bookmarkData)
        return (result.url, result.isStale)
    }

    /// Perform an operation with security-scoped access
    /// - Parameters:
    ///   - path: Path to access
    ///   - operation: Operation to perform while path is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails
    public func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        guard try await startAccessing(path: path) else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }
}

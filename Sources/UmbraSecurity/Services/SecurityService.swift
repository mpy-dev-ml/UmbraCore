import Foundation
import SecurityTypes
import SecurityUtils

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService: SecurityProvider {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()
    
    private let bookmarkService: SecurityBookmarkService
    private var activeSecurityScopedResources: Set<String>
    
    /// Initialize a new SecurityService instance
    private init() {
        self.bookmarkService = SecurityBookmarkService(urlProvider: PathURLProvider())
        self.activeSecurityScopedResources = []
    }
    
    // MARK: - SecurityProvider Protocol
    
    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        try await bookmarkService.createBookmark(for: path)
    }
    
    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        try await bookmarkService.resolveBookmark(bookmarkData)
    }
    
    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        try await bookmarkService.save(bookmarkData, withIdentifier: identifier)
    }
    
    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        try await bookmarkService.load(withIdentifier: identifier)
    }
    
    public func deleteBookmark(withIdentifier identifier: String) async throws {
        try await bookmarkService.delete(withIdentifier: identifier)
    }
    
    public func startAccessing(path: String) async throws -> Bool {
        guard !activeSecurityScopedResources.contains(path) else { return true }
        let url = URL(fileURLWithPath: path)
        let success = url.startAccessingSecurityScopedResource()
        if success {
            activeSecurityScopedResources.insert(path)
        }
        return success
    }
    
    public func stopAccessing(path: String) async {
        guard activeSecurityScopedResources.contains(path) else { return }
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
        activeSecurityScopedResources.remove(path)
    }
    
    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            await stopAccessing(path: path)
        }
    }
    
    public func isAccessing(path: String) async -> Bool {
        activeSecurityScopedResources.contains(path)
    }
    
    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let (_, isStale) = try await resolveBookmark(bookmarkData)
        return !isStale
    }
    
    public func getAccessedPaths() async -> Set<String> {
        activeSecurityScopedResources
    }
    
    public func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        guard try await startAccessing(path: path) else {
            throw SecurityError.accessDenied(path: path)
        }
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }
    
    // MARK: - Convenience Methods
    
    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: The URL to create a bookmark for
    /// - Returns: The bookmark data as Data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        let bytes = try await createBookmark(forPath: url.path)
        return Data(bytes)
    }
    
    /// Resolve a security-scoped bookmark to a URL
    /// - Parameter bookmarkData: The bookmark data to resolve
    /// - Returns: A tuple containing the resolved URL and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        let bytes = Array(bookmarkData)
        let (path, isStale) = try await resolveBookmark(bytes)
        return (URL(fileURLWithPath: path), isStale)
    }
}

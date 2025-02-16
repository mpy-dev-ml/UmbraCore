import Core
import SecurityTypes
import SecurityUtils

/// Service for managing security and sandbox-related operations
@MainActor public final class SecurityService: SecurityProvider {
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = SecurityService()
    
    /// Set of currently accessed security-scoped resources
    private var activeSecurityScopedResources: Set<String> = []
    
    /// Service for managing security-scoped bookmarks
    private let bookmarkService: SecurityBookmarkService
    
    // MARK: - Initialization
    
    private init() {
        self.bookmarkService = SecurityBookmarkService.shared
    }
    
    // MARK: - SecurityProvider Implementation
    
    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        guard let url = URL(string: path) else {
            throw SecurityError.invalidPath(path: path, reason: "Invalid URL")
        }
        return try await bookmarkService.createBookmark(for: url)
    }
    
    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let (url, isStale) = try await bookmarkService.resolveBookmark(bookmarkData)
        return (path: url.path, isStale: isStale)
    }
    
    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        // TODO: Implement bookmark persistence
    }
    
    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        // TODO: Implement bookmark loading
        throw SecurityError.bookmarkNotFound(identifier: identifier)
    }
    
    public func deleteBookmark(withIdentifier identifier: String) async throws {
        // TODO: Implement bookmark deletion
    }
    
    public func startAccessing(path: String) async throws -> Bool {
        guard !activeSecurityScopedResources.contains(path) else {
            return true // Already accessing this resource
        }
        
        guard let url = URL(string: path) else {
            throw SecurityError.invalidPath(path: path, reason: "Invalid URL")
        }
        
        let success = try await bookmarkService.startAccessing(url)
        if success {
            activeSecurityScopedResources.insert(path)
        }
        return success
    }
    
    public func stopAccessing(path: String) async {
        if activeSecurityScopedResources.contains(path),
           let url = URL(string: path) {
            await bookmarkService.stopAccessing(url)
            activeSecurityScopedResources.remove(path)
        }
    }
    
    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            await stopAccessing(path)
        }
    }
    
    public func isAccessing(path: String) async -> Bool {
        activeSecurityScopedResources.contains(path)
    }
    
    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        try await bookmarkService.validateBookmark(bookmarkData)
    }
    
    public func getAccessedPaths() async -> Set<String> {
        activeSecurityScopedResources
    }
}

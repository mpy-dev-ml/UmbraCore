import Foundation
import Core

/// Service for managing security and sandbox-related operations
@MainActor public final class SecurityService: SecurityProvider {
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = SecurityService()
    
    /// Set of currently accessed security-scoped resources
    private var activeSecurityScopedResources: Set<URL> = []
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - SecurityProvider Implementation
    
    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> Data {
        try url.createSecurityScopedBookmark()
    }
    
    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Resolved URL
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: Data) async throws -> URL {
        let (url, isStale) = try URL.resolveSecurityScopedBookmark(bookmarkData)
        if isStale {
            _ = try await createBookmark(for: url)
        }
        return url
    }
    
    /// Start accessing a security-scoped resource
    /// - Parameter url: URL of the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails
    @discardableResult
    public func startAccessing(_ url: URL) async throws -> Bool {
        guard !activeSecurityScopedResources.contains(url) else {
            return true // Already accessing this resource
        }
        
        let success = url.startSecurityScopedAccess()
        if success {
            activeSecurityScopedResources.insert(url)
        }
        return success
    }
    
    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL of the resource to stop accessing
    public func stopAccessing(_ url: URL) async {
        guard activeSecurityScopedResources.contains(url) else {
            return // Not currently accessing this resource
        }
        
        url.stopSecurityScopedAccess()
        activeSecurityScopedResources.remove(url)
    }
    
    /// Perform an operation with security-scoped resource access
    /// - Parameters:
    ///   - url: URL of the resource to access
    ///   - operation: Operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    public func withSecurityScopedAccess<T>(
        to url: URL,
        perform operation: () async throws -> T
    ) async throws -> T {
        try await startAccessing(url)
        defer { Task { await stopAccessing(url) } }
        return try await operation()
    }
    
    /// Stop accessing all security-scoped resources
    public func stopAccessingAllResources() async {
        let urls = Array(activeSecurityScopedResources)
        for url in urls {
            await stopAccessing(url)
        }
    }
    
    deinit {
        // Since we can't use async/await in deinit, we'll use a detached task
        // that doesn't capture self
        let resources = activeSecurityScopedResources
        Task.detached {
            for url in resources {
                url.stopSecurityScopedAccess()
            }
        }
    }
}

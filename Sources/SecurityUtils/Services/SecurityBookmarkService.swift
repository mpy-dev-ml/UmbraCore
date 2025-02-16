import Foundation
import SecurityTypes

/// Service for managing security-scoped bookmarks
@MainActor public final class SecurityBookmarkService {
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = SecurityBookmarkService()
    
    /// Provider for URL operations
    private let urlProvider: URLProvider
    
    // MARK: - Initialization
    
    /// Initialize with a URL provider
    /// - Parameter urlProvider: Provider for URL operations, defaults to URL
    public init(urlProvider: URLProvider = URL(string: "/")!) {
        self.urlProvider = urlProvider
    }
    
    // MARK: - Public Methods
    
    /// Create a security-scoped bookmark for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data as UInt8 array
    /// - Throws: SecurityError if bookmark creation fails
    public func createBookmark(for url: URL) async throws -> [UInt8] {
        let data = try urlProvider.createBookmarkData(for: url)
        return [UInt8](data)
    }
    
    /// Resolve a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (url: URL, isStale: Bool) {
        var isStale = false
        let data = Data(bookmarkData)
        let url = try urlProvider.resolveBookmarkData(data, isStale: &isStale)
        return (url: url, isStale: isStale)
    }
    
    /// Start accessing a security-scoped resource
    /// - Parameter url: URL of the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails
    @discardableResult
    public func startAccessing(_ url: URL) async throws -> Bool {
        urlProvider.startAccessingSecurityScopedResource(url)
    }
    
    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL of the resource to stop accessing
    public func stopAccessing(_ url: URL) async {
        urlProvider.stopAccessingSecurityScopedResource(url)
    }
    
    /// Validate a bookmark's data
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if the bookmark data is valid
    /// - Throws: SecurityError if validation fails
    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        do {
            let (_, isStale) = try await resolveBookmark(bookmarkData)
            return !isStale
        } catch {
            return false
        }
    }
}

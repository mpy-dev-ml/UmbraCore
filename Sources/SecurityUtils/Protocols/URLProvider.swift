import Foundation

/// Protocol for providing URL-based operations
public protocol URLProvider {
    /// Create a bookmark data for a URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    /// - Throws: Error if bookmark creation fails
    func createBookmarkData(for url: URL) throws -> Data
    
    /// Resolve bookmark data to a URL
    /// - Parameters:
    ///   - data: Bookmark data to resolve
    ///   - isStale: Reference to store staleness status
    /// - Returns: Resolved URL
    /// - Throws: Error if bookmark resolution fails
    func resolveBookmarkData(_ data: Data, isStale: inout Bool) throws -> URL
    
    /// Start accessing a security-scoped resource
    /// - Parameter url: URL to access
    /// - Returns: True if access was granted
    func startAccessingSecurityScopedResource(_ url: URL) -> Bool
    
    /// Stop accessing a security-scoped resource
    /// - Parameter url: URL to stop accessing
    func stopAccessingSecurityScopedResource(_ url: URL)
}

/// Default implementation for URL
extension URL: URLProvider {
    public func createBookmarkData(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
    
    public func resolveBookmarkData(_ data: Data, isStale: inout Bool) throws -> URL {
        try URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
    
    public func startAccessingSecurityScopedResource(_ url: URL) -> Bool {
        url.startAccessingSecurityScopedResource()
    }
    
    public func stopAccessingSecurityScopedResource(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}

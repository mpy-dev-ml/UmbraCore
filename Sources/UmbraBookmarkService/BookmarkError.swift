import Foundation

/// Errors that can occur during bookmark operations
@frozen public enum BookmarkError: LocalizedError, Sendable {
    /// Failed to create bookmark data for URL
    case bookmarkCreationFailed(url: URL)

    /// Failed to resolve bookmark data to URL
    case bookmarkResolutionFailed(Error?)

    /// Bookmark data is stale and needs to be recreated
    case staleBookmark(url: URL)

    /// Security-scoped resource access was denied
    case accessDenied(url: URL)

    /// Failed to start security-scoped resource access
    case startAccessFailed(url: URL)

    /// Invalid bookmark data format
    case invalidBookmarkData

    /// File does not exist at URL
    case fileNotFound(url: URL)

    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let url):
            return "Failed to create bookmark for file at \(url.path)"
        case .bookmarkResolutionFailed(let error):
            if let error = error {
                return "Failed to resolve bookmark: \(error.localizedDescription)"
            }
            return "Failed to resolve bookmark"
        case .staleBookmark(let url):
            return "Bookmark is stale for file at \(url.path)"
        case .accessDenied(let url):
            return "Access denied to file at \(url.path)"
        case .startAccessFailed(let url):
            return "Failed to start security-scoped access for \(url.path)"
        case .invalidBookmarkData:
            return "Invalid bookmark data format"
        case .fileNotFound(let url):
            return "File not found at \(url.path)"
        }
    }
}

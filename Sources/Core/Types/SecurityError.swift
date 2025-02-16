import Foundation

/// Errors that can occur during security operations
public enum SecurityError: LocalizedError {
    /// Failed to create a security-scoped bookmark
    case bookmarkCreationFailed(url: URL, underlying: Error)
    
    /// Failed to resolve a security-scoped bookmark
    case bookmarkResolutionFailed(underlying: Error)
    
    /// Access to a security-scoped resource was denied
    case accessDenied(url: URL)
    
    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let url, let error):
            return "Failed to create bookmark for \(url.path): \(error.localizedDescription)"
        case .bookmarkResolutionFailed(let error):
            return "Failed to resolve bookmark: \(error.localizedDescription)"
        case .accessDenied(let url):
            return "Access denied to \(url.path)"
        }
    }
}

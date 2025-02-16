import Foundation

/// Errors that can occur during security operations
public enum SecurityError: LocalizedError {
    /// Failed to create a security-scoped bookmark
    case bookmarkCreationFailed(url: URL, underlying: Error)
    
    /// Failed to resolve a security-scoped bookmark
    case bookmarkResolutionFailed(underlying: Error)
    
    /// Access to a security-scoped resource was denied
    case accessDenied(url: URL)
    
    /// User-friendly error description
    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let url, _):
            return "Failed to create security-scoped bookmark for \(url.path)"
        case .bookmarkResolutionFailed:
            return "Failed to resolve security-scoped bookmark"
        case .accessDenied(let url):
            return "Access denied to \(url.path)"
        }
    }
    
    /// Additional error context
    public var failureReason: String? {
        switch self {
        case .bookmarkCreationFailed(_, let error):
            return error.localizedDescription
        case .bookmarkResolutionFailed(let error):
            return error.localizedDescription
        case .accessDenied:
            return "The application does not have permission to access this location"
        }
    }
    
    /// Recovery suggestion
    public var recoverySuggestion: String? {
        switch self {
        case .bookmarkCreationFailed:
            return "Please ensure the application has permission to access this location and try again"
        case .bookmarkResolutionFailed:
            return "The bookmark may be invalid. Try selecting the location again"
        case .accessDenied:
            return "Grant access to this location in System Settings > Privacy & Security"
        }
    }
}

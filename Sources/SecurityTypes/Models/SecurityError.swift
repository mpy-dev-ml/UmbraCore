import Foundation

/// Errors that can occur during security operations
@frozen public enum SecurityError: LocalizedError, Sendable, Equatable {
    /// Invalid data error
    case invalidData(reason: String)
    /// Item not found error
    case itemNotFound(key: String)
    /// Storage error
    case storageError(reason: String)
    /// Access denied error
    case accessDenied(reason: String)
    /// Bookmark creation failed
    case bookmarkCreationFailed(reason: String)
    /// Bookmark resolution failed
    case bookmarkResolutionFailed(reason: String)
    /// Bookmark not found
    case bookmarkNotFound(path: String)

    public var errorDescription: String? {
        switch self {
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .itemNotFound(let key):
            return "Item not found for key: \(key)"
        case .storageError(let reason):
            return "Storage error: \(reason)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        case .bookmarkCreationFailed(let reason):
            return "Failed to create bookmark: \(reason)"
        case .bookmarkResolutionFailed(let reason):
            return "Failed to resolve bookmark: \(reason)"
        case .bookmarkNotFound(let path):
            return "Bookmark not found: \(path)"
        }
    }
}

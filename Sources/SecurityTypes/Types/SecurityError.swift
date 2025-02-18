import Foundation

/// Errors that can occur during security operations
@frozen public enum SecurityError: LocalizedError, Sendable, Equatable {
    /// Failed to create a security-scoped bookmark
    case bookmarkCreationFailed(reason: String)
    /// Failed to resolve a security-scoped bookmark
    case bookmarkResolutionFailed(reason: String)
    /// Bookmark not found
    case bookmarkNotFound(reason: String)
    /// Access was denied
    case accessDenied(reason: String)
    /// Data is invalid or corrupted
    case invalidData(reason: String)
    /// Item not found
    case itemNotFound(reason: String)
    /// Error with the storage system
    case storageError(reason: String)

    /// A user-friendly description of the error
    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let reason):
            return "Failed to create security bookmark: \(reason)"
        case .bookmarkResolutionFailed(let reason):
            return "Failed to resolve security bookmark: \(reason)"
        case .bookmarkNotFound(let reason):
            return "Security bookmark not found: \(reason)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .itemNotFound(let reason):
            return "Item not found: \(reason)"
        case .storageError(let reason):
            return "Storage error: \(reason)"
        }
    }
}

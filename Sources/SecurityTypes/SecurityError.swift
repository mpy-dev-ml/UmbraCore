import Foundation

/// Errors that can occur during security operations
public enum SecurityError: LocalizedError {
    /// Error creating or resolving a bookmark
    case bookmarkError(String)
    /// Error accessing a security-scoped resource
    case accessError(String)
    /// Error during cryptographic operations
    case cryptoError(String)
    /// Invalid data provided
    case invalidData(reason: String)
    /// Access denied to resource
    case accessDenied(reason: String)

    public var errorDescription: String? {
        switch self {
        case .bookmarkError(let message):
            return "Bookmark error: \(message)"
        case .accessError(let message):
            return "Access error: \(message)"
        case .cryptoError(let message):
            return "Crypto error: \(message)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        }
    }
}

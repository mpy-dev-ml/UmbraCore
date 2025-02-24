import Foundation

/// Errors that can occur during security operations
public enum SecurityError: LocalizedError {
    /// Error creating or resolving a bookmark
    case bookmarkError(String)
    /// Error accessing a security-scoped resource
    case accessError(String)
    /// Error during cryptographic operations
    case cryptoError(String)
    
    public var errorDescription: String? {
        switch self {
        case .bookmarkError(let message):
            return "Bookmark error: \(message)"
        case .accessError(let message):
            return "Access error: \(message)"
        case .cryptoError(let message):
            return "Crypto error: \(message)"
        }
    }
}

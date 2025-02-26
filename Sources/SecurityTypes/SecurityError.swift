import Foundation
import SecurityInterfaces

/// Errors that can occur during security operations
/// This is a compatibility layer for the new SecurityInterfaces.SecurityError
@available(*, deprecated, message: "Use SecurityInterfaces.SecurityError instead")
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
    /// Failed to generate random data
    case randomGenerationFailed
    /// Item not found in secure storage
    case itemNotFound

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
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .itemNotFound:
            return "Item not found in secure storage"
        }
    }
}

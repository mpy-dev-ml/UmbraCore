import Foundation

/// Represents errors that can occur during security-related operations.
///
/// This enum provides specific error cases for different types of security
/// operations, including bookmark management, security-scoped resource access,
/// and cryptographic operations.
///
/// Example:
/// ```swift
/// catch let error as SecurityError {
///     switch error {
///     case .bookmarkError(let message):
///         // Handle bookmark-related error
///     case .accessError(let message):
///         // Handle access-related error
///     case .cryptoError(let message):
///         // Handle cryptography-related error
///     }
/// }
/// ```
public enum SecurityError: LocalizedError, Sendable {
    /// An error occurred while creating or resolving a security bookmark.
    ///
    /// - Parameter message: A description of what went wrong.
    case bookmarkError(String)

    /// An error occurred while accessing a security-scoped resource.
    ///
    /// - Parameter message: A description of what went wrong.
    case accessError(String)

    /// An error occurred during cryptographic operations.
    ///
    /// - Parameter message: A description of what went wrong.
    case cryptoError(String)

    /// Bookmark creation failed
    case bookmarkCreationFailed(path: String)

    /// Bookmark resolution failed
    case bookmarkResolutionFailed

    /// Bookmark is stale and needs to be recreated
    case bookmarkStale(path: String)

    /// Bookmark not found
    case bookmarkNotFound(path: String)

    /// Security-scoped resource access failed
    case resourceAccessFailed(path: String)

    /// Random data generation failed
    case randomGenerationFailed

    /// Hashing operation failed
    case hashingFailed

    /// Credential or secure item not found
    case itemNotFound

    /// General security operation failed
    case operationFailed(String)

    /// A localized message describing what went wrong.
    public var errorDescription: String? {
        switch self {
        case .bookmarkError(let message):
            return "Bookmark error: \(message)"
        case .accessError(let message):
            return "Access error: \(message)"
        case .cryptoError(let message):
            return "Crypto error: \(message)"
        case .bookmarkCreationFailed(let path):
            return "Failed to create bookmark for \(path)"
        case .bookmarkResolutionFailed:
            return "Failed to resolve bookmark"
        case .bookmarkStale(let path):
            return "Bookmark is stale and needs to be recreated for \(path)"
        case .bookmarkNotFound(let path):
            return "Bookmark not found for \(path)"
        case .resourceAccessFailed(let path):
            return "Failed to access security-scoped resource: \(path)"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .hashingFailed:
            return "Failed to hash data"
        case .itemNotFound:
            return "Credential or secure item not found"
        case .operationFailed(let message):
            return "Security operation failed: \(message)"
        }
    }
}

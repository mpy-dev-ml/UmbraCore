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
public enum SecurityError: LocalizedError {
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

    /// A localized message describing what went wrong.
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

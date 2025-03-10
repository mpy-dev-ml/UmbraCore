import ErrorHandlingDomains
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
      case let .bookmarkError(message):
        "Bookmark error: \(message)"
      case let .accessError(message):
        "Access error: \(message)"
      case let .cryptoError(message):
        "Crypto error: \(message)"
      case let .bookmarkCreationFailed(path):
        "Failed to create bookmark for \(path)"
      case .bookmarkResolutionFailed:
        "Failed to resolve bookmark"
      case let .bookmarkStale(path):
        "Bookmark is stale and needs to be recreated for \(path)"
      case let .bookmarkNotFound(path):
        "Bookmark not found for \(path)"
      case let .resourceAccessFailed(path):
        "Failed to access security-scoped resource: \(path)"
      case .randomGenerationFailed:
        "Failed to generate random data"
      case .hashingFailed:
        "Failed to hash data"
      case .itemNotFound:
        "Credential or secure item not found"
      case let .operationFailed(message):
        "Security operation failed: \(message)"
    }
  }
}

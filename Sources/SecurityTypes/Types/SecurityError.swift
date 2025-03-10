import Foundation
import ErrorHandlingDomains

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
  /// Item not found in storage
  case itemNotFound(reason: String)

  public var errorDescription: String? {
    switch self {
      case let .bookmarkError(message):
        "Bookmark error: \(message)"
      case let .accessError(message):
        "Access error: \(message)"
      case let .cryptoError(message):
        "Crypto error: \(message)"
      case let .invalidData(reason):
        "Invalid data: \(reason)"
      case let .accessDenied(reason):
        "Access denied: \(reason)"
      case let .itemNotFound(reason):
        "Item not found: \(reason)"
    }
  }
}

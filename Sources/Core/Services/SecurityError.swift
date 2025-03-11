import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// This file previously contained a duplicate definition of SecurityError.
/// It has been refactored to use the canonical UmbraErrors.Security.Core type directly.
/// The extensions below provide mapping functions for backward compatibility.

/// Extension to provide convenience mapping methods and properties for UmbraErrors.Security.Core
/// This maintains compatibility with code that previously used the local
/// Core.Services.SecurityError enum
extension UmbraErrors.Security.Core {
  /// Create a core security error from a bookmark-related issue
  public static func fromBookmarkError(_ message: String) -> Self {
    .internalError(reason: "Bookmark error: \(message)")
  }

  /// Create a core security error from an access-related issue
  public static func fromAccessError(_ message: String) -> Self {
    .authorizationFailed(reason: message)
  }

  /// Create a core security error from a cryptographic operation issue
  public static func fromCryptoError(_ message: String) -> Self {
    .internalError(reason: "Crypto error: \(message)")
  }

  /// Create a core security error for bookmark creation failure
  public static func fromBookmarkCreationFailed(path: String) -> Self {
    .internalError(reason: "Failed to create bookmark for \(path)")
  }

  /// Create a core security error for bookmark resolution failure
  public static func bookmarkResolutionFailedError() -> Self {
    .internalError(reason: "Failed to resolve bookmark")
  }

  /// Create a core security error for stale bookmark
  public static func fromBookmarkStale(path: String) -> Self {
    .internalError(reason: "Bookmark is stale and needs to be recreated for \(path)")
  }

  /// Create a core security error for bookmark not found
  public static func fromBookmarkNotFound(path: String) -> Self {
    .internalError(reason: "Bookmark not found for \(path)")
  }

  /// Create a core security error for resource access failure
  public static func fromResourceAccessFailed(path: String) -> Self {
    .authorizationFailed(reason: "Failed to access security-scoped resource: \(path)")
  }

  /// Create a core security error for random generation failure
  public static func randomGenerationFailedError() -> Self {
    .internalError(reason: "Failed to generate random data")
  }

  /// Create a core security error for hashing failure
  public static func hashingFailedError() -> Self {
    .hashingFailed(reason: "Failed to hash data")
  }

  /// Create a core security error for item not found
  public static func itemNotFoundError() -> Self {
    .internalError(reason: "Credential or secure item not found")
  }

  /// Create a core security error for operation failure
  public static func fromOperationFailed(_ message: String) -> Self {
    .internalError(reason: "Security operation failed: \(message)")
  }
}

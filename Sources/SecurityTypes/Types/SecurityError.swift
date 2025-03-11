import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// This file previously contained a duplicate definition of SecurityError.
/// It has been refactored to use the canonical UmbraErrors.Security.Core type directly.
/// The extensions below provide mapping functions for backward compatibility.

/// Extension to provide convenience mapping methods to/from the specific error types
/// used in the SecurityTypes module
public extension UmbraErrors.Security.Core {
  /// Create a core security error from a bookmark-related issue
  static func fromBookmarkError(_ message: String) -> Self {
    .internalError(reason: "Bookmark error: \(message)")
  }
  
  /// Create a core security error from an access-related issue
  static func fromAccessError(_ message: String) -> Self {
    .authorizationFailed(reason: message)
  }
  
  /// Create a core security error from a cryptographic operation issue
  static func fromCryptoError(_ message: String) -> Self {
    .internalError(reason: "Crypto error: \(message)")
  }
  
  /// Check if this error represents a bookmark error
  var isBookmarkError: Bool {
    if case .internalError(let reason) = self, reason.starts(with: "Bookmark error:") {
      return true
    }
    return false
  }
  
  /// Check if this error represents an access error
  var isAccessError: Bool {
    if case .authorizationFailed = self {
      return true
    }
    return false
  }
  
  /// Get a user-friendly error description
  var legacyErrorDescription: String? {
    switch self {
      case .internalError(let reason) where reason.starts(with: "Bookmark error:"):
        return reason
      case .authorizationFailed(let reason):
        return "Access error: \(reason)"
      case .encryptionFailed(let reason), .decryptionFailed(let reason), .hashingFailed(let reason):
        return "Crypto error: \(reason)"
      case .internalError(let reason) where reason.starts(with: "Crypto error:"):
        return reason
      case .internalError(let reason) where reason.starts(with: "Invalid data:"):
        return reason
      case .authenticationFailed(let reason):
        return "Access denied: \(reason)"
      default:
        return localizedDescription
    }
  }
}

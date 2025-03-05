import Foundation

/// Errors that can occur during security operations
/// This is a compatibility layer for the new error type in SecurityInterfaces
@available(*, deprecated, message: "Use the SecurityError from SecurityInterfaces module instead")
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
      case .randomGenerationFailed:
        "Failed to generate random data"
      case .itemNotFound:
        "Item not found in secure storage"
    }
  }
}

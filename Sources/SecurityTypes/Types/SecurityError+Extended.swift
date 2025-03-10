import ErrorHandlingDomains
import Foundation

/// Extension for SecurityError to add additional error cases needed for implementations
extension SecurityError {
  /// Key generation failed with the given error
  public static func keyGenerationFailed(error: Error?) -> SecurityError {
    if let error {
      .cryptoError("Key generation failed: \(error.localizedDescription)")
    } else {
      .cryptoError("Key generation failed for unknown reason")
    }
  }

  /// Bookmark creation failed with the given error
  public static func bookmarkCreationFailed(path: String, error: Error) -> SecurityError {
    .bookmarkError("Failed to create bookmark for \(path): \(error.localizedDescription)")
  }

  /// Bookmark resolution failed with the given error
  public static func bookmarkResolutionFailed(error: Error) -> SecurityError {
    .bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
  }

  /// Access denied for the given path with the given error
  public static func accessDenied(path: String, error: Error) -> SecurityError {
    .accessError("Access denied for \(path): \(error.localizedDescription)")
  }
}

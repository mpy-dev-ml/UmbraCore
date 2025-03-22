import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// Extension for UmbraErrors.Security.Core to add additional error cases needed for implementations
extension UmbraErrors.Security.Core {
  /// Key generation failed with the given error
  public static func keyGenerationFailed(error: Error?) -> UmbraErrors.Security.Core {
    if let error {
      .internalError(reason: "Key generation failed: \(error.localizedDescription)")
    } else {
      .internalError(reason: "Key generation failed for unknown reason")
    }
  }

  /// Bookmark creation failed with the given error
  public static func bookmarkCreationFailed(path: String, error: Error) -> UmbraErrors.Security
  .Core {
    .internalError(reason: "Failed to create bookmark for \(path): \(error.localizedDescription)")
  }

  /// Bookmark resolution failed with the given error
  public static func bookmarkResolutionFailed(error: Error) -> UmbraErrors.Security.Core {
    .internalError(reason: "Failed to resolve bookmark: \(error.localizedDescription)")
  }

  /// Access denied for the given path with the given error
  public static func accessDenied(path: String, error: Error) -> UmbraErrors.Security.Core {
    .authorizationFailed(reason: "Access denied for \(path): \(error.localizedDescription)")
  }
}

import Foundation

/// Extension for SecurityError to add additional error cases needed for implementations
public extension SecurityError {
    /// Key generation failed with the given error
    static func keyGenerationFailed(error: Error?) -> SecurityError {
        if let error = error {
            return .cryptoError("Key generation failed: \(error.localizedDescription)")
        } else {
            return .cryptoError("Key generation failed for unknown reason")
        }
    }

    /// Bookmark creation failed with the given error
    static func bookmarkCreationFailed(path: String, error: Error) -> SecurityError {
        return .bookmarkError("Failed to create bookmark for \(path): \(error.localizedDescription)")
    }

    /// Bookmark resolution failed with the given error
    static func bookmarkResolutionFailed(error: Error) -> SecurityError {
        return .bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
    }

    /// Access denied for the given path with the given error
    static func accessDenied(path: String, error: Error) -> SecurityError {
        return .accessError("Access denied for \(path): \(error.localizedDescription)")
    }
}

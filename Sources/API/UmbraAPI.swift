import Core
import Foundation

/// UmbraAPI provides a simplified interface to the UmbraCore security framework.
public enum UmbraAPI {
    /// Initialize the UmbraCore framework
    public static func initialize() async throws {
        try await Core.initialize()
    }

    /// Create an encrypted security-scoped bookmark for the given URL
    public static func createEncryptedBookmark(
        for url: URL,
        identifier: String
    ) async throws {
        // Delegate to SecurityUtils
    }

    /// Resolve an encrypted security-scoped bookmark
    public static func resolveEncryptedBookmark(
        withIdentifier identifier: String
    ) async throws -> URL {
        // Delegate to SecurityUtils
        fatalError("Not implemented")
    }

    /// Delete an encrypted security-scoped bookmark
    public static func deleteEncryptedBookmark(
        withIdentifier identifier: String
    ) async throws {
        // Delegate to SecurityUtils
        fatalError("Not implemented")
    }
}

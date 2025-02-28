import CoreTypes

/// Protocol for providing security-related operations
/// This is a minimal bridge version that doesn't depend on Foundation
public protocol SecurityProviderTypeMinimalBridge: Sendable {
    /// Create a security-scoped bookmark for a path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: The bookmark data as bytes
    /// - Throws: Error if bookmark creation fails
    func createSecurityBookmarkMinimal(for path: String) async throws -> [UInt8]

    /// Resolve a security-scoped bookmark to a path
    /// - Parameter bookmarkData: The bookmark data to resolve
    /// - Returns: The resolved path
    /// - Throws: Error if bookmark resolution fails
    func resolveSecurityBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> String

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    /// - Returns: True if access was granted
    /// - Throws: Error if access cannot be granted
    func startAccessingSecurityScopedResourceMinimal(at path: String) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    func stopAccessingSecurityScopedResourceMinimal(at path: String)

    /// Validate a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: Error if validation fails
    func validateResourceBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> Bool
}

/// Custom error for minimal bridge that doesn't require Foundation
public enum SecurityProviderMinimalError: Error, Sendable {
    case implementationMissing(String)
    case conversionFailed(String)
    case accessDenied(String)
    case invalidBookmark(String)
}

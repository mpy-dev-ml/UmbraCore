import CoreTypes

/// Error types for minimal security provider
public enum SecurityProviderMinimalError: Error {
    /// Failed to convert between types
    case conversionFailed(String)
    /// Operation not supported
    case operationNotSupported(String)
    /// Security operation failed
    case securityOperationFailed(String)
}

/// Protocol for security operations with minimal dependencies
/// This is the absolute minimal interface to break circular dependencies
public protocol SecurityProviderTypeMinimalBridge {
    /// Create a security-scoped bookmark for a path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: Bookmark data as bytes
    /// - Throws: Error if bookmark creation fails
    func createSecurityBookmarkMinimal(for path: String) async throws -> [UInt8]

    /// Resolve a security-scoped bookmark to a path
    /// - Parameter bookmarkData: The bookmark data as bytes
    /// - Returns: The resolved path
    /// - Throws: Error if bookmark resolution fails
    func resolveSecurityBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> String

    /// Start accessing a security-scoped resource
    /// - Parameter path: The path to the resource
    /// - Throws: Error if access cannot be started
    func startAccessingSecurityScopedResource(at path: String) async throws

    /// Stop accessing a security-scoped resource
    /// - Parameter path: The path to the resource
    func stopAccessingSecurityScopedResource(at path: String) async

    /// Validate a resource bookmark
    /// - Parameter bookmarkData: The bookmark data as bytes
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: Error if validation fails
    func validateResourceBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> Bool
}

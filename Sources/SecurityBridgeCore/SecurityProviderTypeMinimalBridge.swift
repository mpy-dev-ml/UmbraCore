// SecurityProviderTypeMinimalBridge.swift
// Minimal bridge protocol that doesn't depend on Foundation

/// Minimal bridge protocol for security provider that doesn't depend on Foundation
/// This protocol is used to break circular dependencies
public protocol SecurityProviderTypeMinimalBridge: AnyObject, Sendable {
    /// Resolve a security bookmark to a path
    /// - Parameter bookmarkData: The bookmark data as bytes
    /// - Returns: The resolved path
    func resolveSecurityBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> String

    /// Create a security bookmark for a path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: The bookmark data as bytes
    func createSecurityBookmarkMinimal(for path: String) async throws -> [UInt8]

    /// Validate a resource bookmark
    /// - Parameter bookmarkData: The bookmark data as bytes
    /// - Returns: True if the bookmark is valid
    func validateResourceBookmarkMinimal(_ bookmarkData: [UInt8]) async throws -> Bool

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    /// - Returns: True if access was granted
    /// - Throws: Error if access cannot be granted
    func startAccessingSecurityScopedResourceMinimal(at path: String) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    func stopAccessingSecurityScopedResourceMinimal(at path: String)
}

/// Error types for minimal security provider
public enum SecurityProviderMinimalError: Error, Sendable {
    /// Conversion between types failed
    case conversionFailed(String)
    /// Operation not supported
    case operationNotSupported(String)
    /// Security error
    case securityError(String)
    /// Unknown error
    case unknown(String)
}

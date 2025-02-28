import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityBridgeCore
import SecurityInterfacesBase
import SecurityInterfacesFoundationBase

/// Adapter that bridges from SecurityProviderTypeMinimalBridge to Foundation-dependent code
/// This adapter doesn't directly import Foundation to avoid circular dependencies
public final class SecurityProviderMinimalAdapter: @unchecked Sendable {
    private let minimalProvider: any SecurityBridgeCore.SecurityProviderTypeMinimalBridge

    /// Initialize with a minimal implementation
    /// - Parameter minimalProvider: The minimal implementation
    public init(minimalProvider: any SecurityBridgeCore.SecurityProviderTypeMinimalBridge) {
        self.minimalProvider = minimalProvider
    }

    /// Create a security-scoped bookmark for a path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: The bookmark data as Any (actually NSData)
    /// - Throws: Error if bookmark creation fails
    public func createSecurityBookmark(for path: String) async throws -> Any {
        let bytes = try await minimalProvider.createSecurityBookmarkMinimal(for: path)
        return Data(bytes)
    }

    /// Resolve a security-scoped bookmark to a path
    /// - Parameter bookmarkData: The bookmark data to resolve as Any (actually NSData)
    /// - Returns: The resolved path
    /// - Throws: Error if bookmark resolution fails
    public func resolveSecurityBookmark(_ bookmarkData: Any) async throws -> String {
        guard let data = bookmarkData as? Data else {
            throw SecurityBridgeCore.SecurityProviderMinimalError.conversionFailed("Bookmark data is not Data")
        }
        return try await minimalProvider.resolveSecurityBookmarkMinimal(Array(data))
    }

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    /// - Returns: True if access was granted
    /// - Throws: Error if access cannot be granted
    public func startAccessingSecurityScopedResource(at path: String) async throws -> Bool {
        return try await minimalProvider.startAccessingSecurityScopedResourceMinimal(at: path)
    }

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    public func stopAccessingSecurityScopedResource(at path: String) {
        minimalProvider.stopAccessingSecurityScopedResourceMinimal(at: path)
    }

    /// Validate a security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to validate as Any (actually NSData)
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: Error if validation fails
    public func validateResourceBookmark(_ bookmarkData: Any) async throws -> Bool {
        guard let data = bookmarkData as? Data else {
            throw SecurityBridgeCore.SecurityProviderMinimalError.conversionFailed("Bookmark data is not Data")
        }
        return try await minimalProvider.validateResourceBookmarkMinimal(Array(data))
    }
}

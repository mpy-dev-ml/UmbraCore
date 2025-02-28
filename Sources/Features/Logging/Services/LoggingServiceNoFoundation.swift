import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import SecurityTypesProtocols

/// Service for handling logging operations without Foundation dependencies
@available(macOS 14.0, *)
public class LoggingServiceNoFoundation {
    private let securityProvider: any SecurityProviderCore

    /// Initialize with a security provider
    /// - Parameter securityProvider: The security provider to use
    public init(securityProvider: any SecurityProviderCore) {
        self.securityProvider = securityProvider
    }

    /// Create a bookmark for a log file
    /// - Parameter path: Path to the log file
    /// - Returns: Bookmark data
    /// - Throws: SecurityProviderCoreError if bookmark creation fails
    public func createBookmark(for path: String) async throws -> [UInt8] {
        return try await securityProvider.createBookmark(path)
    }

    /// Resolve a bookmark for a log file
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Path to the log file
    /// - Throws: SecurityProviderCoreError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: [UInt8]) throws -> String {
        return try securityProvider.resolveBookmark(bookmarkData)
    }

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    /// - Returns: Whether access was successfully started
    /// - Throws: SecurityProviderCoreError if access fails
    public func startAccessingSecurityScopedResource(_ path: String) throws -> Bool {
        return try securityProvider.startAccessingSecurityScopedResource(path)
    }

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource
    public func stopAccessingSecurityScopedResource(_ path: String) {
        securityProvider.stopAccessingSecurityScopedResource(path)
    }

    /// Get all accessed resource identifiers
    /// - Returns: Set of resource identifiers
    public func getAccessedResourceIdentifiers() async -> Set<String> {
        // This requires the DefaultSecurityProviderNoFoundation implementation
        if let provider = securityProvider as? DefaultSecurityProviderNoFoundation {
            return await provider.getAccessedResourceIdentifiers()
        }
        return []
    }

    /// Clear all accessed resources
    public func clearAccessedResources() async {
        // This requires the DefaultSecurityProviderNoFoundation implementation
        if let provider = securityProvider as? DefaultSecurityProviderNoFoundation {
            await provider.clearAccessedResources()
        }
    }
}

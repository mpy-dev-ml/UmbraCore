import Core
import CoreServices
import CoreServicesTypes
import Foundation
import ObjCBridgingTypesFoundation
import SecurityInterfacesFoundationBridge
import SecurityUtils
import UmbraLogging
import UmbraSecurityUtils

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()

    private var activeSecurityScopedResources: Set<String>
    private var bookmarks: [String: [UInt8]] = [:]

    // Services
    private let bookmarkService: UmbraSecurityUtils.SecurityBookmarkService
    private let securityProvider: any SecurityInterfacesFoundationBridge.SecurityProviderTypeBridge

    /// Initialize a new SecurityService instance
    private init() {
        self.activeSecurityScopedResources = []
        self.bookmarkService = UmbraSecurityUtils.SecurityBookmarkService()
        // Use a direct implementation rather than importing FeaturesLoggingServices
        self.securityProvider = DefaultSecurityProviderImpl()
    }

    // MARK: - SecurityProvider Protocol

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let bookmarkData = try await bookmarkService.createBookmark(for: URL(fileURLWithPath: path))
        return Array(bookmarkData)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let result = try await bookmarkService.resolveBookmark(Data(bookmarkData))
        return (result.url.path, result.isStale)
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        let success = try await bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            return true
        }
        return success
    }

    public func stopAccessing(path: String) async {
        if activeSecurityScopedResources.contains(path) {
            let url = URL(fileURLWithPath: path)
            await bookmarkService.stopAccessing(url: url)
            activeSecurityScopedResources.remove(path)
        }
    }

    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            let url = URL(fileURLWithPath: path)
            await bookmarkService.stopAccessing(url: url)
        }
        activeSecurityScopedResources.removeAll()
    }

    public func isAccessing(path: String) async -> Bool {
        return activeSecurityScopedResources.contains(path)
    }

    public func getAccessedPaths() async -> Set<String> {
        return activeSecurityScopedResources
    }

    public func withSecurityScopedAccess<T>(to path: String, perform operation: @Sendable () async throws -> T) async throws -> T {
        let url = URL(fileURLWithPath: path)
        return try await bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            defer {
                Task {
                    await self.stopAccessing(path: path)
                }
            }
            return try await operation()
        }
    }

    // MARK: - Bookmark Management

    /// Store a bookmark for a path
    /// - Parameters:
    ///   - bookmarkData: Bookmark data to store
    ///   - path: Path associated with the bookmark
    public func storeBookmark(_ bookmarkData: [UInt8], forPath path: String) {
        bookmarks[path] = bookmarkData
    }

    /// Retrieve a bookmark for a path
    /// - Parameter path: Path to get bookmark for
    /// - Returns: Bookmark data if available
    public func getBookmark(forPath path: String) -> [UInt8]? {
        return bookmarks[path]
    }

    /// Remove a bookmark for a path
    /// - Parameter path: Path to remove bookmark for
    public func removeBookmark(forPath path: String) {
        bookmarks.removeValue(forKey: path)
    }

    /// Get all paths that have bookmarks
    /// - Returns: Set of paths with bookmarks
    public func getBookmarkedPaths() -> Set<String> {
        return Set(bookmarks.keys)
    }
}

/// Default implementation of SecurityProvider
private final class DefaultSecurityProviderImpl: SecurityInterfacesFoundationBridge.SecurityProviderTypeBridge {
    func createSecurityBookmark(for url: URL) throws -> Data {
        // This is a simple implementation that delegates to the SecurityService
        // We could add proper implementation here or use a different pattern
        let data = try NSData(contentsOf: url).bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
        return data as Data
    }

    func resolveSecurityBookmark(_ bookmarkData: Data) throws -> URL {
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        return url
    }

    func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        return url.startAccessingSecurityScopedResource()
    }

    func stopAccessing(path: String) async {
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
    }

    func stopAccessingAllResources() async {
        // No implementation needed for this simple provider
    }

    func isAccessing(path: String) async -> Bool {
        // No way to check this with standard APIs
        return false
    }

    func getAccessedPaths() async -> Set<String> {
        // No way to get this with standard APIs
        return []
    }

    func withSecurityScopedAccess<T>(to path: String, perform operation: @Sendable () async throws -> T) async throws -> T {
        let url = URL(fileURLWithPath: path)
        let success = url.startAccessingSecurityScopedResource()
        if !success {
            throw NSError(domain: "com.umbra.security", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access security-scoped resource"])
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        return try await operation()
    }
}

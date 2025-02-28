import Core
import CoreServices
import CoreServicesTypes
import Foundation
import FoundationBridgeTypes
import ObjCBridgingTypesFoundation
import SecurityBridgeCore
import SecurityInterfacesFoundationMinimal
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
    private let securityProvider: any SecurityInterfacesFoundationMinimal.SecurityProviderFoundationMinimal

    /// Initialize a new SecurityService instance
    private init() {
        self.activeSecurityScopedResources = []
        self.bookmarkService = UmbraSecurityUtils.SecurityBookmarkService()
        // Use a direct implementation rather than importing FeaturesLoggingServices
        self.securityProvider = DefaultSecurityProviderImpl()
    }

    // MARK: - SecurityProvider Protocol

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        return try securityProvider.createBookmarkMinimal(for: path)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let path = try securityProvider.resolveBookmarkMinimal(bookmarkData)
        return (path, false)
    }

    public func startAccessing(path: String) async throws -> Bool {
        return try securityProvider.startAccessingSecurityScopedResourceMinimal(path)
    }

    public func stopAccessing(path: String) async {
        securityProvider.stopAccessingSecurityScopedResourceMinimal(path)
    }

    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            securityProvider.stopAccessingSecurityScopedResourceMinimal(path)
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
        let success = try await startAccessing(path: path)
        if !success {
            throw NSError(domain: "com.umbra.security", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access security-scoped resource"])
        }

        defer {
            await stopAccessing(path: path)
        }

        return try await operation()
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
private final class DefaultSecurityProviderImpl: SecurityInterfacesFoundationMinimal.SecurityProviderFoundationMinimal {
    func createBookmarkMinimal(for urlPath: String) throws -> [UInt8] {
        // Convert string path to URL
        guard let url = URL(string: urlPath) else {
            throw SecurityProviderMinimalError.conversionFailed
        }

        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return [UInt8](bookmarkData)
        } catch {
            throw SecurityProviderMinimalError.securityError
        }
    }

    func resolveBookmarkMinimal(_ bookmarkData: [UInt8]) throws -> String {
        do {
            var isStale = false
            let data = Data(bookmarkData)
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                Logger.shared.warning("Bookmark is stale and needs to be recreated")
            }

            return url.absoluteString
        } catch {
            throw SecurityProviderMinimalError.securityError
        }
    }

    func startAccessingSecurityScopedResourceMinimal(_ urlPath: String) throws -> Bool {
        guard let url = URL(string: urlPath) else {
            throw SecurityProviderMinimalError.conversionFailed
        }

        return url.startAccessingSecurityScopedResource()
    }

    func stopAccessingSecurityScopedResourceMinimal(_ urlPath: String) {
        guard let url = URL(string: urlPath) else {
            return
        }

        url.stopAccessingSecurityScopedResource()
    }

    func encryptDataMinimal(_ data: [UInt8], key: [UInt8]) throws -> [UInt8] {
        throw SecurityProviderMinimalError.operationNotSupported
    }

    func decryptDataMinimal(_ data: [UInt8], key: [UInt8]) throws -> [UInt8] {
        throw SecurityProviderMinimalError.operationNotSupported
    }

    func generateKeyMinimal(length: Int) throws -> [UInt8] {
        throw SecurityProviderMinimalError.operationNotSupported
    }
}

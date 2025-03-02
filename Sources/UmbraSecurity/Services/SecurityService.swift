import CoreServicesTypesNoFoundation
import Foundation
import ObjCBridgingTypesFoundation
import SecurityBridge
import SecurityUtils
import UmbraLogging
import SecurityInterfacesFoundationBridge

/// Simple protocol for bookmark services to break dependency cycles
protocol BookmarkServiceType {
    func createBookmark(for url: URL) throws -> [UInt8]
    func resolveBookmark(_ bookmark: [UInt8]) throws -> URL
    func withSecurityScopedAccess<T>(to url: URL, perform operation: () throws -> T) throws -> T
    func stopAccessing(url: URL)
}

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()

    private var activeSecurityScopedResources: Set<String>
    private var bookmarks: [String: [UInt8]] = [:]

    // Services
    private let bookmarkService: BookmarkServiceType
    private let securityProvider: any SecurityInterfacesFoundationBridge.SecurityProviderTypeBridge

    /// Initialize a new SecurityService instance
    private init() {
        self.activeSecurityScopedResources = []
        self.bookmarkService = DefaultBookmarkService()
        // Use a direct implementation rather than importing FeaturesLoggingServices
        self.securityProvider = DefaultSecurityProviderImpl()
    }

    // MARK: - SecurityProvider Protocol

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let bookmarkData = try bookmarkService.createBookmark(for: URL(fileURLWithPath: path))
        return bookmarkData
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let isStale = false
        let url = try bookmarkService.resolveBookmark(bookmarkData)
        return (url.path, isStale)
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        let success = try bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            return true
        }
        return success
    }

    public func stopAccessing(path: String) async {
        if activeSecurityScopedResources.contains(path) {
            let url = URL(fileURLWithPath: path)
            bookmarkService.stopAccessing(url: url)
            activeSecurityScopedResources.remove(path)
        }
    }

    public func stopAccessingAll() async {
        for path in activeSecurityScopedResources {
            let url = URL(fileURLWithPath: path)
            bookmarkService.stopAccessing(url: url)
        }
        activeSecurityScopedResources.removeAll()
    }

    public func isAccessing(path: String) async -> Bool {
        return activeSecurityScopedResources.contains(path)
    }

    public func getAccessedPaths() async -> Set<String> {
        return activeSecurityScopedResources
    }

    public func withSecurityScopedAccess<T>(to path: String, perform operation: @Sendable @escaping () async throws -> T) async throws -> T {
        let url = URL(fileURLWithPath: path)
        return try bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            defer {
                activeSecurityScopedResources.remove(path)
            }
            // Since we can't directly run an async operation in the closure,
            // we use a helper to wrap the operation
            let operationResult = UmbySecurity.OperationResult<T>()
            
            Task {
                do {
                    let result = try await operation()
                    operationResult.complete(with: .success(result))
                } catch {
                    operationResult.complete(with: .failure(error))
                }
            }
            
            guard let result = operationResult.waitForResult() else {
                throw NSError(domain: "com.umbrasecurity.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
            }
            
            return try result.get()
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

/// Default implementation of BookmarkServiceType
private final class DefaultBookmarkService: BookmarkServiceType {
    func createBookmark(for url: URL) throws -> [UInt8] {
        let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        return Array(bookmark)
    }
    
    func resolveBookmark(_ bookmark: [UInt8]) throws -> URL {
        let bookmarkData = Data(bookmark)
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        return url
    }
    
    func withSecurityScopedAccess<T>(to url: URL, perform operation: () throws -> T) throws -> T {
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "com.umbrasecurity.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access security scoped resource"])
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        return try operation()
    }
    
    func stopAccessing(url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}

/// Default implementation of SecurityProvider
private final class DefaultSecurityProviderImpl: SecurityInterfacesFoundationBridge.SecurityProviderTypeBridge {
    func createSecurityBookmark(for url: URL) throws -> Data {
        return try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
    }
    
    func resolveSecurityBookmark(_ data: Data) throws -> URL {
        var isStale = false
        return try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
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

/// Simple helper to handle async operations in a synchronous context
fileprivate enum UmbySecurity {
    class OperationResult<T> {
        private var result: Result<T, Error>?
        private let semaphore = DispatchSemaphore(value: 0)
        
        func complete(with result: Result<T, Error>) {
            self.result = result
            semaphore.signal()
        }
        
        func waitForResult() -> Result<T, Error>? {
            if semaphore.wait(timeout: .now() + 30) == .success {
                return result
            }
            return nil
        }
    }
}

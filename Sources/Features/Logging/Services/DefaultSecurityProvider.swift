import Foundation
import SecurityTypes
import SecurityTypesProtocols

/// Default implementation of SecurityProvider for production use
@available(macOS 14.0, *)
public class DefaultSecurityProvider: SecurityProvider {
    /// Dictionary to track accessed URLs and their bookmark data
    private var accessedURLs: [String: (URL, Data)] = [:]

    public init() {}

    public func createSecurityBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    public func resolveSecurityBookmark(_ bookmarkData: Data) throws -> URL {
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

        if isStale {
            // In a real implementation, we might want to refresh the bookmark
            // For now, just log a warning
            print("Warning: Security bookmark for \(url.path) is stale")
        }

        return url
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        let bookmarkData = try createSecurityBookmark(for: url)
        let resolvedURL = try resolveSecurityBookmark(bookmarkData)

        let success = resolvedURL.startAccessingSecurityScopedResource()
        if success {
            accessedURLs[path] = (resolvedURL, bookmarkData)
        }
        return success
    }

    public func stopAccessing(path: String) async {
        if let (url, _) = accessedURLs[path] {
            url.stopAccessingSecurityScopedResource()
            accessedURLs.removeValue(forKey: path)
        }
    }

    public func stopAccessingAllResources() async {
        for (_, (url, _)) in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        accessedURLs.removeAll()
    }

    public func isAccessing(path: String) async -> Bool {
        accessedURLs[path] != nil
    }

    public func getAccessedPaths() async -> Set<String> {
        Set(accessedURLs.keys)
    }

    public func withSecurityScopedAccess<T>(to path: String, perform operation: @Sendable () async throws -> T) async throws -> T {
        let wasAlreadyAccessing = await isAccessing(path: path)

        if !wasAlreadyAccessing {
            _ = try await startAccessing(path: path)
        }

        do {
            let result = try await operation()

            if !wasAlreadyAccessing {
                await stopAccessing(path: path)
            }

            return result
        } catch {
            if !wasAlreadyAccessing {
                await stopAccessing(path: path)
            }
            throw error
        }
    }
}

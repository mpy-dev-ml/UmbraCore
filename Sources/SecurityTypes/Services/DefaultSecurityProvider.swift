import Foundation

/// Default implementation of SecurityProvider protocol
public actor DefaultSecurityProvider: SecurityProvider {
    private var accessedPaths: Set<String>
    private var bookmarks: [String: [UInt8]]

    /// Initialize a new DefaultSecurityProvider
    public init() {
        self.accessedPaths = []
        self.bookmarks = [:]
    }

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        return Array(bookmarkData)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let data = Data(bookmarkData)
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        return (url.path, isStale)
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        if url.startAccessingSecurityScopedResource() {
            accessedPaths.insert(path)
            return true
        } else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }
    }

    public func stopAccessing(path: String) async {
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
        accessedPaths.remove(path)
    }

    public func stopAccessingAllResources() async {
        for path in accessedPaths {
            await stopAccessing(path: path)
        }
        accessedPaths.removeAll()
    }

    public func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        let accessGranted = try await startAccessing(path: path)
        guard accessGranted else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }

        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }

    public func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        do {
            let (_, isStale) = try await resolveBookmark(bookmarkData)
            return !isStale
        } catch {
            return false
        }
    }

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let data = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(path: identifier)
        }
        return data
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        bookmarks.removeValue(forKey: identifier)
    }
}

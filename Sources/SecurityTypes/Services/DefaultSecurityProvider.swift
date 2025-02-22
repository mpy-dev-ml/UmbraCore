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
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return Array(bookmarkData)
        } catch {
            throw SecurityError.bookmarkCreationFailed(reason: "Failed to create bookmark for \(path): \(error.localizedDescription)")
        }
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let data = Data(bookmarkData)
        var isStale = false

        do {
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return (url.path, isStale)
        } catch {
            throw SecurityError.bookmarkResolutionFailed(reason: "Failed to resolve bookmark: \(error.localizedDescription)")
        }
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
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        let accessGranted = try await startAccessing(path: path)
        guard accessGranted else {
            throw SecurityError.accessDenied(reason: "Access denied to: \(path)")
        }

        do {
            let result = try await operation()
            await stopAccessing(path: path)
            return result
        } catch {
            await stopAccessing(path: path)
            throw error
        }
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
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found: \(identifier)")
        }
        return data
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found: \(identifier)")
        }
    }
}

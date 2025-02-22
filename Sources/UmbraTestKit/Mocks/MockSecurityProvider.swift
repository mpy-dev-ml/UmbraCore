import Foundation
import SecurityTypes

public actor MockSecurityProvider: SecurityProvider {
    private var permissions: [String: FilePermission] = [:]
    private var bookmarks: [String: [UInt8]] = [:]
    private var accessedPaths: Set<String> = []

    public init() {}

    public func checkPermission(for path: String) -> FilePermission {
        return permissions[path] ?? .readWrite
    }

    public func setPermission(_ permission: FilePermission, for path: String) {
        permissions[path] = permission
    }

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        // Mock implementation - just encode the path
        return Array(path.utf8)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        // Mock implementation - just decode the path
        guard let path = String(bytes: bookmarkData, encoding: .utf8) else {
            throw SecurityError.bookmarkResolutionFailed(reason: "Invalid bookmark data")
        }
        return (path: path, isStale: false)
    }

    public func startAccessing(path: String) async throws -> Bool {
        accessedPaths.insert(path)
        return true
    }

    public func stopAccessing(path: String) async {
        accessedPaths.remove(path)
    }

    public func stopAccessingAllResources() async {
        accessedPaths.removeAll()
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        let success = try await startAccessing(path: path)
        guard success else {
            throw SecurityError.accessDenied(reason: "Access denied to \(path)")
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

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let bookmark = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found for \(identifier)")
        }
        return bookmark
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityError.bookmarkNotFound(reason: "Bookmark not found for \(identifier)")
        }
    }

    public func isAccessing(path: String) async -> Bool {
        return accessedPaths.contains(path)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        // Mock implementation - just check if it can be decoded as a string
        return String(bytes: bookmarkData, encoding: .utf8) != nil
    }

    public func getAccessedPaths() async -> Set<String> {
        return accessedPaths
    }

    public func reset() async {
        permissions.removeAll()
        bookmarks.removeAll()
        accessedPaths.removeAll()
    }
}

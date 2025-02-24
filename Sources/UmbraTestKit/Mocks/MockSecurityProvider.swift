import Core
import Foundation
import SecurityTypes
import SecurityTypes_Protocols

/// Mock implementation of security provider for testing
public actor MockSecurityProvider: SecurityProvider {
    private var bookmarks: [String: [UInt8]]
    private var accessedPaths: Set<String>

    public init() {
        self.bookmarks = [:]
        self.accessedPaths = []
    }

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        guard !bookmarks.keys.contains(path) else {
            throw SecurityTypes.SecurityError.bookmarkError("Bookmark already exists for path: \(path)")
        }
        let bookmark = Array("mock-bookmark-\(path)".utf8)
        bookmarks[path] = bookmark
        return bookmark
    }

    public func resolveBookmark(_ bookmark: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let bookmarkString = String(bytes: bookmark, encoding: .utf8) ?? ""
        guard bookmarkString.hasPrefix("mock-bookmark-") else {
            throw SecurityTypes.SecurityError.bookmarkError("Invalid bookmark format")
        }
        let path = String(bookmarkString.dropFirst("mock-bookmark-".count))
        guard bookmarks[path] == bookmark else {
            throw SecurityTypes.SecurityError.bookmarkError("Bookmark not found for path: \(path)")
        }
        accessedPaths.insert(path)
        return (path: path, isStale: false)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let bookmarkString = String(bytes: bookmarkData, encoding: .utf8) ?? ""
        return bookmarkString.hasPrefix("mock-bookmark-")
    }

    public func startAccessing(path: String) async throws -> Bool {
        accessedPaths.insert(path)
        return true
    }

    public func stopAccessing(path: String) async {
        accessedPaths.remove(path)
    }

    public func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    public func stopAccessingAllResources() async {
        accessedPaths.removeAll()
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        let granted = try await startAccessing(path: path)
        guard granted else {
            throw SecurityTypes.SecurityError.accessError("Failed to access \(path)")
        }
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }

    // MARK: - Bookmark Storage

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let bookmarkData = bookmarks[identifier] else {
            throw SecurityTypes.SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
        }
        return bookmarkData
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityTypes.SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
        }
    }

    // Test helper methods
    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }
}

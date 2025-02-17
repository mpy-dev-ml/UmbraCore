import SecurityTypes

/// Mock implementation of SecurityProvider for testing
public actor MockSecurityProvider: SecurityProvider {
    // MARK: - Properties
    
    /// Mock bookmarks stored in memory
    private var bookmarks: [String: [UInt8]] = [:]
    
    /// Currently accessed paths
    private var accessedPaths: Set<String> = []
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - SecurityProvider Protocol
    
    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        Array("MockBookmark:\(path)".utf8)
    }
    
    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        guard mockBookmark.hasPrefix("MockBookmark:") else {
            throw SecurityError.bookmarkResolutionFailed(reason: "Invalid bookmark format")
        }
        
        let path = String(mockBookmark.dropFirst("MockBookmark:".count))
        return (path, false)
    }
    
    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }
    
    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let bookmarkData = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(path: identifier)
        }
        return bookmarkData
    }
    
    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityError.bookmarkNotFound(path: identifier)
        }
    }
    
    public func startAccessing(path: String) async throws -> Bool {
        if accessedPaths.contains(path) {
            throw SecurityError.accessDenied(reason: "Path already being accessed: \(path)")
        }
        
        accessedPaths.insert(path)
        return true
    }
    
    public func stopAccessing(path: String) async {
        accessedPaths.remove(path)
    }
    
    public func stopAccessingAllResources() async {
        accessedPaths.removeAll()
    }
    
    public func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }
    
    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }
    
    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        return mockBookmark.hasPrefix("MockBookmark:")
    }
    
    public func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        try await startAccessing(path: path)
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }
    
    /// Reset the mock state
    public func reset() async {
        bookmarks.removeAll()
        accessedPaths.removeAll()
    }
}

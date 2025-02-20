import Foundation
import SecurityTypes

/// Mock implementation of SecurityProvider for testing
@MainActor
public final class MockSecurityProvider: SecurityProvider {
    private let securityScope: MockSecurityScope
    private let bookmarkManager: MockBookmarkManager
    public let securityValidator: MockSecurityValidator

    public init() {
        self.securityScope = MockSecurityScope()
        self.bookmarkManager = MockBookmarkManager()
        self.securityValidator = MockSecurityValidator()
    }

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        let data = try await bookmarkManager.createBookmark(for: url)
        return Array(data)
    }

    public func storeBookmarkData(_ bookmarkData: [UInt8], forPath path: String) async throws {
        let data = Data(bookmarkData)
        try await bookmarkManager.storeBookmark(data, for: URL(fileURLWithPath: path))
    }

    public func getBookmarkData(forPath path: String) async throws -> [UInt8] {
        let data = try await bookmarkManager.getBookmark(for: URL(fileURLWithPath: path))
        return Array(data)
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        let url = URL(fileURLWithPath: identifier)
        try await bookmarkManager.deleteBookmark(for: url)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let result = try await bookmarkManager.resolveBookmark(Data(bookmarkData))
        return (path: result.url.path, isStale: result.isStale)
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        let url = URL(fileURLWithPath: path)
        let isValid = try await securityValidator.validateAccess(to: url)
        guard isValid else {
            throw SecurityError.accessDenied(reason: "Access denied to \(path)")
        }

        let success = try await securityScope.startAccessing(url)
        guard success else {
            throw SecurityError.accessDenied(reason: "Failed to start accessing \(path)")
        }

        defer {
            Task {
                try? await securityScope.stopAccessing(url)
            }
        }

        return try await operation()
    }

    public func getAccessedPaths() async -> Set<String> {
        let urls = await securityScope.getAccessedURLs()
        return Set(urls.map { $0.path })
    }

    // MARK: - SecurityProvider Protocol Conformance

    public func startAccessing(path: String) async throws -> Bool {
        return try await securityScope.startAccessing(URL(fileURLWithPath: path))
    }

    public func stopAccessing(path: String) async {
        // We can safely ignore errors in stopAccessing as it's a cleanup operation
        try? await securityScope.stopAccessing(URL(fileURLWithPath: path))
    }

    public func stopAccessingAllResources() async {
        securityScope.reset()
    }

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        let data = Data(bookmarkData)
        try await bookmarkManager.storeBookmark(data, for: URL(fileURLWithPath: identifier))
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        let data = try await bookmarkManager.getBookmark(for: URL(fileURLWithPath: identifier))
        return Array(data)
    }

    public func isAccessing(path: String) async -> Bool {
        await securityScope.isAccessing(URL(fileURLWithPath: path))
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        try await securityValidator.validateBookmark(Data(bookmarkData))
    }

    // MARK: - Control Methods

    /// Set whether security operations should fail
    /// - Parameter shouldFail: true to make operations fail, false otherwise
    public func setShouldFailOperations(_ shouldFail: Bool) {
        bookmarkManager.setShouldFailOperations(shouldFail)
        securityScope.setShouldFailAccess(shouldFail)
        securityValidator.setShouldFailValidation(shouldFail)
    }

    /// Mark a path as having a stale bookmark
    /// - Parameter path: The path to mark as stale
    public func markAsStale(_ path: String) {
        bookmarkManager.markAsStale(path)
    }

    /// Mark a URL as valid for access
    /// - Parameter path: The path to mark as valid
    public func markPathAsValid(_ path: String) {
        let url = URL(fileURLWithPath: path)
        securityValidator.markURLAsValid(url)
    }

    /// Set permissions for a path
    /// - Parameters:
    ///   - permissions: The permissions to set
    ///   - path: The path to set permissions for
    public func setPermissions(_ permissions: Set<SecurityPermission>, forPath path: String) {
        let url = URL(fileURLWithPath: path)
        securityValidator.setPermissions(permissions, for: url)
    }

    /// Reset all mocks to their initial state
    public func reset() {
        bookmarkManager.reset()
        securityScope.reset()
        securityValidator.reset()
    }
}

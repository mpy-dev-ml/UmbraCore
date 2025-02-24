import CryptoTypes_Protocols
import CryptoTypes_Types
import Foundation
import SecurityTypes_Protocols
import SecurityTypes_Types
import Services_SecurityUtils_Protocols
import Services_SecurityUtils_Services

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService: SecurityProvider {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()

    private let bookmarkService: SecurityBookmarkService
    private let encryptedBookmarkService: EncryptedBookmarkService
    private var activeSecurityScopedResources: Set<String> = []
    private var bookmarks: [String: [UInt8]] = [:]

    private init() {
        let config = CryptoConfiguration.default
        let cryptoService = DefaultCryptoServiceImpl()
        self.bookmarkService = SecurityBookmarkService()
        let credentialManager = CredentialManager(
            service: "com.umbracore.security",
            cryptoService: cryptoService,
            config: config
        )
        self.encryptedBookmarkService = EncryptedBookmarkService(
            cryptoService: cryptoService,
            bookmarkService: bookmarkService,
            credentialManager: credentialManager,
            config: config
        )
    }

    // MARK: - Resource Access Control

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        let success = try await bookmarkService.withSecurityScopedAccess(to: url) {
            _ = await MainActor.run {
                activeSecurityScopedResources.insert(path)
            }
            return true
        }
        return success
    }

    public func stopAccessing(path: String) async {
        let url = URL(fileURLWithPath: path)
        do {
            try await bookmarkService.withSecurityScopedAccess(to: url) { url.stopAccessingSecurityScopedResource() }
        } catch {
            // Log error but continue with removal from active resources
            print("Error stopping access to \(path): \(error)")
        }
        activeSecurityScopedResources.remove(path)
    }

    public func stopAccessingAllResources() async {
        for path in activeSecurityScopedResources {
            await stopAccessing(path: path)
        }
    }

    public func isAccessing(path: String) -> Bool {
        activeSecurityScopedResources.contains(path)
    }

    public func getAllAccessedPaths() -> Set<String> {
        activeSecurityScopedResources
    }

    public func getAccessedPaths() async -> Set<String> {
        activeSecurityScopedResources
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        guard try await startAccessing(path: path) else {
            throw SecurityError.accessDenied(reason: "Failed to access: \(path)")
        }
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }

    // MARK: - Bookmark Management

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        let data = try await bookmarkService.createBookmark(for: url)
        return Array(data)
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let data = Data(bookmarkData)
        let result = try await bookmarkService.resolveBookmark(data)
        return (path: result.url.path, isStale: result.isStale)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let data = Data(bookmarkData)
        let result = try await bookmarkService.resolveBookmark(data)
        return !result.isStale
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

    // MARK: - Encrypted Bookmark Management

    public func createEncryptedBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        let identifier = UUID().uuidString
        try await encryptedBookmarkService.saveBookmark(for: url, withIdentifier: identifier)
        return try await loadBookmark(withIdentifier: identifier)
    }

    public func resolveEncryptedBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let identifier = String(decoding: bookmarkData, as: UTF8.self)
        let url = try await encryptedBookmarkService.resolveBookmark(withIdentifier: identifier)
        return (path: url.path, isStale: false)
    }

    public func validateEncryptedBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let identifier = String(decoding: bookmarkData, as: UTF8.self)
        _ = try await encryptedBookmarkService.resolveBookmark(withIdentifier: identifier)
        return true
    }
}

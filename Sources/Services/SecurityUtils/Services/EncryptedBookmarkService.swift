import CryptoTypes
import CryptoTypes_Protocols
import CryptoTypes_Types
import Foundation
import SecurityTypes

/// Service for managing encrypted security-scoped bookmarks
public actor EncryptedBookmarkService {
    private let cryptoService: CryptoServiceProtocol
    private let bookmarkService: SecurityBookmarkService
    private let credentialManager: CredentialManager
    private let config: CryptoConfiguration
    private let bookmarkKeyIdentifier = "bookmark_encryption_key"

    /// Initialises a new encrypted bookmark service
    /// - Parameters:
    ///   - cryptoService: Service for encryption operations
    ///   - bookmarkService: Service for bookmark operations
    ///   - credentialManager: Manager for secure storage
    ///   - config: Crypto configuration to use
    public init(
        cryptoService: CryptoServiceProtocol,
        bookmarkService: SecurityBookmarkService,
        credentialManager: CredentialManager,
        config: CryptoConfiguration = .default
    ) {
        self.cryptoService = cryptoService
        self.bookmarkService = bookmarkService
        self.credentialManager = credentialManager
        self.config = config
    }

    /// Create and save an encrypted bookmark for a URL
    /// - Parameters:
    ///   - url: URL to create bookmark for
    ///   - identifier: Unique identifier for the bookmark
    /// - Throws: SecurityError or CryptoError if bookmark creation fails
    public func saveBookmark(for url: URL, withIdentifier identifier: String) async throws {
        let bookmarkData = try await bookmarkService.createBookmark(for: url)
        let key = try await getOrCreateKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let encryptedData = try await cryptoService.encrypt(bookmarkData, using: key, iv: iv)
        try await credentialManager.save(String(data: encryptedData, encoding: .utf8)!, forIdentifier: identifier)
    }

    /// Resolve an encrypted bookmark
    /// - Parameter identifier: Unique identifier for the bookmark
    /// - Returns: Resolved URL
    /// - Throws: SecurityError or CryptoError if bookmark resolution fails
    public func resolveBookmark(withIdentifier identifier: String) async throws -> URL {
        let encryptedData: Data = try await credentialManager.load(forIdentifier: identifier).data(using: .utf8)!
        let key = try await getKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let bookmarkData = try await cryptoService.decrypt(encryptedData, using: key, iv: iv)
        let (url, _) = try await bookmarkService.resolveBookmark(bookmarkData)
        return url
    }

    /// Delete an encrypted bookmark
    /// - Parameter identifier: Unique identifier for the bookmark to delete
    /// - Throws: SecurityError if deletion fails
    public func deleteBookmark(withIdentifier identifier: String) async throws {
        try await credentialManager.delete(forIdentifier: identifier)
    }

    // MARK: - Private Methods

    private func getOrCreateKey() async throws -> Data {
        if let key = try? await getKey() {
            return key
        }
        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength)
        try await credentialManager.save(String(data: key, encoding: .utf8)!, forIdentifier: bookmarkKeyIdentifier)
        return key
    }

    private func getKey() async throws -> Data {
        let keyString = try await credentialManager.load(forIdentifier: bookmarkKeyIdentifier)
        return keyString.data(using: .utf8)!
    }
}

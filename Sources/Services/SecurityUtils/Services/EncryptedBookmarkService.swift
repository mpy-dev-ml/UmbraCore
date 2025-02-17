import Foundation
import SecurityTypes
import CryptoTypes
import UmbraCrypto

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
    
    /// Creates an encrypted security-scoped bookmark
    /// - Parameters:
    ///   - url: URL to create bookmark for
    ///   - identifier: Unique identifier for the bookmark
    /// - Throws: SecurityError or CryptoError if operations fail
    public func createEncryptedBookmark(for url: URL, identifier: String) async throws {
        let bookmarkData = try await bookmarkService.createBookmark(for: url)
        try await securelyStore(bookmarkData, identifier: identifier)
    }
    
    /// Resolves an encrypted security-scoped bookmark
    /// - Parameter identifier: Identifier of the bookmark to resolve
    /// - Returns: Tuple containing resolved URL and whether bookmark is stale
    /// - Throws: SecurityError or CryptoError if operations fail
    public func resolveEncryptedBookmark(_ identifier: String) async throws -> (url: URL, isStale: Bool) {
        let bookmarkData = try await retrieveSecureData(identifier: identifier)
        return try await bookmarkService.resolveBookmark(bookmarkData)
    }
    
    /// Stores data securely with encryption
    /// - Parameters:
    ///   - data: The data to store
    ///   - identifier: Unique identifier for the stored data
    /// - Throws: CryptoError if encryption fails
    private func securelyStore(_ data: Data, identifier: String) async throws {
        let key = try await getOrCreateBookmarkKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let encrypted = try await cryptoService.encrypt(data, using: key, iv: iv)
        
        try await credentialManager.securelyStore(
            try JSONEncoder().encode(SecureStorageData(encryptedData: encrypted, iv: iv)),
            identifier: bookmarkIdentifier(for: identifier)
        )
    }
    
    /// Retrieves and decrypts previously stored data
    /// - Parameter identifier: Identifier of the data to retrieve
    /// - Returns: The decrypted data
    /// - Throws: CryptoError if decryption fails
    private func retrieveSecureData(identifier: String) async throws -> Data {
        let encodedData = try await credentialManager.retrieveSecureData(
            identifier: bookmarkIdentifier(for: identifier)
        )
        
        let storageData = try JSONDecoder().decode(SecureStorageData.self, from: encodedData)
        guard let key = try await getBookmarkKey() else {
            throw CryptoError.keyNotFound(identifier: bookmarkKeyIdentifier)
        }
        
        return try await cryptoService.decrypt(storageData.encryptedData, using: key, iv: storageData.iv)
    }
    
    /// Removes securely stored data
    /// - Parameter identifier: Identifier of the data to remove
    /// - Throws: CryptoError if removal fails
    public func removeBookmark(identifier: String) async throws {
        try await credentialManager.removeSecureData(identifier: bookmarkIdentifier(for: identifier))
    }
    
    /// Verifies if secure data exists
    /// - Parameter identifier: Identifier to check
    /// - Returns: True if secure data exists for the identifier
    public func hasBookmark(identifier: String) async throws -> Bool {
        try await credentialManager.hasSecureData(identifier: bookmarkIdentifier(for: identifier))
    }
    
    // MARK: - Private Methods
    
    private func getOrCreateBookmarkKey() async throws -> Data {
        if let key = try await getBookmarkKey() {
            return key
        }
        
        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength / 8)
        try await credentialManager.securelyStore(key, identifier: bookmarkKeyIdentifier)
        return key
    }
    
    private func getBookmarkKey() async throws -> Data? {
        try? await credentialManager.retrieveSecureData(identifier: bookmarkKeyIdentifier)
    }
    
    private func bookmarkIdentifier(for identifier: String) -> String {
        "bookmark_\(identifier)"
    }
}

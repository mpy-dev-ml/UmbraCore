import CryptoTypes
import CryptoTypesProtocols
import CryptoTypesTypes
import Foundation
import SecurityTypes
import SecurityUtilsProtocols
import ErrorHandlingDomains

/// Service for managing encrypted security-scoped bookmarks
public actor EncryptedBookmarkService {
  private let cryptoService: CryptoServiceProtocol
  private let bookmarkService: SecurityBookmarkService
  private let credentialManager: SecurityUtilsProtocols.CredentialManager
  private let config: CryptoConfiguration
  private let bookmarkKeyIdentifier="bookmark_encryption_key"

  /// Initialises a new encrypted bookmark service
  /// - Parameters:
  ///   - cryptoService: Service for encryption operations
  ///   - bookmarkService: Service for bookmark operations
  ///   - credentialManager: Manager for secure storage
  ///   - config: Crypto configuration to use
  public init(
    cryptoService: CryptoServiceProtocol,
    bookmarkService: SecurityBookmarkService,
    credentialManager: SecurityUtilsProtocols.CredentialManager,
    config: CryptoConfiguration = .default
  ) {
    self.cryptoService=cryptoService
    self.bookmarkService=bookmarkService
    self.credentialManager=credentialManager
    self.config=config
  }

  /// Create an encrypted security-scoped bookmark for a URL
  /// - Parameter url: URL to create bookmark for
  /// - Returns: Encrypted bookmark data
  /// - Throws: SecurityError or CryptoError if bookmark creation fails
  public func createBookmark(for url: URL) async throws -> Data {
    let bookmarkData=try await bookmarkService.createBookmark(for: url)
    let key=try await generateKey()
    let iv=try await cryptoService.generateSecureRandomKey(length: config.ivLength)
    return try await cryptoService.encrypt(bookmarkData, using: key, iv: iv)
  }

  /// Resolve an encrypted security-scoped bookmark to a URL
  /// - Parameter encryptedData: Encrypted bookmark data
  /// - Returns: Resolved URL
  /// - Throws: SecurityError or CryptoError if bookmark resolution fails
  public func resolveBookmark(_ encryptedData: Data) async throws -> URL {
    let key=try await getKey()
    // Generate a new IV for decryption - this should be stored with the encrypted data in a real
    // implementation
    let iv=try await cryptoService.generateSecureRandomKey(length: config.ivLength)
    let bookmarkData=try await cryptoService.decrypt(encryptedData, using: key, iv: iv)
    return try await bookmarkService.resolveBookmark(bookmarkData)
  }

  /// Resolve an encrypted security-scoped bookmark by identifier
  /// - Parameter identifier: Bookmark identifier
  /// - Returns: Resolved URL
  /// - Throws: SecurityError or CryptoError if bookmark resolution fails
  public func resolveBookmark(withIdentifier identifier: String) async throws -> URL {
    let encryptedData=try await credentialManager.load(forIdentifier: identifier)
    let key=try await getKey()
    // Generate a new IV for decryption - this should be stored with the encrypted data in a real
    // implementation
    let iv=try await cryptoService.generateSecureRandomKey(length: config.ivLength)
    let bookmarkData=try await cryptoService.decrypt(encryptedData, using: key, iv: iv)
    return try await bookmarkService.resolveBookmark(bookmarkData)
  }

  /// Start accessing a security-scoped resource
  /// - Parameter url: URL to access
  /// - Returns: Whether access was started successfully
  public func startAccessing(_ url: URL) async -> Bool {
    url.startAccessingSecurityScopedResource()
  }

  /// Stop accessing a security-scoped resource
  /// - Parameter url: URL to stop accessing
  public func stopAccessing(_ url: URL) async {
    url.stopAccessingSecurityScopedResource()
  }

  private func generateKey() async throws -> Data {
    if let existingKey=try? await getKey() {
      return existingKey
    }
    let key=try await cryptoService.generateSecureRandomKey(length: config.keyLength)
    try await credentialManager.save(key, forIdentifier: bookmarkKeyIdentifier)
    return key
  }

  private func getKey() async throws -> Data {
    try await credentialManager.load(forIdentifier: bookmarkKeyIdentifier)
  }
}

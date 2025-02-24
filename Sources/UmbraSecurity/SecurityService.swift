import Core
import CryptoTypes
import CryptoTypes_Protocols
import CryptoTypes_Services
import CryptoTypes_Types
import Foundation
import SecurityTypes
import SecurityTypes_Protocols
import SecurityTypes_Types
import SecurityUtils_Protocols
import UmbraSecurityUtils

/// A service that manages security-scoped resource access and bookmarks.
/// This service provides functionality for:
/// - Creating and managing encrypted security-scoped bookmarks
/// - Managing access to security-scoped resources
/// - Handling bookmark persistence and resolution
@MainActor
public final class SecurityService: SecurityProvider {
  /// Shared instance of the SecurityService
  public static let shared = SecurityService()

  private let cryptoService: CryptoTypes_Protocols.CryptoServiceProtocol
  private let bookmarkService: UmbraSecurityUtils.SecurityBookmarkService
  private let encryptedBookmarkService: UmbraSecurityUtils.EncryptedBookmarkService
  private var activeSecurityScopedResources: Set<String> = []

  private init() {
    let config = CryptoTypes_Types.CryptoConfiguration.default
    let cryptoService = CryptoTypes_Services.DefaultCryptoServiceImpl()
    let credentialManager = CryptoTypes_Types.CredentialManager(
      service: "com.umbra.security",
      cryptoService: cryptoService,
      config: CryptoTypes_Types.CryptoConfig.default
    )
    self.cryptoService = cryptoService
    self.bookmarkService = UmbraSecurityUtils.SecurityBookmarkService()
    self.encryptedBookmarkService = UmbraSecurityUtils.EncryptedBookmarkService(
      cryptoService: cryptoService,
      bookmarkService: bookmarkService,
      credentialManager: credentialManager,
      config: config
    )
  }

  // MARK: - SecurityProvider Protocol

  /// Creates an encrypted security-scoped bookmark for the specified path.
  /// - Parameter path: The file system path to create a bookmark for
  /// - Returns: A byte array containing the bookmark identifier
  /// - Throws: SecurityError if bookmark creation fails
  public func createBookmark(forPath path: String) async throws -> [UInt8] {
    let url = URL(fileURLWithPath: path)
    let identifier = UUID().uuidString
    try await encryptedBookmarkService.saveBookmark(for: url, withIdentifier: identifier)
    return Array(identifier.utf8)
  }

  /// Resolves an encrypted security-scoped bookmark to its file system path.
  /// - Parameter bookmarkData: The bookmark data to resolve
  /// - Returns: A tuple containing the resolved path and whether the bookmark is stale
  /// - Throws: SecurityError if bookmark resolution fails
  public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
    let identifier = String(decoding: bookmarkData, as: UTF8.self)
    let url = try await encryptedBookmarkService.resolveBookmark(withIdentifier: identifier)
    return (path: url.path, isStale: false)
  }

  /// Validates whether a bookmark can be resolved.
  /// - Parameter bookmarkData: The bookmark data to validate
  /// - Returns: True if the bookmark can be resolved, false otherwise
  /// - Throws: SecurityError if validation fails
  public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
    let identifier = String(decoding: bookmarkData, as: UTF8.self)
    do {
      _ = try await encryptedBookmarkService.resolveBookmark(withIdentifier: identifier)
      return true
    } catch {
      return false
    }
  }

  /// Loads a bookmark by its identifier.
  /// - Parameter identifier: The identifier of the bookmark to load
  /// - Returns: The bookmark data as a byte array
  /// - Throws: SecurityError if bookmark loading fails
  public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
    let url = try await encryptedBookmarkService.resolveBookmark(withIdentifier: identifier)
    let bookmarkData = try await url.createSecurityScopedBookmark()
    return Array(bookmarkData)
  }

  /// Deletes a bookmark with the specified identifier.
  /// - Parameter identifier: The identifier of the bookmark to delete
  /// - Throws: SecurityError if bookmark deletion fails
  public func deleteBookmark(withIdentifier identifier: String) async throws {
    try await encryptedBookmarkService.deleteBookmark(withIdentifier: identifier)
  }

  /// Saves a bookmark with the specified identifier.
  /// - Parameters:
  ///   - bookmarkData: The bookmark data to save
  ///   - identifier: The identifier to associate with the bookmark
  /// - Throws: SecurityError if bookmark saving fails
  public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
    let data = Data(bookmarkData)
    let (url, _) = try await URL.resolveSecurityScopedBookmark(data)
    try await encryptedBookmarkService.saveBookmark(for: url, withIdentifier: identifier)
  }

  // MARK: - Resource Access

  /// Starts accessing a security-scoped resource.
  /// - Parameter path: The path to the resource to access
  /// - Returns: True if access was granted, false otherwise
  /// - Throws: SecurityError if access cannot be granted
  public func startAccessing(path: String) async throws -> Bool {
    let url = URL(fileURLWithPath: path)
    return try url.withSecurityScopedAccess {
      activeSecurityScopedResources.insert(path)
      return true
    }
  }

  /// Stops accessing a security-scoped resource.
  /// - Parameter path: The path to stop accessing
  public func stopAccessing(path: String) async {
    if activeSecurityScopedResources.contains(path) {
      let url = URL(fileURLWithPath: path)
      url.stopAccessingSecurityScopedResource()
      activeSecurityScopedResources.remove(path)
    }
  }

  /// Stops accessing all currently accessed security-scoped resources.
  public func stopAccessingAllResources() async {
    for path in activeSecurityScopedResources {
      await stopAccessing(path: path)
    }
  }

  /// Performs an operation with security-scoped access to a resource.
  /// - Parameters:
  ///   - path: The path to the resource to access
  ///   - operation: The operation to perform while access is granted
  /// - Returns: The result of the operation
  /// - Throws: SecurityError if access cannot be granted
  public func withSecurityScopedAccess<T: Sendable>(
    to path: String,
    perform operation: @Sendable () async throws -> T
  ) async throws -> T {
    guard try await startAccessing(path: path) else {
      throw SecurityTypes.SecurityError.accessDenied(reason: "Failed to access: \(path)")
    }
    defer { Task { await stopAccessing(path: path) } }
    return try await operation()
  }

  /// Checks if a path is currently being accessed.
  /// - Parameter path: The path to check
  /// - Returns: True if the path is being accessed, false otherwise
  public func isAccessing(path: String) async -> Bool {
    activeSecurityScopedResources.contains(path)
  }

  /// Gets all paths that are currently being accessed.
  /// - Returns: A set of paths that are currently being accessed
  public func getAccessedPaths() async -> Set<String> {
    activeSecurityScopedResources
  }
}

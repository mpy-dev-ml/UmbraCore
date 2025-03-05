import CoreServicesTypes
import CoreTypes
import Foundation
import SecurityInterfaces
import SecurityTypes
import SecurityTypesProtocols
import UmbraLogging

/// Manages security operations and access control
public actor SecurityService: UmbraService, CoreTypes.SecurityProviderBase,
SecurityTypesProtocols.SecurityProvider {
  public static let serviceIdentifier="com.umbracore.security"

  private var _state: ServiceState = .uninitialized
  public private(set) nonisolated(unsafe) var state: ServiceState = .uninitialized

  private let container: ServiceContainer
  private var cryptoService: CryptoService?
  private var accessedPaths: Set<String>
  private var bookmarks: [String: [UInt8]]

  /// Initialize security service
  /// - Parameter container: Service container for dependencies
  public init(container: ServiceContainer) {
    self.container=container
    accessedPaths=[]
    bookmarks=[:]
  }

  /// Initialize the service
  public func initialize() async throws {
    guard _state == .uninitialized else {
      throw ServiceError.configurationError("Service already initialized")
    }

    state = .initializing
    _state = .initializing

    // Resolve dependencies
    cryptoService=try await container.resolve(CryptoService.self)

    _state = .ready
    state = .ready
  }

  /// Gracefully shut down the service
  public func shutdown() async {
    if _state == .ready {
      state = .shuttingDown
      _state = .shuttingDown

      // Stop accessing all paths
      await stopAccessingAllResources()

      // Shutdown crypto service
      if let crypto=cryptoService {
        await crypto.shutdown()
        cryptoService=nil
      }

      state = .uninitialized
      _state = .uninitialized
    }
  }

  // MARK: - SecurityProviderBase Implementation (Foundation-free)

  public func createBookmark(forPath path: String) async throws -> [UInt8] {
    let url=URL(fileURLWithPath: path)
    do {
      let bookmarkData=try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      return Array(bookmarkData)
    } catch {
      throw SecurityError
        .bookmarkError("Failed to create bookmark for \(path): \(error.localizedDescription)")
    }
  }

  public func resolveBookmark(_ bookmarkData: [UInt8]) async throws
  -> (path: String, isStale: Bool) {
    let data=Data(bookmarkData)
    var isStale=false

    do {
      let url=try URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return (url.path, isStale)
    } catch {
      throw SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
    }
  }

  public func startAccessing(path: String) async throws -> Bool {
    let url=URL(fileURLWithPath: path)
    if url.startAccessingSecurityScopedResource() {
      accessedPaths.insert(path)
      return true
    } else {
      throw SecurityError.accessError("Failed to access: \(path)")
    }
  }

  public func stopAccessing(path: String) async {
    let url=URL(fileURLWithPath: path)
    url.stopAccessingSecurityScopedResource()
    accessedPaths.remove(path)
  }

  // Foundation-free credential methods
  public func storeCredential(
    data: [UInt8],
    account: String,
    service: String,
    metadata _: [String: String]?
  ) async throws -> String {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Just store a basic implementation for now
    let key="\(account).\(service)"
    bookmarks[key]=data
    return key
  }

  public func loadCredential(
    account: String,
    service: String
  ) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    let key="\(account).\(service)"
    guard let data=bookmarks[key] else {
      throw SecurityError.itemNotFound
    }

    return data
  }

  public func loadCredentialWithMetadata(
    account: String,
    service: String
  ) async throws -> ([UInt8], [String: String]?) {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    let key="\(account).\(service)"
    guard let data=bookmarks[key] else {
      throw SecurityError.itemNotFound
    }

    // For now, we don't have metadata in our simple implementation
    return (data, nil)
  }

  public func deleteCredential(
    account: String,
    service: String
  ) async throws {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    let key="\(account).\(service)"
    guard bookmarks.removeValue(forKey: key) != nil else {
      throw SecurityError.itemNotFound
    }
  }

  public func generateRandomBytes(count: Int) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    if let crypto=cryptoService {
      // Use crypto service if available
      let data=try await crypto.generateSecureRandomBytes(length: count)
      return Array(data)
    } else {
      // Fallback implementation using SecRandomCopyBytes
      var bytes=[UInt8](repeating: 0, count: count)
      let status=SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

      guard status == errSecSuccess else {
        throw SecurityError.randomGenerationFailed
      }

      return bytes
    }
  }

  // For backward compatibility
  public func generateRandomBytes(length: Int) async throws -> [UInt8] {
    try await generateRandomBytes(count: length)
  }

  // MARK: - SecurityProvider Implementation (Foundation-dependent)

  public func createBookmark(for url: URL) async throws -> Data {
    do {
      return try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
    } catch {
      throw SecurityError
        .bookmarkError("Failed to create bookmark for \(url.path): \(error.localizedDescription)")
    }
  }

  public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
    var isStale=false

    do {
      let url=try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return (url, isStale)
    } catch {
      throw SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
    }
  }

  public func startAccessing(url: URL) async throws -> Bool {
    if url.startAccessingSecurityScopedResource() {
      accessedPaths.insert(url.path)
      return true
    } else {
      throw SecurityError.accessError("Failed to access: \(url.path)")
    }
  }

  public func stopAccessing(url: URL) async {
    url.stopAccessingSecurityScopedResource()
    accessedPaths.remove(url.path)
  }

  public func isAccessing(url: URL) async -> Bool {
    accessedPaths.contains(url.path)
  }

  public func getAccessedUrls() async -> Set<URL> {
    Set(accessedPaths.map { URL(fileURLWithPath: $0) })
  }

  public func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
    do {
      var isStale=false
      _=try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return !isStale
    } catch {
      return false
    }
  }

  public func saveBookmark(_ bookmarkData: Data, withIdentifier identifier: String) async throws {
    bookmarks[identifier]=Array(bookmarkData)
  }

  public func loadBookmark(withIdentifier identifier: String) async throws -> Data {
    guard let bookmark=bookmarks[identifier] else {
      throw SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
    }
    return Data(bookmark)
  }

  public func deleteBookmark(withIdentifier identifier: String) async throws {
    guard bookmarks.removeValue(forKey: identifier) != nil else {
      throw SecurityError.bookmarkError("No bookmark found for identifier: \(identifier)")
    }
  }

  public func storeCredential(
    data: Data,
    account: String,
    service: String,
    metadata _: [String: String]?
  ) async throws -> String {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Simple implementation for now
    let key="\(account).\(service)"
    bookmarks[key]=Array(data)
    return key
  }

  public func loadCredential(
    account: String,
    service: String
  ) async throws -> Data {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    let key="\(account).\(service)"
    guard let data=bookmarks[key] else {
      throw SecurityError.itemNotFound
    }

    return Data(data)
  }

  public func loadCredentialWithMetadata(
    account: String,
    service: String
  ) async throws -> (Data, [String: String]?) {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    let key="\(account).\(service)"
    guard let data=bookmarks[key] else {
      throw SecurityError.itemNotFound
    }

    // We don't have metadata in our simple implementation
    return (Data(data), nil)
  }

  public func generateRandomBytes(length: Int) async throws -> Data {
    let bytes=try await generateRandomBytes(count: length)
    return Data(bytes)
  }

  public func withSecurityScopedAccess<T: Sendable>(
    to path: String,
    perform operation: @Sendable () async throws -> T
  ) async throws -> T {
    let accessGranted=try await startAccessing(path: path)
    guard accessGranted else {
      throw SecurityError.accessError("Access denied to: \(path)")
    }

    defer { Task { await stopAccessing(path: path) } }
    return try await operation()
  }

  public func stopAccessingAllResources() async {
    for path in accessedPaths {
      await stopAccessing(path: path)
    }
  }

  public func isAccessing(path: String) async -> Bool {
    accessedPaths.contains(path)
  }

  public func getAccessedPaths() async -> Set<String> {
    accessedPaths
  }

  // MARK: - SecurityProvider Protocol Implementation

  /// Create a security-scoped bookmark for a URL
  /// - Parameter url: The URL to create a bookmark for
  /// - Returns: The bookmark data
  /// - Throws: Error if bookmark creation fails
  public nonisolated func createSecurityBookmark(for url: URL) throws -> Data {
    // Since this is nonisolated, we can't access actor state directly
    do {
      let bookmarkData=try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      return bookmarkData
    } catch {
      throw SecurityInterfaces.SecurityError.bookmarkError(
        "Failed to create security bookmark: \(error.localizedDescription)"
      )
    }
  }

  /// Resolve a security-scoped bookmark to a URL
  /// - Parameter bookmarkData: The bookmark data to resolve
  /// - Returns: The resolved URL
  /// - Throws: Error if bookmark resolution fails
  public nonisolated func resolveSecurityBookmark(_ bookmarkData: Data) throws -> URL {
    // Since this is nonisolated, we can't access actor state directly
    var isStale=false
    do {
      let url=try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      if isStale {
        // Log that the bookmark is stale but still try to use it
        // We can't access the logger directly in a nonisolated context
        // This would ideally be handled by a proper logging mechanism
        print("Warning: Security bookmark is stale and may need to be recreated")
      }

      return url
    } catch {
      throw SecurityInterfaces.SecurityError.bookmarkError(
        "Failed to resolve security bookmark: \(error.localizedDescription)"
      )
    }
  }

  // MARK: - SecurityInterfacesCore.SecurityProviderBase Implementation

  public func resetSecurityData() async throws {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    bookmarks=[:]
    accessedPaths=[]
  }

  public func getHostIdentifier() async throws -> String {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Generate a unique identifier for this host
    let hostName=Host.current().name ?? "unknown-host"
    return "\(hostName)-\(UUID().uuidString)"
  }

  public func registerClient(bundleIdentifier _: String) async throws -> Bool {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Simple implementation - always return true for now
    return true
  }

  public func requestKeyRotation(keyId _: String) async throws {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Implementation would request key rotation from a key management service
    // For now, just validate the service is ready
  }

  public func notifyKeyCompromise(keyId _: String) async throws {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Implementation would notify about a compromised key
    // For now, just validate the service is ready
  }

  // MARK: - SecurityProvider Implementation (Encryption/Decryption)

  public func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    if let crypto=cryptoService {
      do {
        let result=try await crypto.encrypt(data, using: key)

        // Combine all parts into a single byte array
        var combined=[UInt8]()
        combined.append(contentsOf: result.initializationVector)
        combined.append(contentsOf: result.tag)
        combined.append(contentsOf: result.encrypted)

        return combined
      } catch {
        throw SecurityError.cryptoError("Encryption failed: \(error.localizedDescription)")
      }
    } else {
      throw SecurityError.operationFailed("Encryption not available without CryptoService")
    }
  }

  public func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    if let crypto=cryptoService {
      // Extract IV, tag, and encrypted data from the combined data
      // Assuming IV is 12 bytes and tag is 16 bytes (standard for AES-GCM)
      let ivLength=12
      let tagLength=16

      guard data.count > ivLength + tagLength else {
        throw SecurityError.cryptoError("Invalid encrypted data format")
      }

      let iv=Array(data.prefix(ivLength))
      let tag=Array(data[ivLength..<(ivLength + tagLength)])
      let encrypted=Array(data.suffix(from: ivLength + tagLength))

      let encryptionResult=EncryptionResult(
        encrypted: encrypted,
        initializationVector: iv,
        tag: tag
      )

      do {
        return try await crypto.decrypt(encryptionResult, using: key)
      } catch {
        throw SecurityError.cryptoError("Decryption failed: \(error.localizedDescription)")
      }
    } else {
      throw SecurityError.operationFailed("Decryption not available without CryptoService")
    }
  }

  public func generateKey(length: Int) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    return try await generateRandomBytes(count: length)
  }

  public func hash(_ data: [UInt8]) async throws -> [UInt8] {
    guard state == .ready else {
      throw ServiceError.invalidState("Security service not initialized")
    }

    // Since we don't have a direct hash function in CryptoService,
    // we'll implement a basic hash using a key derivation function
    if let crypto=cryptoService {
      do {
        // Convert data to a hex string for the password parameter
        let hexString=data.map { String(format: "%02x", $0) }.joined()

        // Use a fixed salt for hashing
        let salt=Array("UmbraSecurityHash".utf8)

        // Use the string-based deriveKey method
        return try await crypto.deriveKey(from: hexString, salt: salt)
      } catch {
        throw SecurityError.cryptoError("Hashing failed: \(error.localizedDescription)")
      }
    } else {
      throw SecurityError.operationFailed("Hashing not available without CryptoService")
    }
  }

  // MARK: - Foundation Data Methods

  public func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation
  .Data {
    let result=try await encrypt([UInt8](data), key: [UInt8](key))
    return Data(result)
  }

  public func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation
  .Data {
    let result=try await decrypt([UInt8](data), key: [UInt8](key))
    return Data(result)
  }

  public func generateDataKey(length: Int) async throws -> Foundation.Data {
    let result=try await generateKey(length: length)
    return Data(result)
  }

  public func hashData(_ data: Foundation.Data) async throws -> Foundation.Data {
    let result=try await hash([UInt8](data))
    return Data(result)
  }
}

import Core
import Foundation
import SecurityInterfaces
import SecurityTypes
import SecurityTypesProtocols
import ErrorHandlingDomains

/// Mock implementation of URL security provider
public actor MockURLProvider: SecurityInterfaces.SecurityProvider {
  private var bookmarks: [String: [UInt8]]
  private var accessedPaths: Set<String>

  public init() {
    bookmarks=[:]
    accessedPaths=[]
  }

  public func createBookmark(forPath path: String) async throws -> [UInt8] {
    guard !bookmarks.keys.contains(path) else {
      throw SecurityInterfaces.SecurityError
        .bookmarkError("Bookmark already exists for path: \(path)")
    }
    let bookmark=Array("mock-bookmark-\(path)".utf8)
    bookmarks[path]=bookmark
    return bookmark
  }

  public func resolveBookmark(_ bookmark: [UInt8]) async throws -> (path: String, isStale: Bool) {
    let bookmarkString=String(bytes: bookmark, encoding: .utf8) ?? ""
    guard bookmarkString.hasPrefix("mock-bookmark-") else {
      throw SecurityInterfaces.SecurityError.bookmarkError("Invalid bookmark format")
    }
    let path=String(bookmarkString.dropFirst("mock-bookmark-".count))
    guard bookmarks[path] == bookmark else {
      throw SecurityInterfaces.SecurityError.bookmarkError("Bookmark not found for path: \(path)")
    }
    accessedPaths.insert(path)
    return (path: path, isStale: false)
  }

  public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
    let bookmarkString=String(bytes: bookmarkData, encoding: .utf8) ?? ""
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
    let granted=try await startAccessing(path: path)
    guard granted else {
      throw SecurityInterfaces.SecurityError.accessError("Failed to access \(path)")
    }
    defer { Task { await stopAccessing(path: path) } }
    return try await operation()
  }

  // MARK: - Bookmark Storage

  public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
    guard let bookmarkData=bookmarks[identifier] else {
      throw SecurityInterfaces.SecurityError
        .bookmarkError("Bookmark not found for identifier: \(identifier)")
    }
    return bookmarkData
  }

  public func deleteBookmark(withIdentifier identifier: String) async throws {
    guard bookmarks.removeValue(forKey: identifier) != nil else {
      throw SecurityInterfaces.SecurityError
        .bookmarkError("Bookmark not found for identifier: \(identifier)")
    }
  }

  public func saveBookmark(
    _ bookmarkData: [UInt8],
    withIdentifier identifier: String
  ) async throws {
    bookmarks[identifier]=bookmarkData
  }

  // Test helper methods
  public func getAccessedPaths() async -> Set<String> {
    accessedPaths
  }

  // MARK: - SecurityProvider Protocol Conformance

  public func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
    guard !key.isEmpty else {
      throw SecurityInterfaces.SecurityError.operationFailed("Empty encryption key")
    }

    var result=[UInt8](repeating: 0, count: data.count)
    for i in 0..<data.count {
      let keyByte=key[i % key.count]
      let dataByte=data[i]
      result[i]=dataByte ^ keyByte
    }

    return result
  }

  public func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
    // XOR encryption/decryption is symmetric, so we can reuse the same method
    try await encrypt(data, key: key)
  }

  public func generateKey(length: Int) async throws -> [UInt8] {
    guard length > 0 else {
      throw SecurityInterfaces.SecurityError.operationFailed("Invalid key length")
    }

    // Simple mock implementation - not cryptographically secure
    var key=[UInt8](repeating: 0, count: length)
    for i in 0..<length {
      key[i]=UInt8.random(in: 0...255)
    }
    return key
  }

  public func hash(_ data: [UInt8]) async throws -> [UInt8] {
    // Simple mock hash implementation
    var hash: UInt64=14_695_981_039_346_656_037 // FNV offset basis
    for byte in data {
      hash=hash ^ UInt64(byte)
      hash=hash &* 1_099_511_628_211 // FNV prime
    }

    var result=[UInt8](repeating: 0, count: 8)
    for i in 0..<8 {
      result[i]=UInt8((hash >> (8 * i)) & 0xFF)
    }
    return result
  }

  // MARK: - SecurityProviderBase Protocol Conformance

  public func resetSecurityData() async throws {
    bookmarks.removeAll()
    accessedPaths.removeAll()
  }

  public func getHostIdentifier() async throws -> String {
    "mock-host-identifier"
  }

  public func registerClient(bundleIdentifier _: String) async throws -> Bool {
    true
  }

  public func requestKeyRotation(keyId _: String) async throws {
    // Mock implementation - no-op
  }

  public func notifyKeyCompromise(keyId _: String) async throws {
    // Mock implementation - no-op
  }
}

import Foundation
import SecurityInterfaces
import SecurityTypesProtocols

/// Mock implementation of security provider for testing
public actor MockSecurityProvider: SecurityProvider {
  private var bookmarks: [String: [UInt8]]
  private var accessedPaths: Set<String>

  public init() {
    bookmarks=[:]
    accessedPaths=[]
  }

  public func createBookmark(forPath path: String) async throws -> [UInt8] {
    guard !bookmarks.keys.contains(path) else {
      throw SecurityError.bookmarkError("Bookmark already exists for path: \(path)")
    }
    let bookmark=Array("mock-bookmark-\(path)".utf8)
    bookmarks[path]=bookmark
    return bookmark
  }

  public func resolveBookmark(_ bookmark: [UInt8]) async throws -> (path: String, isStale: Bool) {
    let bookmarkString=String(bytes: bookmark, encoding: .utf8) ?? ""
    guard bookmarkString.hasPrefix("mock-bookmark-") else {
      throw SecurityError.bookmarkError("Invalid bookmark format")
    }
    let path=String(bookmarkString.dropFirst("mock-bookmark-".count))
    guard bookmarks[path] == bookmark else {
      throw SecurityError.bookmarkError("Bookmark not found for path: \(path)")
    }
    accessedPaths.insert(path)
    return (path, false)
  }

  public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
    let bookmarkString=String(bytes: bookmarkData, encoding: .utf8) ?? ""
    return bookmarkString.hasPrefix("mock-bookmark-")
  }

  public func startAccessing(path: String) async throws -> Bool {
    guard !path.isEmpty else {
      throw SecurityError.invalidData(reason: "Empty path")
    }
    accessedPaths.insert(path)
    return true
  }

  public func stopAccessing(path: String) async {
    accessedPaths.remove(path)
  }

  public func isAccessing(path: String) async -> Bool {
    accessedPaths.contains(path)
  }

  public func getAccessedPaths() async -> Set<String> {
    accessedPaths
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
      throw SecurityError.accessError("Failed to access \(path)")
    }
    defer { Task { await stopAccessing(path: path) } }
    return try await operation()
  }

  // MARK: - Bookmark Storage

  public func saveBookmark(
    _ bookmarkData: [UInt8],
    withIdentifier identifier: String
  ) async throws {
    bookmarks[identifier]=bookmarkData
  }

  public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
    guard let bookmarkData=bookmarks[identifier] else {
      throw SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
    }
    return bookmarkData
  }

  public func deleteBookmark(withIdentifier identifier: String) async throws {
    guard bookmarks.removeValue(forKey: identifier) != nil else {
      throw SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
    }
  }

  // MARK: - Encryption

  public func encrypt(data: Data, key: String) async throws -> Data {
    guard !key.isEmpty else {
      throw SecurityError.cryptoError("Empty encryption key")
    }

    guard let keyData=key.data(using: .utf8) else {
      throw SecurityError.cryptoError("Invalid key encoding")
    }

    return try xorCrypt(data: data, key: keyData)
  }

  public func decrypt(data: Data, key: String) async throws -> Data {
    guard !key.isEmpty else {
      throw SecurityError.cryptoError("Empty decryption key")
    }

    guard let keyData=key.data(using: .utf8) else {
      throw SecurityError.cryptoError("Invalid key encoding")
    }

    return try xorCrypt(data: data, key: keyData)
  }

  public func encrypt(data: Data, key: Data) async throws -> Data {
    guard !key.isEmpty else {
      throw SecurityError.cryptoError("Empty encryption key")
    }

    return try xorCrypt(data: data, key: key)
  }

  public func decrypt(data: Data, key: Data) async throws -> Data {
    guard !key.isEmpty else {
      throw SecurityError.cryptoError("Empty decryption key")
    }

    return try xorCrypt(data: data, key: key)
  }

  // MARK: - Private Helpers

  private func xorCrypt(data: Data, key: Data) throws -> Data {
    guard !key.isEmpty else {
      throw SecurityError.cryptoError("Empty key")
    }

    var result=Data(count: data.count)
    for i in 0..<data.count {
      let keyByte=key[i % key.count]
      let dataByte=data[i]
      result[i]=dataByte ^ keyByte
    }

    return result
  }
}

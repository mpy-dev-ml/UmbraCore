import Core
import ErrorHandlingDomains
import SecurityInterfaces
import XCTest

/// A mock security provider for testing
actor TestMockSecurityProvider: SecurityProvider {
  private var bookmarks: [String: Data]=[:]
  private var accessCount: [String: Int]=[:]
  private var shouldFailBookmarkCreation=false
  private var shouldFailAccess=false
  private var accessedPaths: Set<String>=[]
  private var storedBookmarks: [String: [UInt8]]=[:]

  // MARK: - SecurityProvider Implementation

  /// Encrypt data using a simple mock implementation
  func encrypt(_ data: [UInt8], key _: [UInt8]) async throws -> [UInt8] {
    // Mock implementation just returns the data for testing
    data
  }

  /// Decrypt data using a simple mock implementation
  func decrypt(_ data: [UInt8], key _: [UInt8]) async throws -> [UInt8] {
    // Mock implementation just returns the data for testing
    data
  }

  /// Generate a mock key
  func generateKey(length: Int) async throws -> [UInt8] {
    // Mock implementation just returns array of zeros
    [UInt8](repeating: 0, count: length)
  }

  /// Mock hash function
  func hash(_ data: [UInt8]) async throws -> [UInt8] {
    // Mock implementation just returns first 32 bytes or pads with zeros
    if data.count >= 32 {
      return Array(data.prefix(32))
    } else {
      var result=data
      result.append(contentsOf: [UInt8](repeating: 0, count: 32 - data.count))
      return result
    }
  }

  // MARK: - SecurityProviderBase Implementation

  /// Reset all security data
  func resetSecurityData() async throws {
    bookmarks.removeAll()
    accessCount.removeAll()
    accessedPaths.removeAll()
    storedBookmarks.removeAll()
  }

  /// Get the host identifier
  func getHostIdentifier() async throws -> String {
    "mock-host-identifier"
  }

  /// Register a client application
  func registerClient(bundleIdentifier _: String) async throws -> Bool {
    true
  }

  /// Request key rotation - mock implementation
  func requestKeyRotation(keyId _: String) async throws {
    // No-op for mock
  }

  /// Notify about a potentially compromised key - mock implementation
  func notifyKeyCompromise(keyId _: String) async throws {
    // No-op for mock
  }

  // MARK: - Original Implementation

  func createBookmark(forPath path: String) async throws -> [UInt8] {
    if shouldFailBookmarkCreation {
      throw SecurityInterfaces.SecurityError.accessError("Mock failure")
    }
    let bookmarkData=Data("mock_bookmark_\(path)".utf8)
    bookmarks[path]=bookmarkData
    return Array(bookmarkData)
  }

  func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
    guard let mockPath=String(data: Data(bookmarkData), encoding: .utf8) else {
      throw SecurityInterfaces.SecurityError.accessError("Invalid bookmark data")
    }
    let path=mockPath.replacingOccurrences(of: "mock_bookmark_", with: "")
    if shouldFailAccess {
      throw SecurityInterfaces.SecurityError.accessError("Mock access denied")
    }
    accessCount[path, default: 0] += 1
    return (path: path, isStale: false)
  }

  func startAccessing(path: String) async throws -> Bool {
    if shouldFailAccess {
      throw SecurityInterfaces.SecurityError.accessError("Mock access denied")
    }
    accessedPaths.insert(path)
    return true
  }

  func stopAccessing(path: String) async {
    accessedPaths.remove(path)
  }

  func stopAccessingAllResources() async {
    accessedPaths.removeAll()
  }

  func withSecurityScopedAccess<T: Sendable>(
    to path: String,
    perform operation: @Sendable () async throws -> T
  ) async throws -> T {
    if shouldFailAccess {
      throw SecurityInterfaces.SecurityError.accessError("Mock access denied")
    }
    accessedPaths.insert(path)
    defer { accessedPaths.remove(path) }
    return try await operation()
  }

  func isAccessing(path: String) async -> Bool {
    accessedPaths.contains(path)
  }

  func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
    guard let mockPath=String(data: Data(bookmarkData), encoding: .utf8) else {
      return false
    }
    return mockPath.hasPrefix("mock_bookmark_")
  }

  func getAccessedPaths() async -> Set<String> {
    accessedPaths
  }

  func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
    if shouldFailAccess {
      throw SecurityInterfaces.SecurityError.accessError("Mock storage failure")
    }
    storedBookmarks[identifier]=bookmarkData
  }

  func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
    guard let bookmark=storedBookmarks[identifier] else {
      throw SecurityInterfaces.SecurityError.accessError("Bookmark not found: \(identifier)")
    }
    return bookmark
  }

  func deleteBookmark(withIdentifier identifier: String) async throws {
    if shouldFailAccess {
      throw SecurityInterfaces.SecurityError.accessError("Mock storage failure")
    }
    guard storedBookmarks.removeValue(forKey: identifier) != nil else {
      throw SecurityInterfaces.SecurityError.accessError("Bookmark not found: \(identifier)")
    }
  }

  // Test helper methods
  func setBookmarkCreationFailure(_ shouldFail: Bool) {
    shouldFailBookmarkCreation=shouldFail
  }

  func setAccessFailure(_ shouldFail: Bool) {
    shouldFailAccess=shouldFail
  }

  func getAccessCount(for path: String) async -> Int {
    accessCount[path] ?? 0
  }
}

@MainActor
final class MockSecurityProviderTests: XCTestCase {
  private var provider: TestMockSecurityProvider!

  override func setUp() async throws {
    provider=TestMockSecurityProvider()
  }

  override func tearDown() async throws {
    provider=nil
  }

  func testSuccessfulBookmarkCreation() async throws {
    let testPath="/test/path"
    let bookmark=try await provider.createBookmark(forPath: testPath)
    XCTAssertFalse(bookmark.isEmpty)

    let (resolvedPath, isStale)=try await provider.resolveBookmark(bookmark)
    XCTAssertEqual(resolvedPath, testPath)
    XCTAssertFalse(isStale)
  }

  func testFailedBookmarkCreation() async throws {
    let testPath="/test/path"
    await provider.setBookmarkCreationFailure(true)

    do {
      _=try await provider.createBookmark(forPath: testPath)
      XCTFail("Expected bookmark creation to fail")
    } catch let error as SecurityInterfaces.SecurityError {
      XCTAssertTrue(error.errorDescription?.contains("Mock failure") ?? false)
    }
  }

  func testFailedAccess() async throws {
    let testPath="/test/path"
    let bookmark=try await provider.createBookmark(forPath: testPath)

    await provider.setAccessFailure(true)

    do {
      _=try await provider.resolveBookmark(bookmark)
      XCTFail("Expected access to fail")
    } catch let error as SecurityInterfaces.SecurityError {
      XCTAssertTrue(error.errorDescription?.contains("Mock access denied") ?? false)
    }
  }

  func testAccessCounting() async throws {
    let testPath="/test/path"
    let bookmark=try await provider.createBookmark(forPath: testPath)

    // First access
    _=try await provider.resolveBookmark(bookmark)
    let count1=await provider.getAccessCount(for: testPath)
    XCTAssertEqual(count1, 1)

    // Second access
    _=try await provider.resolveBookmark(bookmark)
    let count2=await provider.getAccessCount(for: testPath)
    XCTAssertEqual(count2, 2)
  }

  func testSecurityScopedAccess() async throws {
    let testPath="/test/path"

    // Test starting access
    let success=try await provider.startAccessing(path: testPath)
    XCTAssertTrue(success)

    let isAccessing=await provider.isAccessing(path: testPath)
    XCTAssertTrue(isAccessing)

    // Test stopping access
    await provider.stopAccessing(path: testPath)
    let isStopped=await provider.isAccessing(path: testPath)
    XCTAssertFalse(isStopped)
  }

  func testWithSecurityScopedAccess() async throws {
    let testPath="/test/path"
    var didRunOperation=false

    // Modified approach with a simple atomic wrapper
    let result=try await provider.withSecurityScopedAccess(to: testPath) {
      // Using a completion handler to make it Sendable-compatible
      Task { @MainActor in
        didRunOperation=true
      }
      return "test_result"
    }

    // Allow the Task to complete
    await Task.yield()

    XCTAssertTrue(didRunOperation)
    XCTAssertEqual(result, "test_result")

    // Access should be released after operation completes
    let isAccessing=await provider.isAccessing(path: testPath)
    XCTAssertFalse(isAccessing)
  }

  func testSaveAndLoadBookmark() async throws {
    let testPath="/test/path"
    let bookmark=try await provider.createBookmark(forPath: testPath)

    try await provider.saveBookmark(bookmark, withIdentifier: "test")

    let loadedBookmark=try await provider.loadBookmark(withIdentifier: "test")
    XCTAssertEqual(loadedBookmark, bookmark)
  }

  func testDeleteBookmark() async throws {
    let testPath="/test/path"
    let bookmark=try await provider.createBookmark(forPath: testPath)

    try await provider.saveBookmark(bookmark, withIdentifier: "test")
    try await provider.deleteBookmark(withIdentifier: "test")

    do {
      _=try await provider.loadBookmark(withIdentifier: "test")
      XCTFail("Expected bookmark not found error")
    } catch let error as SecurityInterfaces.SecurityError {
      XCTAssertTrue(error.errorDescription?.contains("Bookmark not found") ?? false)
    }
  }

  func testEncryptDecrypt() async throws {
    let testData: [UInt8]=[1, 2, 3, 4, 5]
    let key: [UInt8]=[10, 20, 30]

    let encrypted=try await provider.encrypt(testData, key: key)
    let decrypted=try await provider.decrypt(encrypted, key: key)

    XCTAssertEqual(decrypted, testData)
  }

  func testGenerateKey() async throws {
    let key=try await provider.generateKey(length: 32)

    XCTAssertEqual(key.count, 32)
    XCTAssertEqual(key, [UInt8](repeating: 0, count: 32))
  }

  func testHash() async throws {
    let testData: [UInt8]=[1, 2, 3, 4, 5]
    let hash=try await provider.hash(testData)

    // Hash length should be 32
    XCTAssertEqual(hash.count, 32)

    // First part should match our data
    let hashPrefix=Array(hash.prefix(testData.count))
    XCTAssertEqual(hashPrefix, testData)

    // Rest should be zeros
    let hashSuffix=Array(hash.suffix(hash.count - testData.count))
    XCTAssertEqual(hashSuffix, [UInt8](repeating: 0, count: hash.count - testData.count))
  }
}

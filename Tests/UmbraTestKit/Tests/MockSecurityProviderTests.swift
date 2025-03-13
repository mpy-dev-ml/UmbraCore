import Core
import ErrorHandlingDomains
import SecurityInterfaces
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

/// A mock security provider for testing
@preconcurrency
actor TestMockSecurityProvider: SecurityProvider, @unchecked Sendable {
    private var bookmarks: [String: Data] = [:]
    private var accessCount: [String: Int] = [:]
    private var shouldFailBookmarkCreation = false
    private var shouldFailAccess = false
    private var accessedPaths: Set<String> = []
    private var storedBookmarks: [String: [UInt8]] = [:]
    
    // Required properties for SecurityProvider protocol
    public let cryptoService: SecurityProtocolsCore.CryptoServiceProtocol = MockCryptoService()
    public let keyManager: SecurityProtocolsCore.KeyManagementProtocol = MockKeyManagementServiceImpl()
    
    // MARK: - SecurityProvider Implementation
    
    // Additional required protocol methods
    public func getSecurityConfiguration() async -> Result<SecurityInterfaces.SecurityConfiguration, SecurityInterfaces.SecurityInterfacesError> {
        return .success(SecurityInterfaces.SecurityConfiguration(
            securityLevel: .standard,
            encryptionAlgorithm: "AES-256",
            hashAlgorithm: "SHA-256",
            options: [:]
        ))
    }
    
    public func updateSecurityConfiguration(_ configuration: SecurityInterfaces.SecurityConfiguration) async throws {
        // Just a mock implementation
    }
    
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: length)))
    }
    
    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfaces.SecurityInterfacesError> {
        let info: [String: AnyObject] = [
            "algorithm": "AES-256" as NSString,
            "keySize": 256 as NSNumber,
            "created": Date() as NSDate
        ]
        return .success(info)
    }
    
    public func registerNotifications() async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }
    
    // New protocol methods
    public func randomBytes(count: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: count)))
    }
    
    public func encryptData(_ data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(data) // Mock just returns the same data
    }
    
    public func decryptData(_ data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(data) // Mock just returns the same data
    }
    
    public func performSecurityOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        return SecurityInterfaces.SecurityResult(success: true)
    }
    
    public func performSecurityOperation(
        operationName: String,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        return SecurityInterfaces.SecurityResult(success: true)
    }
    
    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        return SecurityProtocolsCore.SecurityResultDTO(success: true)
    }
    
    // Must be nonisolated to conform to protocol
    nonisolated public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        return SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: "AES-256",
            keySizeInBits: 256,
            initializationVector: nil,
            additionalAuthenticatedData: nil,
            iterations: nil,
            options: [:],
            keyIdentifier: nil,
            inputData: nil,
            key: nil,
            additionalData: nil
        )
    }
    
    /// Encrypt data using a simple mock implementation
    func encrypt(_ data: [UInt8], key _: [UInt8]) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        return .success(data)
    }

    /// Decrypt data using a simple mock implementation
    func decrypt(_ data: [UInt8], key _: [UInt8]) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        return .success(data)
    }

    /// Generate a mock key
    func generateKey(length: Int) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        // Mock implementation just returns array of zeros
        return .success([UInt8](repeating: 0, count: length))
    }

    /// Mock hash function
    func hash(_ data: [UInt8]) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        // Mock implementation just returns first 32 bytes or pads with zeros
        if data.count >= 32 {
            return .success(Array(data.prefix(32)))
        } else {
            var result = data
            result.append(contentsOf: [UInt8](repeating: 0, count: 32 - data.count))
            return .success(result)
        }
    }

    // MARK: - SecurityProviderBase Implementation

    /// Reset all security data
    func resetSecurityData() async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        bookmarks.removeAll()
        accessCount.removeAll()
        accessedPaths.removeAll()
        storedBookmarks.removeAll()
        return .success(())
    }

    /// Get the host identifier
    func getHostIdentifier() async -> Result<String, SecurityInterfaces.SecurityInterfacesError> {
        return .success("mock-host-identifier")
    }

    /// Register a client application
    func registerClient(bundleIdentifier _: String) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        return .success(true)
    }

    /// Request key rotation - mock implementation
    func requestKeyRotation(keyId _: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }

    /// Notify about a potentially compromised key - mock implementation
    func notifyKeyCompromise(keyId _: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }

    // MARK: - Original Implementation

    func createBookmark(forPath path: String) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        if shouldFailBookmarkCreation {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock failure"))
        }
        let bookmarkData = Data("mock_bookmark_\(path)".utf8)
        bookmarks[path] = bookmarkData
        return .success(Array(bookmarkData))
    }

    func resolveBookmark(_ bookmarkData: [UInt8]) async -> Result<(path: String, isStale: Bool), SecurityInterfaces.SecurityInterfacesError> {
        guard let mockPath = String(data: Data(bookmarkData), encoding: .utf8) else {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Invalid bookmark data"))
        }
        let path = mockPath.replacingOccurrences(of: "mock_bookmark_", with: "")
        if shouldFailAccess {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock access denied"))
        }
        accessCount[path, default: 0] += 1
        return .success((path: path, isStale: false))
    }

    func startAccessing(path: String) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        if shouldFailAccess {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock access denied"))
        }
        accessedPaths.insert(path)
        return .success(true)
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
    ) async -> Result<T, SecurityInterfaces.SecurityInterfacesError> {
        if shouldFailAccess {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock access denied"))
        }
        accessedPaths.insert(path)
        defer { accessedPaths.remove(path) }
        do {
            return .success(try await operation())
        } catch {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock access denied"))
        }
    }

    func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    func validateBookmark(_ bookmarkData: [UInt8]) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        guard let mockPath = String(data: Data(bookmarkData), encoding: .utf8) else {
            return .success(false)
        }
        return .success(mockPath.hasPrefix("mock_bookmark_"))
    }

    func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }

    func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        if shouldFailAccess {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock storage failure"))
        }
        storedBookmarks[identifier] = bookmarkData
        return .success(())
    }

    func loadBookmark(withIdentifier identifier: String) async -> Result<[UInt8], SecurityInterfaces.SecurityInterfacesError> {
        guard let bookmark = storedBookmarks[identifier] else {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Bookmark not found: \(identifier)"))
        }
        return .success(bookmark)
    }

    func deleteBookmark(withIdentifier identifier: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        if shouldFailAccess {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Mock storage failure"))
        }
        guard storedBookmarks.removeValue(forKey: identifier) != nil else {
            return .failure(SecurityInterfaces.SecurityInterfacesError.accessError("Bookmark not found: \(identifier)"))
        }
        return .success(())
    }

    // Test helper methods
    func setBookmarkCreationFailure(_ shouldFail: Bool) {
        shouldFailBookmarkCreation = shouldFail
    }

    func setAccessFailure(_ shouldFail: Bool) {
        shouldFailAccess = shouldFail
    }

    func getAccessCount(for path: String) async -> Int {
        accessCount[path] ?? 0
    }
}

// Create a mock crypto service
@preconcurrency
class MockCryptoService: SecurityProtocolsCore.CryptoServiceProtocol, @unchecked Sendable {
    // Required protocol methods with simpler signatures
    func encrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func generateKey() async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }
    
    func hash(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }
    
    func verify(data: UmbraCoreTypes.SecureBytes, against hash: UmbraCoreTypes.SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        return .success(true)
    }
    
    func encryptSymmetric(data: UmbraCoreTypes.SecureBytes, key: UmbraCoreTypes.SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decryptSymmetric(data: UmbraCoreTypes.SecureBytes, key: UmbraCoreTypes.SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func encryptAsymmetric(data: UmbraCoreTypes.SecureBytes, publicKey: UmbraCoreTypes.SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decryptAsymmetric(data: UmbraCoreTypes.SecureBytes, privateKey: UmbraCoreTypes.SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func hash(data: UmbraCoreTypes.SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }
    
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: length)))
    }
    
    // Additional methods with full signatures
    func encrypt(data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes, iv: UmbraCoreTypes.SecureBytes?, additionalAuthenticatedData: UmbraCoreTypes.SecureBytes?) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decrypt(data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes, iv: UmbraCoreTypes.SecureBytes?, additionalAuthenticatedData: UmbraCoreTypes.SecureBytes?) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func generateKey(algorithm: String, keySizeInBits: Int) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: keySizeInBits / 8)))
    }
    
    func generateIV(algorithm: String) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 16)))
    }
    
    func generateRandomBytes(count: Int) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: count)))
    }
}

// Create a mock key management service
@preconcurrency
class MockKeyManagementServiceImpl: SecurityProtocolsCore.KeyManagementProtocol, @unchecked Sendable {
    private var storedKeys: [String: UmbraCoreTypes.SecureBytes] = [:]
    
    func createKey(algorithm: String, options: [String: String]?) -> String {
        return "test-key-\(UUID().uuidString)"
    }
    
    func retrieveKey(withIdentifier identifier: String) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        if let key = storedKeys[identifier] {
            return .success(key)
        }
        // If key doesn't exist, create a mock one
        let mockKey = UmbraCoreTypes.SecureBytes(bytes: Array(repeating: UInt8(0), count: 32))
        storedKeys[identifier] = mockKey
        return .success(mockKey)
    }
    
    func storeKey(_ key: UmbraCoreTypes.SecureBytes, withIdentifier identifier: String) async -> Result<Void, UmbraErrors.Security.Protocols> {
        storedKeys[identifier] = key
        return .success(())
    }
    
    func deleteKey(withIdentifier identifier: String) async -> Result<Void, UmbraErrors.Security.Protocols> {
        storedKeys.removeValue(forKey: identifier)
        return .success(())
    }
    
    func rotateKey(withIdentifier identifier: String, dataToReencrypt: UmbraCoreTypes.SecureBytes?) async -> Result<(newKey: UmbraCoreTypes.SecureBytes, reencryptedData: UmbraCoreTypes.SecureBytes?), UmbraErrors.Security.Protocols> {
        let newKey = UmbraCoreTypes.SecureBytes(bytes: Array(repeating: UInt8(1), count: 32))
        storedKeys[identifier] = newKey
        
        var reencryptedData: UmbraCoreTypes.SecureBytes? = nil
        if let data = dataToReencrypt {
            reencryptedData = data
        }
        return .success((newKey: newKey, reencryptedData: reencryptedData))
    }
    
    func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.Protocols> {
        return .success(Array(storedKeys.keys))
    }
}

@MainActor
final class MockSecurityProviderTests: XCTestCase {
    private var provider: TestMockSecurityProvider!

    // Add static property for test discovery
    static var allTests = [
        ("testCreateBookmark", testCreateBookmark),
        ("testResolveBookmark", testResolveBookmark),
        ("testStartAccessing", testStartAccessing),
        ("testWithSecurityScopedAccess", testWithSecurityScopedAccess),
        ("testValidateBookmark", testValidateBookmark),
        ("testSaveAndLoadBookmark", testSaveAndLoadBookmark),
        ("testDeleteBookmark", testDeleteBookmark),
        ("testEncryptDecrypt", testEncryptDecrypt),
        ("testGenerateKey", testGenerateKey)
    ]

    override func setUp() async throws {
        provider = TestMockSecurityProvider()
    }

    override func tearDown() async throws {
        provider = nil
    }

    func testCreateBookmark() async throws {
        let testPath = "/test/path"
        let result = await provider.createBookmark(forPath: testPath)
        
        switch result {
        case .success(let bookmarkData):
            // Mock bookmark data should be "mock_bookmark_/test/path"
            let expectedData = Data("mock_bookmark_\(testPath)".utf8)
            XCTAssertEqual(bookmarkData, Array(expectedData))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }

        await provider.setBookmarkCreationFailure(true)
        
        let failResult = await provider.createBookmark(forPath: testPath)
        
        switch failResult {
        case .success:
            XCTFail("Expected bookmark creation to fail")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Mock failure") ?? false)
        }
    }

    func testResolveBookmark() async throws {
        let testPath = "/test/path"
        let bookmarkData = Data("mock_bookmark_\(testPath)".utf8)
        let bookmark = Array(bookmarkData)
        
        let result = await provider.resolveBookmark(bookmark)
        
        switch result {
        case .success(let resolvedPath):
            XCTAssertEqual(resolvedPath.path, testPath)
            XCTAssertFalse(resolvedPath.isStale)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }

        await provider.setAccessFailure(true)
        
        let failResult = await provider.resolveBookmark(bookmark)
        
        switch failResult {
        case .success:
            XCTFail("Expected access to fail")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Mock access denied") ?? false)
        }
    }

    func testStartAccessing() async throws {
        let testPath = "/test/path"
        
        let result = await provider.startAccessing(path: testPath)
        
        switch result {
        case .success(let success):
            XCTAssertTrue(success)
            let isAccessing = await provider.isAccessing(path: testPath)
            XCTAssertTrue(isAccessing)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }

        await provider.setAccessFailure(true)
        
        let failResult = await provider.startAccessing(path: testPath)
        
        switch failResult {
        case .success:
            XCTFail("Expected access to fail")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Mock access denied") ?? false)
        }
    }

    func testWithSecurityScopedAccess() async throws {
        let testPath = "/test/path"
        let result = await provider.withSecurityScopedAccess(to: testPath) {
            return "test-value"
        }
        
        switch result {
        case .success(let value):
            XCTAssertEqual(value, "test-value")
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }

        await provider.setAccessFailure(true)
        
        let failResult = await provider.withSecurityScopedAccess(to: testPath) {
            return "test-value"
        }
        
        switch failResult {
        case .success:
            XCTFail("Expected access to fail")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Mock access denied") ?? false)
        }
    }

    func testValidateBookmark() async throws {
        let testPath = "/test/path"
        let validBookmarkData = Data("mock_bookmark_\(testPath)".utf8)
        let validBookmark = Array(validBookmarkData)
        
        let invalidBookmarkData = Data("invalid_bookmark".utf8)
        let invalidBookmark = Array(invalidBookmarkData)
        
        let validResult = await provider.validateBookmark(validBookmark)
        let invalidResult = await provider.validateBookmark(invalidBookmark)
        
        switch validResult {
        case .success(let isValid):
            XCTAssertTrue(isValid)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
        
        switch invalidResult {
        case .success(let isValid):
            XCTAssertFalse(isValid)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSaveAndLoadBookmark() async throws {
        let testIdentifier = "test-bookmark"
        let bookmarkData: [UInt8] = [1, 2, 3, 4, 5]
        
        let saveResult = await provider.saveBookmark(bookmarkData, withIdentifier: testIdentifier)
        
        switch saveResult {
        case .success:
            // Test successful save
            let loadResult = await provider.loadBookmark(withIdentifier: testIdentifier)
            
            switch loadResult {
            case .success(let loadedData):
                XCTAssertEqual(loadedData, bookmarkData)
            case .failure(let error):
                XCTFail("Unexpected load error: \(error)")
            }
        case .failure(let error):
            XCTFail("Unexpected save error: \(error)")
        }
        
        // Test non-existent bookmark
        let loadMissingResult = await provider.loadBookmark(withIdentifier: "non-existent")
        
        switch loadMissingResult {
        case .success:
            XCTFail("Expected bookmark not found error")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Bookmark not found") ?? false)
        }
    }

    func testDeleteBookmark() async throws {
        let testIdentifier = "test-bookmark"
        let bookmarkData: [UInt8] = [1, 2, 3, 4, 5]
        
        // Save a bookmark first
        let saveResult = await provider.saveBookmark(bookmarkData, withIdentifier: testIdentifier)
        guard case .success = saveResult else {
            XCTFail("Failed to save bookmark")
            return
        }
        
        // Delete the bookmark
        let deleteResult = await provider.deleteBookmark(withIdentifier: testIdentifier)
        
        switch deleteResult {
        case .success:
            // Verify it's deleted by trying to load it
            let loadResult = await provider.loadBookmark(withIdentifier: testIdentifier)
            
            switch loadResult {
            case .success:
                XCTFail("Expected bookmark to be deleted")
            case .failure(let error):
                XCTAssertTrue(error.errorDescription?.contains("Bookmark not found") ?? false)
            }
        case .failure(let error):
            XCTFail("Unexpected delete error: \(error)")
        }
        
        // Test deleting non-existent bookmark
        let deleteNonExistentResult = await provider.deleteBookmark(withIdentifier: "non-existent")
        
        switch deleteNonExistentResult {
        case .success:
            XCTFail("Expected bookmark not found error")
        case .failure(let error):
            XCTAssertTrue(error.errorDescription?.contains("Bookmark not found") ?? false)
        }
    }

    func testEncryptDecrypt() async throws {
        let testData: [UInt8] = [1, 2, 3, 4, 5]
        let testKey: [UInt8] = [10, 20, 30, 40, 50]
        
        let encryptResult = await provider.encrypt(testData, key: testKey)
        
        switch encryptResult {
        case .success(let encryptedData):
            XCTAssertEqual(encryptedData, testData)  // Mock simply returns the same data
            
            let decryptResult = await provider.decrypt(encryptedData, key: testKey)
            
            switch decryptResult {
            case .success(let decryptedData):
                XCTAssertEqual(decryptedData, testData)
            case .failure(let error):
                XCTFail("Unexpected decrypt error: \(error)")
            }
        case .failure(let error):
            XCTFail("Unexpected encrypt error: \(error)")
        }
    }

    func testGenerateKey() async throws {
        let keyResult = await provider.generateKey(length: 32)
        
        switch keyResult {
        case .success(let key):
            XCTAssertEqual(key.count, 32)
            XCTAssertEqual(key, [UInt8](repeating: 0, count: 32))
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
}

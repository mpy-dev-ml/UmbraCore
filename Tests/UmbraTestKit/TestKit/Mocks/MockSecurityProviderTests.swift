import Core
import ErrorHandling
import SecurityInterfaces
import SecurityProtocolsCore
import SecurityTypesProtocols
import UmbraCoreTypes
import XCTest

/// A mock security provider for testing
actor TestMockSecurityProvider: SecurityInterfaces.SecurityProviderProtocol {
    private var bookmarks: [String: Data] = [:]
    private var accessCount: [String: Int] = [:]
    private var mockedResults: [String: Bool] = [:]
    private var lastAccessedFile: String?
    
    public nonisolated let cryptoService: SecurityInterfaces.CryptoServiceProtocol = MockCryptoService()
    public nonisolated let keyManager: SecurityInterfaces.KeyManagementProtocol = MockKeyManagementService()
    
    init() {
        // Default initialization
    }
    
    // MARK: - Test Customization Methods
    
    /// Set a mocked result for a specific operation
    func setMockedResult(forOperation operation: String, result: Bool) {
        mockedResults[operation] = result
    }
    
    /// Get the last accessed file path
    func getLastAccessedFile() -> String? {
        return lastAccessedFile
    }
    
    /// Get the number of times a file was accessed
    func getAccessCount(forPath path: String) -> Int {
        return accessCount[path] ?? 0
    }
    
    // MARK: - Bookmark Management
    
    func createBookmark(forPath path: String) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        guard !bookmarks.keys.contains(path) else {
            return .failure(SecurityInterfaces.SecurityError.operationFailed("Bookmark already exists for path: \(path)"))
        }
        
        let bookmark = "test-bookmark-\(path)".data(using: .utf8)!
        bookmarks[path] = bookmark
        return .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](bookmark)))
    }
    
    func resolveBookmark(_ bookmarkData: UmbraCoreTypes.SecureBytes) async -> Result<(path: String, isStale: Bool), SecurityInterfaces.SecurityInterfacesError> {
        let data = Data(bookmarkData.rawBytes)
        let bookmarkString = String(data: data, encoding: .utf8) ?? ""
        
        guard bookmarkString.hasPrefix("test-bookmark-") else {
            return .failure(SecurityInterfaces.SecurityError.operationFailed("Invalid bookmark format"))
        }
        
        let path = String(bookmarkString.dropFirst("test-bookmark-".count))
        
        guard bookmarks[path] == data else {
            return .failure(SecurityInterfaces.SecurityError.operationFailed("Bookmark not found for path: \(path)"))
        }
        
        return .success((path, false))
    }
    
    func startAccessing(path: String) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        lastAccessedFile = path
        accessCount[path] = (accessCount[path] ?? 0) + 1
        
        if let mockedResult = mockedResults["startAccessing-\(path)"] {
            return mockedResult ? .success(true) : .failure(SecurityInterfaces.SecurityError.operationFailed("Mocked failure"))
        }
        
        return .success(true)
    }
    
    func stopAccessing(path: String) async {
        // No need to return anything, just update internal state
        accessCount[path] = (accessCount[path] ?? 0) - 1
        if accessCount[path] == 0 {
            accessCount.removeValue(forKey: path)
        }
    }
    
    func isPathBeingAccessed(_ path: String) async -> Bool {
        return (accessCount[path] ?? 0) > 0
    }
    
    // MARK: - SecurityProviderProtocol implementation
    
    func encrypt(_ data: UmbraCoreTypes.SecureBytes, key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(data)
    }
    
    func decrypt(_ data: UmbraCoreTypes.SecureBytes, key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(data)
    }
    
    func encryptData(_ data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return await encrypt(data, key: key)
    }
    
    func decryptData(_ data: UmbraCoreTypes.SecureBytes, withKey key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return await decrypt(data, key: key)
    }
    
    func generateKey(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: length)))
    }
    
    func generateKey(algorithm: String, keySizeInBits: Int) async throws -> UmbraCoreTypes.SecureBytes {
        return UmbraCoreTypes.SecureBytes(bytes: Array(repeating: UInt8(0), count: keySizeInBits / 8))
    }
    
    func hash(_ data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 8)))
    }
    
    func getSecurityConfiguration() async -> Result<SecurityInterfaces.SecurityConfiguration, SecurityInterfaces.SecurityInterfacesError> {
        return .success(SecurityInterfaces.SecurityConfiguration())
    }
    
    func updateSecurityConfiguration(_ configuration: SecurityInterfaces.SecurityConfiguration) async throws {
        // Mock implementation does nothing
    }
    
    func getHostIdentifier() async -> Result<String, SecurityInterfaces.SecurityInterfacesError> {
        return .success("test-host-id")
    }
    
    func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        return .success(true)
    }
    
    func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }
    
    func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }
    
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: UInt8(0), count: length)))
    }
    
    func randomBytes(count: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        return await generateRandomData(length: count)
    }
    
    nonisolated func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfaces.SecurityInterfacesError> {
        return .success(["status": "active" as NSString])
    }
    
    func registerNotifications() async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        return .success(())
    }
    
    func performSecurityOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: Data?,
        parameters: [String: String]
    ) async -> Result<SecurityProtocolsCore.SecurityResult, SecurityInterfaces.SecurityInterfacesError> {
        return .success(SecurityProtocolsCore.SecurityResult(
            status: .success,
            data: data ?? Data(),
            message: "Operation completed successfully"
        ))
    }
    
    func performSecurityOperation(
        operationName: String,
        data: Data?,
        parameters: [String: String]
    ) async -> Result<SecurityProtocolsCore.SecurityResult, SecurityInterfaces.SecurityInterfacesError> {
        return .success(SecurityProtocolsCore.SecurityResult(
            status: .success,
            data: data ?? Data(),
            message: "Operation completed successfully"
        ))
    }
    
    func performSecureOperation(
        operation: SecurityOperation,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        return SecurityResultDTO(
            status: .success,
            data: nil,
            message: "Operation completed successfully"
        )
    }
    
    nonisolated func getSecureConfig(options: [String: String]?) -> SecurityConfigDTO {
        return SecurityConfigDTO(
            algorithm: "AES-256",
            keySizeInBits: 256,
            initializationVector: nil,
            additionalAuthenticatedData: nil,
            iterations: nil,
            options: options,
            keyIdentifier: nil,
            inputData: nil,
            key: nil,
            additionalData: nil
        )
    }
    
    nonisolated func createSecureConfig(options: [String: Any]?) -> SecurityConfigDTO {
        var securityOptions: [String: String] = [:]
        
        if let options = options {
            for (key, value) in options {
                securityOptions[key] = String(describing: value)
            }
        }
        
        return SecurityConfigDTO(
            algorithm: "AES-256",
            keySizeInBits: 256,
            initializationVector: nil,
            additionalAuthenticatedData: nil,
            iterations: nil,
            options: securityOptions,
            keyIdentifier: nil,
            inputData: nil,
            key: nil,
            additionalData: nil
        )
    }
}

// MARK: - Mock Supporting Classes

private final class MockCryptoService: SecurityInterfaces.CryptoServiceProtocol {
    func encrypt(data: Data, keyId: String, options: [String: String]?) -> Data {
        return data
    }
    
    func decrypt(data: Data, keyId: String, options: [String: String]?) -> Data {
        return data
    }
    
    func generateKey(algorithm: String, options: [String: String]?) -> String {
        return "test-key-id"
    }
    
    func hash(data: Data, algorithm: String) -> Data {
        return data
    }
    
    func encrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decrypt(data: UmbraCoreTypes.SecureBytes, using key: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func generateKey() async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: 32)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
    
    func generateKey(algorithm: String, length: Int) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: length)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
    
    func hashData(_ data: UmbraCoreTypes.SecureBytes, algorithm: String) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: 32)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
    
    func hash(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: 32)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
    
    func verify(data: UmbraCoreTypes.SecureBytes, against hash: UmbraCoreTypes.SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        return .success(true)
    }
    
    func encryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func encryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        publicKey: UmbraCoreTypes.SecureBytes,
        config: SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func decryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        privateKey: UmbraCoreTypes.SecureBytes,
        config: SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        return .success(data)
    }
    
    func hash(
        data: UmbraCoreTypes.SecureBytes,
        config: SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: 32)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
    
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, UmbraErrors.Security.Protocols> {
        let bytes = Array(repeating: UInt8(0), count: length)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }
}

private final class MockKeyManagementService: SecurityInterfaces.KeyManagementProtocol {
    func createKey(algorithm: String, options: [String: String]?) -> String {
        return "test-key-id"
    }
    
    func deleteKey(keyId: String) -> Bool {
        return true
    }
    
    func getKeyInfo(keyId: String) -> [String: AnyObject]? {
        return ["status": "active" as NSString]
    }
    
    func rotateKey(keyId: String) -> String {
        return "rotated-test-key-id"
    }
}

// MARK: - Test Error Types

enum SecTestError: Error, Equatable {
    case bookmarkError(String)
    case operationFailed(String)
    case invalidInput(String)
    case invalidSecurityState(state: String, expectedState: String)
    case accessError(String)
    case internalError(String)
}

final class MockSecurityProviderTests: XCTestCase {
    private var provider: TestMockSecurityProvider!

    override func setUp() async throws {
        provider = TestMockSecurityProvider()
    }

    override func tearDown() async throws {
        provider = nil
    }

    func testStartStopAccessing() async throws {
        // Test starting access
        let path = "/test/path"
        let result = await provider.startAccessing(path: path)
        XCTAssertEqual(try result.get(), true)
        
        // Check that the path is being accessed
        let isAccessed = await provider.isPathBeingAccessed(path)
        XCTAssertTrue(isAccessed)
        
        // Test stopping access
        await provider.stopAccessing(path: path)
        
        // Check that the path is no longer being accessed
        let isStillAccessed = await provider.isPathBeingAccessed(path)
        XCTAssertFalse(isStillAccessed)
    }

    func testBookmarkCreation() async throws {
        let path = "/test/path"
        let result = await provider.createBookmark(forPath: path)
        
        // Check that bookmark was created successfully
        let bookmark = try result.get()
        XCTAssertNotEqual(bookmark.rawBytes.count, 0)
    }

    func testBookmarkValidation() async throws {
        // Create valid bookmark
        let path = "/test/path"
        let createResult = await provider.createBookmark(forPath: path)
        
        // Resolve the bookmark
        let bookmark = try createResult.get()
        let resolveResult = await provider.resolveBookmark(bookmark)
        
        // Check that the path was resolved correctly
        let resolved = try resolveResult.get()
        XCTAssertEqual(resolved.path, path)
        XCTAssertFalse(resolved.isStale)
    }
}

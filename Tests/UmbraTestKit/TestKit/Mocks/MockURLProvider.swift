import Core
import ErrorHandlingDomains
import Foundation
@preconcurrency import SecurityInterfaces
import SecurityProtocolsCore
import SecurityTypes
import SecurityTypesProtocols
import UmbraCoreTypes

/// Mock implementation of URL security provider
@preconcurrency
public actor MockURLProvider: SecurityInterfaces.SecurityProvider, @unchecked Sendable {
    private var bookmarks: [String: [UInt8]]
    private var accessedPaths: Set<String>
    private var mockConfiguration: SecurityInterfaces.SecurityConfiguration

    // Required protocol properties
    public nonisolated let cryptoService: CryptoServiceProtocol = MockSecurityCryptoService()
    public nonisolated let keyManager: KeyManagementProtocol = MockKeyManagementService()

    public init() {
        bookmarks = [:]
        accessedPaths = []
        mockConfiguration = SecurityInterfaces.SecurityConfiguration(
            securityLevel: .advanced,
            encryptionAlgorithm: "AES-256",
            hashAlgorithm: "SHA-256",
            options: ["requireAuthentication": "true"]
        )
    }

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        guard !bookmarks.keys.contains(path) else {
            throw SecurityInterfaces.SecurityError
                .bookmarkError("Bookmark already exists for path: \(path)")
        }
        let bookmark = Array("mock-bookmark-\(path)".utf8)
        bookmarks[path] = bookmark
        return bookmark
    }

    public func resolveBookmark(_ bookmark: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let bookmarkString = String(bytes: bookmark, encoding: .utf8) ?? ""
        guard bookmarkString.hasPrefix("mock-bookmark-") else {
            throw SecurityInterfaces.SecurityError.bookmarkError("Invalid bookmark format")
        }
        let path = String(bookmarkString.dropFirst("mock-bookmark-".count))
        guard bookmarks[path] == bookmark else {
            throw SecurityInterfaces.SecurityError.bookmarkError("Bookmark not found for path: \(path)")
        }
        accessedPaths.insert(path)
        return (path: path, isStale: false)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let bookmarkString = String(bytes: bookmarkData, encoding: .utf8) ?? ""
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
        let granted = try await startAccessing(path: path)
        guard granted else {
            throw SecurityInterfaces.SecurityError.accessError("Failed to access \(path)")
        }
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }

    // MARK: - Bookmark Storage

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let bookmarkData = bookmarks[identifier] else {
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
        bookmarks[identifier] = bookmarkData
    }

    // Test helper methods
    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }

    // MARK: - Security Configuration Methods

    public func getSecurityConfiguration() async -> Result<SecurityInterfaces.SecurityConfiguration, SecurityInterfaces.SecurityInterfacesError> {
        .success(mockConfiguration)
    }

    public func updateSecurityConfiguration(_ configuration: SecurityInterfaces.SecurityConfiguration) async throws {
        mockConfiguration = configuration
    }

    // MARK: - Host and Client Methods

    public func getHostIdentifier() async -> Result<String, SecurityInterfaces.SecurityInterfacesError> {
        .success("mock-url-provider-host")
    }

    public func registerClient(bundleIdentifier _: String) async -> Result<Bool, SecurityInterfaces.SecurityInterfacesError> {
        .success(true)
    }

    public func requestKeyRotation(keyId _: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        .success(())
    }

    public func notifyKeyCompromise(keyId _: String) async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        .success(())
    }

    // MARK: - Operation Execution Methods

    public func performSecurityOperation(
        operation _: SecurityProtocolsCore.SecurityOperation,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        // Simple mock implementation
        SecurityInterfaces.SecurityResult(
            success: true,
            data: data ?? Data(),
            metadata: parameters
        )
    }

    public func performSecurityOperation(
        operationName _: String,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        // Simple mock implementation
        SecurityInterfaces.SecurityResult(
            success: true,
            data: data ?? Data(),
            metadata: parameters
        )
    }

    public func performSecureOperation(
        operation _: SecurityProtocolsCore.SecurityOperation,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        // Simple mock implementation
        let emptyBytes = UmbraCoreTypes.SecureBytes(bytes: [])
        return SecurityProtocolsCore.SecurityResultDTO(data: emptyBytes)
    }

    public nonisolated func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        var securityOptions: [String: String] = [:]

        if let options {
            for (key, value) in options {
                if let stringValue = value as? String {
                    securityOptions[key] = stringValue
                } else {
                    securityOptions[key] = String(describing: value)
                }
            }
        }

        return SecurityProtocolsCore.SecurityConfigDTO(
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

    // MARK: - Required SecurityProvider Protocol Methods

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        let bytes = [UInt8](repeating: 0, count: length)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    @preconcurrency
    public nonisolated func getKeyInfo(keyId _: String) async -> Result<[String: AnyObject], SecurityInterfaces.SecurityInterfacesError> {
        let info: [String: AnyObject] = [
            "algorithm": "AES-256" as NSString,
            "created": Date() as NSDate,
            "keySize": 256 as NSNumber,
        ]
        return .success(info)
    }

    public func registerNotifications() async -> Result<Void, SecurityInterfaces.SecurityInterfacesError> {
        .success(())
    }

    public func randomBytes(count: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        let bytes = [UInt8](repeating: 0, count: count)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    public func encryptData(_ data: UmbraCoreTypes.SecureBytes, withKey _: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfaces.SecurityInterfacesError> {
        // Mock implementation just returns the same data
        .success(data)
    }

    // MARK: - SecurityProvider Protocol Conformance

    public func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
        guard !key.isEmpty else {
            throw SecurityInterfaces.SecurityError.operationFailed("Empty encryption key")
        }

        var result = [UInt8](repeating: 0, count: data.count)
        for i in 0 ..< data.count {
            let keyByte = key[i % key.count]
            let dataByte = data[i]
            result[i] = dataByte ^ keyByte
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
        var key = [UInt8](repeating: 0, count: length)
        for i in 0 ..< length {
            key[i] = UInt8.random(in: 0 ... 255)
        }
        return key
    }

    public func hash(_ data: [UInt8]) async throws -> [UInt8] {
        // Simple mock hash implementation
        var hash: UInt64 = 14_695_981_039_346_656_037 // FNV offset basis
        for byte in data {
            hash = hash ^ UInt64(byte)
            hash = hash &* 1_099_511_628_211 // FNV prime
        }

        var result = [UInt8](repeating: 0, count: 8)
        for i in 0 ..< 8 {
            result[i] = UInt8((hash >> (8 * i)) & 0xFF)
        }
        return result
    }

    // MARK: - SecurityProviderBase Protocol Conformance

    public func resetSecurityData() async throws {
        bookmarks.removeAll()
        accessedPaths.removeAll()
    }
}

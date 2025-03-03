import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesBase
import SecurityBridge
import SecurityInterfacesProtocols

/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: SecurityProviderBase {
    // MARK: - Security Operations

    /// Encrypt data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8]

    /// Decrypt data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8]

    /// Generate a secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    /// - Throws: SecurityError if key generation fails
    func generateKey(length: Int) async throws -> [UInt8]

    /// Hash data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash value
    /// - Throws: SecurityError if hashing fails
    func hash(_ data: [UInt8]) async throws -> [UInt8]

    // MARK: - Resource Access

    /// Create a security bookmark for a path
    /// - Parameter path: Path to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(for path: String) async throws -> [UInt8]

    /// Resolve a previously created security bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved path and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

    /// Validate a bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: SecurityError if validation fails
    func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool
}

/// Adapter class to convert between SecurityProviderBridge and SecurityProvider
public final class SecurityProviderAdapter: SecurityProvider {
    private let bridge: any SecurityProviderBridge

    public init(bridge: any SecurityProviderBridge) {
        self.bridge = bridge
    }

    public static var protocolIdentifier: String {
        return "com.umbra.security.provider.adapter"
    }

    public func isAvailable() async throws -> Bool {
        // Delegate to the bridge's implementation
        return true
    }

    public func getVersion() async -> String {
        // Delegate to the bridge's implementation
        return "1.0.0"
    }

    // MARK: - SecurityProviderBase Conformance

    public func resetSecurityData() async throws {
        // Delegate to the bridge's implementation if available
        // For now, implement a basic version
        throw SecurityInterfacesError.operationFailed("Not implemented")
    }

    public func getHostIdentifier() async throws -> String {
        // Delegate to the bridge's implementation if available
        // For now, implement a basic version using a simple identifier
        return "host-identifier-\(Int.random(in: 1_000...9_999))"
    }

    public func registerClient(bundleIdentifier: String) async throws -> Bool {
        // Delegate to the bridge's implementation if available
        // For now, implement a basic version
        return true
    }

    public func requestKeyRotation(keyId: String) async throws {
        // Delegate to the bridge's implementation if available
        // For now, implement a basic version
        throw SecurityInterfacesError.operationFailed("Not implemented")
    }

    public func notifyKeyCompromise(keyId: String) async throws {
        // Delegate to the bridge's implementation if available
        // For now, implement a basic version
        throw SecurityInterfacesError.operationFailed("Not implemented")
    }

    public func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
        let dataBridge = DataBridge(data)
        let keyBridge = DataBridge(key)

        let encryptedData = try await bridge.encrypt(dataBridge, key: keyBridge)
        return encryptedData.bytes
    }

    public func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
        let dataBridge = DataBridge(data)
        let keyBridge = DataBridge(key)

        let decryptedData = try await bridge.decrypt(dataBridge, key: keyBridge)
        return decryptedData.bytes
    }

    public func generateKey(length: Int) async throws -> [UInt8] {
        let keyData = try await bridge.generateKey(length: length)
        return keyData.bytes
    }

    public func hash(_ data: [UInt8]) async throws -> [UInt8] {
        let dataBridge = DataBridge(data)

        let hashedData = try await bridge.hash(dataBridge)
        return hashedData.bytes
    }

    public func createBookmark(for path: String) async throws -> [UInt8] {
        let bookmarkData = try await bridge.createBookmark(for: path)
        return bookmarkData.bytes
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let dataBridge = DataBridge(bookmarkData)

        let (urlString, isStale) = try await bridge.resolveBookmark(dataBridge)
        return (path: urlString, isStale: isStale)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        let dataBridge = DataBridge(bookmarkData)
        return try await bridge.validateBookmark(dataBridge)
    }
}

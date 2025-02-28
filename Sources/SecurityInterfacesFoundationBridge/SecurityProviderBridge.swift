import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesProtocols

/// Bridge protocol that connects SecurityProviderProtocol to Foundation-dependent implementations
/// This protocol uses the FoundationBridgeTypes to avoid direct Foundation dependencies
public protocol SecurityProviderBridge: Sendable {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Encrypt data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: Error if encryption fails
    func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

    /// Decrypt data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: Error if decryption fails
    func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

    /// Generate a cryptographically secure random key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    /// - Throws: Error if key generation fails
    func generateKey(length: Int) async throws -> DataBridge

    /// Hash data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash of the data
    /// - Throws: Error if hashing fails
    func hash(_ data: DataBridge) async throws -> DataBridge

    /// Create a security-scoped bookmark for a URL
    /// - Parameter urlString: URL string to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: Error if bookmark creation fails
    func createBookmark(for urlString: String) async throws -> DataBridge

    /// Resolve a previously created security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved URL string and whether bookmark is stale
    /// - Throws: Error if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: DataBridge) async throws -> (urlString: String, isStale: Bool)

    /// Validate a bookmark to ensure it's still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if bookmark is valid, false otherwise
    /// - Throws: Error if validation fails
    func validateBookmark(_ bookmarkData: DataBridge) async throws -> Bool
}

/// Default implementation for SecurityProviderBridge
public extension SecurityProviderBridge {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.security.provider.bridge"
    }
}

/// Adapter class to convert between SecurityProviderProtocol and SecurityProviderBridge
public final class SecurityProviderProtocolAdapter: SecurityProviderProtocol {
    private let bridge: any SecurityProviderBridge

    public init(bridge: any SecurityProviderBridge) {
        self.bridge = bridge
    }

    public static var protocolIdentifier: String {
        return "com.umbra.security.provider.protocol.adapter"
    }

    public func encrypt(_ data: BinaryData, key: BinaryData) async throws -> BinaryData {
        let dataBridge = DataBridge(data.bytes)
        let keyBridge = DataBridge(key.bytes)

        let encryptedData = try await bridge.encrypt(dataBridge, key: keyBridge)
        return BinaryData(encryptedData.bytes)
    }

    public func decrypt(_ data: BinaryData, key: BinaryData) async throws -> BinaryData {
        let dataBridge = DataBridge(data.bytes)
        let keyBridge = DataBridge(key.bytes)

        let decryptedData = try await bridge.decrypt(dataBridge, key: keyBridge)
        return BinaryData(decryptedData.bytes)
    }

    public func generateKey(length: Int) async throws -> BinaryData {
        let keyData = try await bridge.generateKey(length: length)
        return BinaryData(keyData.bytes)
    }

    public func hash(_ data: BinaryData) async throws -> BinaryData {
        let dataBridge = DataBridge(data.bytes)

        let hashedData = try await bridge.hash(dataBridge)
        return BinaryData(hashedData.bytes)
    }
}

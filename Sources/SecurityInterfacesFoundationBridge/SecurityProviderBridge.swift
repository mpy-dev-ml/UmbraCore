import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesProtocols
import Foundation

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

    /// Generate cryptographically secure random data
    /// - Parameter length: Length of the data in bytes
    /// - Returns: Generated random data
    /// - Throws: Error if data generation fails
    func generateRandomData(length: Int) async throws -> DataBridge

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
public final class SecurityProviderProtocolAdapter: SecurityInterfacesProtocols.SecurityProviderProtocol {
    private let bridge: any SecurityProviderBridge

    public init(bridge: any SecurityProviderBridge) {
        self.bridge = bridge
    }

    public static var protocolIdentifier: String {
        return "com.umbra.security.provider.protocol.adapter"
    }

    public func encrypt(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Convert from SecurityInterfacesProtocols.BinaryData to CoreTypes.BinaryData (SecureBytes)
        let secureData = CoreTypes.BinaryData(data.bytes)
        let secureKey = CoreTypes.BinaryData(key.bytes)
        
        // Use the bridge with CoreTypes.BinaryData
        let dataBridge = DataBridge(secureData.unsafeBytes)
        let keyBridge = DataBridge(secureKey.unsafeBytes)

        let encryptedData = try await bridge.encrypt(dataBridge, key: keyBridge)
        let result = CoreTypes.BinaryData(encryptedData.bytes)
        
        // Convert back to SecurityInterfacesProtocols.BinaryData
        return SecurityInterfacesProtocols.BinaryData(result.unsafeBytes)
    }

    public func decrypt(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Convert from SecurityInterfacesProtocols.BinaryData to CoreTypes.BinaryData (SecureBytes)
        let secureData = CoreTypes.BinaryData(data.bytes)
        let secureKey = CoreTypes.BinaryData(key.bytes)
        
        // Use the bridge with CoreTypes.BinaryData
        let dataBridge = DataBridge(secureData.unsafeBytes)
        let keyBridge = DataBridge(secureKey.unsafeBytes)

        let decryptedData = try await bridge.decrypt(dataBridge, key: keyBridge)
        let result = CoreTypes.BinaryData(decryptedData.bytes)
        
        // Convert back to SecurityInterfacesProtocols.BinaryData
        return SecurityInterfacesProtocols.BinaryData(result.unsafeBytes)
    }

    public func generateKey(length: Int) async throws -> SecurityInterfacesProtocols.BinaryData {
        let keyData = try await bridge.generateKey(length: length)
        let result = CoreTypes.BinaryData(keyData.bytes)
        
        // Convert to SecurityInterfacesProtocols.BinaryData
        return SecurityInterfacesProtocols.BinaryData(result.unsafeBytes)
    }

    public func hash(_ data: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Convert from SecurityInterfacesProtocols.BinaryData to CoreTypes.BinaryData
        let secureData = CoreTypes.BinaryData(data.bytes)
        
        let dataBridge = DataBridge(secureData.unsafeBytes)

        let hashedData = try await bridge.hash(dataBridge)
        let result = CoreTypes.BinaryData(hashedData.bytes)
        
        // Convert back to SecurityInterfacesProtocols.BinaryData
        return SecurityInterfacesProtocols.BinaryData(result.unsafeBytes)
    }
    
    public func generateRandomData(length: Int) async throws -> SecurityInterfacesProtocols.BinaryData {
        let randomData = try await bridge.generateRandomData(length: length)
        let result = CoreTypes.BinaryData(randomData.bytes)
        
        // Convert to SecurityInterfacesProtocols.BinaryData
        return SecurityInterfacesProtocols.BinaryData(result.unsafeBytes)
    }
}

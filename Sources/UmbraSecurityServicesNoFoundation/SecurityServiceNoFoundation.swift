import CoreTypes
import ErrorHandling
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import SecurityInterfacesProtocols
import UmbraSecurityNoFoundation

/// Security service that doesn't depend on Foundation
public final class SecurityServiceNoFoundation {
    // MARK: - Properties

    private let securityProvider: any SecurityProviderCore

    // MARK: - Initialization

    /// Create a new security service with the default security provider
    public init() {
        self.securityProvider = SecurityProviderNoFoundationFactory.createDefaultProvider()
    }

    /// Create a new security service with a custom security provider
    public init(securityProvider: any SecurityProviderCore) {
        self.securityProvider = securityProvider
    }

    // MARK: - Public Methods

    /// Encrypt data using the security provider
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityProviderCoreError if encryption fails
    public func encrypt(data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await securityProvider.encryptData(data, key: key)
    }

    /// Decrypt data using the security provider
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityProviderCoreError if decryption fails
    public func decrypt(data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await securityProvider.decryptData(data, key: key)
    }

    /// Generate a random encryption key
    /// - Returns: Generated key
    /// - Throws: SecurityProviderCoreError if key generation fails
    public func generateKey() async throws -> DataBridge {
        return try await securityProvider.generateKey()
    }

    /// Create a security-scoped bookmark for a URL
    /// - Parameter urlString: URL to create a bookmark for
    /// - Returns: Bookmark data
    /// - Throws: SecurityProviderCoreError if bookmark creation fails
    public func createBookmark(for urlString: String) async throws -> [UInt8] {
        return try await securityProvider.createBookmark(urlString)
    }

    /// Resolve a security-scoped bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: URL string
    /// - Throws: SecurityProviderCoreError if bookmark resolution fails
    public func resolveBookmark(_ bookmarkData: [UInt8]) throws -> String {
        return try securityProvider.resolveBookmark(bookmarkData)
    }

    /// Start accessing a security-scoped resource
    /// - Parameter urlString: URL of the resource to access
    /// - Returns: Whether access was successfully started
    /// - Throws: SecurityProviderCoreError if access fails
    public func startAccessingSecurityScopedResource(_ urlString: String) throws -> Bool {
        return try securityProvider.startAccessingSecurityScopedResource(urlString)
    }

    /// Stop accessing a security-scoped resource
    /// - Parameter urlString: URL of the resource to stop accessing
    public func stopAccessingSecurityScopedResource(_ urlString: String) {
        securityProvider.stopAccessingSecurityScopedResource(urlString)
    }
}

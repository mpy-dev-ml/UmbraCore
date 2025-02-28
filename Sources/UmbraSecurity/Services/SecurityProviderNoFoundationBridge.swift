import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import SecurityInterfacesProtocols
import UmbraSecurityNoFoundation
import UmbraSecurityServicesNoFoundation

/// Bridge between Foundation-free security provider and Foundation-dependent code
@available(macOS 14.0, *)
public final class SecurityProviderNoFoundationBridge {
    private let provider: any SecurityProviderCore

    /// Initialize with a security provider
    public init(provider: any SecurityProviderCore) {
        self.provider = provider
    }

    /// Create a default provider
    public static func createDefaultProvider() -> any SecurityProviderCore {
        return SecurityProviderNoFoundationFactory.createDefaultProvider()
    }

    /// Create a security service
    public static func createSecurityService() -> SecurityServiceNoFoundation {
        return SecurityServiceFactoryNoFoundation.createDefaultService()
    }

    /// Encrypt data
    public func encryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await provider.encryptData(data, key: key)
    }

    /// Decrypt data
    public func decryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await provider.decryptData(data, key: key)
    }

    /// Generate encryption key
    public func generateKey() async throws -> DataBridge {
        return try await provider.generateKey()
    }

    /// Create bookmark for URL
    public func createBookmark(_ urlString: String) async throws -> [UInt8] {
        return try await provider.createBookmark(urlString)
    }

    /// Resolve bookmark to URL
    public func resolveBookmark(_ bookmarkData: [UInt8]) throws -> String {
        return try provider.resolveBookmark(bookmarkData)
    }
}

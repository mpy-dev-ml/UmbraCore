import Foundation
import FoundationBridgeTypes
import SecurityInterfaces
import SecurityInterfacesBase
import SecurityInterfacesFoundationBridge
import SecurityInterfacesProtocols

/// Factory class for creating security providers
public final class SecurityProviderFactory {

    /// Create a default security provider
    /// - Returns: A fully configured SecurityProvider instance
    public static func createDefaultProvider() -> SecurityProvider {
        // Create the Foundation implementation
        let foundationImpl = DefaultSecurityProviderFoundationImpl()

        // Create the adapter to convert between Foundation and bridge types
        let foundationAdapter = SecurityProviderFoundationAdapter(impl: foundationImpl)

        // Create the bridge that implements SecurityProviderBridge
        let bridge = DefaultSecurityProviderBridge(adapter: foundationAdapter)

        // Create the final adapter that implements SecurityProvider
        return SecurityProviderAdapter(bridge: bridge)
    }
}

/// Default implementation of SecurityProviderBridge
final class DefaultSecurityProviderBridge: SecurityProviderBridge {
    private let adapter: SecurityProviderFoundationAdapter

    init(adapter: SecurityProviderFoundationAdapter) {
        self.adapter = adapter
    }

    static var protocolIdentifier: String {
        return "com.umbra.security.provider.bridge.default"
    }

    func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await adapter.encrypt(data, key: key)
    }

    func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        return try await adapter.decrypt(data, key: key)
    }

    func generateKey(length: Int) async throws -> DataBridge {
        return try await adapter.generateKey(length: length)
    }

    func hash(_ data: DataBridge) async throws -> DataBridge {
        return try await adapter.hash(data)
    }

    func createBookmark(for urlString: String) async throws -> DataBridge {
        return try await adapter.createBookmark(for: urlString)
    }

    func resolveBookmark(_ bookmarkData: DataBridge) async throws -> (urlString: String, isStale: Bool) {
        return try await adapter.resolveBookmark(bookmarkData)
    }

    func validateBookmark(_ bookmarkData: DataBridge) async throws -> Bool {
        return try await adapter.validateBookmark(bookmarkData)
    }
}

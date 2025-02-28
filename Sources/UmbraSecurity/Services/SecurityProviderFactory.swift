import Foundation
import FoundationBridgeTypes
import SecurityBridgeCore
import SecurityInterfaces
import SecurityInterfacesBase
import SecurityInterfacesFoundationBase
import SecurityInterfacesFoundationMinimal
import SecurityInterfacesMinimalBridge
import SecurityInterfacesProtocols

/// Factory class for creating security providers
public final class SecurityProviderFactory {

    /// Create a default security provider
    /// - Returns: A fully configured SecurityProvider instance
    public static func createDefaultProvider() -> SecurityProvider {
        // Create the minimal implementation first (no Foundation dependency)
        let minimalImpl = SecurityProviderMinimalImpl()

        // Create the Foundation implementation
        let foundationImpl = DefaultSecurityProviderFoundationImpl()

        // Create the core implementation
        let coreImpl = SecurityProviderCoreImpl()

        // Create the minimal adapter
        let minimalAdapter = SecurityProviderMinimalAdapter(
            minimal: minimalImpl,
            foundation: foundationImpl
        )

        // Create the core adapter
        let coreAdapter = SecurityProviderCoreAdapter(
            core: coreImpl,
            foundation: foundationImpl
        )

        // Create the foundation adapter
        let foundationAdapter = SecurityProviderFoundationAdapter(
            foundation: foundationImpl
        )

        // Create the bridge adapter
        let bridgeAdapter = SecurityProviderBridgeImpl(
            minimal: minimalAdapter,
            core: coreAdapter,
            foundation: foundationAdapter
        )

        // Create the security provider
        return SecurityProvider(provider: bridgeAdapter)
    }

    /// Create a security provider factory that can be used to create security providers
    /// - Returns: A factory that can create security providers
    public static func createFactory() -> SecurityProviderFactoryBridge {
        return SecurityProviderFactoryBridgeImpl()
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

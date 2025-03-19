import ErrorHandlingDomains
import Foundation
import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Factory for creating SecurityProtocolsCore providers
/// This factory simplifies direct use of providers from SecurityProtocolsCore
/// - Note: This is used mainly for testing and migration purposes
public enum SPCProviderFactory {
    /// Create a provider of the specified type
    /// - Parameter type: The type of provider to create
    /// - Returns: A SecurityProtocolsCore provider instance
    public static func createProvider(ofType type: String) -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Get the shared instance of the provider adapter factory
        let factory = SecurityProviderAdapterFactory.shared

        // Create a configuration based on the type
        let config = ProviderFactoryConfiguration(
            useModernProtocols: true,
            useMockServices: false,
            securityLevel: .standard,
            options: ["providerType": type]
        )

        // Use the factory to create the provider
        return factory.createSecurityProvider(config: config)
    }

    /// Create a default provider
    /// - Returns: A SecurityProtocolsCore provider instance
    public static func createDefaultProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Use the factory to create a provider with default configuration
        createProvider(ofType: "standard")
    }
}

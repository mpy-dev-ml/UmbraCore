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
        // Create an instance of the standard factory
        let factory = StandardSecurityProviderFactory()

        // Create a configuration based on the type
        let config = SecurityConfiguration(
            securityLevel: .standard,
            encryptionAlgorithm: "AES-256",
            hashAlgorithm: "SHA-256",
            options: ["providerType": type]
        )

        // Use the factory to create the provider
        return factory.createSecurityProvider(config: config)
    }

    /// Create a default provider
    /// - Returns: A SecurityProtocolsCore provider instance
    public static func createDefaultProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Create an instance of the standard factory
        let factory = StandardSecurityProviderFactory()

        // Use the factory to create a default provider
        return factory.createDefaultSecurityProvider()
    }
}

import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Local configuration struct for provider factory
/// This replaces the dependency on SecurityBridge
public struct ProviderFactoryConfiguration {
    /// Whether to use modern protocols
    public let useModernProtocols: Bool
    
    /// Whether to use mock services
    public let useMockServices: Bool
    
    /// Security level for the provider
    public let securityLevel: SecurityLevel
    
    /// Additional options
    public let options: [String: String]
    
    /// Initialize a new configuration
    public init(useModernProtocols: Bool, useMockServices: Bool, securityLevel: SecurityLevel, options: [String: String]) {
        self.useModernProtocols = useModernProtocols
        self.useMockServices = useMockServices
        self.securityLevel = securityLevel
        self.options = options
    }
    
    /// Security level enum
    public enum SecurityLevel {
        case standard
        case high
    }
}

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

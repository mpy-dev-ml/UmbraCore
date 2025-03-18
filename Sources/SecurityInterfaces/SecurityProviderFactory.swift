import ErrorHandlingDomains
import Foundation
import SecurityBridge
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Factory protocol for creating security providers
@available(
    *,
    deprecated,
    message: "Use SecurityProviderAdapter instead"
)
public protocol SecurityProviderFactory {
    /// Create a security provider using the specified configuration
    /// - Parameter config: The configuration to use
    /// - Returns: A new security provider instance
    func createSecurityProvider(config: ProviderFactoryConfiguration) -> any SecurityProtocolsCore.SecurityProviderProtocol

    /// Create a security provider using the default configuration
    /// - Returns: A new security provider instance
    func createDefaultSecurityProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol

    /// Static factory method to create a security provider
    /// - Parameter type: The type of provider to create
    /// - Returns: A new security provider
    /// - Throws: Error if provider creation fails
    static func createProvider(type: SecurityProviderType) async throws -> SecurityProvider

    /// Static factory method to create a security provider using a string type
    /// - Parameter type: The type of provider to create as a string
    /// - Returns: A new security provider
    /// - Throws: Error if provider creation fails
    static func createProvider(ofType type: String) async throws -> SecurityProvider

    /// Create a provider of the specified type (non-async version)
    /// - Parameter type: The provider type to create
    /// - Returns: A configured security provider
    static func createSynchronousProvider(ofType type: String) -> any SecurityProtocolsCore.SecurityProviderProtocol

    /// Create a secure configuration with the specified options
    /// - Parameter options: Options to include in the configuration
    /// - Returns: A security configuration DTO
    func createSecureConfig(options: [String: String]?) -> SecurityProtocolsCore.SecurityConfigDTO
}

/// Static extension to allow using the protocol type directly
public extension SecurityProviderFactory {
    /// Create a provider of the specified type using the default factory
    /// - Parameter type: The provider type to create
    /// - Returns: A configured security provider
    /// - Throws: Error if creation fails
    static func createProvider(type: SecurityProviderType) async throws -> SecurityProvider {
        return try await StandardSecurityProviderFactory.createProvider(type: type)
    }

    /// Create a provider of the specified type using the default factory
    /// - Parameter type: The string representation of the provider type
    /// - Returns: A configured security provider
    /// - Throws: Error if creation fails
    static func createProvider(ofType type: String) async throws -> SecurityProvider {
        return try await StandardSecurityProviderFactory.createProvider(ofType: type)
    }

    /// Create a provider of the specified type (non-async version)
    /// - Parameter type: The string representation of the provider type
    /// - Returns: A SecurityProviderProtocol instance
    static func createSynchronousProvider(ofType type: String) -> any SecurityProtocolsCore.SecurityProviderProtocol {
        return StandardSecurityProviderFactory.createSynchronousProvider(ofType: type)
    }
}

/// Default implementation of the security provider factory
@available(
    *,
    deprecated,
    message: "Use SecurityProviderAdapter instead"
)
public class StandardSecurityProviderFactory: SecurityProviderFactory {
    // MARK: - Properties

    /// Singleton instance
    public static let shared = StandardSecurityProviderFactory()

    // MARK: - Initialization

    public init() {}

    // MARK: - SecurityProviderFactory Protocol Implementation

    public func createSecurityProvider(config: ProviderFactoryConfiguration) -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Check if we should create a dummy provider
        if config.useMockServices {
            // Create mock services
            let cryptoService = SecurityProviderMockCryptoService()
            let keyManager = SecurityProviderMockKeyManager()

            // Return a dummy provider
            return DummySecurityProvider(
                cryptoService: cryptoService,
                keyManager: keyManager
            )
        }

        // Delegate to the new SecurityProviderAdapter
        if config.useModernProtocols {
            return SecurityProviderAdapterFactory.shared.createModernProvider(config: config)
        } else {
            return SecurityProviderAdapterFactory.shared.createLegacyProvider(config: config)
        }
    }

    public func createDefaultSecurityProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Create a default configuration
        let config = ProviderFactoryConfiguration()

        // Delegate to createSecurityProvider
        return createSecurityProvider(config: config)
    }

    /// Create a provider of the specified type
    /// - Parameter type: The provider type to create
    /// - Returns: A configured security provider
    /// - Throws: Error if creation fails
    public static func createProvider(type: SecurityProviderType) async throws -> SecurityProvider {
        // Create factory and configuration
        let factory = StandardSecurityProviderFactory()
        let config = factory.createConfiguration(for: type)

        // Create appropriate adapter based on type
        let adapter: SecurityProvider

        switch type {
        case .standard, .production, .debug:
            // Create modern provider
            adapter = createModernSecurityProvider(config: config)

        case .test, .mock:
            // Create modern provider with mock services
            let mockConfig = ProviderFactoryConfiguration(
                useModernProtocols: true,
                useMockServices: true,
                securityLevel: .basic,
                requiresAuthentication: false,
                debugMode: true,
                options: ["testMode": "true", "mockResponses": "true"]
            )
            adapter = createModernSecurityProvider(config: mockConfig)

        case .legacy:
            // Create legacy provider
            adapter = createLegacySecurityProvider(config: config)
        }

        return adapter
    }

    /// Create a provider based on a string type identifier
    /// - Parameter type: The type of provider to create as a string
    /// - Returns: A configured security provider
    /// - Throws: Error if creation fails
    public static func createProvider(ofType type: String) async throws -> SecurityProvider {
        let providerType: SecurityProviderType

        switch type.lowercased() {
        case "standard", "default", "production":
            providerType = .standard
        case "debug":
            providerType = .debug
        case "test", "mock", "dummy":
            providerType = .test
        case "legacy", "compatible":
            providerType = .legacy
        default:
            // Use standard as fallback
            providerType = .standard
        }

        return try await createProvider(type: providerType)
    }

    /// Create a provider of the specified type (non-async version)
    /// - Parameter type: The string representation of the provider type
    /// - Returns: A SecurityProviderProtocol instance
    public static func createSynchronousProvider(ofType type: String) -> any SecurityProtocolsCore.SecurityProviderProtocol {
        // Create an instance of the standard factory
        let factory = StandardSecurityProviderFactory()

        // Determine the provider type
        let providerType: SecurityProviderType

        switch type.lowercased() {
        case "standard", "default", "production":
            providerType = .standard
        case "debug":
            providerType = .debug
        case "test", "mock", "dummy":
            providerType = .test
        case "legacy", "compatible":
            providerType = .legacy
        default:
            // Use standard as fallback
            providerType = .standard
        }

        // Create a configuration based on the provider type
        let config = factory.createConfiguration(for: providerType)

        // Create and return a provider using the configuration
        return factory.createSecurityProvider(config: config)
    }

    /// Generate security options based on the provided configuration
    /// - Parameter config: The configuration to generate options from
    /// - Returns: A dictionary of security options
    public class func generateSecurityOptions(
        config: ProviderFactoryConfiguration
    ) -> [String: String] {
        var options: [String: String] = [
            "securityLevel": String(config.securityLevel.rawValue),
            "timeout": String(config.debugMode ? 10.0 : 30.0),
            "testMode": String(config.debugMode),
            "allowUnsafeOperations": String(config.requiresAuthentication),
            "retryCount": String(config.securityLevel == .maximum ? 5 : 3)
        ]

        // Add any custom options
        if let customOptions = config.options {
            for (key, value) in customOptions {
                options[key] = value
            }
        }

        return options
    }

    /// Create a secure configuration with the specified options
    /// - Parameter options: Options to include in the configuration
    /// - Returns: A security configuration DTO
    public func createSecureConfig(options: [String: String]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        let safeOptions = options ?? [:]

        // Create a default config with the specified options
        return SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: safeOptions["algorithm"] ?? "AES-GCM",
            keySizeInBits: Int(safeOptions["keySizeInBits"] ?? "256") ?? 256,
            initializationVector: nil,
            additionalAuthenticatedData: nil,
            iterations: Int(safeOptions["iterations"] ?? "10000") ?? 10_000,
            options: safeOptions,
            keyIdentifier: safeOptions["keyIdentifier"],
            inputData: nil,
            key: nil,
            additionalData: nil
        )
    }

    // MARK: - Private Helper Methods

    private func createOptions(for config: ProviderFactoryConfiguration) -> [String: String] {
        // Create basic options from configuration
        var options = [
            "debugMode": String(config.debugMode),
            "testMode": String(config.debugMode),
            "allowUnsafeOperations": String(config.requiresAuthentication),
            "retryCount": String(config.securityLevel == .maximum ? 5 : 3)
        ]

        // Add any custom options
        if let customOptions = config.options {
            for (key, value) in customOptions {
                options[key] = value
            }
        }

        return options
    }

    /// Create a configuration for the specified provider type
    /// - Parameter type: The provider type
    /// - Returns: A configuration for that type
    private func createConfiguration(for type: SecurityProviderType) -> ProviderFactoryConfiguration {
        switch type {
        case .standard, .production:
            return ProviderFactoryConfiguration(
                useModernProtocols: true,
                useMockServices: false,
                securityLevel: .standard,
                requiresAuthentication: true,
                debugMode: false
            )

        case .debug:
            return ProviderFactoryConfiguration(
                useModernProtocols: true,
                useMockServices: false,
                securityLevel: .standard,
                requiresAuthentication: false,
                debugMode: true,
                options: ["debugMode": "true"]
            )

        case .test, .mock:
            return ProviderFactoryConfiguration(
                useModernProtocols: true,
                useMockServices: true,
                securityLevel: .basic,
                requiresAuthentication: false,
                debugMode: true,
                options: ["testMode": "true", "mockResponses": "true"]
            )

        case .legacy:
            return ProviderFactoryConfiguration(
                useModernProtocols: false,
                useMockServices: false,
                securityLevel: .standard,
                requiresAuthentication: true,
                debugMode: false
            )
        }
    }

    private func createModernSecurityProvider(config: ProviderFactoryConfiguration) -> SecurityProvider {
        // Create modern provider
        return SecurityProviderAdapterFactory.shared.createModernProvider(config: config)
    }

    private func createLegacySecurityProvider(config: ProviderFactoryConfiguration) -> SecurityProvider {
        // Create legacy provider
        return SecurityProviderAdapterFactory.shared.createLegacyProvider(config: config)
    }
}

/// The type of security provider to create
public enum SecurityProviderType {
    /// Standard provider for normal use
    case standard

    /// Production provider with optimized settings
    case production

    /// Debug provider with additional logging
    case debug

    /// Test provider with mock implementations
    case test

    /// Mock provider for unit testing
    case mock

    /// Legacy provider for backwards compatibility
    case legacy
}

// MARK: - Supporting Types

/// A simple implementation of SecurityProviderProtocol for testing purposes
public final class DummySecurityProvider: SecurityProtocolsCore.SecurityProviderProtocol {
    public let cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol
    public let keyManager: any SecurityProtocolsCore.KeyManagementProtocol

    public init(cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol, keyManager: any SecurityProtocolsCore.KeyManagementProtocol) {
        self.cryptoService = cryptoService
        self.keyManager = keyManager
    }

    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        // Default implementation
        return SecurityProtocolsCore.SecurityResultDTO.failure(
            code: 1_001,
            message: "Not implemented in dummy provider"
        )
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        // Create a default config
        return SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256,
            initializationVector: nil,
            additionalAuthenticatedData: nil,
            iterations: 10_000,
            options: options as? [String: String] ?? [:],
            keyIdentifier: nil,
            inputData: nil,
            key: nil,
            additionalData: nil
        )
    }
}

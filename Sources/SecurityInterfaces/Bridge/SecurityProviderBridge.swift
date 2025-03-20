// DEPRECATED: SecurityProviderBridge
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import ErrorHandlingDomains
import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes

/// Bridge interface between SecurityProtocolsCore providers and SecurityInterfaces adapters.
/// This bridge enables type-safe use of SecurityProtocolsCore providers through SecurityInterfaces
/// without introducing namespace conflicts or direct dependencies.
public protocol SecurityProviderBridge: AnyObject, Sendable {
    /// Get the crypto service from the provider
    var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol { get }

    /// Get the key manager from the provider
    var keyManager: SecurityProtocolsCore.KeyManagementProtocol { get }

    /// Perform a secure operation with the provider
    /// - Parameters:
    ///   - operation: The operation to perform
    ///   - config: Configuration for the operation
    /// - Returns: Result of the operation
    func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO

    /// Create a secure configuration
    /// - Parameter options: Options for the configuration
    /// - Returns: A secure configuration
    func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO
}

/// Adapter for SecurityProtocolsCore provider that conforms to SecurityProviderBridge
public final class SecurityProviderBridgeAdapter: SecurityProviderBridge {
    private let provider: SecurityProtocolsCore.SecurityProviderProtocol

    public init(provider: SecurityProtocolsCore.SecurityProviderProtocol) {
        self.provider = provider
    }

    public var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
        provider.cryptoService
    }

    public var keyManager: SecurityProtocolsCore.KeyManagementProtocol {
        provider.keyManager
    }

    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        await provider.performSecureOperation(operation: operation, config: config)
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore
        .SecurityConfigDTO {
        provider.createSecureConfig(options: options)
    }
}

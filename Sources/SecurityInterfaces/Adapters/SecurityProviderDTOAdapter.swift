import CoreDTOs
import Foundation
import SecurityBridge
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Adapter that converts a legacy SecurityProvider to the modern SecurityProviderDTO
/// This adapter allows existing SecurityProvider implementations to be used
/// with the new Foundation-independent DTO interfaces.
public final class SecurityProviderDTOAdapter: SecurityProviderDTO {
    // MARK: - Properties

    private let provider: any SecurityProtocolsCore.SecurityProviderProtocol

    // MARK: - Initializer

    /// Initialize with a SecurityProvider
    /// - Parameter provider: The provider to adapt
    public init(provider: any SecurityProtocolsCore.SecurityProviderProtocol) {
        self.provider = provider
    }

    // MARK: - SecurityProviderDTO Implementation

    public func getSecurityConfigDTO() async -> Result<CoreDTOs.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.getSecurityConfiguration()
        switch result {
        case let .success(config):
            return .success(SecurityDTOAdapter.toDTO(config))
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func updateSecurityConfigDTO(_ configuration: CoreDTOs.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        do {
            try await provider.updateSecurityConfiguration(SecurityDTOAdapter.fromDTO(configuration))
            return .success(())
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.adapter",
                message: "Unknown error updating security configuration: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func getHostIdentifier() async -> Result<String, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.getHostIdentifier()
        switch result {
        case let .success(hostId):
            return .success(hostId)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.registerClient(bundleIdentifier: bundleIdentifier)
        switch result {
        case let .success(success):
            return .success(success)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.requestKeyRotation(keyId: keyId)
        switch result {
        case .success:
            return .success(())
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func notifyKeyCompromise(keyId: String) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.notifyKeyCompromise(keyId: keyId)
        switch result {
        case .success:
            return .success(())
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.generateRandomData(length: length)
        switch result {
        case let .success(data):
            return .success(data)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.randomBytes(count: count)
        switch result {
        case let .success(data):
            return .success(data)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        let result = await provider.encryptData(data, withKey: key)
        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func performSecurityOperationDTO(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        do {
            let result = try await provider.performSecurityOperation(
                operation: operation,
                data: data,
                parameters: parameters
            )
            return .success(result.data)
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3002,
                domain: "security.adapter",
                message: "Unknown error performing security operation: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func performSecurityOperationDTO(
        operationName: String,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        do {
            let result = try await provider.performSecurityOperation(
                operationName: operationName,
                data: data,
                parameters: parameters
            )
            return .success(result.data)
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3003,
                domain: "security.adapter",
                message: "Unknown error performing security operation: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    // MARK: - SecurityProviderProtocol Implementation

    public func createSecureConfig(options: [String: String]?) -> Result<CoreDTOs.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        // Convert the string options to Any for the provider
        let anyOptions: [String: Any]? = options?.mapValues { $0 as Any }

        // Call the provider's createSecureConfig which returns a SecurityConfigDTO directly, not a Result
        let config = provider.createSecureConfig(options: anyOptions)
        return .success(SecurityDTOAdapter.toDTO(config))
    }
}

// MARK: - Adapter for SecurityProviderFactory

/// Extension to SecurityProviderFactory to support creating DTO-compatible providers
public extension SecurityProviderFactory {
    /// Create a SecurityProviderDTO instance
    /// - Parameter environment: Optional environment parameters
    /// - Returns: A Foundation-independent SecurityProviderDTO
    static func createSecurityProviderDTO(environment _: [String: String]? = nil) -> any SecurityProviderDTO {
        // Create a provider using the standard factory
        let config = ProviderFactoryConfiguration()
        let provider = StandardSecurityProviderFactory.shared.createSecurityProvider(config: config)
        return SecurityProviderDTOAdapter(provider: provider)
    }
}

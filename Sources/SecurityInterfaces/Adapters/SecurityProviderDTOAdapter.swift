// DEPRECATED: // DEPRECATED: SecurityProviderDTOAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreDTOs
import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Adapter that converts a legacy SecurityProvider to the modern SecurityProviderDTO
/// This adapter allows existing SecurityProvider implementations to be used
/// with the new Foundation-independent DTO interfaces.
// DEPRECATED: // DEPRECATED: public final class SecurityProviderDTOAdapter: SecurityProviderDTO, SecurityProtocolsCore.SecurityProviderProtocol {
    // MARK: - Properties

    private let provider: any SecurityProtocolsCore.SecurityProviderProtocol

    // MARK: - SecurityProviderProtocol Implementation

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

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        provider.createSecureConfig(options: options)
    }

    // MARK: - Initializer

    /// Initialize with a SecurityProvider
    /// - Parameter provider: The provider to adapt
    public init(provider: any SecurityProtocolsCore.SecurityProviderProtocol) {
        self.provider = provider
    }

    // MARK: - SecurityProviderDTO Implementation

    public func getSecurityConfigDTO() async -> Result<CoreDTOs.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        // Call the provider's createSecureConfig instead of requestConfig since this aligns with our needs
        // we'll create a configuration directly
        // We need to create a SecurityConfiguration first, then convert that
        let secConfig = SecurityConfiguration(
            securityLevel: .standard,
            encryptionAlgorithm: "AES-256",
            hashAlgorithm: "SHA-256",
            options: nil
        )
        // DEPRECATED: return .success(SecurityDTOAdapter.toDTO(secConfig))
    }

    public func updateSecurityConfigDTO(_ configuration: CoreDTOs.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // We'll create a security config and execute a configuration update operation
        var options: [String: Any] = [
            "operation": "updateConfiguration",
        ]

        // Add all parameters from the configuration
        _ = CoreDTOs.SecurityConfigDTO(
            algorithm: configuration.algorithm.isEmpty ? "AES" : configuration.algorithm,
            keySizeInBits: configuration.keySizeInBits == 0 ? 256 : configuration.keySizeInBits,
            options: configuration.options,
            inputData: configuration.inputData
        )
        let parameters = configuration.options
        // DEPRECATED: for (key, value) in parameters {
            options[key] = value
        }

        // Create a security configuration directly from the DTO
        let securityConfig = SecurityConfiguration(
            securityLevel: .standard,
            encryptionAlgorithm: configuration.algorithm,
            hashAlgorithm: configuration.options["hashAlgorithm"] ?? "SHA-256",
            options: configuration.options
        )

        // Update the provider with the new configuration
        do {
            if let securityProvider = provider as? SecurityProvider {
                try await securityProvider.updateSecurityConfiguration(securityConfig)
            } else if let dtoProvider = provider as? SecurityProviderDTO {
                try await dtoProvider.updateSecurityConfiguration(securityConfig)
            }
            return .success(())
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 1100,
                domain: "security.configuration",
                message: "Failed to update security configuration: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func getHostIdentifier() async -> Result<String, CoreDTOs.SecurityErrorDTO> {
        // Since there's no direct method in SecurityProviderProtocol, we'll use a secure operation
        let config = provider.createSecureConfig(options: ["operation": "getHostIdentifier"])
        let result = await provider.performSecureOperation(
            operation: .keyRetrieval,
            config: config
        )
        if let data = result.data,
           let hostId = String(data: data.toData(), encoding: .utf8)
        {
            return .success(hostId)
        } else {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3005,
                domain: "security.adapter",
                message: "Invalid host identifier format",
                details: [:]
            ))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, CoreDTOs.SecurityErrorDTO> {
        // Use secure operation to register client
        let config = provider.createSecureConfig(options: [
            "operation": "registerClient",
            "bundleIdentifier": bundleIdentifier,
        ])
        let result = await provider.performSecureOperation(
            operation: .keyStorage,
            config: config
        )
        if let data = result.data,
           let successString = String(data: data.toData(), encoding: .utf8),
           let success = Bool(successString)
        {
            return .success(success)
        } else {
            // DEPRECATED: return .success(true) // Default to success if we can't parse the result
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // Use secure operation for key rotation
        let config = provider.createSecureConfig(options: [
            "operation": "requestKeyRotation",
            "keyId": keyId,
        ])
        _ = await provider.performSecureOperation(
            operation: .keyRotation,
            config: config
        )
        return .success(())
    }

    public func notifyKeyCompromise(keyId: String) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // Use secure operation for compromised key notification
        let config = provider.createSecureConfig(options: [
            "operation": "notifyKeyCompromise",
            "keyId": keyId,
        ])
        _ = await provider.performSecureOperation(
            operation: .keyDeletion,
            config: config
        )
        return .success(())
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // We can delegate this to randomBytes since they serve the same purpose
        await randomBytes(count: length)
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Use crypto service to generate random bytes
        let result = await provider.cryptoService.generateRandomData(length: count)
        switch result {
        case let .success(data):
            return .success(data)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3009,
                domain: "security.adapter",
                message: "Error generating random bytes: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Use crypto service for encryption
        let result = await provider.cryptoService.encrypt(data: data, using: key)
        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3010,
                domain: "security.adapter",
                message: "Error encrypting data: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func performSecurityOperationDTO(
        operationName: String,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        var options: [String: Any] = [
            "operation": operationName,
        ]

        // Add all parameters to the options dictionary
        // DEPRECATED: for (key, value) in parameters {
            options[key] = value
        }

        // Create configuration
        var config = provider.createSecureConfig(options: options)

        // Map operation name to SecurityOperation type
        let operation: SecurityOperation = switch operationName {
        case "symmetricEncryption", "encrypt":
            .symmetricEncryption
        case "symmetricDecryption", "decrypt":
            .symmetricDecryption
        case "asymmetricEncryption":
            .asymmetricEncryption
        case "asymmetricDecryption":
            .asymmetricDecryption
        case "hashing", "hash":
            .hashing
        case "macGeneration", "mac":
            .macGeneration
        case "keyGeneration", "generateKey":
            .keyGeneration
        case "keyStorage", "storeKey":
            .keyStorage
        case "keyRetrieval", "getKey":
            .keyRetrieval
        case "keyRotation", "rotateKey":
            .keyRotation
        case "keyDeletion", "deleteKey":
            .keyDeletion
        case "randomGeneration", "random":
            .randomGeneration
        case "signatureGeneration", "sign":
            .signatureGeneration
        case "signatureVerification", "verify":
            .signatureVerification
        default:
            // Default to key retrieval for unknown operations
            .keyRetrieval
        }

        // If data is provided, add it to the config
        if let inputData = data {
            config.setInputData(inputData)
        }

        let result = await provider.performSecureOperation(
            operation: operation,
            config: config
        )

        if let resultData = result.data {
            return .success(resultData)
        } else {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.adapter",
                message: "Operation returned no data",
                details: [:]
            ))
        }
    }

    public func performSecurityOperationDTO(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        var options: [String: Any] = [
            "operation": operation.rawValue,
        ]

        // Add all parameters to the options dictionary
        // DEPRECATED: for (key, value) in parameters {
            options[key] = value
        }

        // Create configuration
        var config = provider.createSecureConfig(options: options)

        // If data is provided, add it to the config
        if let inputData = data {
            config.setInputData(inputData)
        }

        let result = await provider.performSecureOperation(
            operation: operation,
            config: config
        )

        if let resultData = result.data {
            return .success(resultData)
        } else {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.adapter",
                message: "Operation returned no data",
                details: [:]
            ))
        }
    }

    // MARK: - SecurityProviderProtocol Implementation

    public func createSecureConfig(options: [String: String]?) -> Result<CoreDTOs.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        // Create a default configuration
        // This just uses sensible defaults for example purposes
        let config = CoreDTOs.SecurityConfigDTO(
            algorithm: options?["algorithm"] ?? "AES",
            keySizeInBits: Int(options?["keySizeInBits"] ?? "256") ?? 256,
            options: options ?? [:]
        )

        return .success(config)
    }

    /// Extracts parameters from a dictionary of options
    /// - Parameter optionsDict: The options dictionary to extract from
    /// - Returns: A dictionary of string parameters
    private func extractStringParameters(from optionsDict: [String: String]) -> [String: String] {
        var result = [String: String]()

        // Extract parameters from options dictionary
        // DEPRECATED: for (key, value) in optionsDict {
            // Value is already a string, so we can use it directly
            result[key] = value
        }

        return result
    }
}

// MARK: - Extensions for SecurityConfigDTO

extension CoreDTOs.SecurityConfigDTO {
    /// Convert this config DTO to a parameter dictionary for use with security operations
    /// - Returns: A dictionary of string parameters
    func asParameters() -> [String: String] {
        var params = [String: String]()

        // Add options from the options dictionary
        // DEPRECATED: for (key, value) in options {
            // All values are already strings, just add them directly
            params[key] = value
        }

        return params
    }
}

extension SecurityProtocolsCore.SecurityConfigDTO {
    /// Sets the input data for the operation
    /// - Parameter data: The input data as SecureBytes
    mutating func setInputData(_: SecureBytes) {
        // Note: This is a placeholder since inputData is not directly accessible
        // The actual implementation would depend on how SecurityConfigDTO is defined
        // and whether it has a mutable inputData property
    }

    /// Converts the DTO to a parameter dictionary for use in security operations
    /// - Returns: A dictionary with string keys and values
    func toParameterDictionary() -> [String: String] {
        var result = [String: String]()

        // Extract parameters from options dictionary
        // DEPRECATED: for (key, value) in options {
            result[key] = value
        }

        return result
    }
}

extension SecureBytes {
    /// Convert SecureBytes to Data
    /// - Returns: Foundation Data representation of the bytes
    func toData() -> Data {
        var result = Data(count: count)
        withUnsafeBytes { buffer in
            result.withUnsafeMutableBytes { targetBuffer in
                guard let target = targetBuffer.baseAddress, let source = buffer.baseAddress else {
                    return
                }
                memcpy(target, source, Swift.min(targetBuffer.count, buffer.count))
            }
        }
        return result
    }
}

// MARK: - Utility class for creating DTO-compatible security providers

/// Utility class for creating DTO-compatible security providers
public enum SecurityProviderDTOFactory {
    /// Create a SecurityProviderDTO instance
    /// - Parameter environment: Optional environment parameters
    /// - Returns: A Foundation-independent SecurityProviderDTO
    @MainActor
    public static func createSecurityProviderDTO(environment _: [String: String]? = nil) -> any SecurityProviderDTO {
        // Create a provider using the security provider adapter
        let config = ProviderFactoryConfiguration(
            useModernProtocols: true,
            useMockServices: false,
            securityLevel: .standard,
            options: [:]
        )
        // DEPRECATED: let provider = SecurityProviderAdapterFactory.shared.createSecurityProvider(config: config)
        // DEPRECATED: return SecurityProviderDTOAdapter(provider: provider)
    }
}

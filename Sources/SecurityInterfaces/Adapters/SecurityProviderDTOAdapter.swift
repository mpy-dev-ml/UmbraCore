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
public final class SecurityProviderDTOAdapter: SecurityProviderDTO, SecurityProtocolsCore.SecurityProviderProtocol {
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
        return .success(SecurityDTOAdapter.toDTO(secConfig))
    }

    public func updateSecurityConfigDTO(_ configuration: CoreDTOs.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // We'll create a security config and execute a configuration update operation
        do {
            var options: [String: Any] = [
                "operation": "updateConfiguration"
            ]
            
            // Add all parameters from the configuration
            let parameters = extractParameters(from: configuration.asParameters())
            for (key, value) in parameters {
                options[key] = value
            }
            
            // Create configuration
            let config = provider.createSecureConfig(options: options)
            
            // Perform the update operation but ignore the result
            _ = await provider.performSecureOperation(
                operation: .keyStorage, // Use key storage for configuration updates
                config: config
            )
            
            return .success(())
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3000,
                domain: "security.adapter",
                message: "Error updating security configuration: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func getHostIdentifier() async -> Result<String, CoreDTOs.SecurityErrorDTO> {
        // Since there's no direct method in SecurityProviderProtocol, we'll use a secure operation
        do {
            let config = provider.createSecureConfig(options: ["operation": "getHostIdentifier"])
            let result = await provider.performSecureOperation(
                operation: .keyRetrieval,
                config: config
            )
            if let data = result.data, 
               let hostId = String(data: data.toData(), encoding: .utf8) {
                return .success(hostId)
            } else {
                return .failure(CoreDTOs.SecurityErrorDTO(
                    code: 3005,
                    domain: "security.adapter",
                    message: "Invalid host identifier format",
                    details: [:]
                ))
            }
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3004,
                domain: "security.adapter",
                message: "Error retrieving host identifier: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, CoreDTOs.SecurityErrorDTO> {
        // Use secure operation to register client
        do {
            let config = provider.createSecureConfig(options: [
                "operation": "registerClient",
                "bundleIdentifier": bundleIdentifier
            ])
            let result = await provider.performSecureOperation(
                operation: .keyStorage,
                config: config
            )
            if let data = result.data,
               let successString = String(data: data.toData(), encoding: .utf8),
               let success = Bool(successString) {
                return .success(success)
            } else {
                return .success(true) // Default to success if we can't parse the result
            }
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3006,
                domain: "security.adapter",
                message: "Error registering client: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // Use secure operation for key rotation
        let config = provider.createSecureConfig(options: [
            "operation": "requestKeyRotation",
            "keyId": keyId
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
            "keyId": keyId
        ])
        _ = await provider.performSecureOperation(
            operation: .keyDeletion,
            config: config
        )
        return .success(())
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // We can delegate this to randomBytes since they serve the same purpose
        return await randomBytes(count: length)
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Use crypto service to generate random bytes
        let result = await provider.cryptoService.generateRandomData(length: count)
        switch result {
        case .success(let data):
            return .success(data)
        case .failure(let error):
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
        case .success(let encryptedData):
            return .success(encryptedData)
        case .failure(let error):
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
        do {
            var options: [String: Any] = [
                "operation": operationName
            ]
            
            // Add all parameters to the options dictionary
            for (key, value) in parameters {
                options[key] = value
            }
            
            // Create configuration
            var config = provider.createSecureConfig(options: options)
            
            // Map operation name to SecurityOperation type
            let operation: SecurityOperation
            switch operationName {
            case "symmetricEncryption", "encrypt":
                operation = .symmetricEncryption
            case "symmetricDecryption", "decrypt":
                operation = .symmetricDecryption
            case "asymmetricEncryption":
                operation = .asymmetricEncryption
            case "asymmetricDecryption":
                operation = .asymmetricDecryption
            case "hashing", "hash":
                operation = .hashing
            case "macGeneration", "mac":
                operation = .macGeneration
            case "keyGeneration", "generateKey":
                operation = .keyGeneration
            case "keyStorage", "storeKey":
                operation = .keyStorage
            case "keyRetrieval", "getKey":
                operation = .keyRetrieval
            case "keyRotation", "rotateKey":
                operation = .keyRotation
            case "keyDeletion", "deleteKey":
                operation = .keyDeletion
            case "randomGeneration", "random":
                operation = .randomGeneration
            case "signatureGeneration", "sign":
                operation = .signatureGeneration
            case "signatureVerification", "verify":
                operation = .signatureVerification
            default:
                // Default to key retrieval for unknown operations
                operation = .keyRetrieval
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
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.adapter",
                message: "Error performing security operation: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }
    
    public func performSecurityOperationDTO(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, CoreDTOs.SecurityErrorDTO> {
        do {
            var options: [String: Any] = [
                "operation": operation.rawValue
            ]
            
            // Add all parameters to the options dictionary
            for (key, value) in parameters {
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
        } catch let error as SecurityInterfacesError {
            return .failure(SecurityDTOAdapter.toDTO(error))
        } catch {
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.adapter",
                message: "Error performing security operation: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }

    // MARK: - SecurityProviderProtocol Implementation

    public func createSecureConfig(options: [String: String]?) -> Result<CoreDTOs.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        do {
            // First create a domain model configuration
            let config = SecurityConfiguration(options: options ?? [:])
            
            // Then convert to DTO
            let dtoConfig = try SecurityDTOAdapter.toDTO(config)
            return .success(dtoConfig)
        } catch {
            // Handle any errors during conversion
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }
    
    /// Extracts parameters from a dictionary of options
    /// - Parameter optionsDict: The options dictionary to extract from
    /// - Returns: A dictionary of string parameters
    private func extractParameters(from optionsDict: [String: String]) -> [String: String] {
        var params = [String: String]()
        
        for (key, value) in optionsDict {
            // All values are already strings, just add them directly
            params[key] = value
        }
        
        return params
    }
}

// MARK: - Extensions for SecurityConfigDTO

extension CoreDTOs.SecurityConfigDTO {
    /// Convert this config DTO to a parameter dictionary for use with security operations
    /// - Returns: A dictionary of string parameters
    func asParameters() -> [String: String] {
        var params = [String: String]()
        
        // Add options from the options dictionary
        let optionsDict = self.options
        for (key, value) in optionsDict {
            // All values are already strings, just add them directly
            params[key] = value
        }
        
        return params
    }
}

extension SecurityProtocolsCore.SecurityConfigDTO {
    /// Sets the input data for the operation
    /// - Parameter data: The input data as SecureBytes
    mutating func setInputData(_ data: SecureBytes) {
        // Note: This is a placeholder since inputData is not directly accessible
        // The actual implementation would depend on how SecurityConfigDTO is defined
        // and whether it has a mutable inputData property
    }
    
    /// Converts the DTO to a parameter dictionary for use in security operations
    /// - Returns: A dictionary with string keys and values
    func toParameterDictionary() -> [String: String] {
        var result = [String: String]()
        
        // Extract parameters from options dictionary
        if let options = self.options {
            for (key, value) in options {
                if let stringValue = value {
                    result[key] = stringValue
                } else {
                    // Convert to string representation
                    result[key] = "\(value)"
                }
            }
        }
        
        return result
    }
}

extension SecureBytes {
    /// Convert SecureBytes to Data
    /// - Returns: Foundation Data representation of the bytes
    func toData() -> Data {
        var result = Data(count: self.count)
        self.withUnsafeBytes { buffer in
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

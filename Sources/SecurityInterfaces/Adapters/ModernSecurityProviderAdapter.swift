// DEPRECATED: ModernSecurityProviderAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Modern adapter implementation that wraps a security provider and service
/// and implements the SecurityProviderProtocol using both components.
@available(macOS 14.0, *)
public final class ModernSecurityProviderAdapter: SecurityProtocolsCore.SecurityProviderProtocol {
    // MARK: - Properties
    
    /// The security provider
    private let provider: any SecurityProtocolsCore.SecurityProviderProtocol
    
    /// The underlying XPC service
    private let _service: any XPCServiceProtocolBasic
    
    /// The XPC service accessor
    public let service: any XPCServiceProtocolBasic
    
    /// The crypto service from the provider
    public let cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol
    
    /// The key manager from the provider
    public let keyManager: any SecurityProtocolsCore.KeyManagementProtocol

    // MARK: - Initialization

    /// Initialize a new ModernSecurityProviderAdapter
    /// - Parameters:
    ///   - provider: The security provider to wrap
    ///   - service: The XPC service to use
    public init(provider: any SecurityProtocolsCore.SecurityProviderProtocol, service: any XPCServiceProtocolBasic) {
        self.provider = provider
        self._service = service
        self.service = service
        self.cryptoService = provider.cryptoService
        self.keyManager = provider.keyManager
    }

    // MARK: - SecurityProviderProtocol implementation

    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        await provider.performSecureOperation(operation: operation, config: config)
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        provider.createSecureConfig(options: options)
    }

    // MARK: - SecurityProvider Protocol implementation

    public func getSecurityConfiguration() async -> Result<SecurityConfiguration, SecurityInterfacesError> {
        // Get the status from the service
        let statusResult = await getServiceStatus()

        switch statusResult {
        case let .success(status):
            // Create a security configuration from the status
            var securityLevel: SecurityLevel = .standard
            if let levelString = status["securityLevel"], let level = Int(levelString), let secLevel = SecurityLevel(rawValue: level) {
                securityLevel = secLevel
            }

            // Create a basic configuration with defaults
            let config = SecurityConfiguration(
                securityLevel: securityLevel,
                encryptionAlgorithm: "AES-256",
                hashAlgorithm: "SHA-256",
                options: nil
            )
            return .success(config)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func configure(_ configuration: SecurityConfiguration) async -> Result<SecurityConfiguration, SecurityInterfacesError> {
        let securityLevel = configuration.securityLevel.rawValue

        // Create a configuration for the security level update
        let options = [
            "securityLevel": String(securityLevel),
            "encryptionEnabled": "true",
            "hashingEnabled": "true"
        ]

        let config = provider.createSecureConfig(options: options)

        // Perform the security operation using keyGeneration as a substitute for configuration
        // since there's no specific enum case for configuration updates
        let result = await provider.performSecureOperation(
            operation: .keyGeneration,
            config: config
        )

        // Handle the result
        if result.success {
            return .success(configuration)
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to configure security provider"))
        }
    }

    public func updateSecurityConfiguration(_ configuration: SecurityConfiguration) async throws {
        // Use configure instead since it's already implemented with the proper approach
        let result = await configure(configuration)

        switch result {
        case .success:
            return
        case let .failure(error):
            throw error
        }
    }

    public func getHostIdentifier() async -> Result<String, SecurityInterfacesError> {
        // Use the status method instead as getHardwareIdentifier is not available
        let statusResult = await _service.status()
        
        switch statusResult {
        case .success(let statusInfo):
            // Try to extract hardware identifier from status info
            if let hostId = statusInfo["hardwareIdentifier"] as? String {
                return .success(hostId)
            }
            
            // Fallback to a machine identifier if available
            if let machineId = statusInfo["machineIdentifier"] as? String {
                return .success(machineId)
            }
            
            // If even that fails, use a UUID derived from machine info
            return .success(UUID().uuidString)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        // Create a configuration for the registration operation
        let options = ["bundleIdentifier": bundleIdentifier]
        let config = provider.createSecureConfig(options: options)

        // Perform the security operation using keyStorage as a substitute
        // since there's no specific enum case for client registration
        let result = await provider.performSecureOperation(
            operation: .keyStorage,
            config: config
        )

        // Handle the result
        if result.success {
            return .success(true)
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to register client"))
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Create a configuration for the key rotation operation
        let config = provider.createSecureConfig(options: nil)
        let configWithKey = config.withKeyIdentifier(keyId)

        // Perform the security operation
        let result = await provider.performSecureOperation(
            operation: .keyRotation,
            config: configWithKey
        )

        // Handle the result
        if result.success {
            return .success(())
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to request key rotation"))
        }
    }

    public func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Create a configuration for the key compromise operation
        let options = ["compromised": "true"]
        let config = provider.createSecureConfig(options: options)
        let configWithKey = config.withKeyIdentifier(keyId)

        // Perform the security operation
        let result = await provider.performSecureOperation(
            operation: .keyDeletion, // Use key deletion as it's the closest operation
            config: configWithKey
        )

        // Handle the result
        if result.success {
            return .success(())
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to notify key compromise"))
        }
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        if length <= 0 {
            return .failure(.invalidParameters("Length must be a positive value"))
        }
        
        // Try to use the crypto service since it has methods for generating random data
        let result = await cryptoService.generateRandomData(length: length)
        switch result {
        case .success(let data):
            // Convert Data to SecureBytes
            let bytes = [UInt8](data)
            return .success(SecureBytes(bytes: bytes))
        case .failure(let error):
            // Convert UmbraErrors.Security.Protocols to SecurityInterfacesError directly
            return .failure(SecurityProviderUtils.mapSPCError(error))
        }
    }

    public func getKeyInformation(keyID: String) async -> Result<SecurityKeyInformationDTO, SecurityInterfacesError> {
        // Use the key manager directly
        let keyService = provider.keyManager
        
        // Use retrieveKey instead of getKeyInformation
        let result = await keyService.retrieveKey(withIdentifier: keyID)
        
        // Process the result
        switch result {
        case .success(_):
            // Convert to a more structured format
            let keyInfo = SecurityKeyInformationDTO(
                keyID: keyID,
                algorithm: "unknown", // We don't have algorithm info from basic retrieval
                creationDate: Date(),
                expiryDate: nil,
                status: "active",
                metadata: ["status": "active"]
            )
            return .success(keyInfo)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapSPCError(error))
        }
    }

    public func registerBundle(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        // Create a configuration for the registration operation
        let options: [String: Any] = ["bundleIdentifier": bundleIdentifier]
        
        // Create a secure config for the operation
        let config = provider.createSecureConfig(options: options)
        
        // Register the bundle with the service using key storage as a proxy for registration
        let result = await provider.performSecureOperation(operation: .keyStorage, config: config)
        
        // Process the result
        if result.success {
            return .success(true)
        } else {
            if let error = result.error {
                return .failure(SecurityProviderUtils.mapSPCError(error))
            } else {
                return .failure(.operationFailed(result.errorMessage ?? "Failed to register bundle"))
            }
        }
    }

    public func performKeyGeneration(options: [String: String]) async -> Result<SecurityKeyDTO, SecurityInterfacesError> {
        // Create a configuration for the key generation operation
        let keyOptions: [String: Any] = [
            "algorithm": options["algorithm"] ?? "AES256",
            "keySize": options["keySize"] ?? "256",
            "keyType": options["keyType"] ?? "symmetric"
        ]
        
        // Create a secure config for the operation
        let config = provider.createSecureConfig(options: keyOptions)
        
        // Perform key generation using the standard operation
        let result = await provider.performSecureOperation(operation: .keyGeneration, config: config)
        
        // Process the result
        if result.success, let output = result.data {
            // Convert to a more structured format
            let keyData = output
            
            // Create a DTO version of the key
            return .success(SecurityKeyDTO(
                id: UUID().uuidString,
                algorithm: keyOptions["algorithm"] as? String ?? "AES256",
                keyData: keyData.toBinaryData(),
                metadata: ["keyType": keyOptions["keyType"] as? String ?? "symmetric"]
            ))
        } else {
            if let error = result.error {
                return .failure(SecurityProviderUtils.mapSPCError(error))
            } else {
                return .failure(.operationFailed(result.errorMessage ?? "Failed to generate key"))
            }
        }
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        await generateRandomData(length: count)
    }

    public func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Create a configuration with the data to encrypt and the key
        let config = provider.createSecureConfig(options: nil)
        let configWithInputData = config.withInputData(data)
        let configWithKey = configWithInputData.withKey(key)

        // Perform the encryption operation
        let result = await provider.performSecureOperation(
            operation: .symmetricEncryption,
            config: configWithKey
        )

        // Handle the result
        if let encryptedData = result.data {
            return .success(encryptedData)
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Encryption failed"))
        }
    }

    public func performSecurityOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityResult {
        // Convert data to SecureBytes if provided
        let secureData = data.map { SecurityProviderUtils.dataToSecureBytes($0) }

        // Create a configuration
        let config = provider.createSecureConfig(options: parameters)
        let configWithInputData = secureData.map { config.withInputData($0) } ?? config

        // Perform the operation
        let result = await provider.performSecureOperation(
            operation: operation,
            config: configWithInputData
        )

        // Convert the result
        if result.success {
            let resultData = result.data.map { SecurityProviderUtils.secureBytesToData($0) }
            return SecurityResult(success: true, data: resultData)
        } else if let error = result.error {
            throw SecurityInterfacesError.operationFailed("Operation failed: \(error.localizedDescription)")
        } else {
            throw SecurityInterfacesError.operationFailed("Operation failed with unknown error")
        }
    }

    public func performSecurityOperation(
        operationName: String,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityResult {
        // Map the operation name to a SecurityOperation enum value
        guard let operation = SecurityProtocolsCore.SecurityOperation(rawValue: operationName) else {
            throw SecurityInterfacesError.operationFailed("Invalid operation name: \(operationName)")
        }

        return try await performSecurityOperation(
            operation: operation,
            data: data,
            parameters: parameters
        )
    }

    public func getRandomBytes(length: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Create a configuration for random bytes generation
        let options: [String: Any] = ["length": length]
        
        // Create a secure config for the operation
        let config = provider.createSecureConfig(options: options)
        
        // Get random bytes using the standard operation
        let result = await provider.performSecureOperation(operation: .randomGeneration, config: config)
        
        // Process the result
        if result.success, let data = result.data {
            return .success(data)
        } else {
            if let error = result.error {
                return .failure(SecurityProviderUtils.mapSPCError(error))
            } else {
                return .failure(.operationFailed(result.errorMessage ?? "Failed to generate random bytes"))
            }
        }
    }

    private func handleResponse<T>(_ result: Result<T, Error>) -> Result<T, SecurityInterfacesError> {
        switch result {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            // Convert error to SecurityInterfacesError
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        }
    }

    private func handleServiceOperationResult<T>(_ result: Result<T, Error>) -> Result<T, SecurityInterfacesError> {
        switch result {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        }
    }

    private func getServiceStatus() async -> Result<[String: String], SecurityInterfacesError> {
        // For the status, we don't need a cast since we require a service that conforms
        // to XPCServiceProtocolBasic in the constructor
        let statusResult = await _service.status()
        
        switch statusResult {
        case .success(let result):
            // Convert the dictionary to string-string dictionary
            var stringDict: [String: String] = [:]
            for (key, value) in result {
                stringDict[key] = String(describing: value)
            }
            return .success(stringDict)
        case .failure(let error):
            // Use the mapToSecurityInterfacesError directly with the error
            return .failure(SecurityProviderUtils.mapToSecurityInterfacesError(error))
        }
    }
}

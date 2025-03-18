import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Modern adapter implementation conforming to SecurityProvider protocol
/// This adapter works with the modern SecurityProtocolsCore provider
@available(macOS 14.0, *)
public final class ModernSecurityProviderAdapter: SecurityProvider {
    // MARK: - Properties

    private let provider: any SecurityProtocolsCore.SecurityProviderProtocol
    private let service: any XPCServiceProtocolBasic

    /// The crypto service from the provider
    public var cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol {
        provider.cryptoService
    }

    /// The key manager from the provider
    public var keyManager: any SecurityProtocolsCore.KeyManagementProtocol {
        provider.keyManager
    }

    // MARK: - Initialization

    /// Create a Modern Security Provider Adapter
    /// - Parameters:
    ///   - provider: The security provider to adapt
    ///   - service: The XPC service to use
    public init(
        provider: any SecurityProtocolsCore.SecurityProviderProtocol,
        service: any XPCServiceProtocolBasic
    ) {
        self.provider = provider
        self.service = service
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
        case .success(let status):
            // Create a security configuration from the status
            var securityLevel: SecurityLevel = .standard
            if let levelString = status["securityLevel"], let level = Int(levelString), let secLevel = SecurityLevel(rawValue: level) {
                securityLevel = secLevel
            }

            // Create a basic configuration with defaults
            let config = SecurityConfiguration(securityLevel: securityLevel)
            return .success(config)
        case .failure(let error):
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

        var config = provider.createSecureConfig(options: options)

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
            return .failure(SecurityProviderUtils.mapSPCError(error))
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
        case .failure(let error):
            throw error
        }
    }

    public func getHostIdentifier() async -> Result<String, SecurityInterfacesError> {
        // Use the XPC service to get hardware identifier
        let result = await service.getHardwareIdentifier()

        switch result {
        case .success(let identifier):
            return .success(identifier)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapXPCError(error))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        // Create a configuration for the registration operation
        let options = ["bundleIdentifier": bundleIdentifier]
        var config = provider.createSecureConfig(options: options)

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
            return .failure(SecurityProviderUtils.mapSPCError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to register client"))
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Create a configuration for the key rotation operation
        var config = provider.createSecureConfig(options: nil)
        config = config.withKeyIdentifier(keyId)

        // Perform the security operation
        let result = await provider.performSecureOperation(
            operation: .keyRotation,
            config: config
        )

        // Handle the result
        if result.success {
            return .success(())
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapSPCError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to request key rotation"))
        }
    }

    public func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Create a configuration for the key compromise operation
        var config = provider.createSecureConfig(options: ["compromised": "true"])
        config = config.withKeyIdentifier(keyId)

        // Perform the security operation
        let result = await provider.performSecureOperation(
            operation: .keyDeletion, // Use key deletion as it's the closest operation
            config: config
        )

        // Handle the result
        if result.success {
            return .success(())
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapSPCError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to notify key compromise"))
        }
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Use the XPC service directly
        let result = await service.generateRandomData(length: length)

        switch result {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapXPCError(error))
        }
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfacesError> {
        // Create a configuration with keyIdentifier
        var config = provider.createSecureConfig(options: nil)
        config = config.withKeyIdentifier(keyId)

        // Perform the key info operation
        let result = await provider.performSecureOperation(
            operation: .keyInfo,
            config: config
        )

        // Handle the result
        if result.success, let options = result.options {
            // Convert options to [String: AnyObject]
            var keyInfo: [String: AnyObject] = [:]
            for (key, value) in options {
                keyInfo[key] = value as AnyObject
            }
            return .success(keyInfo)
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapSPCError(error))
        } else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to get key info"))
        }
    }

    public func registerNotifications() async -> Result<Void, SecurityInterfacesError> {
        // For now, just handle this as a special operation rather than through the provider
        // since there's no direct SecurityOperation enum case for registering notifications
        do {
            // Directly call the service ping operation as a way to validate connectivity
            let pingResult = await service.ping()
            if pingResult {
                return .success(())
            } else {
                return .failure(.operationFailed("Service not available"))
            }
        } catch {
            return .failure(.operationFailed("Failed to register notifications: \(error.localizedDescription)"))
        }
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        await generateRandomData(length: count)
    }

    public func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Create a configuration with the data to encrypt and the key
        var config = provider.createSecureConfig(options: nil)
        config = config.withInputData(data)
        config = config.withKey(key)

        // Perform the encryption operation
        let result = await provider.performSecureOperation(
            operation: .symmetricEncryption,
            config: config
        )

        // Handle the result
        if let encryptedData = result.data {
            return .success(encryptedData)
        } else if let error = result.error {
            return .failure(SecurityProviderUtils.mapSPCError(error))
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
        var config = provider.createSecureConfig(options: parameters)
        if let secureData = secureData {
            config = config.withInputData(secureData)
        }

        // Perform the operation
        let result = await provider.performSecureOperation(
            operation: operation,
            config: config
        )

        // Convert the result
        if result.success {
            let resultData = result.data.map { SecurityProviderUtils.secureBytesToData($0) }
            return SecurityResult(success: true, data: resultData)
        } else if let error = result.error {
            throw SecurityProviderUtils.mapSPCError(error)
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

    private func getServiceStatus() async -> Result<[String: String], SecurityInterfacesError> {
        // Use service's type to check if it can provide status
        if let standardService = service as? XPCServiceProtocolStandard {
            // Get the status from the service
            let statusResult = await standardService.status()
            
            // Handle the result
            switch statusResult {
            case .success(let statusDict):
                // Convert the AnyObject values to strings
                var stringDict: [String: String] = [:]
                for (key, value) in statusDict {
                    stringDict[key] = String(describing: value)
                }
                return .success(stringDict)
            case .failure(let error):
                return .failure(.operationFailed("Failed to get service status: \(error)"))
            }
        } else {
            // Basic service doesn't support status
            return .success(["status": "active", "type": "basic"])
        }
    }
}

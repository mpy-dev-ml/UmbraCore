import CoreTypesInterfaces
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import FoundationBridgeTypes
import SecurityBridge
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Legacy adapter implementation conforming to SecurityProvider protocol
/// This adapter works with older SecurityProviderBase implementations
@available(macOS 14.0, *)
@available(*, deprecated, message: "Use ModernSecurityProviderAdapter instead")
public final class LegacySecurityProviderAdapter: SecurityProvider {
    // MARK: - Properties

    private let legacyProvider: any SecurityProviderBase
    private let service: any XPCServiceProtocolStandard
    private let cryptoServiceImpl: any SecurityProtocolsCore.CryptoServiceProtocol
    private let keyManagerImpl: any SecurityProtocolsCore.KeyManagementProtocol

    /// The crypto service from the provider
    public var cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol {
        cryptoServiceImpl
    }

    /// The key manager from the provider
    public var keyManager: any SecurityProtocolsCore.KeyManagementProtocol {
        keyManagerImpl
    }

    // MARK: - Initialization

    /// Initialize with a legacy provider and XPC service
    /// - Parameters:
    ///   - legacyProvider: The SecurityProviderBase implementation to adapt
    ///   - service: The XPC service to use
    ///   - cryptoService: The crypto service to use
    ///   - keyManager: The key manager to use
    public init(
        legacyProvider: any SecurityProviderBase,
        service: any XPCServiceProtocolStandard,
        cryptoService: any SecurityProtocolsCore.CryptoServiceProtocol,
        keyManager: any SecurityProtocolsCore.KeyManagementProtocol
    ) {
        self.legacyProvider = legacyProvider
        self.service = service
        self.cryptoServiceImpl = cryptoService
        self.keyManagerImpl = keyManager
    }

    /// Initialize with a legacy provider and mock services
    /// - Parameter legacyProvider: The SecurityProviderBase implementation to adapt
    public init(legacyProvider: any SecurityProviderBase) {
        self.legacyProvider = legacyProvider
        // Create a basic service and adapt it to the standard protocol
        let basicService = SecurityProviderMockXPCService()
        self.service = basicService as! any XPCServiceProtocolStandard
        self.cryptoServiceImpl = SecurityProviderMockCryptoService()
        self.keyManagerImpl = SecurityProviderMockKeyManager()
    }

    // MARK: - SecurityProviderProtocol implementation

    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        // For legacy providers, we need to map operations
        switch operation {
        case .symmetricEncryption, .symmetricDecryption:
            // Use crypto service for encryption/decryption
            let result = operation == .symmetricEncryption ?
                await cryptoService.encryptSymmetric(
                    data: config.data ?? UmbraCoreTypes.SecureBytes(bytes: []),
                    key: config.key ?? UmbraCoreTypes.SecureBytes(bytes: []),
                    config: config
                ) :
                await cryptoService.decryptSymmetric(
                    data: config.data ?? UmbraCoreTypes.SecureBytes(bytes: []),
                    key: config.key ?? UmbraCoreTypes.SecureBytes(bytes: []),
                    config: config
                )

            switch result {
            case .success(let data):
                return SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
            case .failure(let error):
                return SecurityProtocolsCore.SecurityResultDTO(
                    success: false,
                    error: SecurityProtocolsCore.SecurityError.operationFailed(operation: "decrypt", reason: "\(error)")
                )
            }

        case .keyGeneration:
            // Use key manager for key generation
            let result = await keyManager.generateKey(type: .aes256, config: config)

            switch result {
            case .success(let keyId):
                return SecurityProtocolsCore.SecurityResultDTO(
                    success: true,
                    options: ["keyIdentifier": keyId]
                )
            case .failure(let error):
                return SecurityProtocolsCore.SecurityResultDTO(
                    success: false,
                    error: SecurityProtocolsCore.SecurityError.operationFailed(operation: "generateKey", reason: "\(error)")
                )
            }

        case .keyRotation:
            // Use legacy provider for key rotation
            let keyId = config.keyIdentifier ?? ""
            let result = await legacyProvider.requestKeyRotation(keyId: keyId)

            switch result {
            case .success:
                return SecurityProtocolsCore.SecurityResultDTO(success: true)
            case .failure(let error):
                return SecurityProtocolsCore.SecurityResultDTO(
                    success: false,
                    error: SecurityProtocolsCore.SecurityError.operationFailed(operation: "requestKeyRotation", reason: "\(error)")
                )
            }

        case .configUpdate:
            // For configuration updates, we can't directly map to legacy provider,
            // so we return a success result
            return SecurityProtocolsCore.SecurityResultDTO(success: true)

        default:
            // For unsupported operations, return a default result
            return SecurityProtocolsCore.SecurityResultDTO(
                success: false,
                error: SecurityProtocolsCore.SecurityError.operationFailed(operation: "unknown", reason: "Unsupported operation for legacy provider")
            )
        }
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore.SecurityConfigDTO {
        // Create a default config with the required algorithm and key size parameters
        SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: "AES",
            keySizeInBits: 256,
            options: options as? [String: String] ?? [:]
        )
    }

    // MARK: - SecurityProvider Protocol implementation

    public func getSecurityConfiguration() async -> Result<SecurityConfiguration, SecurityInterfacesError> {
        // Get service status from XPC service
        let result = await service.status()

        switch result {
        case .success(let status):
            let config = SecurityProviderUtils.createSecurityConfiguration(from: status)
            return .success(config)
        case .failure(let error):
            return .failure(SecurityProviderUtils.mapXPCError(error))
        }
    }

    public func updateSecurityConfiguration(_ configuration: SecurityConfiguration) async throws {
        // Legacy providers don't support security configuration updates,
        // so we just return successfully
    }

    public func getHostIdentifier() async -> Result<String, SecurityInterfacesError> {
        // Use the legacy provider directly
        let result = await legacyProvider.getHostIdentifier()

        switch result {
        case .success(let identifier):
            return .success(identifier)
        case .failure(let error):
            return .failure(SecurityInterfacesError.operationFailed("Host identifier error: \(error)"))
        }
    }

    public func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        // Use the legacy provider directly
        let result = await legacyProvider.registerClient(bundleIdentifier: bundleIdentifier)

        switch result {
        case .success(let registered):
            return .success(registered)
        case .failure(let error):
            return .failure(SecurityInterfacesError.operationFailed("Client registration error: \(error)"))
        }
    }

    public func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Use the legacy provider directly
        let result = await legacyProvider.requestKeyRotation(keyId: keyId)

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(SecurityInterfacesError.operationFailed("Key rotation error: \(error)"))
        }
    }

    public func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        // Use the legacy provider directly
        let result = await legacyProvider.notifyKeyCompromise(keyId: keyId)

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(SecurityInterfacesError.operationFailed("Key compromise notification error: \(error)"))
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
        // Legacy providers don't have key info functionality
        // Return a basic set of information
        let keyInfo: [String: AnyObject] = [
            "keyId": keyId as AnyObject,
            "type": "unknown" as AnyObject,
            "creationDate": Date() as AnyObject
        ]

        return .success(keyInfo)
    }

    public func registerNotifications() async -> Result<Void, SecurityInterfacesError> {
        // Legacy providers don't support notifications
        return .success(())
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        await generateRandomData(length: count)
    }

    public func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Use the crypto service directly
        let result = await cryptoService.encryptSymmetric(
            data: data,
            key: key,
            config: createSecureConfig(options: nil)
        )

        switch result {
        case .success(let encryptedData):
            return .success(encryptedData)
        case .failure(let error):
            return .failure(
                error: SecurityProtocolsCore.SecurityError.operationFailed(operation: "encrypt", reason: "\(error)")
            )
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
        var config = createSecureConfig(options: parameters)
        if let secureData = secureData {
            config = config.withInputData(secureData)
        }

        // Perform the operation
        let result = await performSecureOperation(
            operation: operation,
            config: config
        )

        // Convert the result
        if result.success {
            let resultData = result.data.map { SecurityProviderUtils.secureBytesToData($0) }
            return SecurityResult(success: true, data: resultData, options: result.options)
        } else if let error = result.error {
            throw SecurityProviderUtils.mapSPCError(error)
        } else {
            throw SecurityInterfacesError.operationFailed("Operation failed without specific error")
        }
    }

    public func performSecurityOperation(
        operationName: String,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityResult {
        // Map the operation name to a SecurityOperation enum value
        guard let operation = SecurityProtocolsCore.SecurityOperation(rawValue: operationName) else {
            throw SecurityInterfacesError.invalidParameters("Invalid operation name: \(operationName)")
        }

        return try await performSecurityOperation(
            operation: operation,
            data: data,
            parameters: parameters
        )
    }
}

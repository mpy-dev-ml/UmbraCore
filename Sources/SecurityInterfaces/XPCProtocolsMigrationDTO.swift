import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// MARK: - Modern XPC Service Protocol with DTOs

/// XPC Service protocol that uses Foundation-independent DTOs
/// This protocol is an extension of XPCServiceProtocolComplete with DTO support
public protocol XPCServiceProtocolDTO: XPCServiceProtocolComplete {
    /// Get the security configuration
    /// - Returns: Result with the security configuration DTO or an error
    func getSecurityConfigDTO() async -> Result<SecurityProtocolsCore.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO>

    /// Update the security configuration
    /// - Parameter config: The new security configuration DTO
    /// - Returns: Result with success or an error
    func updateSecurityConfigDTO(_ config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO>

    /// Encrypt data using the DTO-based approach
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - config: Configuration options
    /// - Returns: Encrypted data or an error
    func encryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO>

    /// Decrypt data using the DTO-based approach
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    ///   - config: Configuration options
    /// - Returns: Decrypted data or an error
    func decryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO>

    /// Perform a hash operation using the DTO-based approach
    /// - Parameters:
    ///   - data: Data to hash
    ///   - config: Configuration options
    /// - Returns: Hash data or an error
    func hashDTO(
        data: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO>

    /// Generate a key using the DTO-based approach
    /// - Parameter config: Key generation configuration
    /// - Returns: Generated key or an error
    func generateKeyDTO(
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO>
}

// MARK: - XPC Adapter for DTO Protocol

/// Adapter that implements XPCServiceProtocolDTO by wrapping XPCServiceProtocolComplete
/// This allows existing XPC services to be accessed through the Foundation-independent
/// DTO interface.
public final class XPCServiceDTOAdapter: XPCServiceProtocolDTO {
    // MARK: - Properties

    private let service: any XPCServiceProtocolComplete

    // MARK: - Initializer

    /// Initialize with an XPCServiceProtocolComplete
    /// - Parameter service: The service to adapt
    public init(_ service: any XPCServiceProtocolComplete) {
        self.service = service
    }

    // MARK: - XPCServiceProtocolComplete Implementation

    public static var protocolIdentifier: String {
        "\(XPCServiceProtocolComplete.protocolIdentifier).dto"
    }

    public func ping() async throws -> Bool {
        try await service.ping()
    }

    public func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async throws {
        try await service.synchroniseKeys(syncData)
    }

    public func status() async -> Result<SecurityServiceStatus, XPCProtocolsCore.SecurityError> {
        await service.status()
    }

    public func encrypt(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.encrypt(data: data, key: key, config: config)
    }

    public func decrypt(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.decrypt(data: data, key: key, config: config)
    }

    public func hash(
        data: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.hash(data: data, config: config)
    }

    public func generateKey(
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.generateKey(config: config)
    }

    public func authenticatedEncrypt(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        authData: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.authenticatedEncrypt(data: data, key: key, authData: authData, config: config)
    }

    public func authenticatedDecrypt(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        authData: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.authenticatedDecrypt(data: data, key: key, authData: authData, config: config)
    }

    public func secureRandom(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.secureRandom(length: length)
    }

    // MARK: - XPCServiceProtocolDTO Implementation

    public func getSecurityConfigDTO() async -> Result<SecurityProtocolsCore.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        let result = await service.status()
        switch result {
        case let .success(status):
            // Extract config information from status
            var options: [String: String] = [:]
            if let configDict = status.info["config"] as? [String: Any] {
                for (key, value) in configDict {
                    options[key] = String(describing: value)
                }
            }

            return .success(SecurityProtocolsCore.SecurityConfigDTO(
                algorithm: options["algorithm"] ?? "AES-GCM",
                keySizeInBits: Int(options["keySizeInBits"] ?? "256") ?? 256,
                options: options
            ))

        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func updateSecurityConfigDTO(_ config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await service.updateSecurityConfig(securityConfig)
        switch result {
        case .success:
            return .success(())
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func encryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await service.encrypt(data: data)
        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func decryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await service.decrypt(data: data)
        switch result {
        case let .success(decryptedData):
            return .success(decryptedData)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func hashDTO(
        data: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await service.generateHash(data: data)
        switch result {
        case let .success(hashData):
            return .success(hashData)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }

    public func generateKeyDTO(
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service with appropriate parameters
        let result = await service.generateKey(
            algorithm: config.algorithm,
            keySize: config.keySizeInBits,
            purpose: config.options["purpose"] ?? "general"
        )
        switch result {
        case let .success(keyData):
            return .success(keyData)
        case let .failure(error):
            return .failure(SecurityDTOAdapter.toDTO(error))
        }
    }
}

// MARK: - Factory

/// Factory for creating XPC service adapters with DTO support
public extension XPCProtocolMigrationFactory {
    /// Create a service adapter that supports Foundation-independent DTOs
    /// - Parameter service: The underlying XPC service
    /// - Returns: An XPCServiceProtocolDTO adapter
    static func createDTOAdapter(_ service: any XPCServiceProtocolComplete) -> any XPCServiceProtocolDTO {
        XPCServiceDTOAdapter(service)
    }

    /// Create a DTO adapter from a legacy XPC service
    /// - Parameter service: The legacy XPC service
    /// - Returns: An XPCServiceProtocolDTO adapter
    static func createDTOAdapterFromLegacy(_ service: any XPCServiceProtocol) -> any XPCServiceProtocolDTO {
        let completeAdapter = createCompleteAdapter(wrapping: service)
        return XPCServiceDTOAdapter(completeAdapter)
    }
}

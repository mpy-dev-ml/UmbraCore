import CoreDTOs
import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// MARK: - XPC Service Protocol with DTOs

/// XPC Service protocol that uses Foundation-independent DTOs
/// This protocol is an extension of XPCServiceProtocolComplete with DTO support
public protocol XPCServiceProtoDTO: XPCServiceProtocolComplete {
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

/// Adapter that implements XPCServiceProtoDTO by wrapping XPCServiceProtocolComplete
/// This allows existing XPC services to be accessed through the Foundation-independent
/// DTO interface.
public final class XPCServiceDTOAdapter: XPCServiceProtoDTO {
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
        "dto.xpc.service"
    }

    public func ping() async -> Bool {
        await service.ping()
    }

    public func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async throws {
        try await service.synchroniseKeys(syncData)
    }

    public func status() async -> Result<UmbraCoreTypes.SecurityServiceStatus, XPCProtocolsCore.SecurityError> {
        let result = await service.status()
        switch result {
        case let .success(statusDict):
            // Convert dictionary to SecurityServiceStatus
            let status = statusDict["status"] as? String ?? "unknown"
            let version = statusDict["version"] as? String ?? "0.0.0"
            let metrics = [String: Double]()
            let stringInfo = [String: String]()
            return .success(SecurityServiceStatus(
                status: status,
                version: version,
                metrics: metrics,
                stringInfo: stringInfo
            ))
        case let .failure(error):
            // Convert XPCSecurityError to XPCProtocolsCore.SecurityError
            return .failure(.internalError(reason: "Status retrieval failed: \(error.localizedDescription)"))
        }
    }

    public func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        await service.resetSecurity()
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await service.getServiceVersion()
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await service.getHardwareIdentifier()
    }

    public func pingStandard() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        let result = await service.ping()
        return .success(result)
    }

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.generateRandomData(length: length)
    }

    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.encryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.decryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.sign(data, keyIdentifier: keyIdentifier)
    }

    // DEPRECATED: public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // DEPRECATED: await service.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
    }

    public func generateKey(algorithm: String, keySize: Int, purpose: String) async -> Result<String, XPCProtocolsCore.SecurityError> {
        await service.generateKey(algorithm: algorithm, keySize: keySize, purpose: purpose)
    }

    public func deleteKey(keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        await service.deleteKey(keyIdentifier: keyIdentifier)
    }

    public func exportKey(keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        let result = await service.exportKey(keyIdentifier: keyIdentifier)
        switch result {
        case let .success(keyData):
            // Return the key data directly
            return .success(keyData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func generateSignature(data: UmbraCoreTypes.SecureBytes, keyIdentifier: String, algorithm: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await service.generateSignature(data: data, keyIdentifier: keyIdentifier, algorithm: algorithm)
    }

    public func verifySignature(signature: UmbraCoreTypes.SecureBytes, data: UmbraCoreTypes.SecureBytes, keyIdentifier: String, algorithm: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        await service.verifySignature(signature: signature, data: data, keyIdentifier: keyIdentifier, algorithm: algorithm)
    }

    // MARK: - SecurityAPI Implementation

    public func encrypt(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        let result = await service.encryptSecureData(data, keyIdentifier: nil)

        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func decrypt(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        let result = await service.decryptSecureData(data, keyIdentifier: nil)

        switch result {
        case let .success(decryptedData):
            return .success(decryptedData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func hash(
        data: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Use generateSignature with a special identifier to perform hashing
        let result = await service.generateSignature(
            data: data,
            keyIdentifier: "hash-operation",
            algorithm: config.algorithm
        )

        switch result {
        case let .success(hashData):
            return .success(hashData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func generateKey(
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Generate a key using the complete service adapter
        let result = await service.generateKey(
            algorithm: config.algorithm,
            keySize: config.keySizeInBits,
            purpose: "general"
        )

        switch result {
        case let .success(keyId):
            // Export the key to get the actual key data
            let exportResult = await service.exportKey(keyIdentifier: keyId)

            switch exportResult {
            case let .success(exportedData):
                // Clean up the key since we've exported it
                _ = await service.deleteKey(keyIdentifier: keyId)
                return .success(exportedData) // Access first element of the tuple
            case let .failure(error):
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    // MARK: - XPCServiceProtoDTO Implementation

    public func getSecurityConfigDTO() async -> Result<SecurityProtocolsCore.SecurityConfigDTO, CoreDTOs.SecurityErrorDTO> {
        let result = await service.status()
        switch result {
        case let .success(statusDict):
            // Extract config information from status
            var options: [String: String] = [:]

            // Add common status fields
            options["status"] = statusDict["status"] as? String ?? "unknown"
            options["version"] = statusDict["version"] as? String ?? "unknown"

            // Extract algorithm info from the status dictionary
            if let algorithm = statusDict["algorithm"] as? String {
                options["algorithm"] = algorithm
            }

            if let keySizeStr = statusDict["keySizeInBits"] as? String {
                options["keySizeInBits"] = keySizeStr
            } else if let keySize = statusDict["keySizeInBits"] as? Int {
                options["keySizeInBits"] = String(keySize)
            }

            // Add all other string values
            // DEPRECATED: for (key, value) in statusDict {
                if key != "algorithm", key != "status", key != "version" {
                    if let stringValue = value as? String {
                        options[key] = stringValue
                    } else if let numValue = value as? Double {
                        options[key] = String(numValue)
                    } else if let numValue = value as? Int {
                        options[key] = String(numValue)
                    }
                }
            }

            // Default values if not found
            let algorithm = options["algorithm"] ?? "AES-GCM"
            let keySizeInBits = Int(options["keySizeInBits"] ?? "256") ?? 256

            return .success(SecurityProtocolsCore.SecurityConfigDTO(
                algorithm: algorithm,
                keySizeInBits: keySizeInBits,
                options: options
            ))
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 500,
                message: "Failed to get security config: \(error.localizedDescription)",
                details: ["operation": "getSecurityConfig"]
            ))
        }
    }

    public func updateSecurityConfigDTO(_ config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<Void, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        _ = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        // DEPRECATED: return .success(()) // Return success for now until a proper implementation is available
    }

    public func encryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await encrypt(data: data, key: key, config: securityConfig)
        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 500,
                message: "Encryption failed: \(error.localizedDescription)",
                details: ["operation": "encrypt"]
            ))
        }
    }

    public func decryptDTO(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<UmbraCoreTypes.SecureBytes, CoreDTOs.SecurityErrorDTO> {
        // Convert DTO to SecurityConfig
        let securityConfig = SecurityConfig(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits
        )

        // Call the underlying service
        let result = await decrypt(data: data, key: key, config: securityConfig)
        switch result {
        case let .success(decryptedData):
            return .success(decryptedData)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 500,
                message: "Decryption failed: \(error.localizedDescription)",
                details: ["operation": "decrypt"]
            ))
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
        let result = await hash(data: data, config: securityConfig)
        switch result {
        case let .success(hashData):
            return .success(hashData)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 500,
                message: "Hashing failed: \(error.localizedDescription)",
                details: ["operation": "hash"]
            ))
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

        // Call the underlying service
        let result = await generateKey(config: securityConfig)
        switch result {
        case let .success(keyData):
            return .success(keyData)
        case let .failure(error):
            return .failure(CoreDTOs.SecurityErrorDTO(
                code: 500,
                message: "Key generation failed: \(error.localizedDescription)",
                details: ["operation": "generateKey"]
            ))
        }
    }
}

// MARK: - Factory

/// Factory for creating XPC service adapters with DTO support
public enum XPCProtocolDTOFactory {
    /// Create a service adapter that supports Foundation-independent DTOs
    /// - Parameter service: The underlying XPC service
    /// - Returns: An XPCServiceProtoDTO adapter
    public static func createDTOAdapter(_ service: any XPCServiceProtocolComplete) -> any XPCServiceProtoDTO {
        // DEPRECATED: XPCServiceDTOAdapter(service)
    }
}

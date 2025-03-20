// DEPRECATED: KeyExchangeDTOAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

/**
 # Key Exchange DTO Adapter

 This file implements an adapter for standardised key exchange operations using the DTO-based
 protocols. It provides a simple way to perform key exchange operations between XPC clients
 and services with Foundation-independent DTOs.

 ## Features

 * Simplified API for key exchange operations
 * Complete Foundation independence
 * Support for multiple key exchange algorithms
 * Standard error handling using DTOs
 */

import CoreDTOs
import UmbraCoreTypes

/// Protocol for key exchange operations using DTOs
public protocol KeyExchangeDTOProtocol {
    /// Generate key exchange parameters
    /// - Parameter config: Configuration for key exchange
    /// - Returns: Operation result with key exchange parameters or error
    func generateKeyExchangeParametersWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<KeyExchangeParametersDTO>

    /// Calculate shared secret
    /// - Parameters:
    ///   - publicKey: Public key from the other party
    ///   - privateKey: Private key from this party
    ///   - config: Configuration for key exchange
    /// - Returns: Operation result with shared secret or error
    func calculateSharedSecretWithDTO(
        publicKey: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>
}

/// Data transfer object for key exchange parameters
public struct KeyExchangeParametersDTO: Sendable, Equatable {
    /// Public key for key exchange
    public let publicKey: SecureBytes

    /// Private key for key exchange (should be kept secret)
    public let privateKey: SecureBytes

    /// Algorithm used for key exchange
    public let algorithm: String

    /// Additional parameters for the key exchange
    public let parameters: [String: String]

    /// Initialize key exchange parameters
    /// - Parameters:
    ///   - publicKey: Public key bytes
    ///   - privateKey: Private key bytes
    ///   - algorithm: Algorithm identifier
    ///   - parameters: Additional parameters
    public init(
        publicKey: SecureBytes,
        privateKey: SecureBytes,
        algorithm: String,
        parameters: [String: String] = [:]
    ) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.algorithm = algorithm
        self.parameters = parameters
    }
}

/// Adapter that adds key exchange DTO functionality to a standard XPC service
public class KeyExchangeDTOAdapter: KeyExchangeDTOProtocol {
    /// The underlying service to use for key exchange operations
    private let keyManagementService: any KeyManagementDTOProtocol
    private let basicService: any XPCServiceProtocolDTO

    /// Initialize with a DTO-compatible service
    /// - Parameter service: Service to wrap
    public init(service: any(KeyManagementDTOProtocol & XPCServiceProtocolDTO)) {
        keyManagementService = service
        basicService = service
    }

    /// Generate key exchange parameters
    /// - Parameter config: Configuration for key exchange
    /// - Returns: Operation result with key exchange parameters or error
    public func generateKeyExchangeParametersWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<KeyExchangeParametersDTO> {
        // Generate a random string as key ID instead of depending on generateKeyWithDTO
        let publicKeyResult = await basicService.generateRandomDataWithDTO(length: 16)

        // Check if public key generation succeeded
        guard case .success = publicKeyResult.status, let publicKeyData = publicKeyResult.value else {
            // Return the error
            return OperationResultDTO(
                errorCode: 10012,
                errorMessage: "Failed to generate public key",
                details: ["error": "Key generation failed"]
            )
        }

        // Convert to a simple ID
        let publicKeyId = "key-\(publicKeyData.hexString())"

        // Generate private key with the same approach
        let privateKeyResult = await basicService.generateRandomDataWithDTO(length: 32)

        // Check if private key generation succeeded
        guard case .success = privateKeyResult.status, let privateKeyData = privateKeyResult.value else {
            // Return the error from the service
            return OperationResultDTO(
                errorCode: 10013,
                errorMessage: "Failed to generate private key",
                details: ["error": "Key generation failed"]
            )
        }

        // Convert to a simple ID
        let privateKeyId = "key-\(privateKeyData.hexString())"

        // Export public key
        let exportPublicResult = await keyManagementService.exportKeyWithDTO(
            keyIdentifier: publicKeyId,
            config: SecurityConfigDTO(
                algorithm: config.algorithm,
                keySizeInBits: config.keySizeInBits,
                options: [:]
            )
        )

        // Check if public key export succeeded
        guard case .success = exportPublicResult.status, let publicKeyData = exportPublicResult.value else {
            // Return the error from the service
            return OperationResultDTO(
                errorCode: 10014,
                errorMessage: "Failed to export public key",
                details: ["error": "Key export failed"]
            )
        }

        // Export private key
        let exportPrivateResult = await keyManagementService.exportKeyWithDTO(
            keyIdentifier: privateKeyId,
            config: SecurityConfigDTO(
                algorithm: config.algorithm,
                keySizeInBits: config.keySizeInBits,
                options: [:]
            )
        )

        // Check if private key export succeeded
        guard case .success = exportPrivateResult.status, let privateKeyData = exportPrivateResult.value else {
            // Return the error from the service
            return OperationResultDTO(
                errorCode: 10015,
                errorMessage: "Failed to export private key",
                details: ["error": "Key export failed"]
            )
        }

        // Create key exchange parameters
        let parameters = KeyExchangeParametersDTO(
            publicKey: publicKeyData,
            privateKey: privateKeyData,
            algorithm: config.algorithm,
            parameters: ["publicKeyId": publicKeyId, "privateKeyId": privateKeyId]
        )

        return OperationResultDTO(value: parameters)
    }

    /// Calculate shared secret
    /// - Parameters:
    ///   - publicKey: Public key from the other party
    ///   - privateKey: Private key from this party
    ///   - config: Configuration for key exchange
    /// - Returns: Operation result with shared secret or error
    public func calculateSharedSecretWithDTO(
        publicKey: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Import other party's public key
        let importConfig = SecurityConfigDTO(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            options: ["purpose": "publicKey", "temporary": "true"]
        )

        let importPublicResult = await keyManagementService.importKeyWithDTO(
            keyData: publicKey,
            config: importConfig
        )

        // Check if public key import succeeded
        guard case .success = importPublicResult.status, let publicKeyId = importPublicResult.value else {
            // Return the error from the service
            return OperationResultDTO(
                errorCode: 10016,
                errorMessage: "Failed to import public key",
                details: ["error": "Key import failed"]
            )
        }

        // Import our private key
        let importPrivateConfig = SecurityConfigDTO(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            options: ["purpose": "privateKey", "temporary": "true"]
        )

        let importPrivateResult = await keyManagementService.importKeyWithDTO(
            keyData: privateKey,
            config: importPrivateConfig
        )

        // Check if private key import succeeded
        guard case .success = importPrivateResult.status, let privateKeyId = importPrivateResult.value else {
            // Return the error from the service
            return OperationResultDTO(
                errorCode: 10017,
                errorMessage: "Failed to import private key",
                details: ["error": "Key import failed"]
            )
        }

        // For this example, we'll simulate a key agreement by:
        // 1. XORing the public and private keys
        // 2. Hashing the result with a simple algorithm
        // NOTE: In a real implementation, proper cryptographic operations would be used

        // Simplified "shared secret" calculation - this is just for the example!
        let secretConfig = SecurityConfigDTO(
            algorithm: "SHARED_SECRET",
            keySizeInBits: 256,
            options: [
                "publicKeyId": publicKeyId,
                "privateKeyId": privateKeyId,
            ]
        )

        // Use the service's encryption as a proxy for key derivation
        let result: OperationResultDTO<SecureBytes> = if let keyService = keyManagementService as? XPCServiceProtocolDTO {
            await keyService.encryptWithDTO(
                data: privateKey,
                config: secretConfig
            )
        } else {
            OperationResultDTO(
                status: .failure,
                errorCode: -1,
                errorMessage: "Service does not support encryption"
            )
        }

        // Clean up temporary keys
        _ = await keyManagementService.deleteKeyWithDTO(keyIdentifier: publicKeyId)
        _ = await keyManagementService.deleteKeyWithDTO(keyIdentifier: privateKeyId)

        return result
    }
}

/// Extension to XPCServiceProtocolDTO to add key exchange functionality
public extension XPCServiceProtocolDTO where Self: KeyManagementDTOProtocol {
    /// Create a key exchange adapter for this service
    /// - Returns: Key exchange adapter
    func keyExchangeAdapter() -> KeyExchangeDTOProtocol {
        KeyExchangeDTOAdapter(service: self)
    }
}

/// Protocol that combines KeyExchangeDTOProtocol with other adapter-based protocols
/// Renamed to avoid conflict with XPCServiceWithKeyExchangeDTO defined elsewhere
public protocol KeyExchangeCompleteProtocol: XPCServiceProtocolDTO, KeyExchangeDTOProtocol {
    /// Perform a secure operation with multiple inputs and outputs
    /// - Parameters:
    ///   - operation: Operation identifier
    ///   - inputs: Input data for the operation
    ///   - config: Configuration for the operation
    /// - Returns: Operation result with outputs or error
    func performSecureOperationWithDTO(
        operation: String,
        inputs: [String: SecureBytes],
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<[String: SecureBytes]>
}

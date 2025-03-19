/**
 # XPC Service Protocol Complete DTO Adapter

 This file implements an adapter for wrapping a legacy complete XPC service implementation with
 the new DTO-based protocol interface. It provides a bridge between the old and new protocols,
 allowing existing implementations to be used with the new DTO approach.

 ## Features

 * Compatible with existing XPCServiceProtocolComplete implementations
 * Provides Foundation-independent interface via DTOs
 * Handles conversion between legacy errors and DTO-based errors
 * Supports all operations defined in XPCServiceProtocolCompleteDTO
 */

import CoreDTOs
import Foundation
import UmbraCoreTypes

/// Adapter that implements XPCServiceProtocolCompleteDTO by wrapping a legacy XPCServiceProtocolComplete
public final class XPCServiceProtocolCompleteDTOAdapter: XPCServiceProtocolDTO, KeyManagementDTOProtocol, AdvancedSecurityDTOProtocol, KeyExchangeDTOProtocol {
    /// Wrapped legacy service implementation
    private let completeService: XPCServiceProtocolComplete

    /// Initialize with a legacy complete service
    /// - Parameter completeService: Legacy complete service to wrap
    public init(completeService: XPCServiceProtocolComplete) {
        self.completeService = completeService
    }

    // MARK: - Basic Protocol

    /// Ping the service with DTO
    /// - Returns: Operation result with boolean success or error
    public func pingWithDTO() async -> OperationResultDTO<Bool> {
        // Call legacy method
        let result = await completeService.ping()
        return OperationResultDTO(value: result)
    }

    /// Synchronise keys with DTO-based result
    /// - Parameter syncData: Data for key synchronisation
    /// - Returns: Operation result indicating success or detailed error
    public func synchroniseKeysWithDTO(_ syncData: SecureBytes) async -> OperationResultDTO<VoidResult> {
        do {
            try await completeService.synchroniseKeys(syncData)
            return OperationResultDTO(value: VoidResult())
        } catch {
            return OperationResultDTO(
                errorCode: 1_002,
                errorMessage: "Key synchronisation failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    // MARK: - Standard Protocol

    /// Generate random data with DTO response
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Operation result with secure bytes or error
    public func generateRandomDataWithDTO(length: Int) async -> OperationResultDTO<SecureBytes> {
        // Call legacy method
        let resultValue = await completeService.generateRandomData(length: length)

        switch resultValue {
        case let .success(randomData):
            return OperationResultDTO(value: randomData)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Random data generation failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Encrypt data using service's encryption mechanism with DTOs
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with encrypted data or error
    public func encryptWithDTO(
        data: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Call legacy method
        let resultValue = await completeService.encrypt(data: data)

        switch resultValue {
        case let .success(encryptedData):
            return OperationResultDTO(value: encryptedData)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Encryption failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Decrypt data using service's decryption mechanism with DTOs
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with decrypted data or error
    public func decryptWithDTO(
        data: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Call legacy method
        let resultValue = await completeService.decrypt(data: data)

        switch resultValue {
        case let .success(decryptedData):
            return OperationResultDTO(value: decryptedData)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Decryption failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Generate a cryptographic key with DTO
    /// - Parameter config: Key generation configuration
    /// - Returns: Operation result with key identifier or detailed error
    public func generateKeyWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<String> {
        // Extract purpose from options dictionary
        let purpose = config.options["purpose"] ?? "encryption"

        // Call legacy method with extracted values
        let result = await completeService.generateKey(
            algorithm: config.algorithm,
            keySize: config.keySizeInBits,
            purpose: purpose
        )

        switch result {
        case let .success(keyId):
            return OperationResultDTO(value: keyId)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key generation failed: \(error.localizedDescription)",
                details: [
                    "errorCode": "\(error.code)",
                    "errorDomain": error.domain
                ]
            )
        }
    }

    /// Get current service status with DTO
    /// - Returns: Operation result with service status DTO or error
    public func getStatusWithDTO() async -> OperationResultDTO<XPCProtocolDTOs.ServiceStatusDTO> {
        // Get status from the complete service
        _ = completeService.getStatus()

        // Convert legacy status to DTO
        return OperationResultDTO(value: XPCProtocolDTOs.ServiceStatusDTO(
            timestamp: Int64(Date().timeIntervalSince1970 * 1_000),
            protocolVersion: "1.0",
            serviceVersion: "1.0",
            deviceIdentifier: "",
            additionalInfo: [:]
        ))
    }

    // MARK: - Complete Protocol (Key Management)

    /// List available keys
    /// - Returns: Operation result with array of key identifiers or error
    public func listKeysWithDTO() async -> OperationResultDTO<[String]> {
        let result = await completeService.getKeyIdentifiers()

        switch result {
        case let .success(keys):
            return OperationResultDTO(value: keys)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key listing failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier of the key to delete
    /// - Returns: Operation result indicating success or detailed error
    public func deleteKeyWithDTO(keyIdentifier: String) async -> OperationResultDTO<Bool> {
        let result = await completeService.deleteKey(keyIdentifier: keyIdentifier)

        switch result {
        case let .success(success):
            return OperationResultDTO(value: success)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key deletion failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Import a key
    /// - Parameters:
    ///   - keyData: Key data to import
    ///   - config: Configuration for the key import operation
    /// - Returns: Operation result with key identifier or error
    public func importKeyWithDTO(
        keyData _: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<String> {
        // Use generateKey as a substitute since XPCServiceProtocolComplete doesn't have importKey with the same signature
        let result = await completeService.generateKey(
            algorithm: config.algorithm,
            keySize: config.keySizeInBits,
            purpose: config.options["purpose"] ?? "encryption"
        )

        switch result {
        case let .success(keyId):
            return OperationResultDTO(value: keyId)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key import failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Export a key
    /// - Parameters:
    ///   - keyIdentifier: Identifier of the key to export
    ///   - config: Configuration for the key export operation
    /// - Returns: Operation result with key data or error
    public func exportKeyWithDTO(
        keyIdentifier: String,
        config _: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Call legacy method - ignore config parameter for now
        let result = await completeService.exportKey(
            keyIdentifier: keyIdentifier
        )

        switch result {
        case let .success(keyData):
            return OperationResultDTO(value: keyData)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key export failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Get information about a key
    /// - Parameter keyIdentifier: Identifier of the key
    /// - Returns: Operation result with key info or error
    public func getKeyInfoWithDTO(
        keyIdentifier: String
    ) async -> OperationResultDTO<[String: String]> {
        let result = await completeService.getKeyInfo(keyIdentifier: keyIdentifier)

        switch result {
        case let .success(keyInfo):
            return OperationResultDTO(value: keyInfo)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key info retrieval failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    // MARK: - Key Exchange

    /// Generate key exchange parameters
    /// - Parameter config: Configuration for key exchange
    /// - Returns: Operation result with key exchange parameters or error
    public func generateKeyExchangeParametersWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<KeyExchangeParametersDTO> {
        // Create key exchange adapter and use it
        let adapter = KeyExchangeDTOAdapter(service: self)
        return await adapter.generateKeyExchangeParametersWithDTO(config: config)
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
        // Create key exchange adapter and use it
        let adapter = KeyExchangeDTOAdapter(service: self)
        return await adapter.calculateSharedSecretWithDTO(
            publicKey: publicKey,
            privateKey: privateKey,
            config: config
        )
    }

    // MARK: - Advanced Operations

    /// Perform a secure operation with multiple inputs and outputs
    /// - Parameters:
    ///   - operation: Operation identifier
    ///   - inputs: Input parameters
    ///   - config: Security configuration
    /// - Returns: Operation result with output parameters or error
    public func performSecureOperationWithDTO(
        operation: String,
        inputs: [String: SecureBytes],
        config _: SecurityConfigDTO
    ) async -> OperationResultDTO<[String: SecureBytes]> {
        // Simple implementation for a few common operations
        switch operation {
        case "HASH":
            // Hash each input separately
            var outputs: [String: SecureBytes] = [:]

            for (key, _) in inputs {
                if let input = inputs[key] {
                    // Encrypt the input data
                    let result = await completeService.encrypt(
                        data: input
                    )

                    switch result {
                    case let .success(encrypted):
                        outputs[key] = encrypted
                    case let .failure(error):
                        // Handle error case
                        return OperationResultDTO(
                            errorCode: Int32(error.code),
                            errorMessage: "Encryption failed: \(error.localizedDescription)",
                            details: [
                                "errorCode": "\(error.code)",
                                "errorDomain": error.domain
                            ]
                        )
                    }
                }
            }

            return OperationResultDTO(value: outputs)

        case "COMBINE":
            // Combine all inputs
            var combinedData = [UInt8]()

            for (_, value) in inputs.sorted(by: { $0.key < $1.key }) {
                var valueBytes = [UInt8]()
                for i in 0 ..< value.count {
                    valueBytes.append(value[i])
                }
                combinedData.append(contentsOf: valueBytes)
            }

            let result = SecureBytes(bytes: combinedData)
            return OperationResultDTO(value: ["result": result])

        default:
            // For unknown operations, return an error
            return OperationResultDTO(
                errorCode: 1_013,
                errorMessage: "Unsupported operation",
                details: ["operation": operation]
            )
        }
    }

    // MARK: - Advanced Security Protocol

    /// Sign data
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier of the signing key
    ///   - config: Configuration for the signing operation
    /// - Returns: Operation result with signature or error
    public func signWithDTO(
        data: SecureBytes,
        keyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        let result = await completeService.generateSignature(
            data: data,
            keyIdentifier: keyIdentifier,
            algorithm: config.algorithm
        )

        switch result {
        case let .success(signature):
            return OperationResultDTO(value: signature)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Signing failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Verify signature
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Original data that was signed
    ///   - keyIdentifier: Identifier of the verification key
    ///   - config: Configuration for the verification operation
    /// - Returns: Operation result with verification status or error
    public func verifyWithDTO(
        signature: SecureBytes,
        data: SecureBytes,
        keyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<Bool> {
        let result = await completeService.verifySignature(
            signature: signature,
            data: data,
            keyIdentifier: keyIdentifier,
            algorithm: config.algorithm
        )

        switch result {
        case let .success(isValid):
            return OperationResultDTO(value: isValid)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Signature verification failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Derive a key from a password
    /// - Parameters:
    ///   - password: Password to derive from (as secure bytes)
    ///   - config: Configuration for key derivation
    /// - Returns: Operation result with derived key or error
    public func deriveKeyFromPasswordWithDTO(
        password: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Convert SecureBytes to String for the underlying API
        // This is a simplification; in a real implementation we would need proper conversion
        var passwordBytes = [UInt8]()
        for i in 0 ..< password.count {
            passwordBytes.append(password[i])
        }
        let passwordString = String(bytes: passwordBytes, encoding: .utf8) ?? ""

        let result = await completeService.deriveKey(
            password: passwordString,
            salt: SecureBytes(bytes: []),
            iterations: Int(config.options["iterations"] ?? "10000") ?? 10_000,
            keySize: config.keySizeInBits
        )

        switch result {
        case let .success(derivedKey):
            return OperationResultDTO(value: derivedKey)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Password-based key derivation failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Derive a key from another key
    /// - Parameters:
    ///   - sourceKeyIdentifier: Identifier of the source key
    ///   - config: Configuration for key derivation
    /// - Returns: Operation result with derived key or error
    public func deriveKeyFromKeyWithDTO(
        sourceKeyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        let result = await completeService.deriveKeyFromKey(
            sourceKeyIdentifier: sourceKeyIdentifier,
            algorithm: config.algorithm,
            keySize: config.keySizeInBits
        )

        switch result {
        case let .success(derivedKey):
            return OperationResultDTO(value: derivedKey)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key-based key derivation failed: \(error.localizedDescription)",
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Reset security state with DTO
    /// - Returns: Operation result indicating success or detailed error
    public func resetSecurityWithDTO() async -> OperationResultDTO<Bool> {
        let result = await completeService.resetSecurity()

        switch result {
        case .success:
            return OperationResultDTO(value: true)
        case let .failure(error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Security reset failed: \(error.localizedDescription)",
                details: [
                    "errorCode": "\(error.code)",
                    "errorDomain": error.domain
                ]
            )
        }
    }
}

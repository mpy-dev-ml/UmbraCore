/**
 # XPC Service Protocol with DTOs

 This file defines a new approach to XPC service protocols using Foundation-independent
 Data Transfer Objects (DTOs). This protocol is designed to work seamlessly with the
 existing protocol hierarchy while providing improved data exchange standardisation.

 ## Features

 * Uses CoreDTOs for all data exchange
 * Provides Foundation-independent operation results
 * Standardised security configuration and error handling
 * Maintains full compatibility with existing XPC protocol hierarchy
 * Includes adapters for migrating from legacy protocols
 */

import CoreDTOs
import CoreFoundation
import UmbraCoreTypes

/// Protocol defining XPC service interface using DTO-based communication
public protocol XPCServiceProtocolDTO: Sendable {
    /// Protocol identifier for service discovery and negotiation
    static var protocolIdentifier: String { get }

    /// Basic health check to verify service is responsive
    /// - Returns: An operation result indicating success or failure
    func pingWithDTO() async -> OperationResultDTO<Bool>

    /// Generate random data securely
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Operation result with secure bytes or error
    func generateRandomDataWithDTO(length: Int) async -> OperationResultDTO<SecureBytes>

    /// Encrypt data using service's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with encrypted data or error
    func encryptWithDTO(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Decrypt data using service's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with decrypted data or error
    func decryptWithDTO(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Synchronise keys with DTO-based result
    /// - Parameter syncData: Data for key synchronisation
    /// - Returns: Operation result indicating success or detailed error
    func synchroniseKeysWithDTO(
        _ syncData: SecureBytes
    ) async -> OperationResultDTO<VoidResult>

    /// Generate a cryptographic key
    /// - Parameter config: Configuration specifying algorithm and key parameters
    /// - Returns: Operation result with key identifier or error
    func generateKeyWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<String>

    /// Get current service status
    /// - Returns: Operation result with service status DTO or error
    func getStatusWithDTO() async -> OperationResultDTO<XPCProtocolDTOs.ServiceStatusDTO>
}

/// Default implementations for XPCServiceProtocolDTO
public extension XPCServiceProtocolDTO {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.dto"
    }

    /// Default implementation of ping that always returns success
    func pingWithDTO() async -> OperationResultDTO<Bool> {
        OperationResultDTO(value: true)
    }

    /// Default implementation that creates an operation failure
    func generateRandomDataWithDTO(length: Int) async -> OperationResultDTO<SecureBytes> {
        OperationResultDTO(
            errorCode: 1001,
            errorMessage: "Random data generation not implemented",
            details: ["requestedLength": "\(length)"]
        )
    }

    /// Get status with current timestamp and protocol version
    func getStatusWithDTO() async -> OperationResultDTO<XPCProtocolDTOs.ServiceStatusDTO> {
        let status = XPCProtocolDTOs.ServiceStatusDTO.current(
            protocolVersion: Self.protocolIdentifier,
            serviceVersion: "1.0.0",
            additionalInfo: ["serviceType": "XPC"]
        )

        return OperationResultDTO(value: status)
    }
}

/// Protocol for services that provide key management functionality with DTO support
public protocol KeyManagementDTOProtocol: Sendable {
    /// List available keys
    /// - Returns: Operation result with array of key identifiers or error
    func listKeysWithDTO() async -> OperationResultDTO<[String]>

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier of the key to delete
    /// - Returns: Operation result indicating success or detailed error
    func deleteKeyWithDTO(keyIdentifier: String) async -> OperationResultDTO<Bool>

    /// Import a key
    /// - Parameters:
    ///   - keyData: Key data to import
    ///   - config: Configuration for the key import operation
    /// - Returns: Operation result with key identifier or error
    func importKeyWithDTO(
        keyData: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<String>

    /// Export a key
    /// - Parameters:
    ///   - keyIdentifier: Identifier of the key to export
    ///   - config: Configuration for the key export operation
    /// - Returns: Operation result with key data or error
    func exportKeyWithDTO(
        keyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Get information about a key
    /// - Parameter keyIdentifier: Identifier of the key
    /// - Returns: Operation result with key info or error
    func getKeyInfoWithDTO(
        keyIdentifier: String
    ) async -> OperationResultDTO<[String: String]>
}

/// Advanced security operations protocol with DTO support
public protocol AdvancedSecurityDTOProtocol: Sendable {
    /// Sign data
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier of the signing key
    ///   - config: Configuration for the signing operation
    /// - Returns: Operation result with signature or error
    func signWithDTO(
        data: SecureBytes,
        keyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Verify signature
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Original data that was signed
    ///   - keyIdentifier: Identifier of the verification key
    ///   - config: Configuration for the verification operation
    /// - Returns: Operation result with verification status or error
    func verifyWithDTO(
        signature: SecureBytes,
        data: SecureBytes,
        keyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<Bool>

    /// Derive a key from a password
    /// - Parameters:
    ///   - password: Password to derive from (as secure bytes)
    ///   - config: Configuration for key derivation
    /// - Returns: Operation result with derived key or error
    func deriveKeyFromPasswordWithDTO(
        password: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Derive a key from another key
    /// - Parameters:
    ///   - sourceKeyIdentifier: Identifier of the source key
    ///   - config: Configuration for key derivation
    /// - Returns: Operation result with derived key or error
    func deriveKeyFromKeyWithDTO(
        sourceKeyIdentifier: String,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Reset security state
    /// - Returns: Operation result indicating success or detailed error
    func resetSecurityWithDTO() async -> OperationResultDTO<Bool>
}

// MARK: - XPCServiceWithKeyExchangeDTO Protocol

/// Complete protocol combining all DTO-based protocols including key exchange
public protocol XPCServiceWithKeyExchangeDTO: XPCServiceProtocolDTO, KeyManagementDTOProtocol, AdvancedSecurityDTOProtocol, KeyExchangeDTOProtocol {
    /// Get detailed service information
    /// - Returns: Operation result with service info or error
    func getServiceInfoWithDTO() async -> OperationResultDTO<[String: String]>

    /// Configure the service
    /// - Parameter config: Configuration settings
    /// - Returns: Operation result indicating success or detailed error
    func configureServiceWithDTO(
        config: [String: String]
    ) async -> OperationResultDTO<Bool>

    /// Create secure backup
    /// - Parameter config: Configuration for backup operation
    /// - Returns: Operation result with backup data or error
    func createSecureBackupWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes>

    /// Restore from secure backup
    /// - Parameters:
    ///   - backupData: Backup data to restore from
    ///   - config: Configuration for restore operation
    /// - Returns: Operation result indicating success or detailed error
    func restoreFromSecureBackupWithDTO(
        backupData: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<Bool>
}

/// Default implementations for the complete DTO protocol
public extension XPCServiceWithKeyExchangeDTO {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.complete.dto"
    }

    /// Default implementation for service info
    func getServiceInfoWithDTO() async -> OperationResultDTO<[String: String]> {
        let info: [String: String] = [
            "protocolVersion": Self.protocolIdentifier,
            "implementationTimestamp": "\(Int64(CFAbsoluteTimeGetCurrent()))",
        ]

        return OperationResultDTO(value: info)
    }
}

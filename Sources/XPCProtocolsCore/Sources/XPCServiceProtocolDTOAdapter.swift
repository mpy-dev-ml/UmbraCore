/**
 # XPC Service Protocol DTO Adapter
 
 This file implements an adapter for wrapping legacy XPC service implementations with
 the new DTO-based protocol interface. It provides a bridge between the old and new protocols,
 allowing existing implementations to be used with the new DTO approach.
 
 ## Features
 
 * Compatible with existing XPCServiceProtocol implementations
 * Provides Foundation-independent interface via DTOs
 */

import UmbraCoreTypes
import Foundation

/// Adapter to wrap a standard XPC service protocol implementation with the DTO protocol interface
public class XPCServiceProtocolDTOAdapter: XPCServiceProtocolDTO, @unchecked Sendable {
    /// The underlying service protocol implementation
    private let service: XPCServiceProtocolStandard
    
    /// Protocol identifier
    public static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.dto.adapter"
    }
    
    /// Initialize with a standard protocol implementation
    /// - Parameter service: The underlying service to adapt
    public init(service: XPCServiceProtocolStandard) {
        self.service = service
    }
    
    /// Convert from standard result to DTO result for types that are Equatable
    /// - Parameters:
    ///   - result: Standard result to convert
    ///   - defaultErrorCode: Default error code to use if none provided
    ///   - defaultErrorMessage: Default error message to use if none provided
    /// - Returns: DTO-based operation result
    private func convertToDTO<T: Equatable>(
        _ result: Result<T, XPCSecurityError>,
        defaultErrorCode: Int32 = 10000,
        defaultErrorMessage: String = "Operation failed"
    ) -> OperationResultDTO<T> {
        switch result {
        case .success(let value):
            return OperationResultDTO(value: value)
            
        case .failure(let error):
            // Create a standard error format
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: error.localizedDescription,
                details: ["domain": error.domain]
            )
        }
    }
    
    /// Convert from standard result to DTO result for any type (not requiring Equatable)
    /// - Parameters:
    ///   - result: Standard result to convert
    ///   - defaultErrorCode: Default error code to use if none provided
    ///   - defaultErrorMessage: Default error message to use if none provided
    /// - Returns: DTO-based operation result
    private func convertAnyToDTO<T>(
        _ result: Result<T, XPCSecurityError>,
        defaultErrorCode: Int32 = 10000,
        defaultErrorMessage: String = "Operation failed"
    ) -> OperationResultDTO<T> {
        switch result {
        case .success(let value):
            return OperationResultDTO(value: value)
            
        case .failure(let error):
            // Create a standard error format
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: error.localizedDescription,
                details: ["domain": error.domain]
            )
        }
    }
    
    /// Helper to convert a Result with XPCSecurityError failure to OperationResultDTO
    /// - Parameters:
    ///   - result: The result to convert
    ///   - defaultErrorCode: Error code to use if conversion fails
    ///   - defaultErrorMessage: Error message to use if conversion fails
    /// - Returns: Converted OperationResultDTO
    private func convertSecurityResult<T>(_ result: Result<T, XPCSecurityError>, defaultErrorCode: Int32, defaultErrorMessage: String) -> OperationResultDTO<T> {
        switch result {
        case .success(let value):
            return OperationResultDTO(value: value)
        case .failure(let error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: error.localizedDescription,
                details: ["domain": error.domain]
            )
        }
    }
    
    /// Ping the service using DTOs
    /// - Returns: Operation result with ping status
    public func pingWithDTO() async -> OperationResultDTO<Bool> {
        let result = await service.pingStandard()
        return convertToDTO(result)
    }
    
    /// Generate random data with DTO response
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Operation result with secure bytes or error
    public func generateRandomDataWithDTO(length: Int) async -> OperationResultDTO<SecureBytes> {
        let result = await service.generateRandomData(length: length)
        return convertAnyToDTO(result)
    }
    
    /// Encrypt data using service's encryption mechanism with DTOs
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with encrypted data or error
    public func encryptWithDTO(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Extract key identifier from config if present
        let keyIdentifier = config.options["keyIdentifier"]
        
        let result = await service.encryptSecureData(data, keyIdentifier: keyIdentifier)
        return convertAnyToDTO(result)
    }
    
    /// Decrypt data using service's decryption mechanism with DTOs
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - config: Security configuration for the operation
    /// - Returns: Operation result with decrypted data or error
    public func decryptWithDTO(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<SecureBytes> {
        // Extract key identifier from config if present
        let keyIdentifier = config.options["keyIdentifier"]
        
        let result = await service.decryptSecureData(data, keyIdentifier: keyIdentifier)
        return convertAnyToDTO(result)
    }
    
    /// Synchronise keys with DTO-based result
    /// - Parameter syncData: Synchronisation data
    /// - Returns: Operation result indicating success or detailed error
    public func synchroniseKeysWithDTO(
        _ syncData: SecureBytes
    ) async -> OperationResultDTO<VoidResult> {
        let result = await service.synchronizeKeys(syncData)
        
        switch result {
        case .success:
            return OperationResultDTO(value: VoidResult())
        case .failure(let error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Key synchronisation failed: \(error.localizedDescription)",
                details: ["domain": error.domain]
            )
        }
    }
    
    /// Generate a cryptographic key with DTO
    /// - Parameter config: Configuration specifying algorithm and key parameters
    /// - Returns: Operation result with key identifier or error
    public func generateKeyWithDTO(
        config: SecurityConfigDTO
    ) async -> OperationResultDTO<String> {
        // Convert to legacy key type if possible
        let keyTypeStr = config.algorithm.lowercased()
        var keyType: XPCProtocolTypeDefs.KeyType
        
        switch keyTypeStr {
        case "aes", "chacha20":
            keyType = .symmetric
        case "rsa", "ecc", "ec":
            keyType = .asymmetric
        case "hmac":
            keyType = .hmac
        default:
            // Default to symmetric for unknown types
            keyType = .symmetric
        }
        
        // Extract key identifier and metadata from config
        let keyIdentifier = config.options["keyIdentifier"]
        var metadata: [String: String] = [:]
        
        for (key, value) in config.options {
            if key != "keyIdentifier" {
                metadata[key] = value
            }
        }
        
        // If service conforms to key management protocol, use it
        if let keyService = service as? KeyManagementServiceProtocol {
            let result = await keyService.generateKey(
                keyType: keyType,
                keyIdentifier: keyIdentifier,
                metadata: metadata.isEmpty ? nil : metadata
            )
            return convertToDTO(result, defaultErrorCode: 10002, defaultErrorMessage: "Key generation failed")
        } else {
            // Service doesn't support key management
            return OperationResultDTO(
                errorCode: 10006,
                errorMessage: "Operation not supported",
                details: ["operation": "generateKey"]
            )
        }
    }
    
    /// Get current service status with DTO
    /// - Returns: Operation result with service status DTO or error
    public func getStatusWithDTO() async -> OperationResultDTO<XPCProtocolDTOs.ServiceStatusDTO> {
        let result = await service.status()
        
        switch result {
        case .success(let statusDict):
            // Extract relevant fields from the dictionary
            let protocolVersion = statusDict["protocolVersion"] as? String ?? Self.protocolIdentifier
            let serviceVersion = statusDict["serviceVersion"] as? String ?? "1.0.0"
            
            // Get current timestamp
            let timestamp = Int64(CFAbsoluteTimeGetCurrent())
            
            // Convert additional info
            var additionalInfo: [String: String] = [:]
            for (key, value) in statusDict {
                if key != "protocolVersion" && key != "serviceVersion" {
                    additionalInfo[key] = String(describing: value)
                }
            }
            
            // Create status DTO
            let statusDTO = XPCProtocolDTOs.ServiceStatusDTO(
                timestamp: timestamp,
                protocolVersion: protocolVersion,
                serviceVersion: serviceVersion,
                additionalInfo: additionalInfo
            )
            
            return OperationResultDTO(value: statusDTO)
            
        case .failure(let error):
            return OperationResultDTO(
                errorCode: Int32(error.code),
                errorMessage: "Failed to retrieve service status: \(error.localizedDescription)",
                details: ["domain": error.domain]
            )
        }
    }
    
    /// Adapter to wrap a complete XPC service protocol implementation with the complete DTO protocol interface
    public final class XPCServiceProtocolCompleteDTOAdapter: XPCServiceProtocolDTOAdapter, XPCServiceWithKeyExchangeDTO, KeyExchangeDTOProtocol, @unchecked Sendable {
        /// The underlying complete service protocol implementation
        private let completeService: XPCServiceProtocolComplete
        
        /// Complete protocol identifier - differs from the base class but doesn't override
        public static let completeProtocolIdentifier: String = "com.umbra.xpc.service.protocol.complete.dto.adapter"
        
        /// Initialize with a complete protocol implementation
        /// - Parameter service: The underlying service to adapt
        public init(completeService: XPCServiceProtocolComplete) {
            self.completeService = completeService
            super.init(service: completeService)
        }
        
        /// List available keys with DTO
        /// - Returns: Operation result with array of key identifiers or error
        public func listKeysWithDTO() async -> OperationResultDTO<[String]> {
            // If service conforms to key management protocol, use it
            if let keyService = service as? KeyManagementServiceProtocol {
                let result = await keyService.listKeys()
                return convertAnyToDTO(result, defaultErrorCode: 10004, defaultErrorMessage: "Failed to list keys")
            } else {
                // Service doesn't support key management
                return OperationResultDTO(
                    errorCode: 10006,
                    errorMessage: "Operation not supported",
                    details: ["operation": "listKeys"]
                )
            }
        }
        
        /// Delete a key with DTO
        /// - Parameter keyIdentifier: Identifier of the key to delete
        /// - Returns: Operation result indicating success or detailed error
        public func deleteKeyWithDTO(keyIdentifier: String) async -> OperationResultDTO<Bool> {
            // If service conforms to key management protocol, use it
            if let keyService = service as? KeyManagementServiceProtocol {
                let result = await keyService.deleteKey(keyIdentifier: keyIdentifier)
                
                switch result {
                case .success:
                    return OperationResultDTO(value: true)
                case .failure(let error):
                    return OperationResultDTO(
                        errorCode: Int32(error.code),
                        errorMessage: "Failed to delete key: \(error.localizedDescription)",
                        details: ["domain": error.domain]
                    )
                }
            } else {
                // Service doesn't support key management
                return OperationResultDTO(
                    errorCode: 10006,
                    errorMessage: "Operation not supported",
                    details: ["operation": "deleteKey"]
                )
            }
        }
        
        /// Import a key with DTO
        /// - Parameters:
        ///   - keyData: Key data to import
        ///   - config: Configuration for the key import operation
        /// - Returns: Operation result with key identifier or error
        public func importKeyWithDTO(
            keyData: SecureBytes,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<String> {
            // If service conforms to key management protocol, use it
            if let keyService = completeService as? KeyManagementServiceProtocol {
                // Convert to legacy key type if possible
                let keyTypeStr = config.algorithm.lowercased()
                var keyType: XPCProtocolTypeDefs.KeyType
                
                switch keyTypeStr {
                case "aes", "chacha20":
                    keyType = .symmetric
                case "rsa", "ecc", "ec":
                    keyType = .asymmetric
                case "hmac":
                    keyType = .hmac
                default:
                    // Default to symmetric for unknown types
                    keyType = .symmetric
                }
                
                // Extract key identifier and metadata from config
                let keyIdentifier = config.options["keyIdentifier"]
                var metadata: [String: String] = [:]
                
                for (key, value) in config.options {
                    if key != "keyIdentifier" {
                        metadata[key] = value
                    }
                }
                
                let result = await keyService.importKey(
                    keyData: keyData,
                    keyType: keyType,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata.isEmpty ? nil : metadata
                )
                return convertAnyToDTO(result, defaultErrorCode: 10002, defaultErrorMessage: "Key import failed")
            } else {
                // Service doesn't support key management
                return OperationResultDTO(
                    errorCode: 10006,
                    errorMessage: "Operation not supported",
                    details: ["operation": "importKey"]
                )
            }
        }
        
        /// Export a key with DTO
        /// - Parameters:
        ///   - keyIdentifier: Identifier of the key to export
        ///   - config: Configuration for the key export operation
        /// - Returns: Operation result with key data or error
        public func exportKeyWithDTO(
            keyIdentifier: String,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<SecureBytes> {
            // If service conforms to key management protocol, use it
            if let keyService = completeService as? KeyManagementServiceProtocol {
                // Determine format from config
                let formatStr = config.options["format"]?.lowercased() ?? "raw"
                var format: XPCProtocolTypeDefs.KeyFormat
                
                switch formatStr {
                case "pkcs8":
                    format = .pkcs8
                case "pem":
                    format = .pem
                default:
                    format = .raw
                }
                
                let result = await keyService.exportKey(
                    keyIdentifier: keyIdentifier,
                    format: format
                )
                return convertAnyToDTO(result, defaultErrorCode: 10007, defaultErrorMessage: "Key export failed")
            } else {
                // Service doesn't support key management
                return OperationResultDTO(
                    errorCode: 10006,
                    errorMessage: "Operation not supported",
                    details: ["operation": "exportKey"]
                )
            }
        }
        
        /// Get key info with DTO
        /// - Parameter keyIdentifier: Identifier of the key
        /// - Returns: Operation result with key info or error
        public func getKeyInfoWithDTO(
            keyIdentifier: String
        ) async -> OperationResultDTO<[String: String]> {
            let result = await completeService.getKeyInfo(keyIdentifier: keyIdentifier)
            return convertAnyToDTO(result, defaultErrorCode: 10008, defaultErrorMessage: "Failed to retrieve key info")
        }
        
        /// Sign data with DTO
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
            let algorithm = config.algorithm
            
            let result = await completeService.generateSignature(
                data: data,
                keyIdentifier: keyIdentifier,
                algorithm: algorithm
            )
            return convertAnyToDTO(result, defaultErrorCode: 10009, defaultErrorMessage: "Signing failed")
        }
        
        /// Verify signature with DTO
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
            let algorithm = config.algorithm
            
            let result = await completeService.verifySignature(
                signature: signature,
                data: data,
                keyIdentifier: keyIdentifier,
                algorithm: algorithm
            )
            return convertAnyToDTO(result, defaultErrorCode: 10010, defaultErrorMessage: "Verification failed")
        }
        
        /// Derive key from password with DTO
        /// - Parameters:
        ///   - password: Password to derive from (as secure bytes)
        ///   - config: Configuration for key derivation
        /// - Returns: Operation result with derived key or error
        public func deriveKeyFromPasswordWithDTO(
            password: SecureBytes,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<SecureBytes> {
            // Basic parameter validation
            guard
                let passwordString = String(bytes: password, encoding: .ascii),
                let saltData = config.inputData
            else {
                return OperationResultDTO(
                    errorCode: 10007,
                    errorMessage: "Invalid input parameters for key derivation",
                    details: ["reason": "Missing required parameters"]
                )
            }
            
            let salt = SecureBytes(bytes: saltData)
            let keySize = config.keySizeInBits / 8 // Convert bits to bytes
            
            let iterations = Int(config.options["iterations"] ?? "10000") ?? 10000
            
            let result = await completeService.deriveKey(
                password: passwordString,
                salt: salt,
                iterations: iterations,
                keySize: keySize
            )
            return convertSecurityResult(result, defaultErrorCode: 10011, defaultErrorMessage: "Key derivation failed")
        }
        
        /// Derive key from another key with DTO
        /// - Parameters:
        ///   - sourceKeyIdentifier: Identifier of the source key
        ///   - config: Configuration for key derivation
        /// - Returns: Operation result with derived key or error
        public func deriveKeyFromKeyWithDTO(
            sourceKeyIdentifier: String,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<SecureBytes> {
            let algorithm = config.algorithm
            let keySize = config.keySizeInBits
            
            let result = await completeService.deriveKeyFromKey(
                sourceKeyIdentifier: sourceKeyIdentifier,
                algorithm: algorithm,
                keySize: keySize
            )
            return convertSecurityResult(result, defaultErrorCode: 10012, defaultErrorMessage: "Key derivation failed")
        }
        
        /// Reset security with DTO
        /// - Returns: Operation result indicating success or detailed error
        public func resetSecurityWithDTO() async -> OperationResultDTO<Bool> {
            let result = await completeService.resetService()
            return convertSecurityResult(result, defaultErrorCode: 10013, defaultErrorMessage: "Security reset failed")
        }
        
        /// Get service info with DTO
        /// - Returns: Operation result with service info or error
        public func getServiceInfoWithDTO() async -> OperationResultDTO<[String: String]> {
            let versionResult = await completeService.getVersion()
            let diagnosticResult = await completeService.getDiagnosticInfo()
            let configResult = await completeService.getConfiguration()
            
            var info: [String: String] = [
                "protocolIdentifier": Self.completeProtocolIdentifier,
                "timestamp": "\(Date().timeIntervalSince1970)"
            ]
            
            if case .success(let version) = versionResult {
                info["version"] = version
            }
            
            if case .success(let diagnostic) = diagnosticResult {
                info["diagnostic"] = diagnostic
            }
            
            if case .success(let config) = configResult {
                for (key, value) in config {
                    info["config.\(key)"] = value
                }
            }
            
            return OperationResultDTO(value: info)
        }
        
        /// Configure service with DTO
        /// - Parameter config: Configuration settings
        /// - Returns: Operation result indicating success or detailed error
        public func configureServiceWithDTO(
            config: [String: String]
        ) async -> OperationResultDTO<Bool> {
            let result = await completeService.setConfiguration(config)
            return convertSecurityResult(result, defaultErrorCode: 10014, defaultErrorMessage: "Service configuration failed")
        }
        
        /// Create secure backup with DTO
        /// - Parameter config: Configuration for backup operation
        /// - Returns: Operation result with backup data or error
        public func createSecureBackupWithDTO(
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<SecureBytes> {
            // Extract password from config
            guard
                let passwordData = config.inputData,
                let password = String(bytes: passwordData, encoding: .ascii)
            else {
                return OperationResultDTO(
                    errorCode: 10007,
                    errorMessage: "Invalid input parameters for secure backup",
                    details: ["reason": "Missing or invalid password"]
                )
            }
            
            let result = await completeService.createSecureBackup(password: password)
            return convertSecurityResult(result, defaultErrorCode: 10015, defaultErrorMessage: "Secure backup creation failed")
        }
        
        /// Restore from secure backup with DTO
        /// - Parameters:
        ///   - backupData: Backup data to restore from
        ///   - config: Configuration for restore operation
        /// - Returns: Operation result indicating success or detailed error
        public func restoreFromSecureBackupWithDTO(
            backupData: SecureBytes,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<Bool> {
            // Extract password from config
            guard
                let passwordData = config.inputData,
                let password = String(bytes: passwordData, encoding: .ascii)
            else {
                return OperationResultDTO(
                    errorCode: 10007,
                    errorMessage: "Invalid input parameters for secure restore",
                    details: ["reason": "Missing or invalid password"]
                )
            }
            
            let result = await completeService.restoreFromSecureBackup(
                backup: backupData,
                password: password
            )
            return convertSecurityResult(result, defaultErrorCode: 10016, defaultErrorMessage: "Secure restore failed")
        }
        
        // MARK: - KeyExchangeDTOProtocol
        
        /// Generate parameters for key exchange using DTO
        /// - Parameter config: Configuration for key exchange
        /// - Returns: Operation result with key exchange parameters or error
        public func generateKeyExchangeParametersWithDTO(
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<KeyExchangeParametersDTO> {
            // Create a KeyExchangeDTOAdapter using self as the service
            let adapter = KeyExchangeDTOAdapter(service: self)
            return await adapter.generateKeyExchangeParametersWithDTO(config: config)
        }
        
        /// Calculate shared secret using public and private keys with DTO
        /// - Parameters:
        ///   - publicKey: Public key data
        ///   - privateKey: Private key data
        ///   - config: Configuration for key exchange
        /// - Returns: Operation result with shared secret or error
        public func calculateSharedSecretWithDTO(
            publicKey: SecureBytes,
            privateKey: SecureBytes,
            config: SecurityConfigDTO
        ) async -> OperationResultDTO<SecureBytes> {
            // Create a KeyExchangeDTOAdapter using self as the service
            let adapter = KeyExchangeDTOAdapter(service: self)
            return await adapter.calculateSharedSecretWithDTO(
                publicKey: publicKey,
                privateKey: privateKey,
                config: config
            )
        }
    }
}

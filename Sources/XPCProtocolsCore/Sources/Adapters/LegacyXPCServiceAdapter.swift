/**
 # Legacy XPC Service Adapter
 
 This adapter bridges between legacy Objective-C XPC service protocols and
 the modern Swift-based XPC protocol system. It adapts older NSData-based
 APIs to work with the newer SecureBytes-based interfaces.
 
 ## Deprecation Notice
 
 This adapter is being phased out as part of the modernization of the UmbraCore
 XPC protocol system. New code should use the ModernXPCService implementation
 or the factory methods in XPCProtocolMigrationFactory.
 
 ## Migration Guide
 
 1. Replace direct instantiation of LegacyXPCServiceAdapter with the appropriate
    factory method from XPCProtocolMigrationFactory
 2. Ensure your code is using the protocol interfaces (XPCServiceProtocolBasic, etc.)
    rather than concrete implementation types
 3. Consider updating legacy services to implement the modern protocols directly
 
 ## Implementation Details
 
 This adapter implements all the methods required by XPCServiceProtocolComplete:
 
 - pingComplete(): Implemented - Provides a Result-based ping response
 - getServiceStatus(): Implemented - Provides detailed service status
 - generateKey(): Implemented - Generates keys with specified parameters
 - deleteKey(): Implemented - Deletes keys by identifier
 - listKeys(): Implemented - Lists available key identifiers
 - importKey(): Implemented - Imports keys with specified parameters
 - exportKey(): Implemented - Exports keys by identifier
 - deriveKey(): Implemented - Derives keys from source keys or passwords
 - encryptSecureData(): Implemented - Encrypts data with specified key
 - decryptSecureData(): Implemented - Decrypts data with specified key
 - hashSecureData(): Implemented - Hashes data with specified algorithm
 - signSecureData(): Implemented - Signs data with specified key
 - verifySecureSignature(): Implemented - Verifies signatures against data
 - generateSecureRandomData(): Implemented - Generates random data
 
 The implementation delegates to the legacy service implementation where available,
 with fallback mechanisms for services that don't implement all functionality.
 */

/// Format options for exporting keys
@available(*, deprecated, message: "Use XPCProtocolTypeDefs.KeyFormat instead")
public enum KeyFormat {
    /// Raw key material
    case raw
    
    /// PKCS#8 formatted key (commonly used for asymmetric keys)
    case pkcs8
    
    /// PEM format (Base64-encoded with header/footer)
    case pem
    
    /// JWK format (JSON Web Key)
    case jwk
}

@available(*, deprecated, message: "Use ModernXPCService or the factory methods in XPCProtocolMigrationFactory instead")
public final class LegacyXPCServiceAdapter: NSObject, XPCServiceProtocolComplete {
    /// The underlying legacy service
    private let service: NSObject
    
    /// Initialize with a legacy service object
    /// - Parameter service: NSObject implementing legacy XPC protocols
    @available(*, deprecated, message: "Use ModernXPCService or the factory methods in XPCProtocolMigrationFactory instead")
    public init(service: NSObject) {
        self.service = service
        super.init()
    }
    
    // MARK: - XPCServiceProtocolComplete Conformance Adapter

    /// Ping the service to check if it's available and responding
    /// - Returns: Result with boolean success or error
    public func pingComplete() async -> Result<Bool, XPCSecurityError> {
        print("DEBUG: In pingComplete, service type: \(type(of: service))")
        
        // Check explicitly for the ping method
        if let legacyService = service as? PingProtocol {
            print("DEBUG: Found service that implements ping")
            let result = legacyService.ping()
            print("DEBUG: Service returned: \(result)")
            return .success(result)
        }
        
        print("DEBUG: Using default implementation")
        // Default implementation always succeeds
        return .success(true)
    }
    
    /// Derive a key from another key or password
    /// - Parameters:
    ///   - sourceKeyIdentifier: Identifier of the source key
    ///   - salt: Salt data for key derivation
    ///   - iterations: Number of iterations for key derivation
    ///   - keyLength: Length of the derived key in bytes
    ///   - targetKeyIdentifier: Optional identifier for the derived key
    /// - Returns: Identifier for the derived key or error
    public func deriveKey(
        from sourceKeyIdentifier: String,
        salt: SecureBytes,
        iterations: Int,
        keyLength: Int,
        targetKeyIdentifier: String?
    ) async -> Result<String, XPCSecurityError> {
        // Check if the legacy service supports key derivation
        if let keyDeriver = service as? KeyDerivationProtocol {
            do {
                return try keyDeriver.deriveKey(
                    from: sourceKeyIdentifier,
                    salt: salt,
                    iterations: iterations,
                    keyLength: keyLength,
                    targetKeyIdentifier: targetKeyIdentifier
                )
                .mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support key derivation
        return .failure(.unsupportedOperation(name: "Key derivation is not supported by this legacy service"))
    }
    
    /// Get the current status of the service with detailed information
    /// - Returns: Service status information or error
    public func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError> {
        if let statusProvider = service as? StatusReportingProtocol {
            do {
                let status = try await statusProvider.getStatus()
                return .success(XPCServiceStatus(
                    isActive: status.isOperational,
                    version: status.version ?? "unknown",
                    serviceType: status.serviceType ?? "legacy",
                    additionalInfo: status.additionalInfo ?? [:]
                ))
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support status reporting
        let pingResult = await ping()
        return .success(XPCServiceStatus(
            isActive: pingResult,
            version: "unknown",
            serviceType: "legacy",
            additionalInfo: [
                "status": pingResult ? "operational" : "unavailable",
                "source": "legacy adapter"
            ]
        ))
    }
    
    /// Encrypt data using the legacy XPC service
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Optional identifier for the encryption key
    /// - Returns: Result with encrypted data or error
    public func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        if let encryptor = service as? EncryptionProtocol {
            do {
                return try encryptor.encrypt(data, keyIdentifier: keyIdentifier)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let nsData = secureBytesToNSData(data)
            let encryptedData = legacyService.encryptData(nsData, keyIdentifier: keyIdentifier)
            return .success(nsDataToSecureBytes(encryptedData))
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "encrypt", reason: "No encryption service available"))
    }
    
    /// Decrypt data using the legacy XPC service
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Optional identifier for the decryption key
    /// - Returns: Result with decrypted data or error
    public func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        if let decryptor = service as? DecryptionProtocol {
            do {
                return try decryptor.decrypt(data, keyIdentifier: keyIdentifier)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let nsData = secureBytesToNSData(data)
            let decryptedData = legacyService.decryptData(nsData, keyIdentifier: keyIdentifier)
            return .success(nsDataToSecureBytes(decryptedData))
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "decrypt", reason: "No decryption service available"))
    }
    
    /// Hash data using the legacy XPC service
    /// - Parameter data: Data to hash
    /// - Returns: Result with hashed data or error
    public func hashSecureData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        if let hasher = service as? HashingProtocol {
            do {
                return try hasher.hash(data)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let nsData = secureBytesToNSData(data)
            let hashedData = legacyService.hashData(nsData)
            return .success(nsDataToSecureBytes(hashedData))
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "hash", reason: "No hashing service available"))
    }
    
    /// Sign data using the legacy XPC service
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Result with signature or error
    public func signSecureData(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        if let signer = service as? SigningProtocol {
            do {
                return try signer.signSecureData(data, keyIdentifier: keyIdentifier)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let nsData = secureBytesToNSData(data)
            let signature = legacyService.signSecureData(nsData, keyIdentifier: keyIdentifier)
            return .success(nsDataToSecureBytes(signature))
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "sign", reason: "No signing service available"))
    }
    
    /// Verify a signature using the legacy XPC service
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Data for which the signature was generated
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Result with verification status or error
    public func verifySecureSignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        if let verifier = service as? SignatureVerificationProtocol {
            do {
                return try verifier.verify(signature: signature, data: data, keyIdentifier: keyIdentifier)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyVerificationProtocol {
            // Use our mock service for testing
            let nsData = secureBytesToNSData(data)
            let nsSignature = secureBytesToNSData(signature)
            
            guard let result = legacyService.verifySignature(nsSignature, for: nsData, keyIdentifier: keyIdentifier) else {
                return .failure(.operationFailed(operation: "verify", reason: "Verification failed"))
            }
            
            return .success(result.boolValue)
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "verify", reason: "No verification service available"))
    }
    
    /// Generate secure random data
    /// - Parameter length: Length of the random data to generate
    /// - Returns: Result with random data or error
    public func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        if let randomGenerator = service as? LegacyCryptoProtocol {
            do {
                // Use the legacy NSData-based API
                let randomData = randomGenerator.generateRandomData(length: length)
                
                // Convert NSData to SecureBytes
                return .success(nsDataToSecureBytes(randomData))
            } catch let error as NSError {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let randomGenerator = service as? RandomDataGenerationProtocol {
            // Try to use the more modern protocol if available
            do {
                let result = try randomGenerator.generateRandomData(length: length)
                
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support random data generation
        return .failure(.unsupportedOperation(name: "Random data generation is not supported by this legacy service"))
    }
    
    /// Export a key by identifier
    /// - Parameter keyIdentifier: Identifier of the key to export
    /// - Returns: Key material or error
    public func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        if let keyExporter = service as? KeyExportProtocol {
            do {
                return try keyExporter.exportKey(keyIdentifier: keyIdentifier, format: .raw)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.unsupportedOperation(name: "Key export"))
    }
    
    /// Import a key with simplified interface
    /// - Parameters:
    ///   - keyData: Key material to import
    ///   - identifier: Optional identifier for the key
    /// - Returns: Key identifier or error
    public func importKey(
        _ keyData: SecureBytes,
        identifier: String?
    ) async -> Result<String, XPCSecurityError> {
        // Delegate to the more complete implementation
        return await importKey(
            keyData: keyData,
            keyType: .symmetric,
            keyIdentifier: identifier,
            metadata: nil
        )
    }
    
    /// Import a key with the full parameter set required by XPCServiceProtocolComplete
    /// - Parameters:
    ///   - keyData: Key data to import as SecureBytes
    ///   - keyType: Type of key using modern enum type
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the imported key or error
    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // Convert the modern enum type to a string representation for legacy protocols
        let typeString = keyType.rawValue
        
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try keyManager.importKey(
                    keyData: keyData,
                    keyType: typeString,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                
                // Map the CoreErrors.SecurityError to XPCSecurityError
                return result.mapError { error in
                    // Use the utility function to convert errors
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // If no key management protocol is available, return an error
        return .failure(.operationFailed(
            reason: "Key management functionality not available",
            operationName: "importKey"
        ))
    }
    
    // MARK: - Key Management Operations
    
    /// Delete a cryptographic key
    /// - Parameter keyIdentifier: Identifier of the key to delete
    /// - Returns: Success or error with detailed failure information
    public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
        // Check if the legacy service supports key deletion
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try keyManager.deleteKey(keyIdentifier: keyIdentifier)
                
                // Map the CoreErrors.SecurityError to XPCSecurityError
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support key deletion
        return .failure(.unsupportedOperation(name: "Key deletion is not supported by this legacy service"))
    }
    
    /// Generate a cryptographic key to XPCServiceProtocolComplete specifications
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the generated key or error
    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // Check if the legacy service supports key generation with identifiers and metadata
        if let keyManager = service as? KeyManagementProtocol {
            do {
                // Convert the modern enum type to a string representation for legacy protocols
                let typeString = keyType.rawValue
                
                let result = try keyManager.generateKey(
                    keyType: typeString,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                
                // Map the CoreErrors.SecurityError to XPCSecurityError
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Fall back to the simpler key generation if metadata is not supported
        let keyResult = await generateKey(type: keyType, bits: keyType == .rsa ? 2048 : 256)
        
        switch keyResult {
        case .success(let keyData):
            // Generate an identifier if one wasn't provided
            let generatedId = keyIdentifier ?? UUID().uuidString
            
            // Try to import the generated key with the desired identifier
            return await importKey(
                keyData: keyData,
                keyType: keyType,
                keyIdentifier: generatedId,
                metadata: metadata
            )
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Generate a key with basic parameters (legacy method)
    /// - Parameters:
    ///   - type: Type of key to generate
    ///   - bits: Size of the key in bits
    /// - Returns: Generated key data as SecureBytes or error
    /// - Note: This is a legacy method and should be avoided in favor of
    ///         generateKey(keyType:keyIdentifier:metadata:) which conforms to XPCServiceProtocolComplete
    @available(*, deprecated, message: "Use generateKey(keyType:keyIdentifier:metadata:) instead")
    public func generateKey(
        type: XPCProtocolTypeDefs.KeyType,
        bits: Int
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // Delegate to the legacy implementation using string type
        let typeString = type.rawValue
        return await generateKey(type: typeString, bits: bits)
    }
    
    /// List all available cryptographic keys
    /// - Returns: Array of key identifiers or error with detailed failure information
    public func listKeys() async -> Result<[String], XPCSecurityError> {
        // Check if the legacy service supports key listing
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try keyManager.listKeys()
                
                // Map the CoreErrors.SecurityError to XPCSecurityError
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support key listing
        return .failure(.unsupportedOperation(name: "Key listing is not supported by this legacy service"))
    }
    
    /// Generate a key using the legacy string-based key type and bit length
    /// - Parameters:
    ///   - type: String representation of key type
    ///   - bits: Size of the key in bits
    /// - Returns: Generated key data as SecureBytes or error
    private func generateKey(type: String, bits: Int) async -> Result<SecureBytes, XPCSecurityError> {
        // Check if the legacy service supports key generation
        if let keyGenerator = service as? LegacyCryptoProtocol {
            do {
                // Use the legacy NSData-based API
                // Note: This is a synchronous call that may block the thread in legacy implementations
                let keyData = keyGenerator.generateKey(withType: type, bits: bits)
                
                // Convert NSData to SecureBytes
                return .success(nsDataToSecureBytes(keyData))
            } catch let error as NSError {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let keyManager = service as? KeyManagementProtocol {
            // Try to use the more modern KeyManagementProtocol if available
            do {
                let result = try keyManager.generateKey(
                    keyType: type,
                    keyIdentifier: nil,
                    metadata: nil
                )
                
                switch result {
                case .success(let keyIdentifier):
                    // If we successfully generated a key, try to export it
                    if let keyExporter = service as? KeyExportProtocol {
                        let exportResult = try keyExporter.exportKey(
                            keyIdentifier: keyIdentifier,
                            format: .raw
                        )
                        
                        return exportResult.mapError { error in
                            XPCErrorUtilities.convertToXPCError(error)
                        }
                    } else {
                        // We generated a key but can't export it
                        return .failure(.unsupportedOperation(name: "Key export after generation"))
                    }
                    
                case .failure(let error):
                    return .failure(XPCErrorUtilities.convertToXPCError(error))
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation for services that don't support key generation
        return .failure(.unsupportedOperation(name: "Key generation is not supported by this legacy service"))
    }
    
    /// Convert a legacy NSData to SecureBytes
    private func nsDataToSecureBytes(_ nsData: NSData) -> SecureBytes {
        let dataBytes = [UInt8](Data(referencing: nsData))
        return SecureBytes(bytes: dataBytes)
    }
    
    /// Convert SecureBytes to legacy NSData
    private func secureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        var bytes = [UInt8]()
        
        // Use withUnsafeBytes to access the bytes
        secureBytes.withUnsafeBytes { rawBuffer in
            bytes = Array(rawBuffer)
        }
        
        return NSData(bytes: bytes, length: bytes.count)
    }
}

// MARK: - Objective-C Legacy Protocol Definitions

/// Base protocol for legacy XPC service implementations
@available(*, deprecated, message: "Use XPCServiceProtocolBasic instead")
public protocol LegacyXPCServiceProtocolBase: NSObjectProtocol {
    @objc func ping() -> Bool
    @objc func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
}

/// Legacy crypto protocol using NSData
@available(*, deprecated, message: "Use XPCServiceProtocolComplete instead")
public protocol LegacyCryptoProtocol: NSObjectProtocol {
    @objc func encryptData(_ data: NSData, keyIdentifier: String) -> NSData
    @objc func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData
    @objc func hashData(_ data: NSData) -> NSData
    @objc func generateRandomData(length: Int) -> NSData
    @objc func signSecureData(_ data: NSData, keyIdentifier: String) -> NSData
    @objc func generateKey(withType type: String, bits: Int) -> NSData
}

/// Define protocol for verification operations
@available(*, deprecated, message: "Use SignatureVerificationProtocol instead")
public protocol LegacyVerificationProtocol: NSObjectProtocol {
    @objc func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) -> NSNumber
}

/// Basic protocol for legacy XPC services
@available(*, deprecated, message: "Use XPCServiceProtocolStandard instead")
@objc public protocol LegacyXPCServiceProtocol: LegacyXPCServiceProtocolBase {
    // This needs to be updated but we'll come back to fix the other methods later
}

/// Protocol for encryption operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol EncryptionProtocol {
    func encrypt(_ data: SecureBytes, keyIdentifier: String?) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for decryption operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol DecryptionProtocol {
    func decrypt(_ data: SecureBytes, keyIdentifier: String?) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for signing operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol SigningProtocol {
    func signSecureData(_ data: SecureBytes, keyIdentifier: String) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for signature verification
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol SignatureVerificationProtocol {
    func verify(signature: SecureBytes, data: SecureBytes, keyIdentifier: String) throws -> Result<Bool, CoreErrors.SecurityError>
}

/// Protocol for hashing operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol HashingProtocol {
    func hash(_ data: SecureBytes) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for random data generation
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol RandomDataGenerationProtocol {
    func generateRandomData(length: Int) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for key management
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol KeyManagementProtocol {
    func generateKey(keyType: String, keyIdentifier: String?, metadata: [String: String]?) throws -> Result<String, CoreErrors.SecurityError>
    func importKey(keyData: SecureBytes, keyType: String, keyIdentifier: String?, metadata: [String: String]?) throws -> Result<String, CoreErrors.SecurityError>
    func deleteKey(keyIdentifier: String) throws -> Result<Void, CoreErrors.SecurityError>
    func listKeys() throws -> Result<[String], CoreErrors.SecurityError>
}

/// Protocol for key export operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol KeyExportProtocol {
    func exportKey(keyIdentifier: String, format: KeyFormat) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for key derivation
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol KeyDerivationProtocol {
    func deriveKey(
        from sourceKeyIdentifier: String,
        salt: SecureBytes,
        iterations: Int,
        keyLength: Int,
        targetKeyIdentifier: String?
    ) throws -> Result<String, CoreErrors.SecurityError>
}

/// Protocol for certificate operations
@available(*, deprecated, message: "Use modern protocols with SecureBytes instead")
protocol CertificateOperationsProtocol {
    func createCertificateRequest(
        _ request: SecureBytes,
        subjectName: String,
        keyIdentifier: String
    ) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Interface protocol for ping operations
@available(*, deprecated, message: "Use XPCServiceProtocolBasic instead")
@objc
public protocol PingProtocol: NSObjectProtocol {
    @objc func ping() -> Bool
}

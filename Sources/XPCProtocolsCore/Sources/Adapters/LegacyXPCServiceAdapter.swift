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
 */
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
                return .failure(.internalError(reason: "Key derivation failed: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Failed to get service status: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Encryption failed: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Decryption failed: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Hashing failed: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Signing failed: \(error.localizedDescription)"))
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
                return .failure(.internalError(reason: "Verification failed: \(error.localizedDescription)"))
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
        if let randomGenerator = service as? RandomDataGenerationProtocol {
            do {
                return try randomGenerator.generateRandomData(length: length)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(.internalError(reason: "Random generation failed: \(error.localizedDescription)"))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let randomData = legacyService.generateRandomData(length: length)
            return .success(nsDataToSecureBytes(randomData))
        }
        
        // Default implementation returns error
        return .failure(.operationFailed(operation: "generateRandom", reason: "No random generation service available"))
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
                return .failure(.internalError(reason: "Key export failed: \(error.localizedDescription)"))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "exportKey"))
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
    
    /// Create a typed key for protocol conformance
    public func generateKey(
        type: XPCProtocolTypeDefs.KeyType,
        bits: Int
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // Delegate to the legacy implementation using string type
        let typeString = type.rawValue
        return await generateKey(type: typeString, bits: bits)
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

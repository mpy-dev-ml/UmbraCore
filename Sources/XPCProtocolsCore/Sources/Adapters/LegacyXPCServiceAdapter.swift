import CoreErrors
import ErrorHandlingDomains
import Foundation

// Removed import SecurityProtocolsCore to break circular dependency
import UmbraCoreTypes

// Using qualified name for CoreErrors.SecurityError to avoid ambiguity
// Note: Don't need the SPCSecurityError alias as it's already defined in XPCProtocolMigrationFactory.swift

/// LegacyXPCServiceAdapter
///
/// This adapter facilitates the migration from legacy XPC services to the new
/// protocol-based system by wrapping legacy services in a compatible interface.
/// It handles converting between different data formats and error types.
@objc
public class LegacyXPCServiceAdapter: NSObject, @unchecked Sendable {
    /// The legacy service being adapted
    private let service: Any

    /// Initialize with a legacy service instance
    /// - Parameter service: The legacy service to adapt
    public init(service: Any) {
        self.service = service
        super.init()
    }

    /// Maps from legacy error types to the standardised XPCSecurityError domain
    /// This method provides consistent error handling across different implementations.
    ///
    /// - Parameter error: Legacy error from any domain
    /// - Returns: Equivalent XPCSecurityError
    private func convertToXPCError(_ error: Error) -> XPCSecurityError {
        // Use the error utilities to handle conversion
        return XPCErrorUtilities.convertToXPCError(error)
    }
    
    /// Create SecureBytes from NSData
    /// - Parameter data: Source NSData
    /// - Returns: SecureBytes
    private func secureBytes(from data: NSObject) -> SecureBytes {
        if let data = data as? NSData {
            let bytes = data.bytes.bindMemory(to: UInt8.self, capacity: data.length)
            let buffer = UnsafeBufferPointer(start: bytes, count: data.length)
            return SecureBytes(bytes: Array(buffer))
        }
        
        // Return empty SecureBytes if conversion fails
        return SecureBytes(bytes: [])
    }

    /// Verify signature for data with internal implementation
    /// - Parameters:
    ///   - signature: Signature bytes to verify
    ///   - data: Original data that was signed
    ///   - keyIdentifier: Key used to verify the signature
    /// - Returns: Success with boolean indicating validity, or error
    public func verifyInternal(
        signature: SecureBytes,
        data: SecureBytes, 
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        // Check if the service directly supports signature verification
        if let verifier = self.service as? SignatureVerificationProtocol {
            do {
                let result = try verifier.verify(signature: signature, data: data, keyIdentifier: keyIdentifier)
                return result.mapError { error -> XPCSecurityError in
                    return XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyVerificationProtocol {
            // Use legacy service for verification
            if let isValid = legacyService.verifySignature(
                signature.nsData,
                for: data.nsData,
                keyIdentifier: keyIdentifier
            ) {
                if let boolValue = isValid as? Bool {
                    return .success(boolValue)
                } else if let number = isValid as? NSNumber {
                    return .success(number.boolValue)
                } else {
                    return .failure(.invalidData(reason: "Verification result has unexpected type"))
                }
            } else {
                return .failure(.cryptographicError(operation: "verify", details: "Legacy verification failed"))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "verify"))
    }
    
    /// Compute a hash for the given data
    /// - Parameter data: Data to hash
    /// - Returns: Hash result or error
    public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports hashing, use it
        if let hashingService = self.service as? HashingProtocol {
            do {
                let result = try hashingService.hash(data)
                return result.mapError { error -> XPCSecurityError in
                    return XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let hashedData = legacyService.hashData(data.nsData)
            return .success(secureBytes(from: hashedData))
        }
        
        return .failure(.operationNotSupported(name: "hash"))
    }
    
    /// Synchronize keys with the service
    /// - Parameter keyData: Key data for synchronization
    /// - Returns: Result with success or failure
    public func synchronizeKeys(_ keyData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        // If the legacy service supports key synchronization, use it
        if let keySyncService = self.service as? KeySynchronisationProtocol {
            do {
                let result = try keySyncService.synchroniseKeyData(keyData)
                switch result {
                case .success:
                    return .success(())
                case .failure(let error):
                    return .failure(XPCErrorUtilities.convertToXPCError(error))
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyXPCServiceProtocolObjC {
            // Call the legacy service directly
            return await withCheckedContinuation { continuation in
                legacyService.synchroniseKeys?(keyData.withUnsafeBytes { Array($0) }) { error in
                    if let error = error {
                        continuation.resume(returning: .failure(.internalError(reason: error.localizedDescription)))
                    } else {
                        continuation.resume(returning: .success(()))
                    }
                }
            }
        }
        
        return .failure(.operationNotSupported(name: "synchronizeKeys"))
    }
}

// MARK: - Verification Implementation

extension LegacyXPCServiceAdapter {
    /// Verify signature for data and return detailed result
    /// - Parameters:
    ///   - signature: Signature bytes to verify
    ///   - data: Original data that was signed
    ///   - keyIdentifier: Key used to verify the signature
    /// - Returns: Success with boolean indicating validity, or error
    public func verify(
        signature: SecureBytes,
        data: SecureBytes, 
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        // Forward to the internal implementation
        return await verifyInternal(signature: signature, data: data, keyIdentifier: keyIdentifier)
    }
}

// MARK: - XPCServiceProtocolBasic Conformance Extension

extension LegacyXPCServiceAdapter: XPCServiceProtocolBasic {
    /// Return the protocol identifier for this adapter
    public static var protocolIdentifier: String {
        "com.umbra.legacy.adapter.xpc.service"
    }
    
    /// Simple ping implementation required by XPCServiceProtocolBasic
    /// Returns true if the service is available
    @objc
    public func ping() async -> Bool {
        // Check explicitly for the ping method
        if let legacyService = service as? PingProtocol {
            print("DEBUG: found a service implementing ping")
            return legacyService.ping()
        }
        
        print("DEBUG: Using default ping implementation")
        // Default implementation always pings successfully
        return true
    }
    
    /// Implementation of key synchronisation required by XPCServiceProtocolBasic
    /// This is the Objective-C compatible interface with a completion handler.
    /// - Parameters:
    ///   - bytes: Key bytes for synchronisation
    ///   - completionHandler: Callback for success or failure
    @objc
    public func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // If the legacy service implements key synchronisation, use it
        if let keySyncService = self.service as? KeySynchronisationProtocol {
            Task {
                do {
                    let result = try keySyncService.synchroniseKeyData(SecureBytes(bytes: bytes))
                    switch result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        // Convert our error to an NSError for the objc interface
                        let nsError = NSError(domain: "XPCService", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                        completionHandler(nsError)
                    }
                } catch {
                    completionHandler(error as NSError)
                }
            }
        } else if let legacyService = self.service as? LegacyXPCServiceProtocolObjC {
            // Call the legacy service directly
            legacyService.synchroniseKeys?(bytes, completionHandler: completionHandler)
        } else {
            // No implementation available, return generic error
            let error = NSError(domain: "XPCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation not supported"])
            completionHandler(error)
        }
    }
    
    /// Extended ping implementation with error handling
    public func pingBasic() async -> Result<Bool, XPCSecurityError> {
        .success(await ping())
    }
    
    /// Get the service version
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0-legacy")
    }
    
    /// Get the device identifier
    public func getDeviceIdentifier() async -> Result<String, XPCSecurityError> {
        .success(UUID().uuidString)
    }
}

// MARK: - XPCServiceProtocolStandard Conformance Extension

extension LegacyXPCServiceAdapter: XPCServiceProtocolStandard {
    /// Generate random data of the specified length
    /// - Parameter length: Length of random data to generate
    /// - Returns: Random data of specified length or nil if generation failed
    @objc
    public func generateRandomData(length: Int) async -> NSObject? {
        // If the legacy service supports random data generation, use it
        if let legacyService = self.service as? LegacyCryptoProtocol {
            return legacyService.generateRandomData(length: length)
        }
        return nil
    }
    
    /// Ping with error handling
    public func pingStandard() async -> Result<Bool, XPCSecurityError> {
        await pingBasic()
    }
    
    /// Reset security state
    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // Default implementation succeeds without doing anything
        .success(())
    }
    
    /// Encrypt data with type-safe interface
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use for encryption
    /// - Returns: Encrypted data result or error
    public func encrypt(
        data: SecureBytes,
        keyIdentifier: String? = nil
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // Check if the service directly supports encryption
        if let cryptoService = self.service as? EncryptionProtocol {
            do {
                let result = try cryptoService.encrypt(data)
                return result.mapError { error -> XPCSecurityError in
                    return XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let encryptedData = legacyService.encryptData(data.nsData, keyIdentifier: keyIdentifier)
            return .success(secureBytes(from: encryptedData))
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "encrypt"))
    }
    
    /// Decrypt data with type-safe interface
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use for decryption
    /// - Returns: Decrypted data result or error
    public func decrypt(
        data: SecureBytes,
        keyIdentifier: String? = nil
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // Check if the service directly supports decryption
        if let cryptoService = self.service as? DecryptionProtocol {
            do {
                let result = try cryptoService.decrypt(data, keyIdentifier: keyIdentifier ?? "")
                return result.mapError { error -> XPCSecurityError in
                    return XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use the legacy service directly for testing
            let decryptedData = legacyService.decryptData(data.nsData, keyIdentifier: nil)
            return .success(secureBytes(from: decryptedData))
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "decrypt"))
    }
    
    /// Objective-C compatible encryption method
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Optional key identifier to use for encryption
    /// - Returns: Encrypted data or nil
    @objc
    public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        let secureData = secureBytes(from: data)
        let result = await encrypt(data: secureData, keyIdentifier: keyIdentifier)
        
        switch result {
        case .success(let encryptedData):
            return encryptedData.nsData
        case .failure:
            return nil
        }
    }
    
    /// Objective-C compatible decryption method
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Optional key identifier to use for decryption
    /// - Returns: Decrypted data or nil
    @objc
    public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        // If the legacy service supports decryption, use it
        if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use the legacy service directly for testing
            return legacyService.decryptData(data, keyIdentifier: keyIdentifier)
        }
        
        return nil
    }
    
    /// Hash data using cryptographic function
    /// - Parameter data: Data to hash
    /// - Returns: Hash digest or nil
    @objc
    public func hashData(_ data: NSData) async -> NSObject? {
        // If the legacy service supports hashing, use it
        if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use the legacy service directly for testing
            return legacyService.hashData(data)
        }
        
        return nil
    }
    
    /// Sign data with legacy interface
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Key identifier to use for signing
    /// - Returns: Signature data or nil
    @objc
    public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        // Convert to SecureBytes for internal use
        let dataBytes = secureBytes(from: data)
        
        // Use the async sign method and extract the result
        let result = await sign(data: dataBytes, keyIdentifier: keyIdentifier)
        
        switch result {
        case .success(let signatureBytes):
            return signatureBytes.nsData
        case .failure:
            return nil
        }
    }
    
    /// Verify signature with legacy interface
    /// - Parameters:
    ///   - signature: Signature data to verify
    ///   - data: Original data that was signed
    ///   - keyIdentifier: Key identifier for verification
    /// - Returns: Boolean indication of validity as NSNumber or nil
    @objc
    public func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier: String
    ) async -> NSNumber? {
        // Convert to SecureBytes for internal use
        let signatureBytes = secureBytes(from: signature)
        let dataBytes = secureBytes(from: data)
        
        // Use the internal verification method
        let result = await verifyInternal(signature: signatureBytes, data: dataBytes, keyIdentifier: keyIdentifier)
        switch result {
        case .success(let isValid):
            return NSNumber(value: isValid)
        case .failure:
            return nil
        }
    }
    
    /// Get service status information
    /// - Returns: Dictionary with service status information
    @objc
    public func getServiceStatus() async -> NSDictionary? {
        // If the legacy service supports status retrieval, use it
        if let legacyService = self.service as? LegacyXPCServiceProtocolObjC {
            // Use our mock service for testing
            if let statusString = legacyService.getServiceStatus?() {
                // Convert NSString to NSDictionary if possible
                if let statusDict = ["status": statusString] as NSDictionary? {
                    return statusDict
                }
            }
        }
        
        // Default implementation returns basic status
        return ["status": "running"] as NSDictionary
    }
    
    /// Delete a key by identifier
    /// - Parameter keyIdentifier: Identifier of the key to delete
    /// - Returns: Success or error
    public func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError> {
        // If the legacy service supports key deletion, use it
        if let keyManager = self.service as? KeyManagementProtocol {
            do {
                let result = try keyManager.deleteKey(keyIdentifier: keyIdentifier)
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "deleteKey"))
    }
    
    /// List all available keys
    /// - Returns: Array of key identifiers
    public func listKeys() async -> Result<[String], XPCSecurityError> {
        // If the legacy service supports key listing, use it
        if let keyManager = self.service as? KeyManagementProtocol {
            do {
                let result = try keyManager.listKeys()
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation returns mock keys
        return .success(["legacy-key-1", "legacy-key-2"])
    }
    
    /// Generate a cryptographic key with full type information
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata for the key
    /// - Returns: Key identifier or error
    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // If the legacy service supports key generation, use it
        if let keyManager = self.service as? KeyManagementProtocol {
            do {
                let result = try keyManager.generateKey(
                    keyType: keyType.rawValue,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation returns mock key identifier
        return .success(keyIdentifier ?? "legacy-gen-key-\(UUID().uuidString)")
    }
    
    /// Import a key with full type information
    /// - Parameters:
    ///   - keyData: Key material to import
    ///   - keyType: Type of key being imported
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata for the key
    /// - Returns: Key identifier or error
    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // If the legacy service supports key import, use it
        if let keyManager = self.service as? KeyManagementProtocol {
            do {
                let result = try keyManager.importKey(
                    keyData: keyData,
                    keyType: keyType.rawValue,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                return result.mapError { error in
                    XPCErrorUtilities.convertToXPCError(error)
                }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        }
        
        // Default implementation returns failure
        return .failure(.operationNotSupported(name: "importKey"))
    }
}

// MARK: - Legacy Extensions (Deprecated)

/// Extension containing deprecated methods that may conflict with protocol requirements
@available(*, deprecated, message: "Use ModernXPCService instead")
extension LegacyXPCServiceAdapter {
    /// Generate a cryptographic key
    ///
    /// - Parameters:
    ///   - type: Type of key to generate
    ///   - bits: Bit size for the key
    /// - Returns: Key material or error
    public func generateKey(
        type: String,
        bits: Int
    ) async -> Result<SecureBytes, XPCSecurityError> {
        guard let randomData = await generateRandomData(length: bits / 8) else {
            return .failure(.cryptographicError(operation: "key generation", details: "Failed to generate random data"))
        }

        // Convert to SecureBytes using helper method
        return .success(secureBytes(from: randomData))
    }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolComplete {
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
    
    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier for the key to use for signing
    /// - Returns: Signature bytes or error
    public func sign(
        data: SecureBytes,
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports signing, use it
        if let signer = self.service as? SigningProtocol {
            do {
                return try signer.sign(data, keyIdentifier: keyIdentifier)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let signature = legacyService.signData(data.nsData, keyIdentifier: keyIdentifier)
            return .success(secureBytes(from: signature))
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "sign"))
    }
    
    /// Generate cryptographically secure random data
    /// - Parameter length: Length of random data to generate
    /// - Returns: Random data or error
    public func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports random data generation, use it
        if let generator = self.service as? RandomDataGenerationProtocol {
            do {
                return try generator.generateRandomData(length: length)
                    .mapError { error in
                        XPCErrorUtilities.convertToXPCError(error)
                    }
            } catch {
                return .failure(XPCErrorUtilities.convertToXPCError(error))
            }
        } else if let legacyService = self.service as? LegacyCryptoProtocol {
            // Use our mock service for testing
            let randomData = legacyService.generateRandomData(length: length)
            return .success(secureBytes(from: randomData))
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "generateSecureRandomData"))
    }
    
    /// Export a key by identifier
    /// - Parameter keyIdentifier: Identifier of the key to export
    /// - Returns: Key material or error
    public func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
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
}

// MARK: - Legacy Protocol Definitions

/// Define protocols for cryptographic operations
@objc
public protocol LegacyCryptoProtocol: NSObjectProtocol {
    @objc func encryptData(_ data: NSData, keyIdentifier: String?) -> NSData
    @objc func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData
    @objc func hashData(_ data: NSData) -> NSData
    @objc func generateRandomData(length: Int) -> NSData
    @objc func signData(_ data: NSData, keyIdentifier: String) -> NSData
}

/// Define protocol for verification operations
@objc
public protocol LegacyVerificationProtocol: NSObjectProtocol {
    @objc func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) -> NSNumber?
}

/// Protocol for a basic legacy XPC service interface
@objc
public protocol LegacyXPCServiceProtocolBase {
    @objc func ping() -> Bool
}

@objc
public protocol LegacyXPCServiceProtocolObjC {
    @objc func ping() -> Bool
    @objc optional func encryptData(_ data: NSData, keyIdentifier: String?) -> NSData?
    @objc optional func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData?
    @objc optional func hashData(_ data: NSData) -> NSData?
    @objc optional func generateRandomData(length: Int) -> NSData?
    @objc optional func signData(_ data: NSData, keyIdentifier: String) -> NSData?
    @objc optional func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) -> NSNumber?
    @objc optional func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
    @objc optional func getServiceStatus() -> NSDictionary?
    @objc optional func generateKey(keyType: String, keyIdentifier: String?, metadata: NSDictionary?) -> NSNumber?
    @objc optional func deleteKey(keyIdentifier: String) -> NSNumber?
    @objc optional func listKeys() -> NSArray?
    @objc optional func importKey(keyData: NSData, keyType: String, keyIdentifier: String?, metadata: NSDictionary?) -> NSNumber?
}

protocol LegacyXPCServiceProtocol: LegacyXPCServiceProtocolBase {
    // This needs to be updated but we'll come back to fix the other methods later
}

/// Protocol for encryption operations
protocol EncryptionProtocol {
    func encrypt(_ data: SecureBytes) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for decryption operations
protocol DecryptionProtocol {
    func decrypt(_ data: SecureBytes, keyIdentifier: String) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for signing operations
protocol SigningProtocol {
    func sign(_ data: SecureBytes, keyIdentifier: String) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for signature verification
protocol SignatureVerificationProtocol {
    func verify(signature: SecureBytes, data: SecureBytes, keyIdentifier: String) throws -> Result<Bool, CoreErrors.SecurityError>
}

/// Protocol for hashing operations
protocol HashingProtocol {
    func hash(_ data: SecureBytes) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for random data generation
protocol RandomDataGenerationProtocol {
    func generateRandomData(length: Int) throws -> Result<SecureBytes, CoreErrors.SecurityError>
}

/// Protocol for key management
protocol KeyManagementProtocol {
    func generateKey(keyType: String, keyIdentifier: String?, metadata: [String: String]?) throws -> Result<String, CoreErrors.SecurityError>
    func importKey(keyData: SecureBytes, keyType: String, keyIdentifier: String?, metadata: [String: String]?) throws -> Result<String, CoreErrors.SecurityError>
    func deleteKey(keyIdentifier: String) throws -> Result<Void, CoreErrors.SecurityError>
    func listKeys() throws -> Result<[String], CoreErrors.SecurityError>
}

/// Protocol for key synchronisation
protocol KeySynchronisationProtocol {
    func synchroniseKeyData(_ data: SecureBytes) throws -> Result<Void, CoreErrors.SecurityError>
}

/// Protocol for format conversion
protocol LegacyEncryptor {
    func createSecureBytes(from bytes: [UInt8]) -> Any
    func extractBytesFromSecureBytes(_ data: Any) -> [UInt8]
}

/// Define a simple protocol just for ping
@objc
public protocol PingProtocol: NSObjectProtocol {
    @objc func ping() -> Bool
}

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
    /// - Returns: Standardised XPCSecurityError
    private static func mapError(_ error: Error) -> XPCSecurityError {
        XPCErrorUtilities.convertToXPCError(error)
    }

    /// This method provides bidirectional conversion capability for backward compatibility.
    /// It delegates to the centralised mapper for consistent error handling.
    ///
    /// - Parameter error: A standardised XPCSecurityError
    /// - Returns: A legacy SecurityError from the SecurityProtocolsCore module
    @available(*, deprecated, message: "Use XPCSecurityError instead")
    public static func mapToLegacyError(_ error: XPCSecurityError) -> CoreErrors.SecurityError {
        // Map XPCSecurityError to CoreErrors.SecurityError with proper cases
        switch error {
        case .serviceUnavailable:
            return CoreErrors.SecurityError.operationFailed(operation: "service connection", reason: "Service unavailable")
        case .operationNotSupported(let name):
            return CoreErrors.SecurityError.missingImplementation(component: name)
        case .invalidData(let reason):
            return CoreErrors.SecurityError.invalidContext(reason: reason)
        case .encryptionFailed(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "encryption", reason: reason)
        case .decryptionFailed(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "decryption", reason: reason)
        case .keyGenerationFailed(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "key generation", reason: reason)
        case .notImplemented(let reason):
            return CoreErrors.SecurityError.missingImplementation(component: reason)
        case .internalError(let reason):
            return CoreErrors.SecurityError.internalError(description: reason)
        case .invalidInput(let details):
            return CoreErrors.SecurityError.invalidParameter(name: "input", reason: details)
        case .serviceNotReady(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "service initialization", reason: reason)
        case .timeout(let after):
            return CoreErrors.SecurityError.operationFailed(operation: "request", reason: "Timed out after \(after) seconds")
        case .authenticationFailed(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "authentication", reason: reason)
        case .authorizationDenied(let operation):
            return CoreErrors.SecurityError.operationFailed(operation: operation, reason: "Authorization denied")
        case .invalidState(let details):
            return CoreErrors.SecurityError.invalidContext(reason: details)
        case .keyNotFound(let identifier):
            return CoreErrors.SecurityError.invalidKey(reason: "Key not found: \(identifier)")
        case .invalidKeyType(let expected, let received):
            return CoreErrors.SecurityError.invalidKey(reason: "Invalid key type: expected \(expected), got \(received)")
        case .cryptographicError(let operation, let details):
            return CoreErrors.SecurityError.operationFailed(operation: operation, reason: details)
        case .connectionInterrupted:
            return CoreErrors.SecurityError.operationFailed(operation: "connection", reason: "Connection interrupted")
        case .connectionInvalidated(let reason):
            return CoreErrors.SecurityError.operationFailed(operation: "connection", reason: "Connection invalidated: \(reason)")
        }
    }

    /// Convert SecureBytes to legacy SecureBytes
    /// - Parameter bytes: SecureBytes to convert
    /// - Returns: Legacy SecureBytes
    private func convertToSecureBytes(_ bytes: SecureBytes) -> Any {
        // If the legacy service implements conversion, use that
        if let legacyEncryptor = service as? LegacyEncryptor {
            return legacyEncryptor.createSecureBytes(from: bytes.withUnsafeBytes { Array($0) })
        }

        // Otherwise, just return the bytes array directly
        return bytes.withUnsafeBytes { Array($0) }
    }

    /// Convert legacy SecureBytes to SecureBytes
    /// - Parameter binaryData: Legacy SecureBytes to convert
    /// - Returns: SecureBytes
    private func convertToSecureBytes(_ binaryData: Any) -> Result<SecureBytes, XPCSecurityError> {
        // Try to extract bytes using a protocol extension
        if let legacyEncryptor = service as? LegacyEncryptor {
            let bytes = legacyEncryptor.extractBytesFromSecureBytes(binaryData)
            return .success(SecureBytes(bytes: bytes))
        }

        // If we can extract the bytes directly
        if let dataBytes = binaryData as? [UInt8] {
            return .success(SecureBytes(bytes: dataBytes))
        }

        // If we can't extract bytes, return an error
        return .failure(.invalidInput(details: "Could not convert legacy data to SecureBytes"))
    }

    /// Convert any error to an XPCSecurityError
    /// - Parameter error: Error to convert
    /// - Returns: Converted XPCSecurityError
    private func mapErrorToXPCError(_ error: Error) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }
        
        // Default to internal error if we can't map specifically
        return .internalError(reason: "Legacy service error: \(error.localizedDescription)")
    }
    
    /// Helper method to convert to SecureBytes
    /// - Parameter data: NSData to convert
    /// - Returns: SecureBytes instance
    private func secureBytes(from data: NSData) -> SecureBytes {
        // Create SecureBytes from the NSData bytes
        let bytes = data.bytes.bindMemory(to: UInt8.self, capacity: data.length)
        let buffer = UnsafeBufferPointer(start: bytes, count: data.length)
        return SecureBytes(bytes: Array(buffer))
    }
}

// MARK: - XPCServiceProtocolBasic Conformance Extension

extension LegacyXPCServiceAdapter: XPCServiceProtocolBasic {
    /// Return the protocol identifier for this adapter
    public static var protocolIdentifier: String {
        "com.umbra.legacy.adapter.xpc.service"
    }

    /// Ping the service to check if it's responsive
    /// - Returns: `true` if the service is responsive, `false` otherwise
    @objc
    public func ping() async -> Bool {
        // If the legacy service supports ping, use it
        if let pingable = service as? PingableService {
            let result = await pingable.ping()
            switch result {
            case let .success(value):
                return value
            case .failure:
                return false
            }
        } else if let legacyBase = service as? LegacyXPCBase {
            // Try the legacy XPC base protocol
            do {
                let pingResult = try await legacyBase.ping()
                return pingResult
            } catch {
                return false
            }
        }

        // Default to true if no ping method available
        return true
    }

    /// Synchronise keys with the legacy service
    /// - Parameters:
    ///   - bytes: Raw byte array for key synchronisation
    ///   - completionHandler: Called with `nil` if successful, or an NSError if failed
    @objc
    public func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // If the legacy service implements key synchronisation, use it
        if let keySyncService = service as? KeySynchronisationProtocol {
            Task {
                do {
                    let data = try await keySyncService.synchroniseKeyData(SecureBytes(bytes: bytes))
                    if data != nil {
                        completionHandler(nil)
                    } else {
                        completionHandler(NSError(domain: "com.umbra.xpc.error", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Key synchronisation failed with nil result"
                        ]))
                    }
                } catch {
                    completionHandler(error as NSError)
                }
            }
        } else if let legacyKeySync = service as? LegacyKeySynchronisation {
            // Try the legacy key synchronisation protocol
            legacyKeySync.synchroniseKeys(bytes) { error in
                // Convert Error? to NSError? by wrapping it in an NSError if needed
                let nsError = error.map { NSError(domain: "XPCProtocolsCore", code: -1, userInfo: [NSLocalizedDescriptionKey: $0.localizedDescription]) }
                completionHandler(nsError)
            }
        } else {
            // No implementation available
            completionHandler(NSError(domain: "com.umbra.xpc.error", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "Key synchronisation not supported by service"
            ]))
        }
    }
}

// MARK: - XPCServiceProtocolStandard Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolStandard {
    /// Generate random data of specified length
    /// - Parameter length: Length of random data to generate in bytes
    /// - Returns: Random data as NSObject or nil if generation failed
    @objc
    public func generateRandomData(length: Int) async -> NSObject? {
        // If the legacy service supports generateRandomData, use it
        if let randomDataGenerator = service as? RandomDataGeneratorProtocol {
            do {
                let result = try await randomDataGenerator.generateRandomData(Int64(length))
                if let data = result as? NSObject {
                    return data
                }
                return nil
            } catch {
                return nil
            }
        }
        
        // Check if the service conforms to our test protocol
        if let legacyService = service as? LegacyXPCServiceProtocol {
            return legacyService.generateRandomData(length: length)
        }
        
        // Default implementation returns nil indicating failure
        return nil
    }
    
    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Identifier for the key to use
    /// - Returns: Encrypted data as NSObject or nil if encryption failed
    @objc
    public func encryptData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        // If the legacy service supports encryption, use it
        if let encryptor = service as? EncryptionProtocol {
            do {
                let secureData = secureBytes(from: data)
                let result = try await encryptor.encrypt(secureData, keyIdentifier: keyIdentifier)
                if case let .success(encryptedData) = result {
                    return encryptedData.nsData as NSObject
                }
                return nil
            } catch {
                return nil
            }
        }
        
        // Check if the service conforms to our test protocol
        if let legacyService = service as? LegacyXPCServiceProtocol {
            return legacyService.encryptData(data, keyIdentifier: keyIdentifier)
        }
        
        // Default implementation returns nil indicating failure
        return nil
    }
    
    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: Raw data to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Encrypted data as NSObject (typically NSData) or nil if encryption failed
    public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        // If keyIdentifier is nil, we can't proceed with encryption
        guard let keyId = keyIdentifier else {
            return nil
        }
        
        // Delegate to the existing implementation with the non-optional key ID
        return await encryptData(data, keyIdentifier: keyId)
    }
    
    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Identifier for the key to use
    /// - Returns: Decrypted data as NSObject or nil if decryption failed
    @objc
    public func decryptData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        // If the legacy service supports decryption, use it
        if let decryptor = service as? DecryptionProtocol {
            do {
                let secureData = secureBytes(from: data)
                let result = try await decryptor.decrypt(secureData, keyIdentifier: keyIdentifier)
                if case let .success(decryptedData) = result {
                    return decryptedData.nsData as NSObject
                }
                return nil
            } catch {
                return nil
            }
        }
        // Default implementation returns nil indicating failure
        return nil
    }
    
    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: Encrypted data to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Decrypted data as NSObject (typically NSData) or nil if decryption failed
    public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        // If keyIdentifier is nil, we can't proceed with decryption
        guard let keyId = keyIdentifier else {
            return nil
        }
        
        // Delegate to the existing implementation with the non-optional key ID
        return await decryptData(data, keyIdentifier: keyId)
    }
    
    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier for the key to use
    /// - Returns: Signature as NSObject or nil if signing failed
    @objc
    public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        // If the legacy service supports signing, use it
        if let signer = service as? SigningProtocol {
            do {
                let secureData = secureBytes(from: data)
                let result = try await signer.sign(secureData, keyIdentifier: keyIdentifier)
                if case let .success(signature) = result {
                    return signature.nsData as NSObject
                }
                return nil
            } catch {
                return nil
            }
        }
        
        // Check if the service conforms to our test protocol
        if let legacyService = service as? LegacyXPCServiceProtocol {
            return legacyService.signData(data, keyIdentifier: keyIdentifier)
        }
        
        // Default implementation returns nil indicating failure
        return nil
    }
    
    /// Verify signature for data
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Data to verify signature against
    ///   - keyIdentifier: Identifier for the key to use
    /// - Returns: NSNumber containing a boolean indicating if signature is valid
    @objc
    public func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier: String
    ) async -> NSNumber? {
        // If the legacy service supports signature verification, use it
        if let verifier = service as? VerificationProtocol {
            do {
                let secureSignature = secureBytes(from: signature)
                let secureData = secureBytes(from: data)
                let result = try await verifier.verify(
                    signature: secureSignature,
                    data: secureData,
                    keyIdentifier: keyIdentifier
                )
                return NSNumber(value: result)
            } catch {
                return nil
            }
        }
        
        // Check if the service conforms to our test protocol
        if let legacyService = service as? LegacyXPCServiceProtocol {
            return legacyService.verifySignature(signature, for: data, keyIdentifier: keyIdentifier)
        }
        
        // Default implementation returns nil indicating failure
        return nil
    }
    
    /// Delete a key from the service's key store
    /// - Parameter keyIdentifier: Identifier of key to delete
    /// - Returns: Success or error
    public func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError> {
        // If the legacy service supports key deletion, use it
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try await keyManager.deleteKey(keyIdentifier: keyIdentifier)
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "deleteKey"))
    }
    
    /// List all key identifiers
    /// - Returns: Array of key identifiers
    public func listKeys() async -> Result<[String], XPCSecurityError> {
        // If the legacy service supports listing keys, use it
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try await keyManager.listKeys()
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "listKeys"))
    }
    
    /// Generate a cryptographic key
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key, or nil to auto-generate
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the generated key or error
    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // If the legacy service supports key generation, use it
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try await keyManager.generateKey(
                    keyType: keyType.rawValue,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "generateKey"))
    }
    
    /// Import a key
    /// - Parameters:
    ///   - keyData: Key data
    ///   - keyType: Type of key
    ///   - keyIdentifier: Optional identifier for the key, or nil to auto-generate
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the imported key
    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // If the legacy service supports key import, use it
        if let keyManager = service as? KeyManagementProtocol {
            do {
                let result = try await keyManager.importKey(
                    keyData: keyData,
                    keyType: keyType.rawValue,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "importKey"))
    }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolComplete {
    /// Verify a signature with secure bytes
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - data: The data to verify against
    ///   - keyIdentifier: The key identifier to use for verification
    /// - Returns: Whether the signature is valid
    public func verify(
        signature: SecureBytes,
        data: SecureBytes,
        keyIdentifier: String
    ) async -> Bool {
        // If the legacy service supports verification with SecureBytes, use it
        if let verifier = service as? VerificationProtocol {
            do {
                let isValid = try await verifier.verify(
                    signature: signature,
                    data: data,
                    keyIdentifier: keyIdentifier
                )
                return isValid
            } catch {
                return false
            }
        } else if let legacyVerifier = service as? LegacyVerificationProtocol {
            // Try legacy verification
            let result = await legacyVerifier.verifySignature(
                signature,
                for: data,
                keyIdentifier: keyIdentifier
            )
            
            switch result {
            case let .success(isValid):
                return isValid
            case .failure:
                return false
            }
        }
        
        // Default to false if verification isn't supported
        return false
    }
    
    public func encrypt(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports encryption, use it
        if let encryptor = service as? EncryptionProtocol {
            do {
                let result = try await encryptor.encrypt(data, keyIdentifier: keyIdentifier)
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "encrypt"))
    }
    
    public func decrypt(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports decryption, use it
        if let decryptor = service as? DecryptionProtocol {
            do {
                let result = try await decryptor.decrypt(data, keyIdentifier: keyIdentifier)
                return result.mapError { error in
                    mapErrorToXPCError(error)
                }
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "decrypt"))
    }
    
    public func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        // If the legacy service supports random data generation, use it
        if let randomDataGenerator = service as? RandomDataGeneratorProtocol {
            do {
                let result = try await randomDataGenerator.generateRandomData(Int64(length))
                if let data = result as? NSData {
                    return .success(secureBytes(from: data))
                }
                return .failure(.invalidData(reason: "Generated data has unexpected type"))
            } catch {
                return .failure(mapErrorToXPCError(error))
            }
        }
        
        // Default implementation returns error
        return .failure(.operationNotSupported(name: "generateSecureRandomData"))
    }
}

// MARK: - XPCServiceProtocolComplete Conformance Methods

extension LegacyXPCServiceAdapter {
    /// Verify a signature for data using the proper protocol signature
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - data: The data to verify against
    ///   - keyIdentifier: Identifier of the key to use for verification
    /// - Returns: Verification result or error with detailed failure information
    public func verify(
        signature: SecureBytes,
        data: SecureBytes,
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        // Call the specific boolean-returning verify method to avoid ambiguity
        let verifyMethod = self.verify(signature:data:keyIdentifier:) as (SecureBytes, SecureBytes, String) async -> Bool
        let isValid = await verifyMethod(signature, data, keyIdentifier)
        return .success(isValid)
    }
}

// MARK: - Legacy Protocol Definitions

/// Protocol for legacy verification
protocol LegacyVerificationProtocol {
    func verifySignature(
        _ signature: SecureBytes,
        for data: SecureBytes,
        keyIdentifier: String
    ) async -> Result<Bool, Error>
}

/// Protocol for legacy XPC base functionality
protocol LegacyXPCBase {
    func ping() async throws -> Bool
    func synchroniseKeys(_ syncData: Any) async throws
}

/// Protocol for legacy ping functionality
protocol PingableService {
    func ping() async -> Result<Bool, Error>
}

/// Protocol for legacy encryption
protocol LegacyEncryptor {
    func encrypt(_ data: Any) async -> Result<Any, Error>
    func decrypt(_ data: Any) async -> Result<Any, Error>
    // Helper methods for type conversion
    func createSecureBytes(from bytes: [UInt8]) -> Any
    func extractBytesFromSecureBytes(_ secureBytes: Any) -> [UInt8]
}

/// Protocol for legacy key generation
protocol LegacyKeyGenerator {
    func generateKey() async throws -> Any
}

/// Protocol for legacy hashing
protocol LegacyHasher {
    func hash(_ data: Any) async -> Result<Any, Error>
}

/// Protocol for legacy random data generation
protocol LegacyRandomGenerator {
    func generateRandomData(length: Int) async throws -> Any
}

/// Protocol for legacy signature verification
protocol LegacyVerifier {
    func verifySignature(_ signature: Any, for data: Any, keyIdentifier: String) async
        -> Result<Bool, Error>
}

/// Protocol for legacy key synchronisation
protocol LegacyKeySynchronisation {
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (Error?) -> Void)
}

/// Protocol for key synchronisation
protocol KeySynchronisationProtocol {
    func synchroniseKeyData(_ data: SecureBytes) async throws -> Any?
}

/// Protocol for random data generation
protocol RandomDataGeneratorProtocol {
    func generateRandomData(_ length: Int64) async throws -> Any?
}

/// Protocol for encryption
protocol EncryptionProtocol {
    func encrypt(_ data: SecureBytes, keyIdentifier: String) async throws -> Result<SecureBytes, Error>
}

/// Protocol for decryption
protocol DecryptionProtocol {
    func decrypt(_ data: SecureBytes, keyIdentifier: String) async throws -> Result<SecureBytes, Error>
}

/// Protocol for signing
protocol SigningProtocol {
    func sign(_ data: SecureBytes, keyIdentifier: String) async throws -> Result<SecureBytes, Error>
}

/// Protocol for verification
protocol VerificationProtocol {
    func verify(signature: SecureBytes, data: SecureBytes, keyIdentifier: String) async throws -> Bool
}

/// Protocol for key management
protocol KeyManagementProtocol {
    func deleteKey(keyIdentifier: String) async throws -> Result<Void, Error>
    func listKeys() async throws -> Result<[String], Error>
    func generateKey(
        keyType: String,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async throws -> Result<String, Error>
    func importKey(
        keyData: SecureBytes,
        keyType: String,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async throws -> Result<String, Error>
}

/// Protocol for test XPC service
protocol LegacyXPCServiceProtocol {
    func ping() -> Bool
    func encryptData(_ data: NSData, keyIdentifier: String?) -> NSData?
    func decryptData(_ data: NSData, keyIdentifier: String?) -> NSData?
    func hashData(_ data: NSData) -> NSData?
    func generateRandomData(length: Int) -> NSObject?
    func signData(_ data: NSData, keyIdentifier: String) -> NSObject?
    func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier: String
    ) -> NSNumber?
}

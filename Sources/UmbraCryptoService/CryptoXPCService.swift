import Core
import CoreErrors
import CryptoSwiftFoundationIndependent
import CryptoTypes
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraCoreTypes
import UmbraXPC
import XPC
import XPCProtocolsCore

/// Extension to generate random data using SecRandomCopyBytes
extension Data {
    static func random(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }
}

/// Custom GCM format for CryptoXPCService
/// Format: <iv (12 bytes)><ciphertext>
enum CryptoFormat {
    static let ivSize = 12

    static func packEncryptedData(iv: [UInt8], ciphertext: [UInt8]) -> [UInt8] {
        iv + ciphertext
    }

    static func unpackEncryptedData(data: [UInt8]) -> (iv: [UInt8], ciphertext: [UInt8])? {
        guard data.count > ivSize else { return nil }
        let iv = Array(data[0 ..< ivSize])
        let ciphertext = Array(data[ivSize...])
        return (iv, ciphertext)
    }
}

/// XPC service for cryptographic operations
///
/// This service uses CryptoSwiftFoundationIndependent to provide platform-independent cryptographic
/// operations across process boundaries. It is specifically designed for:
/// - Cross-process encryption/decryption via XPC
/// - Platform-independent cryptographic operations
/// - Flexible implementation for XPC service requirements
///
/// Note: This implementation uses CryptoSwift instead of CryptoKit to ensure
/// reliable cross-process operations. For main app cryptographic operations,
/// use DefaultCryptoService which provides hardware-backed security.
@available(macOS 14.0, *)
@objc(CryptoXPCService)
public final class CryptoXPCService: NSObject, XPCServiceProtocolComplete, @unchecked Sendable {
    /// Dependencies for the crypto service
    private let dependencies: CryptoXPCServiceDependencies

    /// Queue for cryptographic operations
    private let cryptoQueue = DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)

    /// XPC connection for the service
    var connection: NSXPCConnection?

    /// Protocol identifier for XPC service
    public static var protocolIdentifier: String {
        "com.umbracore.xpc.crypto"
    }

    /// Initialize the crypto service with dependencies
    /// - Parameter dependencies: Dependencies required by the service
    public init(dependencies: CryptoXPCServiceDependencies) {
        self.dependencies = dependencies
        super.init()
    }

    // MARK: - XPCServiceProtocolBasic

    /// Basic ping method to test if service is responsive
    /// - Returns: True if service is available
    @objc
    public func ping() async -> Bool {
        return true
    }

    /// Synchronize keys between XPC service and client
    /// - Parameter syncData: Secure bytes for key synchronization
    /// - Throws: XPCSecurityError if synchronization fails
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Basic implementation - no key synchronization needed in this service
        // Could be expanded if needed
        if syncData.isEmpty {
            throw XPCSecurityError.invalidInput(details: "Empty synchronization data")
        }
    }

    // MARK: - XPCServiceProtocolStandard

    /// Generate random data of specified length
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or error on failure
    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        let data = Data.random(count: length)
        return .success(SecureBytes(bytes: [UInt8](data)))
    }

    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with encrypted SecureBytes on success or error on failure
    public func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            guard let keyId = keyIdentifier, !keyId.isEmpty else {
                return .failure(.invalidInput(details: "Missing key identifier"))
            }

            let keyData = try await retrieveKeyData(identifier: keyId)

            // Generate a random IV for AES-GCM
            let iv = CryptoWrapper.generateRandomIV(size: CryptoFormat.ivSize)

            // Use AES-GCM encryption from CryptoSwiftFoundationIndependent
            let ciphertext = try CryptoWrapper.encryptAES_GCM(
                data: data.bytes,
                key: keyData,
                iv: iv
            )

            // Pack the IV and ciphertext together
            let packedData = CryptoFormat.packEncryptedData(iv: iv, ciphertext: ciphertext)

            return .success(SecureBytes(bytes: packedData))
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.cryptographicError(operation: "encrypt", details: error.localizedDescription))
        }
    }

    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with decrypted SecureBytes on success or error on failure
    public func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            guard let keyId = keyIdentifier, !keyId.isEmpty else {
                return .failure(.invalidInput(details: "Missing key identifier"))
            }

            let keyData = try await retrieveKeyData(identifier: keyId)

            // Unpack the IV and ciphertext
            guard let (iv, ciphertext) = CryptoFormat.unpackEncryptedData(data: data.bytes) else {
                return .failure(.invalidInput(details: "Invalid encrypted data format"))
            }

            // Use AES-GCM decryption with the extracted IV
            let decrypted = try CryptoWrapper.decryptAES_GCM(
                data: ciphertext,
                key: keyData,
                iv: iv
            )

            return .success(SecureBytes(bytes: decrypted))
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.cryptographicError(operation: "decrypt", details: error.localizedDescription))
        }
    }

    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: SecureBytes to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Result with signature as SecureBytes on success or error on failure
    public func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        // This is a simple implementation
        // In a real-world scenario, this would use proper signing algorithms
        do {
            let keyData = try await retrieveKeyData(identifier: keyIdentifier)

            // Create a simple HMAC signature using the key
            let signature = try CryptoWrapper.calculateHMAC(
                data: data.bytes,
                key: keyData
            )

            return .success(SecureBytes(bytes: signature))
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.cryptographicError(operation: "sign", details: error.localizedDescription))
        }
    }

    /// Verify signature for data
    /// - Parameters:
    ///   - signature: SecureBytes containing the signature
    ///   - data: SecureBytes containing the data to verify
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Result with boolean indicating verification result or error on failure
    public func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        do {
            let keyData = try await retrieveKeyData(identifier: keyIdentifier)

            // Verify the HMAC signature using the key
            let computedSignature = try CryptoWrapper.calculateHMAC(
                data: data.bytes,
                key: keyData
            )

            let isValid = computedSignature == signature.bytes
            return .success(isValid)
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.cryptographicError(operation: "verify", details: error.localizedDescription))
        }
    }

    /// Reset the security state of the service
    /// - Returns: Result with void on success or error on failure
    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // In a real implementation, this would reset internal state,
        // clear caches, and potentially rotate encryption keys
        return .success(())
    }

    /// Get the service version
    /// - Returns: Result with version string on success or error on failure
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        return .success("1.0.0")
    }

    /// Get the hardware identifier
    /// - Returns: Result with identifier string on success or error on failure
    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        // In a real implementation, this would return a unique identifier for the hardware
        return .success("crypto-xpc-service-hardware-id")
    }

    /// Get the service status
    /// - Returns: Result with status dictionary on success or error on failure
    public func status() async -> Result<[String: Any], XPCSecurityError> {
        let statusInfo: [String: Any] = [
            "available": true,
            "version": "1.0.0",
            "protocol": Self.protocolIdentifier
        ]
        return .success(statusInfo)
    }

    // MARK: - XPCServiceProtocolComplete Methods

    /// Enhanced ping with detailed error reporting
    /// - Returns: Result with boolean and detailed error information
    public func pingAsync() async -> Result<Bool, XPCSecurityError> {
        return .success(true)
    }

    /// Get diagnostic information about the service
    /// - Returns: Result with diagnostic string or error
    public func getDiagnosticInfo() async -> Result<String, XPCSecurityError> {
        let info = """
        CryptoXPCService Diagnostics:
        - Version: 1.0.0
        - Protocol: \(Self.protocolIdentifier)
        - Status: Active
        - Dependencies: All available
        """
        return .success(info)
    }

    /// Get service version with modern interface
    /// - Returns: Result with version string or error
    public func getVersion() async -> Result<String, XPCSecurityError> {
        return .success("1.0.0")
    }

    /// Get metrics about service performance
    /// - Returns: Result with metrics dictionary or error
    public func getMetrics() async -> Result<[String: Any], XPCSecurityError> {
        // In a real implementation, this would track performance metrics
        let metrics: [String: Any] = [
            "operations_count": 0,
            "errors_count": 0,
            "average_operation_time_ms": 0.0
        ]
        return .success(metrics)
    }

    /// Generate a key with the specified algorithm and size
    /// - Parameters:
    ///   - algorithm: The encryption algorithm
    ///   - keySize: Size of the key in bits
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Result with the key identifier or error
    public func generateKey(algorithm: String, keySize: Int, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
        do {
            let keyId = "key-\(UUID().uuidString)"
            let bytes = keySize / 8
            let keyData = Data.random(count: bytes)

            // Store the key in the keychain
            try await storeKeyData(keyData: [UInt8](keyData), identifier: keyId)

            return .success(keyId)
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.keyManagementError(operation: "generate", details: error.localizedDescription))
        }
    }

    /// Export a key by its identifier
    /// - Parameter keyIdentifier: The identifier of the key to export
    /// - Returns: Result with the key material as SecureBytes or error
    public func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let keyData = try await retrieveKeyData(identifier: keyIdentifier)
            return .success(SecureBytes(bytes: keyData))
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.keyManagementError(operation: "export", details: error.localizedDescription))
        }
    }

    // MARK: - Legacy Helper Methods

    /// Validate the XPC connection
    /// - Parameter reply: Completion handler with validation result
    @objc
    public func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void) {
        reply(true, nil)
    }

    /// Encrypt data using the specified key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - completion: Completion handler with encrypted data or error
    @objc
    public func encrypt(
        _ data: Data,
        key: Data,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard self != nil else {
                completion(nil, XPCSecurityError.invalidInput(details: "Service is no longer available"))
                return
            }

            do {
                // Generate a random IV for AES-GCM
                let iv = CryptoWrapper.generateRandomIV(size: CryptoFormat.ivSize)

                // Use AES-GCM encryption from CryptoSwiftFoundationIndependent
                let ciphertext = try CryptoWrapper.encryptAES_GCM(
                    data: [UInt8](data),
                    key: [UInt8](key),
                    iv: iv
                )

                // Pack the IV and ciphertext together
                let packedData = CryptoFormat.packEncryptedData(iv: iv, ciphertext: ciphertext)

                completion(Data(packedData), nil)
            } catch {
                completion(
                    nil,
                    XPCSecurityError.invalidInput(details: "Encryption failed: \(error.localizedDescription)")
                )
            }
        }
    }

    /// Decrypt data using the specified key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    ///   - completion: Completion handler with decrypted data or error
    @objc
    public func decrypt(
        _ data: Data,
        key: Data,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        cryptoQueue.async { [weak self] in
            guard self != nil else {
                completion(nil, XPCSecurityError.invalidInput(details: "Service is no longer available"))
                return
            }

            do {
                let dataBytes = [UInt8](data)

                // Unpack the IV and ciphertext
                guard let (iv, ciphertext) = CryptoFormat.unpackEncryptedData(data: dataBytes) else {
                    completion(nil, XPCSecurityError.invalidInput(details: "Invalid encrypted data format"))
                    return
                }

                // Use AES-GCM decryption with the extracted IV
                let decrypted = try CryptoWrapper.decryptAES_GCM(
                    data: ciphertext,
                    key: [UInt8](key),
                    iv: iv
                )

                completion(Data(decrypted), nil)
            } catch {
                completion(
                    nil,
                    XPCSecurityError.invalidInput(details: "Decryption failed: \(error.localizedDescription)")
                )
            }
        }
    }

    /// Generate a cryptographic key of the specified bit length
    /// - Parameters:
    ///   - bits: Key length in bits (typically 128, 256)
    ///   - completion: Completion handler with generated key data or error
    @objc
    public func generateKey(bits: Int, completion: @escaping (Data?, Error?) -> Void) {
        let bytes = bits / 8
        let key = Data.random(count: bytes)
        completion(key, nil)
    }

    /// Generate random data of the specified length
    /// - Parameters:
    ///   - length: Length of random data in bytes
    ///   - completion: Completion handler with random data or error
    @objc
    public func generateRandomData(length: Int, completion: @escaping (Data?, Error?) -> Void) {
        let data = Data.random(count: length)
        completion(data, nil)
    }

    /// Store a key in the keychain
    /// - Parameters:
    ///   - key: Key data to store
    ///   - identifier: Key identifier
    ///   - completion: Completion handler with status or error
    @objc
    public func storeKey(
        _ key: Data,
        identifier: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard !identifier.isEmpty else {
            completion(false, XPCSecurityError.invalidInput(details: "Empty identifier"))
            return
        }

        // Convert Data to base64 string for storage
        let keyString = key.base64EncodedString()

        do {
            try dependencies.keychain.store(password: keyString, for: identifier)
            completion(true, nil)
        } catch {
            completion(
                false,
                XPCSecurityError
                    .invalidInput(details: "Keychain storage failed: \(error.localizedDescription)")
            )
        }
    }

    /// Retrieve a key from the keychain
    /// - Parameters:
    ///   - identifier: Key identifier
    ///   - completion: Completion handler with key data or error
    @objc
    public func retrieveKey(identifier: String, completion: @escaping (Data?, Error?) -> Void) {
        guard !identifier.isEmpty else {
            completion(nil, XPCSecurityError.invalidInput(details: "Empty identifier"))
            return
        }

        do {
            let keyString = try dependencies.keychain.retrievePassword(for: identifier)
            if let keyData = Data(base64Encoded: keyString) {
                completion(keyData, nil)
            } else {
                completion(nil, XPCSecurityError.invalidInput(details: "Invalid key data format"))
            }
        } catch {
            completion(
                nil,
                XPCSecurityError
                    .invalidInput(details: "Keychain retrieval failed: \(error.localizedDescription)")
            )
        }
    }

    /// Delete a key from the keychain
    /// - Parameters:
    ///   - identifier: Key identifier
    ///   - completion: Completion handler with status or error
    @objc
    public func deleteKey(identifier: String, completion: @escaping (Bool, Error?) -> Void) {
        guard !identifier.isEmpty else {
            completion(false, XPCSecurityError.invalidInput(details: "Empty identifier"))
            return
        }

        do {
            try dependencies.keychain.deletePassword(for: identifier)
            completion(true, nil)
        } catch {
            completion(
                false,
                XPCSecurityError
                    .invalidInput(details: "Keychain deletion failed: \(error.localizedDescription)")
            )
        }
    }

    // MARK: - Private Helpers

    /// Store key data in the keychain
    /// - Parameters:
    ///   - keyData: Key data as bytes
    ///   - identifier: Key identifier
    /// - Throws: Error if storage fails
    private func storeKeyData(keyData: [UInt8], identifier: String) async throws {
        guard !identifier.isEmpty else {
            throw XPCSecurityError.invalidInput(details: "Empty identifier")
        }

        // Convert bytes to base64 string for storage
        let keyString = Data(keyData).base64EncodedString()

        do {
            try dependencies.keychain.store(password: keyString, for: identifier)
        } catch {
            throw XPCSecurityError.keyManagementError(
                operation: "store",
                details: "Keychain storage failed: \(error.localizedDescription)"
            )
        }
    }

    /// Retrieve key data from the keychain
    /// - Parameter identifier: Key identifier
    /// - Returns: Key data as bytes
    /// - Throws: Error if retrieval fails
    private func retrieveKeyData(identifier: String) async throws -> [UInt8] {
        guard !identifier.isEmpty else {
            throw XPCSecurityError.invalidInput(details: "Empty identifier")
        }

        do {
            let keyString = try dependencies.keychain.retrievePassword(for: identifier)
            guard let keyData = Data(base64Encoded: keyString) else {
                throw XPCSecurityError.invalidInput(details: "Invalid key data format")
            }
            return [UInt8](keyData)
        } catch let error as XPCSecurityError {
            throw error
        } catch {
            throw XPCSecurityError.keyManagementError(
                operation: "retrieve",
                details: "Keychain retrieval failed: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Required Protocol Methods (Default Implementations)

    // Methods with default implementations in the protocol
    // but listed here for clarity and future customization

    public func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // Generate a key for this operation
        let key = SecureBytes(bytes: [UInt8](Data.random(count: 32)))

        do {
            // Generate a random IV for AES-GCM
            let iv = CryptoWrapper.generateRandomIV(size: CryptoFormat.ivSize)

            // Use AES-GCM encryption from CryptoSwiftFoundationIndependent
            let ciphertext = try CryptoWrapper.encryptAES_GCM(
                data: data.bytes,
                key: key.bytes,
                iv: iv
            )

            // Pack the IV and ciphertext together
            let packedData = CryptoFormat.packEncryptedData(iv: iv, ciphertext: ciphertext)
            return .success(SecureBytes(bytes: packedData))
        } catch {
            return .failure(.cryptographicError(operation: "encrypt", details: error.localizedDescription))
        }
    }

    public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // Without a key, we can't decrypt
        return .failure(.invalidInput(details: "Key required for decryption"))
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let hashedData = try CryptoWrapper.hash(data: data.bytes)
            return .success(SecureBytes(bytes: hashedData))
        } catch {
            return .failure(.cryptographicError(operation: "hash", details: error.localizedDescription))
        }
    }

    public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        let keyData = [UInt8](Data.random(count: 32))
        return .success(SecureBytes(bytes: keyData))
    }

    public func deriveKey(from password: String, salt: SecureBytes, iterations: Int, keyLength: Int, targetKeyIdentifier: String?) async -> Result<String, XPCSecurityError> {
        // This would typically use PBKDF2 or similar
        return .failure(.notImplemented(reason: "Key derivation not implemented"))
    }

    public func generateKey(keyType: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
        let actualKeyId = keyIdentifier ?? "key-\(UUID().uuidString)"
        let keySize = keyType == .aes256 ? 256 : 128

        do {
            let keyData = [UInt8](Data.random(count: keySize / 8))
            try await storeKeyData(keyData: keyData, identifier: actualKeyId)
            return .success(actualKeyId)
        } catch let error as XPCSecurityError {
            return .failure(error)
        } catch {
            return .failure(.keyManagementError(operation: "generate", details: error.localizedDescription))
        }
    }
}

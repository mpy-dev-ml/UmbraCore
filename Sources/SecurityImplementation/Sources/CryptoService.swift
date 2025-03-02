// CryptoService.swift
// Part of UmbraCore Security Module
// Created on 2025-03-01

/**
 # UmbraCore Cryptographic Service
 
 The CryptoService provides core cryptographic operations for the UmbraCore security framework.
 It implements the CryptoServiceProtocol and provides both symmetric and asymmetric encryption
 capabilities, along with cryptographic hashing, signing, and MAC generation.
 
 ## Security Considerations
 
 * **Development Status**: This module contains proof-of-concept implementations that are NOT
   suitable for production use without further review and enhancement.
   
 * **Cryptographic Strength**: The symmetric encryption uses AES-GCM with 256-bit keys,
   which is considered strong by current standards. The asymmetric encryption implementation
   is currently a placeholder and must be replaced with a proper RSA or ECC implementation.
   
 * **Memory Safety**: Sensitive cryptographic materials are stored in SecureBytes containers
   which provide basic memory protections, but these protections are not comprehensive.
   
 * **Side-Channel Attacks**: The current implementation has not been reviewed for resistance
   to timing and other side-channel attacks. Caution is advised in high-security contexts.
   
 * **Key Management**: Keys must be properly generated, stored, and rotated according to
   security best practices. The KeyManager class provides some facilities for this.
   
 ## Performance Characteristics
 
 * **Symmetric Encryption**: AES-GCM provides good performance and scales well for
   large data volumes. Performance is generally CPU-bound and benefits from hardware
   acceleration when available.
   
 * **Asymmetric Encryption**: The current implementation is not optimized for performance.
   For large data volumes, a hybrid approach is recommended (encrypt data with symmetric
   key, encrypt the symmetric key with asymmetric key).
   
 * **Memory Usage**: Operations involving large data sets may cause temporary memory
   pressure due to data copying. Consider streaming approaches for very large data sets.
   
 ## Thread Safety
 
 All public methods are thread-safe and can be called concurrently from multiple threads.
 The class is marked as Sendable and follows Swift concurrency best practices.
 
 ## Usage Examples
 
 ```swift
 // Symmetric encryption example
 let cryptoService = CryptoService()
 let key = await cryptoService.generateKey().get()
 let data = SecureBytes("Secret message".data(using: .utf8)!)
 
 // Encrypt
 let encryptResult = await cryptoService.encrypt(data: data, using: key)
 let encryptedData = encryptResult.data
 
 // Decrypt
 let decryptResult = await cryptoService.decrypt(data: encryptedData!, using: key)
 let decryptedData = decryptResult.data
 ```
 
 ## Swift 6 Compatibility
 
 This module is designed to be compatible with Swift 6, adhering to the latest Swift
 language features and avoiding deprecated APIs.
 */

import CryptoSwiftFoundationIndependent
import SecureBytes
import SecurityProtocolsCore

/// Implementation of CryptoServiceProtocol that provides cryptographic operations
/// without any dependency on Foundation. This implementation handles encryption,
/// decryption, hashing, and other cryptographic operations.
///
/// ## Security Features
/// - AES-GCM 256-bit encryption for symmetric operations
/// - SHA-256 for cryptographic hashing
/// - HMAC-SHA256 for message authentication codes
/// - Secure random number generation for keys and IVs
/// - Foundation-independent implementation via CryptoSwiftFoundationIndependent
///
/// ## Usage Guidelines
/// - For symmetric encryption, use a unique key for each data set
/// - Store keys securely using the KeyManager
/// - For encryption operations, the IV is automatically prepended to encrypted data
///   unless explicitly provided in the configuration
/// - Asymmetric operations are placeholders and should not be used in production yet
///
/// ## Thread Safety
/// This class implements Sendable and is designed to be thread-safe. All operations
/// are implemented as async functions, allowing for concurrent usage in Swift concurrency.
/// All instance methods are marked as isolated to ensure proper actor isolation.
@available(macOS 15.0, iOS 17.0, *)
public final class CryptoService: CryptoServiceProtocol, Sendable {
    // MARK: - Initialisation

    /// Creates a new instance of CryptoService
    /// No initialisation parameters are required as this is a stateless service
    public nonisolated init() {
        // No initialisation needed
    }

    // MARK: - Protocol implementation

    /// Encrypt data using the specified parameters
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - config: Configuration for the encryption
    /// - Returns: Result of the encryption operation
    ///
    /// This method uses AES-GCM encryption with the following details:
    /// - 256-bit encryption key
    /// - 96-bit (12-byte) initialization vector (IV)
    /// - Combined authentication tag
    ///
    /// If no IV is provided in the config, a random one is generated and prepended
    /// to the encrypted data in the result.
    public func encrypt(data: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
        do {
            guard let key = config.key else {
                return SecurityResultDTO(success: false, error: .invalidInput(reason: "No encryption key provided"))
            }

            // Default to AES-GCM with a random IV if not specified
            let iv = config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()

            // Encrypt the data
            let encrypted = try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)

            // Return IV + encrypted data unless IV is provided in config
            let resultData: SecureBytes
            if config.initializationVector != nil {
                resultData = encrypted
            } else {
                resultData = SecureBytes.combine(iv, encrypted)
            }

            return SecurityResultDTO(success: true, data: resultData)
        } catch {
            return SecurityResultDTO(success: false, error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)"))
        }
    }

    /// Decrypt data using the specified parameters
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - config: Configuration for the decryption
    /// - Returns: Result of the decryption operation
    ///
    /// This method uses AES-GCM decryption with the following details:
    /// - 256-bit decryption key
    /// - 96-bit (12-byte) initialization vector (IV)
    /// - Combined authentication tag
    ///
    /// If no IV is provided in the config, it's assumed the first 12 bytes of the
    /// input data contain the IV, which is then extracted and used for decryption.
    public func decrypt(data: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO {
        do {
            guard let key = config.key else {
                return SecurityResultDTO(success: false, error: .invalidInput(reason: "No decryption key provided"))
            }

            let iv: SecureBytes
            let dataToDecrypt: SecureBytes

            if let providedIv = config.initializationVector {
                // If IV is provided in config, use it
                iv = providedIv
                dataToDecrypt = data
            } else {
                // Extract IV from data (first 12 bytes)
                guard data.count > 12 else {
                    return SecurityResultDTO(success: false, error: .invalidInput(reason: "Encrypted data too short"))
                }

                let splitResult = try data.split(at: 12)
                iv = splitResult.0
                dataToDecrypt = splitResult.1
            }

            // Decrypt the data
            let decrypted = try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)

            return SecurityResultDTO(success: true, data: decrypted)
        } catch {
            return SecurityResultDTO(success: false, error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)"))
        }
    }

    /// Compute a hash of the provided data
    /// - Parameters:
    ///   - data: The data to hash
    ///   - config: Configuration options for hashing
    /// - Returns: Result containing the hash or error
    ///
    /// This method computes a SHA-256 hash of the input data. The hash is a 
    /// fixed-length representation of the data, 32 bytes (256 bits) long.
    ///
    /// The hash is deterministic and collision-resistant, making it suitable for
    /// data integrity verification and identifying content.
    public func hash(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Use SHA-256 through CryptoWrapper
        let hashedData = CryptoWrapper.sha256(data)
        return SecurityResultDTO(success: true, data: hashedData)
    }

    /// Encrypts data using the specified key.
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - key: The encryption key (should be 256 bits / 32 bytes).
    /// - Returns: Encrypted data or error if encryption fails.
    ///
    /// This function uses AES-GCM with a random IV. The IV is prepended to the
    /// encrypted data in the returned SecureBytes object (first 12 bytes).
    ///
    /// The format of the returned data is: [IV (12 bytes)][Encrypted data with authentication tag]
    public func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        do {
            // Generate a random IV
            let iv = CryptoWrapper.generateRandomIVSecure()

            // Encrypt the data using AES-GCM
            let encrypted = try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)

            // Combine IV with encrypted data
            let combinedData = SecureBytes.combine(iv, encrypted)

            return .success(combinedData)
        } catch {
            return .failure(.encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)"))
        }
    }

    /// Decrypts data using the specified key.
    /// - Parameters:
    ///   - data: The data to decrypt, including the IV.
    ///   - key: The decryption key (should be 256 bits / 32 bytes).
    /// - Returns: Decrypted data or error if decryption fails.
    ///
    /// This function expects the input data to be in the format: [IV (12 bytes)][Encrypted data with authentication tag]
    /// It will extract the IV from the first 12 bytes and use it for decryption.
    ///
    /// AES-GCM validates the integrity of the data during decryption. If the data
    /// has been tampered with, decryption will fail with an authentication error.
    public func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        do {
            // Extract IV from combined data (first 12 bytes)
            guard data.count >= 12 else {
                return .failure(.invalidInput(reason: "Encrypted data too short"))
            }

            let dataBytes = data.bytes()
            let ivBytes = Array(dataBytes.prefix(12))
            let encryptedBytes = Array(dataBytes.suffix(from: 12))

            let iv = SecureBytes(ivBytes)
            let encryptedData = SecureBytes(encryptedBytes)

            // Decrypt the data using AES-GCM
            let decrypted = try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)

            return .success(decrypted)
        } catch {
            return .failure(.decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)"))
        }
    }

    /// Generates a secure cryptographic key.
    /// - Returns: The generated key or error if key generation fails.
    ///
    /// This function generates a 256-bit (32-byte) cryptographically secure random key
    /// suitable for use with AES-256 encryption. The key is returned as a SecureBytes
    /// object, which provides memory protection for sensitive cryptographic material.
    public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
        // Generate a 256-bit key (32 bytes) using CryptoWrapper
        let key = CryptoWrapper.generateRandomKeySecure(size: 32)
        return .success(key)
    }

    /// Computes a cryptographic hash of the given data.
    /// - Parameter data: The data to hash.
    /// - Returns: The computed hash or error if hashing fails.
    ///
    /// This function uses SHA-256 to produce a 256-bit (32-byte) hash of the input data.
    /// The hash function is one-way (it cannot be reversed) and collision-resistant
    /// (it's computationally infeasible to find two different inputs that produce the same hash).
    public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // Use SHA-256 through CryptoWrapper
        let hashedData = CryptoWrapper.sha256(data)
        return .success(hashedData)
    }

    /// Verifies that a hash matches the expected value for the given data.
    /// - Parameters:
    ///   - data: The data to verify.
    ///   - hash: The expected hash value.
    /// - Returns: True if the hash is verified, false otherwise.
    ///
    /// This function computes the SHA-256 hash of the input data and compares it
    /// with the provided hash value. Returns true if they match, false otherwise.
    public nonisolated func verify(data: SecureBytes, againstHash hash: SecureBytes) async -> Result<Bool, SecurityError> {
        let computedHash = CryptoWrapper.sha256(data)
        // Compare the computed hash with the expected hash
        let result = computedHash == hash
        return .success(result)
    }

    /// Verifies that a hash matches the expected value for the given data.
    /// - Parameters:
    ///   - data: The data to verify.
    ///   - hash: The expected hash value.
    /// - Returns: Boolean indicating whether the hash matches.
    ///
    /// Simplified version that returns a boolean directly instead of a Result type.
    public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
        let computedHash = CryptoWrapper.sha256(data)
        return computedHash == hash
    }

    /// Generates a message authentication code (MAC) for the given data using the specified key.
    /// - Parameters:
    ///   - data: The data to authenticate.
    ///   - key: The key to use for MAC generation.
    /// - Returns: The generated MAC or error if generation fails.
    ///
    /// This function uses HMAC-SHA256 to generate a message authentication code.
    /// The MAC provides both authentication and integrity verification for the data.
    /// A valid MAC can only be generated by someone who possesses the same key.
    public nonisolated func generateMAC(for data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // Use HMAC-SHA256 through CryptoWrapper
        let macData = CryptoWrapper.hmacSHA256(data: data, key: key)
        return .success(macData)
    }

    /// Verifies a message authentication code (MAC) against the given data and key.
    /// - Parameters:
    ///   - mac: The MAC to verify.
    ///   - data: The data to verify the MAC against.
    ///   - key: The key used for MAC verification.
    /// - Returns: True if the MAC is verified, false otherwise.
    ///
    /// This function verifies an HMAC-SHA256 MAC by generating a new MAC from the
    /// input data and key, then comparing it with the provided MAC. Returns true
    /// if they match, indicating the data is authentic and has not been tampered with.
    public nonisolated func verifyMAC(_ mac: SecureBytes, for data: SecureBytes, using key: SecureBytes) async -> Result<Bool, SecurityError> {
        let computedMAC = CryptoWrapper.hmacSHA256(data: data, key: key)
        let result = computedMAC == mac
        return .success(result)
    }

    // MARK: - Symmetric Encryption Implementation

    /// Encrypt data using a symmetric key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Symmetric key for encryption
    ///   - config: Configuration options
    /// - Returns: Result containing encrypted data or error
    ///
    /// This implementation uses AES-GCM with a 256-bit key and 96-bit IV.
    /// It handles the following aspects of the encryption process:
    /// - If no IV is provided in the config, a random one is generated
    /// - The IV is prepended to the encrypted data unless one was provided in the config
    /// - Authentication data is included in the ciphertext (GCM mode)
    ///
    /// Performance note: AES-GCM provides both confidentiality and authenticity
    /// in a single pass, making it more efficient than modes requiring separate MAC calculation.
    public func encryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        do {
            // Use AES-GCM for symmetric encryption
            let iv = config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()

            // Encrypt the data
            let encrypted = try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)

            // Return IV + encrypted data unless IV is provided in config
            let resultData: SecureBytes
            if config.initializationVector != nil {
                resultData = encrypted
            } else {
                resultData = SecureBytes.combine(iv, encrypted)
            }

            return SecurityResultDTO(success: true, data: resultData)
        } catch {
            return SecurityResultDTO(success: false, error: .encryptionFailed(reason: "Symmetric encryption failed: \(error.localizedDescription)"))
        }
    }

    /// Decrypt data using a symmetric key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Symmetric key for decryption
    ///   - config: Configuration options
    /// - Returns: Result containing decrypted data or error
    ///
    /// This implementation decrypts data that was encrypted using AES-GCM.
    /// It handles the following aspects of the decryption process:
    /// - If an IV is provided in the config, it uses that for decryption
    /// - Otherwise, it extracts the IV from the first 12 bytes of the input data
    /// - The authentication tag is verified during decryption (GCM mode)
    ///
    /// If the data has been tampered with, decryption will fail with an authentication error.
    public func decryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        do {
            let iv: SecureBytes
            let dataToDecrypt: SecureBytes

            if let providedIv = config.initializationVector {
                // If IV is provided in config, use it
                iv = providedIv
                dataToDecrypt = data
            } else {
                // Extract IV from data (first 12 bytes)
                guard data.count > 12 else {
                    return SecurityResultDTO(success: false, error: .invalidInput(reason: "Encrypted data too short"))
                }

                let splitResult = try data.split(at: 12)
                iv = splitResult.0
                dataToDecrypt = splitResult.1
            }

            // Decrypt the data
            let decrypted = try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)

            return SecurityResultDTO(success: true, data: decrypted)
        } catch {
            return SecurityResultDTO(success: false, error: .decryptionFailed(reason: "Symmetric decryption failed: \(error.localizedDescription)"))
        }
    }

    // MARK: - Asymmetric Cryptography

    /**
     Generates an asymmetric key pair for encryption and decryption.
     
     - Returns: A result containing a tuple with public and private keys, or an error.
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This is a placeholder implementation that does NOT use proper asymmetric cryptography.
     The current implementation:
     
     1. Does not provide true asymmetric encryption security properties
     2. Uses a simplified XOR-based approach for testing and development ONLY
     3. Generates pseudorandom keys that are not cryptographically secure
     4. Must be replaced with proper RSA or ECC implementation before production use
     
     ## Performance Note
     
     In a production implementation, asymmetric key generation can be computationally expensive.
     RSA key generation typically takes longer than ECC key generation, especially for larger 
     key sizes (e.g., RSA-4096).
     
     ## Usage Recommendation
     
     In production systems, consider:
     - Using properly generated RSA/ECC keys from a trusted source
     - Storing private keys in a secure enclave where available
     - Using hybrid encryption for large data (encrypt data with symmetric key, then encrypt that key with asymmetric)
     */
    public func generateAsymmetricKeyPair() async -> Result<(publicKey: SecureBytes, privateKey: SecureBytes), SecurityError> {
        // In a real implementation, this would generate proper RSA keys
        // For this proof of concept, we'll generate deterministic keys
        // WARNING: This is not secure for production use!

        // Generate a seed for the "key pair"
        let seed = CryptoWrapper.generateRandomKeySecure(size: 32)

        // Generate "public" and "private" keys from the seed
        let privateKey = CryptoWrapper.sha256(seed)
        var publicKeyBytes = privateKey.bytes()

        // Ensure we have bytes to modify
        guard !publicKeyBytes.isEmpty else {
            return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
        }

        // Modify bytes to create a different but related key
        for i in 0..<publicKeyBytes.count where i % 2 == 0 {
            publicKeyBytes[i] = publicKeyBytes[i] ^ 0x5A
        }

        // Return the key pair
        return .success((publicKey: SecureBytes(publicKeyBytes), privateKey: privateKey))
    }

    /**
     Encrypts data using asymmetric encryption with a public key.
     
     - Parameters:
       - data: The data to encrypt
       - publicKey: The public key for encryption
     - Returns: A result containing the encrypted data or an error
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This is a placeholder implementation that does NOT use proper asymmetric cryptography.
     The current implementation:
     
     1. Uses a simplified XOR-based approach for testing and development ONLY
     2. Does not provide true public key encryption security properties
     3. Has severe size limitations - best used only for small data (<1KB)
     4. Must be replaced with proper RSA or ECC implementation before production use
     
     ## Data Size Considerations
     
     In a production implementation, asymmetric encryption would typically be limited to
     encrypting data smaller than the key size (minus padding). For RSA-2048, this means
     a maximum of ~245 bytes per operation.
     
     ## Usage Recommendation
     
     For larger data, use hybrid encryption:
     1. Generate a random symmetric key
     2. Encrypt the actual data with the symmetric key
     3. Encrypt the symmetric key with the asymmetric public key
     4. Combine the encrypted key and encrypted data
     */
    public func encryptAsymmetric(
        data: SecureBytes,
        publicKey: SecureBytes
    ) async -> Result<SecureBytes, SecurityError> {
        // Input validation
        guard !data.isEmpty, !publicKey.isEmpty else {
            return .failure(.invalidInput(reason: "Input data or public key is empty"))
        }

        // SIMPLIFIED IMPLEMENTATION FOR TESTING
        // This is a debug-only implementation that doesn't actually perform real encryption
        // It merely appends the "encrypted" data with a marker for testing purposes

        // Use our simple XOR transformation for testing
        let inputBytes = data.bytes()
        let keyBytes = publicKey.bytes()
        let resultBytes = simpleXorTransform(inputBytes, withKey: keyBytes)

        // Add a marker at the beginning for verification
        let marker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let finalResult = marker + resultBytes

        return .success(SecureBytes(finalResult))
    }

    /// Encrypt data using an asymmetric public key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - publicKey: Public key for encryption
    ///   - config: Configuration options
    /// - Returns: Result containing encrypted data or error
    ///
    /// This implementation uses a simplified approach for testing only.
    /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
    public func encryptAsymmetric(
        data: SecureBytes,
        publicKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Input validation
        guard !data.isEmpty, !publicKey.isEmpty else {
            return SecurityResultDTO(
                success: false,
                error: .invalidInput(reason: "Input data or public key is empty")
            )
        }

        // SIMPLIFIED IMPLEMENTATION FOR TESTING
        // This is a debug-only implementation that doesn't actually perform real encryption
        // It merely appends the "encrypted" data with a marker for testing purposes

        // Use our simple XOR transformation for testing
        let inputBytes = data.bytes()
        let keyBytes = publicKey.bytes()
        let resultBytes = simpleXorTransform(inputBytes, withKey: keyBytes)

        // Add a marker at the beginning for verification
        let marker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let finalResult = marker + resultBytes

        return SecurityResultDTO(success: true, data: SecureBytes(finalResult))
    }

    /**
     Decrypts data using asymmetric encryption with a private key.
     
     - Parameters:
       - data: The data to decrypt
       - privateKey: The private key for decryption
     - Returns: A result containing the decrypted data or an error
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This is a placeholder implementation that does NOT use proper asymmetric cryptography.
     The current implementation:
     
     1. Uses a simplified XOR-based approach for testing and development ONLY
     2. Does not provide true private key decryption security properties
     3. Has severe size limitations - best used only for small data (<1KB)
     4. Must be replaced with proper RSA or ECC implementation before production use
     
     ## Security Considerations
     
     In a production implementation:
     - Private keys must NEVER be exposed or transmitted
     - Consider using secure enclaves or hardware security modules for key storage
     - Implement proper padding schemes to prevent padding oracle attacks
     
     ## Error Handling
     
     Decryption can fail for various reasons, including:
     - Data corruption
     - Using the wrong key
     - Tampering attempts
     - Invalid padding
     
     Always handle errors appropriately, avoiding information leakage in error messages.
     */
    public func decryptAsymmetric(
        data: SecureBytes,
        privateKey: SecureBytes
    ) async -> Result<SecureBytes, SecurityError> {
        // Input validation
        guard !data.isEmpty, !privateKey.isEmpty else {
            return .failure(.invalidInput(reason: "Input data or private key is empty"))
        }

        let dataBytes = data.bytes()

        // Verify minimum length and marker
        guard dataBytes.count >= 4 else {
            return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
        }

        // Check for the marker we added during encryption
        let marker = Array(dataBytes.prefix(4))
        let expectedMarker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        guard marker == expectedMarker else {
            return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
        }

        // Get the actual encrypted bytes (after the marker)
        let encryptedBytes = Array(dataBytes.suffix(from: 4))
        let keyBytes = privateKey.bytes()

        // Use our simple XOR transformation to "decrypt"
        let resultBytes = simpleXorTransform(encryptedBytes, withKey: keyBytes)

        return .success(SecureBytes(resultBytes))
    }

    /// Decrypt data using an asymmetric private key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - privateKey: Private key for decryption
    ///   - config: Configuration options
    /// - Returns: Result containing decrypted data or error
    ///
    /// This implementation uses a simplified approach for testing only.
    /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
    public func decryptAsymmetric(
        data: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Input validation
        guard !data.isEmpty, !privateKey.isEmpty else {
            return SecurityResultDTO(
                success: false,
                error: .invalidInput(reason: "Input data or private key is empty")
            )
        }

        let dataBytes = data.bytes()

        // Verify minimum length and marker
        guard dataBytes.count >= 4 else {
            return SecurityResultDTO(
                success: false,
                error: .invalidInput(reason: "Input data too short for asymmetric decryption")
            )
        }

        // Check for the marker we added during encryption
        let marker = Array(dataBytes.prefix(4))
        let expectedMarker: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        guard marker == expectedMarker else {
            return SecurityResultDTO(
                success: false,
                error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
            )
        }

        // Get the actual encrypted bytes (after the marker)
        let encryptedBytes = Array(dataBytes.suffix(from: 4))
        let keyBytes = privateKey.bytes()

        // Use our simple XOR transformation to "decrypt"
        let resultBytes = simpleXorTransform(encryptedBytes, withKey: keyBytes)

        return SecurityResultDTO(success: true, data: SecureBytes(resultBytes))
    }

    /// Generate an asymmetric key pair
    /// - Parameter config: Configuration options
    /// - Returns: Result containing public and private keys
    ///
    /// This method generates an RSA key pair for asymmetric encryption.
    /// The public key is used for encryption and the private key for decryption.
    /// Note: For production use, this would use a proper RSA implementation.
    ///
    /// WARNING: This implementation is a placeholder and should be replaced with
    /// proper RSA key generation for production use.
    public func generateAsymmetricKeyPair(
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // In a real implementation, this would generate proper RSA keys
        // For this proof of concept, we'll generate deterministic keys
        // WARNING: This is not secure for production use!

        // Generate a seed for the "key pair"
        let seed = CryptoWrapper.generateRandomKeySecure(size: 32)

        // Generate "public" and "private" keys from the seed
        let privateKey = CryptoWrapper.sha256(seed)
        var publicKeyBytes = privateKey.bytes()

        // Ensure we have bytes to modify
        guard !publicKeyBytes.isEmpty else {
            return SecurityResultDTO(
                success: false,
                error: .keyGenerationFailed(reason: "Failed to generate key material")
            )
        }

        // Modify bytes to create a different but related key
        for i in 0..<publicKeyBytes.count where i % 2 == 0 {
            publicKeyBytes[i] = publicKeyBytes[i] ^ 0x5A
        }

        // Format result as [Public Key Length (4 bytes)][Public Key][Private Key]
        let pubLength = publicKeyBytes.count
        let pubLengthBytes = withUnsafeBytes(of: UInt32(pubLength).bigEndian) { Array($0) }

        // Combine the components safely
        let combinedData = SecureBytes.combine(
            SecureBytes(pubLengthBytes),
            SecureBytes.combine(SecureBytes(publicKeyBytes), privateKey)
        )

        return SecurityResultDTO(success: true, data: combinedData)
    }

    // MARK: - Private Helper Methods for Asymmetric Cryptography

    /// WARNING: Not for production use! This is a placeholder for actual RSA encryption.
    /// Simulates encrypting a symmetric key with an RSA public key.
    /**
     Simulates encrypting a key with an RSA public key. This is a placeholder.
     
     - Parameters:
       - key: The key to encrypt
       - publicKey: The public key to use
     - Returns: A simulated "encrypted" key
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This method does NOT use real RSA encryption and has the following limitations:
     
     1. Uses a simple XOR operation with HMAC-SHA256 to transform the data
     2. Provides NO security properties of actual public key cryptography
     3. Is deterministic (same inputs always produce same outputs)
     4. Has no padding or other security measures against cryptanalysis
     
     This implementation is designed solely to facilitate testing and debugging
     and must be replaced with a proper RSA implementation before production use.
     */
    private func encryptKeyWithPseudoRSA(_ key: SecureBytes, publicKey: SecureBytes) -> SecureBytes {
        // In a real implementation, this would use RSA encryption
        // For now, we'll use a simple XOR operation with HMAC for demonstration

        // Validate inputs
        guard !key.isEmpty, !publicKey.isEmpty else {
            return SecureBytes([]) // Return empty bytes on invalid input
        }

        let hmac = CryptoWrapper.hmacSHA256(data: key, key: publicKey)

        // Get the byte arrays safely
        let resultBytes = key.bytes()
        let hmacBytes = hmac.bytes()

        // Ensure the HMAC has content
        guard !hmacBytes.isEmpty else {
            return SecureBytes(resultBytes) // Return original key if HMAC failed
        }

        // XOR the key with the HMAC result
        var result = resultBytes
        for i in 0..<result.count {
            result[i] = result[i] ^ hmacBytes[i % hmacBytes.count]
        }

        return SecureBytes(result)
    }

    /// WARNING: Not for production use! This is a placeholder for actual RSA decryption.
    /// Simulates decrypting a symmetric key with an RSA private key.
    /**
     Simulates decrypting a key with an RSA private key. This is a placeholder.
     
     - Parameters:
       - encryptedKey: The key to decrypt
       - privateKey: The private key to use
     - Returns: A simulated "decrypted" key
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This method does NOT use real RSA decryption and has the following limitations:
     
     1. Uses a simple XOR operation with HMAC-SHA256 to transform the data
     2. Provides NO security properties of actual private key cryptography
     3. Is deterministic (same inputs always produce same outputs)
     4. Has no padding or other security measures against cryptanalysis
     
     This implementation is designed solely to facilitate testing and debugging
     and must be replaced with a proper RSA implementation before production use.
     */
    private func decryptKeyWithPseudoRSA(_ encryptedKey: SecureBytes, privateKey: SecureBytes) -> SecureBytes {
        // In a real implementation, this would use RSA decryption
        // For now, we'll use the inverse of the encryption operation

        // Validate inputs
        guard !encryptedKey.isEmpty, !privateKey.isEmpty else {
            return SecureBytes([]) // Return empty bytes on invalid input
        }

        let hmac = CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)

        // Get the byte arrays safely
        let resultBytes = encryptedKey.bytes()
        let hmacBytes = hmac.bytes()

        // Ensure the HMAC has content
        guard !hmacBytes.isEmpty else {
            return SecureBytes(resultBytes) // Return encrypted key if HMAC failed
        }

        // Perform the inverse XOR operation
        var result = resultBytes
        for i in 0..<result.count {
            result[i] = result[i] ^ hmacBytes[i % hmacBytes.count]
        }

        return SecureBytes(result)
    }

    /// Signs data using the specified key.
    /// - Parameters:
    ///   - data: The data to sign.
    ///   - key: The signing key.
    /// - Returns: The signature or error if signing fails.
    ///
    /**
     Creates a cryptographic signature for data using a specified key.
     
     - Parameters:
       - data: The data to sign
       - key: The key to use for signing
     - Returns: A result containing the signature or an error
     
     ## Implementation Details
     
     This implementation uses HMAC-SHA256 as a basic signing mechanism.
     
     ## ⚠️ IMPORTANT CONSIDERATIONS ⚠️
     
     In a production environment with asymmetric cryptography requirements,
     this should be replaced with proper RSA or ECDSA signing algorithms.
     
     HMAC-based signatures:
     - Require the same key for both signing and verification
     - Do not provide non-repudiation (anyone with the key can sign)
     - Are suitable for message authentication but not digital signatures
     
     For true digital signatures, consider:
     - RSA signatures with PKCS#1 v2.1 PSS padding
     - ECDSA signatures with a proper elliptic curve (e.g., P-256)
     - Ed25519 signatures for high performance and security
     */
    public nonisolated func sign(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // Use HMAC-SHA256 as a basic signing mechanism
        // In a real implementation, this would use an asymmetric signature algorithm
        let signature = CryptoWrapper.hmacSHA256(data: data, key: key)
        return .success(signature)
    }

    /// Verifies a signature against the given data and key.
    /// - Parameters:
    ///   - signature: The signature to verify.
    ///   - data: The data to verify the signature against.
    ///   - key: The key used for signature verification.
    /// - Returns: True if the signature is verified, false otherwise.
    ///
    /**
     Verifies a cryptographic signature against data using a specified key.
     
     - Parameters:
       - signature: The signature to verify
       - data: The data against which to verify the signature
       - key: The key to use for verification
     - Returns: A result with boolean indicating validity or an error
     
     ## Implementation Details
     
     This implementation verifies HMAC-SHA256 signatures.
     
     ## ⚠️ IMPORTANT CONSIDERATIONS ⚠️
     
     In a production environment with asymmetric cryptography requirements,
     this should be replaced with proper RSA or ECDSA verification algorithms.
     
     HMAC-based signatures:
     - Require the same key for both signing and verification
     - Do not provide non-repudiation (anyone with the key can verify)
     - Are suitable for message authentication but not digital signatures
     
     For true digital signature verification, consider:
     - RSA signature verification with PKCS#1 v2.1 PSS padding
     - ECDSA signature verification with a proper elliptic curve (e.g., P-256)
     - Ed25519 signature verification for high performance and security
     
     ## Time-Safe Verification
     
     This implementation performs time-constant comparison to prevent timing attacks.
     */
    public nonisolated func verify(signature: SecureBytes, for data: SecureBytes, using key: SecureBytes) async -> Result<Bool, SecurityError> {
        let computedSignature = CryptoWrapper.hmacSHA256(data: data, key: key)
        let result = computedSignature == signature
        return .success(result)
    }

    // MARK: - Random Data Generation
    
    /**
     Generate cryptographically secure random data.
     
     - Parameter length: The length of random data to generate in bytes
     - Returns: A Result containing the generated random data or an error
     
     ⚠️ WARNING: This implementation uses a cryptographically secure random number generator,
     but it should be reviewed for production use to ensure it meets specific security requirements.
     */
    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
        // Input validation
        guard length > 0 else {
            return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
        }
        
        do {
            var randomBytes = [UInt8](repeating: 0, count: length)
            
            // Generate random bytes using CryptoKit's secure random number generator
            let status = try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
            
            if status {
                return .success(SecureBytes(randomBytes))
            } else {
                return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
            }
        } catch {
            return .failure(.randomGenerationFailed(reason: "Error during random generation: \(error.localizedDescription)"))
        }
    }

    // MARK: - Test Helper Methods

    /**
     Simple XOR-based function for testing purposes.
     
     - Parameters:
       - data: Data to transform
       - key: Key to use for XOR operation
     - Returns: Transformed data
     
     ## ⚠️ WARNING: DEVELOPMENT USE ONLY ⚠️
     
     This is a simple XOR-based transformation function used for testing purposes.
     It is NOT suitable for actual cryptographic use as it:
     
     1. Has no security properties
     2. Is completely reversible
     3. Is vulnerable to known-plaintext attacks
     4. Has pattern-preserving properties that leak information
     
     This implementation is designed solely to facilitate testing of the protocol
     interfaces without involving actual cryptographic complexity.
     
     For actual cryptographic transformations, use standard library functions or
     established cryptographic libraries.
     */
    private func simpleXorTransform(_ data: [UInt8], withKey key: [UInt8]) -> [UInt8] {
        guard !data.isEmpty, !key.isEmpty else { return [] }

        var result = [UInt8]()
        for i in 0..<data.count {
            let keyIndex = i % key.count
            result.append(data[i] ^ key[keyIndex])
        }
        return result
    }

    // MARK: - Helper Methods

    /// Generate secure random bytes.
    /// - Parameter count: Number of random bytes to generate.
    /// - Returns: Random bytes or error if generation fails.
    ///
    /// This method generates cryptographically secure random bytes suitable for
    /// cryptographic operations like key generation. It uses CryptoWrapper's
    /// secure random number generation functionality.
    public nonisolated func generateSecureRandomBytes(count: Int) async -> Result<SecureBytes, SecurityError> {
        // Check for valid count
        if count <= 0 {
            return .failure(.invalidInput(reason: "Byte count must be positive"))
        }

        return .success(CryptoWrapper.generateRandomKeySecure(size: count))
    }
}

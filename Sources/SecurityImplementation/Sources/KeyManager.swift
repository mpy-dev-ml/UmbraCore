// KeyManager.swift
// Part of UmbraCore Security Module
// Created on 2025-03-01

/**
 # UmbraCore Key Management Service
 
 The KeyManager module provides secure storage and lifecycle management for cryptographic keys.
 It implements the KeyManagementProtocol and provides functionality for storing, retrieving,
 rotating, and generating cryptographic keys.
 
 ## Security Considerations
 
 * **Memory-Only Storage**: This implementation stores keys in memory only. Keys are not
   persisted between application launches, which means they must be regenerated or imported
   on each start. For production use, consider implementing secure persistent storage.
   
 * **Key Protection**: Keys are stored in SecureBytes containers which provide basic memory
   protections, but these protections are not comprehensive. The keys are still vulnerable
   to memory-dumping attacks in certain scenarios.
   
 * **Thread Safety**: The implementation uses Swift actors to ensure thread safety for all
   key operations. This prevents race conditions and data corruption when multiple threads
   access the key store.
   
 * **Key Rotation**: The manager provides key rotation capabilities with the option to
   re-encrypt data using the new key. This helps maintain good cryptographic hygiene by
   limiting the amount of data encrypted with a single key.
   
 ## Limitations
 
 * **Development Stage**: This implementation is designed for development and testing.
   For production use, consider enhancing with:
     - Secure persistent storage with proper encryption
     - Integration with platform key stores (Keychain, HSMs, etc.)
     - Key attestation and verification
     - Key access control and auditing
   
 * **No Key Derivation**: This implementation does not include functions for key derivation
   from passwords or other inputs. Use CryptoService for these operations.
   
 * **No Key Splitting**: There is no support for cryptographic key splitting or threshold
   schemes that require multiple parties to reconstruct a key.
   
 ## Usage Guidelines
 
 * For long-term keys, implement a persistence strategy compatible with your security requirements
 * Rotate keys regularly, especially for keys that encrypt large amounts of data
 * Use unique identifiers for different key types and purposes (e.g., "data-encryption-key-v1")
 * Always handle SecurityError results appropriately and avoid leaking information in error messages
 
 ## Example Usage
 
 ```swift
 // Create a key manager
 let keyManager = KeyManager()
 
 // Generate and store a new key
 let keyResult = await keyManager.generateKey(keySize: 256)
 guard case .success(let key) = keyResult else {
     // Handle error
     return
 }
 
 // Store the key with an identifier
 let storeResult = await keyManager.storeKey(key, withIdentifier: "data-encryption-key")
 
 // Retrieve the key later
 let retrieveResult = await keyManager.retrieveKey(withIdentifier: "data-encryption-key")
 
 // Rotate the key
 let rotateResult = await keyManager.rotateKey(withIdentifier: "data-encryption-key")
 ```
 */

import SecureBytes
import SecurityProtocolsCore

/// A concrete implementation of `KeyManagementProtocol` that stores and manages cryptographic keys.
/// This implementation provides a simple in-memory storage for keys with support for key generation,
/// rotation, and lifecycle management.
public final class KeyManager: KeyManagementProtocol {
    // MARK: - Properties

    /// The secure storage for keys
    private let keyStorage: SafeStorage

    // MARK: - Initialisation

    /// Creates a new instance of KeyManager
    public init() {
        self.keyStorage = SafeStorage()
    }

    // MARK: - KeyManagementProtocol

    /// Retrieve a key with the given identifier
    /// - Parameter identifier: The identifier of the key to retrieve
    /// - Returns: The key or an error if the key does not exist
    public func retrieveKey(withIdentifier identifier: String) async -> Result<SecureBytes, SecurityError> {
        if let key = await keyStorage.get(identifier: identifier) {
            return .success(key)
        } else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }
    }

    /// Store a key with the given identifier
    /// - Parameters:
    ///   - key: The key to store
    ///   - identifier: The identifier to store the key under
    /// - Returns: Success or failure
    public func storeKey(_ key: SecureBytes, withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        await keyStorage.set(key: key, identifier: identifier)
        return .success(())
    }

    /// Delete a key with the given identifier
    /// - Parameter identifier: The identifier of the key to delete
    /// - Returns: Success or failure
    public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        if await keyStorage.contains(identifier: identifier) {
            await keyStorage.remove(identifier: identifier)
            return .success(())
        } else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }
    }

    /// Rotates a security key, creating a new key and optionally re-encrypting data.
    /// - Parameters:
    ///   - identifier: A string identifying the key to rotate.
    ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
    /// - Returns: The new key and re-encrypted data (if provided) or an error.
    public func rotateKey(withIdentifier identifier: String,
                          dataToReencrypt: SecureBytes?) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), SecurityError> {
        // Check if the key exists first
        guard let oldKey = await keyStorage.get(identifier: identifier) else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }

        // Generate a new key
        let crypto = CryptoService()
        let keyResult = await crypto.generateKey()

        switch keyResult {
        case .success(let newKey):
            // Store the new key
            await keyStorage.set(key: newKey, identifier: identifier)

            // If data was provided to re-encrypt
            if let dataToReencrypt = dataToReencrypt {
                // First decrypt the data with the old key
                let decryptResult = await crypto.decryptSymmetric(
                    data: dataToReencrypt,
                    key: oldKey,
                    config: SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
                )

                switch decryptResult.success {
                case true:
                    guard let decryptedData = decryptResult.data else {
                        return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
                    }

                    // Then encrypt it with the new key
                    let encryptResult = await crypto.encryptSymmetric(
                        data: decryptedData,
                        key: newKey,
                        config: SecurityConfigDTO(algorithm: "AES-GCM", keySizeInBits: 256)
                    )

                    switch encryptResult.success {
                    case true:
                        guard let reencryptedData = encryptResult.data else {
                            return .failure(.encryptionFailed(reason: "Failed to encrypt data with new key"))
                        }
                        return .success((newKey: newKey, reencryptedData: reencryptedData))
                    case false:
                        return .failure(encryptResult.error ?? .encryptionFailed(reason: "Unknown encryption error"))
                    }

                case false:
                    return .failure(decryptResult.error ?? .decryptionFailed(reason: "Unknown decryption error"))
                }
            } else {
                // No data to re-encrypt
                return .success((newKey: newKey, reencryptedData: nil))
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    /// Rotate a key with the given identifier
    /// - Parameter identifier: The identifier of the key to rotate
    /// - Returns: The new key or an error if the key does not exist
    public func rotateKey(withIdentifier identifier: String) async -> Result<SecureBytes, SecurityError> {
        // Delegate to the full rotation method
        let result = await rotateKey(withIdentifier: identifier, dataToReencrypt: nil)

        // Convert the result type
        switch result {
        case .success(let tuple):
            return .success(tuple.newKey)
        case .failure(let error):
            return .failure(error)
        }
    }

    /// List all key identifiers
    /// - Returns: A list of all key identifiers
    public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
        let identifiers = await keyStorage.allIdentifiers()
        return .success(identifiers)
    }

    /// Generate a new key
    /// - Parameter keySize: The size of the key to generate in bits
    /// - Returns: The generated key
    public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
        // Basic implementation that delegates to CryptoService
        let crypto = CryptoService()
        return await crypto.generateSecureRandomBytes(count: keySize / 8)
    }

    // MARK: - Helper Classes

    /// Thread-safe storage for keys
    private actor SafeStorage {
        private var storage: [String: SecureBytes] = [:]

        func get(identifier: String) -> SecureBytes? {
            return storage[identifier]
        }

        func set(key: SecureBytes, identifier: String) {
            storage[identifier] = key
        }

        func remove(identifier: String) {
            storage.removeValue(forKey: identifier)
        }

        func contains(identifier: String) -> Bool {
            return storage[identifier] != nil
        }

        func allIdentifiers() -> [String] {
            return Array(storage.keys)
        }
    }
}

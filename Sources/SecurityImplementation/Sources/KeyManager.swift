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

import ErrorHandlingDomains
import UmbraCoreTypes
import SecurityProtocolsCore

/// A concrete implementation of `KeyManagementProtocol` that stores and manages cryptographic keys.
/// This implementation provides a simple in-memory storage for keys with support for key
/// generation,
/// rotation, and lifecycle management.
public final class KeyManager: KeyManagementProtocol {
  // MARK: - Properties

  /// The secure storage for keys
  private let keyStorage: SafeStorage

  // MARK: - Initialisation

  /// Creates a new instance of KeyManager
  public init() {
    keyStorage=SafeStorage()
  }

  // MARK: - KeyManagementProtocol

  /// Retrieve a key with the given identifier
  /// - Parameter identifier: The identifier of the key to retrieve
  /// - Returns: The key or an error if the key does not exist
  public func retrieveKey(withIdentifier identifier: String) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    if let key=await keyStorage.get(identifier: identifier) {
      .success(key)
    } else {
      .failure(.invalidFormat(reason: "Key not found: \(identifier)"))
    }
  }

  /// Store a key with the given identifier
  /// - Parameters:
  ///   - key: The key to store
  ///   - identifier: The identifier to store the key under
  /// - Returns: Success or failure
  public func storeKey(
    _ key: SecureBytes,
    withIdentifier identifier: String
  ) async -> Result<Void, UmbraErrors.Security.Protocols> {
    await keyStorage.set(key: key, identifier: identifier)
    return .success(())
  }

  /// Delete a key with the given identifier
  /// - Parameter identifier: The identifier of the key to delete
  /// - Returns: Success or failure
  public func deleteKey(withIdentifier identifier: String) async -> Result<Void, UmbraErrors.Security.Protocols> {
    if await keyStorage.contains(identifier: identifier) {
      await keyStorage.remove(identifier: identifier)
      return .success(())
    } else {
      return .failure(.invalidFormat(reason: "Key not found: \(identifier)"))
    }
  }

  /// Rotates a security key, creating a new key and optionally re-encrypting data.
  /// - Parameters:
  ///   - identifier: A string identifying the key to rotate.
  ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
  /// - Returns: The new key and re-encrypted data (if provided) or an error.
  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async -> Result<(
    newKey: SecureBytes,
    reencryptedData: SecureBytes?
  ), UmbraErrors.Security.Protocols> {
    // Check if the key exists first
    guard let oldKey=await keyStorage.get(identifier: identifier) else {
      return .failure(.invalidFormat(reason: "Key not found: \(identifier)"))
    }

    // Generate a new key
    let crypto=CryptoService()
    let keyResult=await crypto.generateKey()

    switch keyResult {
      case let .success(newKey):
        // Store the new key
        await keyStorage.set(key: newKey, identifier: identifier)

        // If data was provided to re-encrypt
        if let dataToReencrypt {
          // First decrypt the data with the old key
          let decryptResult=await crypto.decrypt(data: dataToReencrypt, using: oldKey)

          switch decryptResult {
            case .success(let decryptedData):
              // Then encrypt it with the new key
              let encryptResult=await crypto.encrypt(data: decryptedData, using: newKey)

              switch encryptResult {
                case .success(let reencryptedData):
                  // Store the new key with the same identifier
                  let storeResult=await storeKey(newKey, withIdentifier: identifier)

                  switch storeResult {
                    case .success:
                      return .success((newKey: newKey, reencryptedData: reencryptedData))
                    case .failure(let error):
                      return .failure(error)
                  }
                case .failure(let error):
                  return .failure(error)
              }
            case .failure(let error):
              return .failure(error)
          }
        } else {
          // No data to re-encrypt
          return .success((newKey: newKey, reencryptedData: nil))
        }

      case let .failure(error):
        return .failure(error)
    }
  }

  /// Rotate a key with the given identifier
  /// - Parameter identifier: The identifier of the key to rotate
  /// - Returns: The new key or an error if the key does not exist
  public func rotateKey(withIdentifier identifier: String) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Delegate to the full rotation method
    let result=await rotateKey(withIdentifier: identifier, dataToReencrypt: nil as SecureBytes?)

    // Convert the result type
    switch result {
      case let .success(tuple):
        return .success(tuple.newKey)
      case let .failure(error):
        return .failure(error)
    }
  }

  /// List all key identifiers
  /// - Returns: A list of all key identifiers
  public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.Protocols> {
    let identifiers=await keyStorage.allIdentifiers()
    return .success(identifiers)
  }

  /// Generate a new key with the specified size
  /// - Parameter keySize: The size of the key in bits
  /// - Returns: The generated key
  public func generateKey(keySize: Int) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Basic implementation that delegates to CryptoService
    let crypto=CryptoService()
    return await crypto.generateRandomData(length: keySize / 8)
  }

  // MARK: - Helper Classes

  /// Thread-safe storage for keys
  private actor SafeStorage {
    private var storage: [String: SecureBytes]=[:]

    func get(identifier: String) -> SecureBytes? {
      storage[identifier]
    }

    func set(key: SecureBytes, identifier: String) {
      storage[identifier]=key
    }

    func remove(identifier: String) {
      storage.removeValue(forKey: identifier)
    }

    func contains(identifier: String) -> Bool {
      storage[identifier] != nil
    }

    func allIdentifiers() -> [String] {
      Array(storage.keys)
    }
  }
}

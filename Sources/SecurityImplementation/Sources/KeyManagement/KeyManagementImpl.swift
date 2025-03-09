import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// In-memory implementation of KeyManagementProtocol
/// This is a basic implementation that stores keys in memory for demonstration purposes
/// In a real implementation, keys would be stored securely in a platform-specific secure storage
public actor KeyManagementImpl: KeyManagementProtocol {

  // MARK: - Properties

  /// Storage provider for secure key storage
  private let secureStorage: SecureStorageProtocol?

  /// In-memory storage of keys (used as fallback when secureStorage is nil)
  private var keyStore: [String: SecureBytes]=[:]

  // MARK: - Initialization

  /// Initialize with a specific secure storage implementation
  /// - Parameter secureStorage: Implementation of SecureStorageProtocol
  public init(secureStorage: SecureStorageProtocol?=nil) {
    self.secureStorage=secureStorage
  }

  // MARK: - KeyManagementProtocol Implementation

  public func retrieveKey(withIdentifier identifier: String) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // If secure storage is available, use it
    if let secureStorage {
      let result=await secureStorage.retrieveSecurely(identifier: identifier)
      switch result {
        case let .success(data):
          return .success(data)
        case let .failure(error):
          switch error {
            case .keyNotFound:
              return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
            default:
              return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
          }
        @unknown default:
          return .failure(.storageOperationFailed(reason: "Unknown storage result"))
      }
    }

    // Fallback to in-memory storage
    guard let key=keyStore[identifier] else {
      return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
    }
    return .success(key)
  }

  public func storeKey(
    _ key: SecureBytes,
    withIdentifier identifier: String
  ) async -> Result<Void, UmbraErrors.Security.Protocols> {
    // If secure storage is available, use it
    if let secureStorage {
      let result=await secureStorage.storeSecurely(data: key, identifier: identifier)
      switch result {
        case .success:
          return .success(())
        case let .failure(error):
          return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
        @unknown default:
          return .failure(.storageOperationFailed(reason: "Unknown storage result"))
      }
    }

    // Fallback to in-memory storage
    keyStore[identifier]=key
    return .success(())
  }

  public func deleteKey(withIdentifier identifier: String) async
  -> Result<Void, UmbraErrors.Security.Protocols> {
    // If secure storage is available, use it
    if let secureStorage {
      let result=await secureStorage.deleteSecurely(identifier: identifier)
      switch result {
        case .success:
          return .success(())
        case let .failure(error):
          switch error {
            case .keyNotFound:
              return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
            default:
              return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
          }
        @unknown default:
          return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
      }
    }

    // Fallback to in-memory storage
    guard keyStore[identifier] != nil else {
      return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
    }

    keyStore.removeValue(forKey: identifier)
    return .success(())
  }

  /// - Returns: A result containing the key or an error
  public func rotateKey(
    withIdentifier identifier: String,
    andRencryptData dataToReencrypt: SecureBytes?
  ) async -> Result<(newKey: SecureBytes, oldKey: SecureBytes), UmbraErrors.Security.Protocols> {
    // Retrieve the old key
    let oldKeyResult=await retrieveKey(withIdentifier: identifier)
    guard case let .success(oldKey)=oldKeyResult else {
      if case let .failure(error)=oldKeyResult {
        return .failure(error)
      }
      return .failure(.keyNotFound(identifier: identifier))
    }

    do {
      // Get a key generator to create the new key
      let keyGenerator=KeyGenerator()

      // Generate a new key
      let keyResult=await keyGenerator.generateKey(
        bits: 256,
        keyType: .symmetric,
        purpose: .encryption
      )
      guard case let .success(newKey)=keyResult else {
        if case let .failure(error)=keyResult {
          return .failure(error)
        }
        return .failure(.keyGenerationFailed(reason: "Unknown error"))
      }

      // Re-encrypt data if provided
      if let existingCiphertext=dataToReencrypt {
        // First decrypt with old key
        let decryptResult=await keyGenerator.decryptData(existingCiphertext, using: oldKey)
        guard case let .success(decryptedData)=decryptResult else {
          if case let .failure(error)=decryptResult {
            return .failure(error)
          }
          return .failure(.decryptionFailed(reason: "Failed to decrypt with old key"))
        }

        // Then encrypt with new key
        let encryptResult=await keyGenerator.encryptData(decryptedData, using: newKey)
        guard case .success=encryptResult else {
          if case let .failure(error)=encryptResult {
            return .failure(error)
          }
          return .failure(.encryptionFailed(reason: "Failed to encrypt with new key"))
        }
      }

      // Store the new key
      let storeResult=await storeKey(newKey, withIdentifier: identifier)
      guard case .success=storeResult else {
        if case let .failure(error)=storeResult {
          return .failure(error)
        }
        return .failure(.keyStoreFailed(reason: "Failed to store new key"))
      }

      // Return both keys
      return .success((newKey: newKey, oldKey: oldKey))
    } catch {
      return .failure(.generalError(error: error))
    }
  }

  public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.Protocols> {
    // If secure storage is available, it should provide a way to list keys
    // For now, we'll just return the in-memory keys
    .success(Array(keyStore.keys))
  }
}

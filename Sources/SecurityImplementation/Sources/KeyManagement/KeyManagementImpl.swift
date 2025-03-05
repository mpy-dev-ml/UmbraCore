import CryptoSwiftFoundationIndependent
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
  -> Result<SecureBytes, SecurityError> {
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
  ) async -> Result<Void, SecurityError> {
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

  public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
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

  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async -> Result<(
    newKey: SecureBytes,
    reencryptedData: SecureBytes?
  ), SecurityError> {
    // Retrieve the old key
    let oldKeyResult=await retrieveKey(withIdentifier: identifier)
    guard case let .success(oldKey)=oldKeyResult else {
      if case let .failure(error)=oldKeyResult {
        return .failure(error)
      }
      return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
    }

    // Generate a new key
    let newKey=CryptoWrapper.generateRandomKeySecure()

    // Re-encrypt data if provided
    var reencryptedData: SecureBytes?
    if let dataToReencrypt {
      do {
        // Extract IV (first 12 bytes) and ciphertext from the combined data
        let ivSize=12 // AES GCM IV size is 12 bytes
        guard dataToReencrypt.count > ivSize else {
          return .failure(.invalidInput(reason: "Data is too short to contain IV"))
        }

        let (existingIv, existingCiphertext)=try dataToReencrypt.split(at: ivSize)

        // First decrypt with old key and existing IV
        let decryptedData=try CryptoWrapper.decryptAES_GCM(
          data: existingCiphertext,
          key: oldKey,
          iv: existingIv
        )

        // Then encrypt with new key
        let newIv=CryptoWrapper.generateRandomIVSecure()
        let encryptedData=try CryptoWrapper.encryptAES_GCM(
          data: decryptedData,
          key: newKey,
          iv: newIv
        )

        // Combine IV with encrypted data
        reencryptedData=SecureBytes.combine(newIv, encryptedData)
      } catch {
        return .failure(
          .storageOperationFailed(
            reason: "Failed to re-encrypt data: \(error.localizedDescription)"
          )
        )
      }
    }

    // Store the new key
    let storeResult=await storeKey(newKey, withIdentifier: identifier)
    if case let .failure(error)=storeResult {
      return .failure(error)
    }

    return .success((newKey: newKey, reencryptedData: reencryptedData))
  }

  public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    // If secure storage is available, it should provide a way to list keys
    // For now, we'll just return the in-memory keys
    .success(Array(keyStore.keys))
  }
}

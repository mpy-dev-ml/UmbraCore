// CryptoKit removed - cryptography will be handled in ResticBar
import CoreErrors
import CryptoTypesProtocols
import CryptoTypesTypes
import ErrorHandlingDomains
import Foundation
import SecurityTypes
import SecurityTypesProtocols
import UmbraCoreTypes
import XPCCore
import XPCProtocolsCore

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
  private let keychain: any SecureStorageProvider
  private let xpcService: ModernCryptoXPCServiceProtocol
  private let config: CryptoConfig

  /// Initialize a new CredentialManager
  /// - Parameters:
  ///   - service: Service name for the keychain
  ///   - xpcService: XPC service for cryptographic operations
  ///   - config: Cryptographic configuration
  public init(service: String, xpcService: ModernCryptoXPCServiceProtocol, config: CryptoConfig) {
    keychain=KeychainAccess(service: service)
    self.xpcService=xpcService
    self.config=config
  }

  /// Store a credential securely in the keychain
  /// - Parameters:
  ///   - credential: The credential data to store
  ///   - identifier: Unique identifier for the credential
  public func store(credential: Data, withIdentifier identifier: String) async throws {
    let key=try await getMasterKey()

    // Generate random IV using the XPC service
    let service=xpcService
    let ivResult=await service.generateSecureRandomData(length: config.ivLength)
    guard case let .success(iv)=ivResult else {
      if case let .failure(error)=ivResult {
        throw error
      }
      throw UmbraErrors.GeneralSecurity.Core
        .randomGenerationFailed(reason: "Failed to generate random IV")
    }

    // Encrypt the credential
    // Convert Data to SecureBytes using array initializer
    let credentialBytes=SecureBytes(bytes: [UInt8](credential))
    let keyBytes=SecureBytes(bytes: [UInt8](key))
    let ivBytes=SecureBytes(bytes: [UInt8](iv))

    let encryptResult=await encrypt(
      data: credentialBytes,
      using: keyBytes,
      iv: ivBytes
    )

    switch encryptResult {
      case let .success(encrypted):
        // Convert SecureBytes to Data for storage
        var encryptedData=Data()
        encrypted.withUnsafeBytes { buffer in
          encryptedData=Data(buffer)
        }

        let storageData=SecureStorageData(encryptedData: encryptedData, iv: iv)
        let encodedData=try JSONEncoder().encode(storageData)
        try await keychain.save(encodedData, forKey: identifier, metadata: nil)
      case let .failure(error):
        throw error
    }
  }

  /// Retrieve a credential from the keychain
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: The decrypted credential data
  public func retrieve(withIdentifier identifier: String) async throws -> Data {
    let key=try await getMasterKey()
    let (encodedData, _)=try await keychain.loadWithMetadata(forKey: identifier)
    let storageData=try JSONDecoder().decode(SecureStorageData.self, from: encodedData)

    let keyBytes=SecureBytes(bytes: [UInt8](key))
    let encryptedBytes=SecureBytes(bytes: [UInt8](storageData.encryptedData))
    let ivBytes=SecureBytes(bytes: [UInt8](storageData.iv))

    let decryptResult=await decrypt(data: encryptedBytes, using: keyBytes, iv: ivBytes)

    switch decryptResult {
      case let .success(decrypted):
        // Convert SecureBytes to Data
        var resultData=Data()
        decrypted.withUnsafeBytes { buffer in
          resultData=Data(buffer)
        }
        return resultData
      case let .failure(error):
        throw error
    }
  }

  /// Delete a credential from the keychain
  /// - Parameter identifier: Unique identifier for the credential
  public func delete(withIdentifier identifier: String) async throws {
    try await keychain.delete(forKey: identifier)
  }

  /// Check if a credential exists in the keychain
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: True if the credential exists, false otherwise
  public func exists(withIdentifier identifier: String) async -> Bool {
    do {
      _=try await keychain.loadWithMetadata(forKey: identifier)
      return true
    } catch {
      return false
    }
  }

  /// List all credential identifiers in the keychain
  /// - Returns: Array of credential identifiers
  public func listCredentials() async throws -> [String] {
    try await keychain.allKeys()
  }

  /// Reset the credential manager, optionally preserving master keys
  public func reset() async {
    await keychain.reset(preserveKeys: false)
  }

  /// Get or generate the master encryption key
  /// - Returns: The master encryption key data
  private func getMasterKey() async throws -> Data {
    do {
      let (key, _)=try await keychain.loadWithMetadata(forKey: "master_key")
      return key
    } catch {
      // Master key doesn't exist, generate a new one
    }

    // Generate a secure random key using the XPC service
    let keyLength=config.keyLength / 8
    let service=xpcService
    let randomDataResult=await service.generateSecureRandomData(length: keyLength)
    guard case let .success(key)=randomDataResult else {
      if case let .failure(error)=randomDataResult {
        throw error
      }
      throw UmbraErrors.GeneralSecurity.Core
        .randomGenerationFailed(reason: "Failed to generate master key")
    }

    try await keychain.save(key, forKey: "master_key", metadata: nil)
    return key
  }

  // Helper method to encrypt data using the XPC service
  private func encrypt(
    data: SecureBytes,
    using key: SecureBytes,
    iv _: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Convert SecureBytes to Data for XPC interface
    var dataBytes=Data()
    var keyBytes=Data()

    data.withUnsafeBytes { buffer in
      dataBytes=Data(buffer)
    }

    key.withUnsafeBytes { buffer in
      keyBytes=Data(buffer)
    }

    // Using the direct encrypt method from ModernCryptoXPCServiceProtocol
    let service=xpcService
    let result=await service.encrypt(dataBytes, key: keyBytes)

    // Convert result back to SecureBytes
    return result.map { encryptedData in
      SecureBytes(bytes: [UInt8](encryptedData))
    }
  }

  // Helper method to decrypt data using the XPC service
  private func decrypt(
    data: SecureBytes,
    using key: SecureBytes,
    iv _: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Convert SecureBytes to Data for XPC interface
    var dataBytes=Data()
    var keyBytes=Data()

    data.withUnsafeBytes { buffer in
      dataBytes=Data(buffer)
    }

    key.withUnsafeBytes { buffer in
      keyBytes=Data(buffer)
    }

    // Using the direct decrypt method from ModernCryptoXPCServiceProtocol
    let service=xpcService
    let result=await service.decrypt(dataBytes, key: keyBytes)

    // Convert result back to SecureBytes
    return result.map { decryptedData in
      SecureBytes(bytes: [UInt8](decryptedData))
    }
  }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageProvider {
  private let service: String
  private var items: [String: (data: Data, metadata: [String: String]?)]=[:]

  init(service: String) {
    self.service=service
  }

  func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws {
    items[key]=(data: data, metadata: metadata)
  }

  func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?) {
    guard let item=items[key] else {
      throw UmbraErrors.GeneralSecurity.Core.storageOperationFailed(reason: "Item not found")
    }
    return (item.data, item.metadata)
  }

  func delete(forKey key: String) async throws {
    guard items.removeValue(forKey: key) != nil else {
      throw UmbraErrors.GeneralSecurity.Core.storageOperationFailed(reason: "Item not found")
    }
  }

  func exists(forKey key: String) async -> Bool {
    items[key] != nil
  }

  func allKeys() async throws -> [String] {
    Array(items.keys)
  }

  func reset(preserveKeys: Bool) async {
    if preserveKeys {
      // Only clear data but preserve keys
      for key in items.keys {
        items[key]=(data: Data(), metadata: nil)
      }
    } else {
      items.removeAll()
    }
  }
}

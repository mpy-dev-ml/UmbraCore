// CryptoKit removed - cryptography will be handled in ResticBar
import CoreErrors
import CryptoTypesProtocols
import CryptoTypesTypes
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore
import ErrorHandlingDomains

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
  private let keychain: any SecureStorageProvider
  private let xpcService: ModernCryptoXPCServiceProtocol
  private let config: CryptoConfig

  /// Initialize the credential manager
  /// - Parameters:
  ///   - service: Service identifier for the keychain
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
    let ivResult=try await xpcService.generateRandomData(length: config.ivLength)
    let iv=ivResult.asData()

    // Encrypt the credential
    let credentialBytes=SecureBytes(data: credential)
    let keyBytes=SecureBytes(data: key)
    let encryptResult=await encrypt(
      data: credentialBytes,
      using: keyBytes,
      iv: SecureBytes(data: iv)
    )

    switch encryptResult {
      case let .success(encrypted):
        let storageData=SecureStorageData(encryptedData: encrypted.asData(), iv: iv)
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

    let keyBytes=SecureBytes(data: key)
    let encryptedBytes=SecureBytes(data: storageData.encryptedData)
    let ivBytes=SecureBytes(data: storageData.iv)

    let decryptResult=await decrypt(data: encryptedBytes, using: keyBytes, iv: ivBytes)

    switch decryptResult {
      case let .success(decrypted):
        return decrypted.asData()
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
  public func hasCredential(withIdentifier identifier: String) async -> Bool {
    await keychain.exists(forKey: identifier)
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
    if let (key, _)=try? await keychain.loadWithMetadata(forKey: "master_key") {
      return key
    }

    // Generate a secure random key using the XPC service
    let keyLength=config.keyLength / 8
    let randomDataResult=try await xpcService.generateRandomData(length: keyLength)
    let key=randomDataResult.asData()

    try await keychain.save(key, forKey: "master_key", metadata: nil)
    return key
  }

  // Helper method to encrypt data using the XPC service
  private func encrypt(
    data: SecureBytes,
    using key: SecureBytes,
    iv _: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Using the direct encrypt method from ModernCryptoXPCServiceProtocol
    await xpcService.encrypt(data, key: key)
  }

  // Helper method to decrypt data using the XPC service
  private func decrypt(
    data: SecureBytes,
    using key: SecureBytes,
    iv _: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Using the direct decrypt method from ModernCryptoXPCServiceProtocol
    await xpcService.decrypt(data, key: key)
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
      throw CoreErrors.SecurityError.itemNotFound
    }
    return (item.data, item.metadata)
  }

  func delete(forKey key: String) async throws {
    guard items.removeValue(forKey: key) != nil else {
      throw CoreErrors.SecurityError.itemNotFound
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

// CryptoKit removed - cryptography will be handled in ResticBar
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
  private let keychain: any SecureStorageServiceProtocol
  private let config: CryptoConfig

  public init(service: String, config: CryptoConfig) {
    keychain = KeychainAccess(service: service)
    self.config = config
  }

  /// Save a credential securely
  /// - Parameters:
  ///   - identifier: Identifier for the credential
  ///   - data: Data to store
  public func save(_ data: Data, forIdentifier identifier: String) async throws {
    let secureBytes = SecureBytes(data: data)
    try await keychain.storeSecurely(secureBytes, identifier: identifier, metadata: nil)
  }

  /// Retrieve a credential
  /// - Parameter identifier: Identifier for the credential
  /// - Returns: Stored data
  public func retrieve(forIdentifier identifier: String) async throws -> Data {
    let secureBytes = try await keychain.retrieveSecurely(identifier: identifier)
    return secureBytes.asData()
  }

  /// Delete a credential
  /// - Parameter identifier: Identifier for the credential
  public func delete(forIdentifier identifier: String) async throws {
    try await keychain.deleteSecurely(identifier: identifier)
  }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageServiceProtocol {
  private let service: String
  private var items: [String: (data: SecureBytes, metadata: [String: String]?)] = [:]

  init(service: String) {
    self.service = service
  }

  func storeSecurely(_ data: SecureBytes, identifier: String, metadata: [String: String]?) async throws {
    items[identifier] = (data: data, metadata: metadata)
  }

  func retrieveSecurely(identifier: String) async throws -> SecureBytes {
    guard let item = items[identifier] else {
      throw CoreErrors.SecurityError.itemNotFound
    }
    return item.data
  }

  func deleteSecurely(identifier: String) async throws {
    guard items.removeValue(forKey: identifier) != nil else {
      throw CoreErrors.SecurityError.itemNotFound
    }
  }

  func listIdentifiers() async throws -> [String] {
    Array(items.keys)
  }

  func getMetadata(for identifier: String) async throws -> [String: String]? {
    guard let item = items[identifier] else {
      throw CoreErrors.SecurityError.itemNotFound
    }
    return item.metadata
  }
}

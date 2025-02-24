import CryptoKit
import CryptoTypes_Protocols
import Foundation
import SecurityTypes
import SecurityTypes_Protocols

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
    private let keychain: any SecureStorageProvider
    private let cryptoService: CryptoServiceProtocol
    private let config: CryptoConfig

    public init(service: String, cryptoService: CryptoServiceProtocol, config: CryptoConfig) {
        self.keychain = KeychainAccess(service: service)
        self.cryptoService = cryptoService
        self.config = config
    }

    /// Save a credential securely
    /// - Parameters:
    ///   - identifier: Identifier for the credential
    ///   - credential: The credential to save
    public func save(_ credential: String, forIdentifier identifier: String) async throws {
        let key = try await getPrimaryKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let credentialData = credential.data(using: .utf8)!
        let encryptedData = try await cryptoService.encrypt(credentialData, using: key, iv: iv)

        let storageData = SecureStorageData(
            encryptedData: encryptedData,
            iv: iv
        )

        let encodedData = try JSONEncoder().encode(storageData)
        try await keychain.save(encodedData, forKey: identifier, metadata: nil)
    }

    /// Load a credential
    /// - Parameter identifier: Identifier for the credential
    /// - Returns: The decrypted credential
    public func load(forIdentifier identifier: String) async throws -> String {
        let key = try await getPrimaryKey()
        let encodedData = try await keychain.loadWithMetadata(forKey: identifier).0
        let storageData = try JSONDecoder().decode(SecureStorageData.self, from: encodedData)

        let decryptedData = try await cryptoService.decrypt(storageData.encryptedData, using: key, iv: storageData.iv)
        guard let credential = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.invalidData(reason: "Could not decode credential data")
        }
        return credential
    }

    /// Delete a credential
    /// - Parameter identifier: Identifier for the credential to delete
    /// - Throws: SecurityError if deletion fails
    public func delete(forIdentifier identifier: String) async throws {
        try await keychain.delete(forKey: identifier)
    }

    private func getPrimaryKey() async throws -> Data {
        if try await keychain.exists(forKey: "master_key") {
            return try await keychain.loadWithMetadata(forKey: "master_key").0
        }

        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength / 8)
        try await keychain.save(key, forKey: "master_key", metadata: nil)
        return key
    }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageProvider {
    private let service: String
    private var items: [String: (data: Data, metadata: [String: String]?)] = [:]

    init(service: String) {
        self.service = service
    }

    func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws {
        items[key] = (data: data, metadata: metadata)
    }

    func load(forKey key: String) async throws -> Data {
        guard let item = items[key] else {
            throw SecurityError.accessError("Item not found: \(key)")
        }
        return item.data
    }

    func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?) {
        guard let item = items[key] else {
            throw SecurityError.accessError("Item not found: \(key)")
        }
        return (item.data, item.metadata)
    }

    func delete(forKey key: String) async throws {
        guard items.removeValue(forKey: key) != nil else {
            throw SecurityError.accessError("Item not found: \(key)")
        }
    }

    func exists(forKey key: String) async -> Bool {
        items[key] != nil
    }

    func allKeys() async throws -> [String] {
        Array(items.keys)
    }

    func reset(preserveKeys: Bool) async {
        if !preserveKeys {
            items.removeAll()
        }
    }

    func updateMetadata(_ metadata: [String: String], forKey key: String) async throws {
        guard var item = items[key] else {
            throw SecurityError.accessError("Item not found: \(key)")
        }
        item.metadata = metadata
        items[key] = item
    }
}

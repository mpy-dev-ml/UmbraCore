// CryptoKit removed - cryptography will be handled in ResticBar
import CryptoTypesProtocols
import CryptoTypesTypes
import Foundation
import SecurityInterfaces
import SecurityInterfacesProtocols
import SecurityTypes
import SecurityTypesProtocols

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

    public func store(credential: Data, withIdentifier identifier: String) async throws {
        let key = try await getMasterKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let encrypted = try await cryptoService.encrypt(credential, using: key, iv: iv)
        let storageData = SecureStorageData(encryptedData: encrypted, iv: iv)
        let encodedData = try JSONEncoder().encode(storageData)
        try await keychain.save(encodedData, forKey: identifier, metadata: nil)
    }

    public func retrieve(withIdentifier identifier: String) async throws -> Data {
        let key = try await getMasterKey()
        let (encodedData, _) = try await keychain.loadWithMetadata(forKey: identifier)
        let storageData = try JSONDecoder().decode(SecureStorageData.self, from: encodedData)
        return try await cryptoService.decrypt(storageData.encryptedData, using: key, iv: storageData.iv)
    }

    public func delete(withIdentifier identifier: String) async throws {
        try await keychain.delete(forKey: identifier)
    }

    public func hasCredential(withIdentifier identifier: String) async -> Bool {
        await keychain.exists(forKey: identifier)
    }

    public func listCredentials() async throws -> [String] {
        try await keychain.allKeys()
    }

    public func reset() async {
        await keychain.reset(preserveKeys: false)
    }

    private func getMasterKey() async throws -> Data {
        if let (key, _) = try? await keychain.loadWithMetadata(forKey: "master_key") {
            return key
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

    public func store(data: Data, forKey key: String) async throws {
        try await save(data, forKey: key, metadata: nil)
    }

    public func retrieve(forKey key: String) async throws -> Data? {
        try await load(forKey: key)
    }

    func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws {
        items[key] = (data: data, metadata: metadata)
    }

    func load(forKey key: String) async throws -> Data {
        guard let item = items[key] else {
            throw SecurityInterfaces.SecurityError.itemNotFound
        }
        return item.data
    }

    func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?) {
        guard let item = items[key] else {
            throw SecurityInterfaces.SecurityError.itemNotFound
        }
        return (item.data, item.metadata)
    }

    func delete(forKey key: String) async throws {
        guard items.removeValue(forKey: key) != nil else {
            throw SecurityInterfaces.SecurityError.itemNotFound
        }
    }

    func exists(forKey key: String) async -> Bool {
        items[key] != nil
    }

    func allKeys() async throws -> [String] {
        Array(items.keys)
    }

    func updateMetadata(_ metadata: [String: String], forKey key: String) async throws {
        guard var item = items[key] else {
            throw SecurityInterfaces.SecurityError.itemNotFound
        }
        item.metadata = metadata
        items[key] = item
    }

    func reset(preserveKeys: Bool) async {
        if preserveKeys {
            // Only clear data but preserve keys
            for key in items.keys {
                items[key] = (data: Data(), metadata: nil)
            }
        } else {
            items.removeAll()
        }
    }
}

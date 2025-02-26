// CryptoKit removed - cryptography will be handled in ResticBar
import Foundation
import SecurityInterfaces
import SecurityTypes
import SecurityTypesProtocols

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
    private let keychain: any SecureStorageProvider
    private let config: CryptoConfig

    public init(service: String, config: CryptoConfig) {
        self.keychain = KeychainAccess(service: service)
        self.config = config
    }

    /// Save a credential securely
    /// - Parameters:
    ///   - identifier: Identifier for the credential
    ///   - data: Data to store
    public func save(_ data: Data, forIdentifier identifier: String) async throws {
        try await keychain.save(data, forKey: identifier, metadata: nil)
    }

    /// Retrieve a credential
    /// - Parameter identifier: Identifier for the credential
    /// - Returns: Stored data
    public func retrieve(forIdentifier identifier: String) async throws -> Data {
        let (data, _) = try await keychain.loadWithMetadata(forKey: identifier)
        return data
    }

    /// Delete a credential
    /// - Parameter identifier: Identifier for the credential
    public func delete(forIdentifier identifier: String) async throws {
        try await keychain.delete(forKey: identifier)
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

    func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?) {
        guard let item = items[key] else {
            throw SecurityInterfaces.SecurityError.itemNotFound
        }
        return (item.data, item.metadata)
    }

    func load(forKey key: String) async throws -> Data {
        let (data, _) = try await loadWithMetadata(forKey: key)
        return data
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

    func reset(preserveKeys: Bool) async {
        if !preserveKeys {
            items.removeAll()
        }
    }
}

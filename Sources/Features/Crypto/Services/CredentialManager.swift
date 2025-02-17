import Foundation
import CryptoTypes

/// A service for securely storing and retrieving credentials
public actor CredentialManager {
    private let cryptoService: CryptoServiceProtocol
    private let keychain: SecureStorageProvider
    private let config: CryptoConfiguration
    
    public init(cryptoService: CryptoServiceProtocol, keychain: SecureStorageProvider, config: CryptoConfiguration = .default) {
        self.cryptoService = cryptoService
        self.keychain = keychain
        self.config = config
    }
    
    public func securelyStore(_ data: Data, identifier: String) async throws {
        let key = try await getOrCreateMasterKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let encrypted = try await cryptoService.encrypt(data, using: key, iv: iv)
        let storageData = SecureStorageData(encryptedData: encrypted, iv: iv)
        let encodedData = try JSONEncoder().encode(storageData)
        try await keychain.set(encodedData, key: identifier)
    }
    
    public func retrieveSecureData(identifier: String) async throws -> Data {
        guard let encodedData = try await keychain.getData(identifier) else {
            throw CryptoError.decryptionFailed(reason: "No data found for identifier: \(identifier)")
        }
        
        let storageData = try JSONDecoder().decode(SecureStorageData.self, from: encodedData)
        guard let key = try await getMasterKey() else {
            throw CryptoError.keyNotFound(identifier: "master_key")
        }
        
        return try await cryptoService.decrypt(storageData.encryptedData, using: key, iv: storageData.iv)
    }
    
    public func removeSecureData(identifier: String) async throws {
        try await keychain.remove(identifier)
    }
    
    public func hasSecureData(identifier: String) async throws -> Bool {
        try await keychain.contains(identifier)
    }
    
    private func getOrCreateMasterKey() async throws -> Data {
        if let existingKey = try await getMasterKey() {
            return existingKey
        }
        
        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength / 8)
        try await keychain.set(key, key: "master_key")
        return key
    }
    
    private func getMasterKey() async throws -> Data? {
        try await keychain.getData("master_key")
    }
}

// MARK: - Supporting Types

/// Access to the system keychain
private actor KeychainAccess: SecureStorageProvider {
    private let service: String
    
    init(service: String) {
        self.service = service
    }
    
    func set(_ data: Data, key: String) async throws {
        var query = baseQuery(key: key)
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            try await update(data, key: key)
        } else if status != errSecSuccess {
            throw CryptoError.encryptionFailed(reason: "Keychain add failed: \(status)")
        }
    }
    
    func getData(_ key: String) async throws -> Data? {
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw CryptoError.decryptionFailed(reason: "Keychain read failed: \(status)")
        }
        
        return result as? Data
    }
    
    func remove(_ key: String) async throws {
        let query = baseQuery(key: key)
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw CryptoError.encryptionFailed(reason: "Keychain delete failed: \(status)")
        }
    }
    
    func contains(_ key: String) async throws -> Bool {
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = false
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func update(_ data: Data, key: String) async throws {
        let query = baseQuery(key: key)
        let attributes = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status != errSecSuccess {
            throw CryptoError.encryptionFailed(reason: "Keychain update failed: \(status)")
        }
    }
    
    private func baseQuery(key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecUseDataProtectionKeychain as String: true
        ]
    }
}

/// Structure representing credentials that can be securely stored
public struct Credentials: Codable, Sendable {
    public let username: String
    public let password: String
    public let additionalData: [String: String]
    
    public init(
        username: String,
        password: String,
        additionalData: [String: String] = [:]
    ) {
        self.username = username
        self.password = password
        self.additionalData = additionalData
    }
}

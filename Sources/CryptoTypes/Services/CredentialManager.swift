import Foundation
import SecurityTypes

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
    
    public func store<T: Encodable>(credential: T, withIdentifier identifier: String) async throws {
        let data = try JSONEncoder().encode(credential)
        let key = try await getOrCreateMasterKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: config.ivLength)
        let encrypted = try await cryptoService.encrypt(data, using: key, iv: iv)
        let storageData = SecureStorageData(encryptedData: encrypted, iv: iv)
        let encodedData = try JSONEncoder().encode(storageData)
        try await keychain.save(encodedData, forKey: identifier)
    }
    
    public func retrieve<T: Decodable>(withIdentifier identifier: String) async throws -> T {
        let encodedData = try await keychain.load(forKey: identifier)
        let storageData = try JSONDecoder().decode(SecureStorageData.self, from: encodedData)
        let key = try await getOrCreateMasterKey()
        let decryptedData = try await cryptoService.decrypt(storageData.encryptedData, using: key, iv: storageData.iv)
        return try JSONDecoder().decode(T.self, from: decryptedData)
    }
    
    public func delete(withIdentifier identifier: String) async throws {
        try await keychain.delete(forKey: identifier)
    }
    
    public func exists(withIdentifier identifier: String) async -> Bool {
        do {
            _ = try await keychain.load(forKey: identifier)
            return true
        } catch {
            return false
        }
    }
    
    private func getOrCreateMasterKey() async throws -> Data {
        if let key = try await getMasterKey() {
            return key
        }
        return try await createMasterKey()
    }
    
    private func createMasterKey() async throws -> Data {
        guard await exists(withIdentifier: "master_key") == false else {
            throw CryptoError.keyExists(identifier: "master_key")
        }
        
        let key = try await cryptoService.generateSecureRandomKey(length: config.keyLength / 8)
        try await keychain.save(key, forKey: "master_key")
        return key
    }
    
    private func getMasterKey() async throws -> Data? {
        do {
            return try await keychain.load(forKey: "master_key")
        } catch {
            return nil
        }
    }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageProvider {
    private let service: String
    
    init(service: String = "com.umbracore.keychain") {
        self.service = service
    }
    
    func save(_ data: Data, forKey key: String) async throws {
        var query = baseQuery(key: key)
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw CryptoError.keychainError(status: status)
        }
    }
    
    func load(forKey key: String) async throws -> Data {
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw CryptoError.keychainError(status: status)
        }
        
        guard let data = result as? Data else {
            throw CryptoError.keychainError(status: errSecDecode)
        }
        
        return data
    }
    
    func delete(forKey key: String) async throws {
        let query = baseQuery(key: key)
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw CryptoError.keychainError(status: status)
        }
    }
    
    func reset() async {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ] as [String: Any]
        
        _ = SecItemDelete(query as CFDictionary)
    }
    
    private func baseQuery(key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

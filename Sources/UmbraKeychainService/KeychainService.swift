import Foundation
import Security

/// Service for managing secure keychain access
public actor KeychainService: KeychainServiceProtocol {
    private let xpcService: KeychainXPCService?
    private let accessGroup: String?
    
    public init(enableXPC: Bool = false, accessGroup: String? = nil) {
        self.xpcService = enableXPC ? KeychainXPCService() : nil
        self.accessGroup = accessGroup
    }
    
    public func addItem(_ data: Data,
                       account: String,
                       service: String,
                       accessGroup: String?,
                       accessibility: CFString = kSecAttrAccessibleWhenUnlocked,
                       flags: SecAccessControlCreateFlags = []) async throws {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateItem
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func updateItem(_ data: Data,
                         account: String,
                         service: String,
                         accessGroup: String?) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary,
                                 attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func deleteItem(account: String,
                         service: String,
                         accessGroup: String?) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func readItem(account: String,
                       service: String,
                       accessGroup: String?) async throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidDataFormat
        }
        
        return data
    }
    
    public func containsItem(account: String,
                          service: String,
                          accessGroup: String?) async -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

/// XPC service for keychain operations
private final class KeychainXPCService: NSObject, KeychainServiceXPCProtocol, NSXPCListenerDelegate {
    private let listener: NSXPCListener
    private let service: KeychainService
    
    override init() {
        self.listener = NSXPCListener(machServiceName: "com.umbracore.keychain")
        self.service = KeychainService(enableXPC: false)
        super.init()
        self.listener.delegate = self
        self.listener.resume()
    }
    
    // MARK: - NSXPCListenerDelegate
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: KeychainServiceXPCProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }
    
    // MARK: - KeychainServiceXPCProtocol
    
    func addItem(_ data: Data,
                account: String,
                service: String,
                accessGroup: String?,
                accessibility: String,
                flags: UInt) async throws {
        let cfAccessibility = accessibility as CFString
        let secFlags = SecAccessControlCreateFlags(rawValue: flags)
        try await self.service.addItem(data,
                                     account: account,
                                     service: service,
                                     accessGroup: accessGroup,
                                     accessibility: cfAccessibility,
                                     flags: secFlags)
    }
    
    func updateItem(_ data: Data,
                   account: String,
                   service: String,
                   accessGroup: String?) async throws {
        try await self.service.updateItem(data,
                                        account: account,
                                        service: service,
                                        accessGroup: accessGroup)
    }
    
    func deleteItem(account: String,
                   service: String,
                   accessGroup: String?) async throws {
        try await self.service.deleteItem(account: account,
                                        service: service,
                                        accessGroup: accessGroup)
    }
    
    func readItem(account: String,
                 service: String,
                 accessGroup: String?) async throws -> Data {
        try await self.service.readItem(account: account,
                                      service: service,
                                      accessGroup: accessGroup)
    }
    
    func containsItem(account: String,
                     service: String,
                     accessGroup: String?) async -> Bool {
        await self.service.containsItem(account: account,
                                      service: service,
                                      accessGroup: accessGroup)
    }
}

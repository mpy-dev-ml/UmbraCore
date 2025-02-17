import Foundation
import Security

/// Service for managing secure keychain access
public actor KeychainService: KeychainServiceProtocol {
    private let xpcService: KeychainXPCService?
    private let accessGroup: String?

    public init(enableXPC: Bool = true, accessGroup: String? = nil) {
        self.xpcService = enableXPC ? KeychainXPCService() : nil
        self.accessGroup = accessGroup

        if enableXPC {
            self.xpcService?.start()

            // Wait for XPC service to start
            if let service = self.xpcService, !service.waitForStartup(timeout: 5.0) {
                print("Warning: XPC service failed to start, falling back to direct keychain access")
            }
        }
    }

    deinit {
        xpcService?.stop()
    }

    public func addItem(_ data: Data,
                       account: String,
                       service: String,
                       accessGroup: String? = nil,
                       accessibility: CFString = kSecAttrAccessibleWhenUnlocked,
                       flags: SecAccessControlCreateFlags = []) async throws {
        // Create SecAccessControl
        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            accessibility,
            flags,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                print("Failed to create access control: \(error)")
            }
            throw KeychainError.unexpectedStatus(errSecParam)
        }

        // Create query with access control
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: access
        ]

        // Add access group if specified
        if let accessGroup = accessGroup ?? self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        // Try to add the item
        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw KeychainError.duplicateItem
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    public func updateItem(_ data: Data,
                         account: String,
                         service: String,
                         accessGroup: String? = nil) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup = accessGroup ?? self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            // Handle common error cases
            switch status {
            case errSecMissingEntitlement:
                throw KeychainError.unexpectedStatus(status)
            case errSecDecode:
                throw KeychainError.invalidData
            default:
                throw KeychainError.unexpectedStatus(status)
            }
        }
    }

    public func deleteItem(account: String,
                         service: String,
                         accessGroup: String? = nil) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup = accessGroup ?? self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound {
            return // Item already deleted, no need to throw
        }
        guard status == errSecSuccess else {
            // Handle common error cases
            switch status {
            case errSecMissingEntitlement:
                throw KeychainError.unexpectedStatus(status)
            default:
                throw KeychainError.unexpectedStatus(status)
            }
        }
    }

    public func readItem(account: String,
                       service: String,
                       accessGroup: String? = nil) async throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]

        if let accessGroup = accessGroup ?? self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            // Handle common error cases
            switch status {
            case errSecMissingEntitlement:
                throw KeychainError.unexpectedStatus(status)
            case errSecDecode:
                throw KeychainError.invalidData
            default:
                throw KeychainError.unexpectedStatus(status)
            }
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    public func containsItem(account: String,
                          service: String,
                          accessGroup: String? = nil) async -> Bool {
        do {
            _ = try await readItem(account: account,
                                service: service,
                                accessGroup: accessGroup)
            return true
        } catch KeychainError.itemNotFound {
            return false
        } catch {
            // Log other errors but return false
            print("Warning: Error checking keychain item: \(error)")
            return false
        }
    }
}

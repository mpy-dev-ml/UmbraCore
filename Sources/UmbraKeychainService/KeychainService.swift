import Foundation
import Security
import SwiftyBeaver
import UmbraLogging

/// A service for secure keychain operations
public final class KeychainService {
    private let queue = DispatchQueue(label: "com.umbracore.keychain")
    private let log = SwiftyBeaver.self

    /// Add a new item to the keychain
    /// - Parameters:
    ///   - account: The account name
    ///   - service: The service name
    ///   - accessGroup: Optional access group
    ///   - data: The data to store
    /// - Throws: KeychainError if the operation fails
    public func addItem(account: String, service: String, accessGroup: String?, data: Data) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            let error = convertError(status)
            log.error("Failed to add keychain item", context: [
                "error": String(describing: error),
                "status": String(status),
                "operation": "addItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw error
        }

        log.info("Successfully added keychain item", context: [
            "operation": "addItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
    }

    /// Update an existing item in the keychain
    /// - Parameters:
    ///   - account: The account name
    ///   - service: The service name
    ///   - accessGroup: Optional access group
    ///   - data: The new data to store
    /// - Throws: KeychainError if the operation fails
    public func updateItem(account: String, service: String, accessGroup: String?, data: Data) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            let error = convertError(status)
            log.error("Failed to update keychain item", context: [
                "error": String(describing: error),
                "status": String(status),
                "operation": "updateItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw error
        }

        log.info("Successfully updated keychain item", context: [
            "operation": "updateItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
    }

    /// Remove an item from the keychain
    /// - Parameters:
    ///   - account: The account name
    ///   - service: The service name
    ///   - accessGroup: Optional access group
    /// - Throws: KeychainError if the operation fails
    public func removeItem(account: String, service: String, accessGroup: String?) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            let error = convertError(status)
            log.error("Failed to remove keychain item", context: [
                "error": String(describing: error),
                "status": String(status),
                "operation": "removeItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw error
        }

        log.info("Successfully removed keychain item", context: [
            "operation": "removeItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
    }

    /// Check if an item exists in the keychain
    /// - Parameters:
    ///   - account: The account name
    ///   - service: The service name
    ///   - accessGroup: Optional access group
    /// - Returns: true if the item exists, false otherwise
    /// - Throws: KeychainError if the operation fails
    public func containsItem(account: String, service: String, accessGroup: String?) async throws -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: false
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            log.debug("Found keychain item", context: [
                "operation": "containsItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            return true
        case errSecItemNotFound:
            log.debug("Keychain item not found", context: [
                "operation": "containsItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            return false
        default:
            let error = convertError(status)
            log.error("Failed to check keychain item", context: [
                "error": String(describing: error),
                "status": String(status),
                "operation": "containsItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw error
        }
    }

    /// Retrieve an item from the keychain
    /// - Parameters:
    ///   - account: The account name
    ///   - service: The service name
    ///   - accessGroup: Optional access group
    /// - Returns: The stored data
    /// - Throws: KeychainError if the operation fails
    public func retrieveItem(account: String, service: String, accessGroup: String?) async throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            let error = convertError(status)
            log.error("Failed to retrieve keychain item", context: [
                "error": String(describing: error),
                "status": String(status),
                "operation": "retrieveItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw error
        }

        guard let data = result as? Data else {
            log.error("Invalid data format in keychain item", context: [
                "error": String(describing: KeychainError.invalidData),
                "operation": "retrieveItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            throw KeychainError.invalidData
        }

        log.info("Successfully retrieved keychain item", context: [
            "operation": "retrieveItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])

        return data
    }

    /// Convert an OSStatus to a KeychainError
    private func convertError(_ status: OSStatus) -> KeychainError {
        switch Int32(status) {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDuplicateItem:
            return .duplicateItem
        case errSecInvalidData:
            return .invalidData
        case -25_293: // errSecAccessDenied
            return .accessDenied
        default:
            return .unexpectedStatus(status)
        }
    }
}

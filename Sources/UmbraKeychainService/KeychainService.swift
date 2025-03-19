import Foundation
import Security
import UmbraLogging

/// A thread-safe service for managing secure keychain operations.
///
/// `KeychainService` provides a safe interface for storing and retrieving sensitive data
/// from the system keychain. It handles all common keychain operations and provides
/// detailed error information when operations fail.
///
/// Example:
/// ```swift
/// let service = KeychainService()
/// try await service.addItem(
///     account: "user@example.com",
///     service: "com.example.app",
///     accessGroup: nil,
///     data: "secret".data(using: .utf8)!
/// )
/// ```
public actor KeychainService {
    /// Logger instance for tracking operations.
    private let logger: LoggingProtocol

    /// Creates a new keychain service instance.
    public init(logger: LoggingProtocol) {
        self.logger = logger
    }

    /// Adds a new item to the keychain.
    ///
    /// - Parameters:
    ///   - account: The account identifier for the item.
    ///   - service: The service identifier for the item.
    ///   - accessGroup: Optional access group for sharing items between apps.
    ///   - data: The sensitive data to store.
    /// - Throws: `KeychainError` if the operation fails, with specific error information.
    public func addItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data
    ) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            let error = convertError(status)
            let metadata = LogMetadata([
                "error": String(describing: error),
                "status": String(status),
                "operation": "addItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            await logger.error("Failed to add keychain item", metadata: metadata)
            throw error
        }

        let metadata = LogMetadata([
            "operation": "addItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
        await logger.info("Successfully added keychain item", metadata: metadata)
    }

    /// Updates an existing item in the keychain.
    ///
    /// - Parameters:
    ///   - account: The account identifier for the item.
    ///   - service: The service identifier for the item.
    ///   - accessGroup: Optional access group for sharing items between apps.
    ///   - data: The new sensitive data to store.
    /// - Throws: `KeychainError` if the operation fails, with specific error information.
    public func updateItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data
    ) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            let error = convertError(status)
            let metadata = LogMetadata([
                "error": String(describing: error),
                "status": String(status),
                "operation": "updateItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            await logger.error("Failed to update keychain item", metadata: metadata)
            throw error
        }

        let metadata = LogMetadata([
            "operation": "updateItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
        await logger.info("Successfully updated keychain item", metadata: metadata)
    }

    /// Removes an item from the keychain.
    ///
    /// - Parameters:
    ///   - account: The account identifier for the item.
    ///   - service: The service identifier for the item.
    ///   - accessGroup: Optional access group for sharing items between apps.
    /// - Throws: `KeychainError` if the operation fails, with specific error information.
    public func removeItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            let error = convertError(status)
            let metadata = LogMetadata([
                "error": String(describing: error),
                "status": String(status),
                "operation": "removeItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            await logger.error("Failed to remove keychain item", metadata: metadata)
            throw error
        }

        let metadata = LogMetadata([
            "operation": "removeItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
        await logger.info("Successfully removed keychain item", metadata: metadata)
    }

    /// Checks if an item exists in the keychain.
    ///
    /// - Parameters:
    ///   - account: The account identifier to check.
    ///   - service: The service identifier to check.
    ///   - accessGroup: Optional access group for shared items.
    /// - Returns: `true` if the item exists, `false` otherwise.
    /// - Throws: `KeychainError` if the query operation fails.
    public func containsItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: false
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            // Item exists if errSecSuccess, doesn't exist if errSecItemNotFound
            return status == errSecSuccess
        default:
            let error = convertError(status)
            let metadata = LogMetadata([
                "error": String(describing: error),
                "status": String(status),
                "operation": "containsItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            await logger.error("Failed to check keychain item existence", metadata: metadata)
            throw error
        }
    }

    /// Retrieves an item from the keychain.
    ///
    /// - Parameters:
    ///   - account: The account identifier for the item.
    ///   - service: The service identifier for the item.
    ///   - accessGroup: Optional access group for sharing items between apps.
    /// - Returns: The stored sensitive data.
    /// - Throws: `KeychainError` if the operation fails, with specific error information.
    public func retrieveItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            let error = convertError(status)
            let metadata = LogMetadata([
                "error": String(describing: error),
                "status": String(status),
                "operation": "retrieveItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none"
            ])
            await logger.error("Failed to retrieve keychain item", metadata: metadata)
            throw error
        }

        guard let data = result as? Data else {
            let metadata = LogMetadata([
                "operation": "retrieveItem",
                "account": account,
                "service": service,
                "accessGroup": accessGroup ?? "none",
                "resultType": String(describing: type(of: result))
            ])
            await logger.error("Retrieved keychain item is not Data", metadata: metadata)
            throw KeychainError.unexpectedData
        }

        let metadata = LogMetadata([
            "operation": "retrieveItem",
            "account": account,
            "service": service,
            "accessGroup": accessGroup ?? "none"
        ])
        await logger.info("Successfully retrieved keychain item", metadata: metadata)
        return data
    }

    /// Converts a `SecItemError` to a `KeychainError`.
    private func convertError(_ status: OSStatus) -> KeychainError {
        switch status {
        case errSecDuplicateItem:
            .duplicateItem
        case errSecItemNotFound:
            .itemNotFound
        case errSecAuthFailed:
            .authenticationFailed
        default:
            .unhandledError(status: status)
        }
    }
}

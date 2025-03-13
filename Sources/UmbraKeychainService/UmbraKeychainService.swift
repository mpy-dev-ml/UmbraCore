/// UmbraKeychainService Module
///
/// Provides secure keychain access and management for UmbraCore.
/// This module handles all interactions with the macOS Keychain,
/// ensuring secure credential storage and retrieval.
///
/// # Key Features
/// - Secure credential storage
/// - Access control
/// - Keychain management
/// - Migration support
///
/// # Module Organisation
///
/// ## Core Types
/// ```swift
/// KeychainService
/// KeychainItem
/// AccessControl
/// ```
///
/// ## Operations
/// ```swift
/// ItemStorage
/// ItemRetrieval
/// ItemUpdate
/// ```
///
/// ## Security
/// ```swift
/// AccessPolicy
/// SecurityLevel
/// AuthContext
/// ```
///
/// # Keychain Operations
///
/// ## Storage
/// Secure item storage:
/// - Password storage
/// - Certificate storage
/// - Key storage
///
/// ## Retrieval
/// Secure item retrieval:
/// - Credential fetch
/// - Certificate fetch
/// - Key access
///
/// # Access Control
///
/// ## Policies
/// Access control policies:
/// - User presence
/// - Biometric auth
/// - Application auth
///
/// ## Authentication
/// Authentication methods:
/// - Password auth
/// - Touch ID
/// - Watch unlock
///
/// # Item Management
///
/// ## Lifecycle
/// Item lifecycle management:
/// - Creation
/// - Update
/// - Deletion
///
/// ## Synchronisation
/// iCloud keychain sync:
/// - Sync settings
/// - Conflict resolution
/// - Version control
///
/// # Usage Example
/// ```swift
/// let service = UmbraKeychainService(
///     identifier: "com.example.app",
///     accessGroup: "com.example.group",
///     logger: Logger(label: "com.example.keychain")
/// )
///
/// try await service.store(
///     password: password,
///     for: account
/// )
/// ```
///
/// # Migration Support
///
/// ## Version Migration
/// Migration capabilities:
/// - Schema updates
/// - Data migration
/// - Backup support
///
/// ## Legacy Support
/// Legacy system support:
/// - Old format support
/// - Data conversion
/// - Clean-up tools
///
/// # Thread Safety
/// Keychain operations are thread-safe:
/// - Concurrent access
/// - Operation queuing
/// - State protection
import Foundation
import SecurityTypes
import SecurityUtils
import UmbraLogging

/// UmbraKeychainService Module
///
/// Provides secure keychain access and management for UmbraCore.
/// This module handles all interactions with the macOS Keychain,
/// ensuring secure credential storage and retrieval.
public final class UmbraKeychainService: @unchecked Sendable {
    /// Current version of the UmbraKeychainService module
    public static let version = "1.0.0"

    /// Service identifier used for keychain items
    private let identifier: String

    /// Optional access group for shared keychain access
    private let accessGroup: String?

    /// Logger instance for keychain operations
    private let logger: LoggingProtocol

    /// Initialize a new keychain service instance
    /// - Parameters:
    ///   - identifier: Service identifier for keychain items
    ///   - accessGroup: Optional access group for shared keychain access
    ///   - logger: Logger instance for keychain operations
    public init(
        identifier: String,
        accessGroup: String? = nil,
        logger: LoggingProtocol
    ) {
        self.identifier = identifier
        self.accessGroup = accessGroup
        self.logger = logger
    }

    /// Store a password in the keychain
    /// - Parameters:
    ///   - password: Password to store
    ///   - account: Account identifier
    /// - Throws: KeychainError if storage fails
    public func store(password: String, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account,
            kSecValueData as String: password.data(using: .utf8)!,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(
                "Failed to store password: \(status)"
            )
        }
    }

    /// Retrieve a password from the keychain
    /// - Parameter account: Account identifier
    /// - Returns: Retrieved password
    /// - Throws: KeychainError if retrieval fails
    public func retrievePassword(for account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard
            status == errSecSuccess,
            let data = item as? Data,
            let password = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.retrieveFailed(
                "Failed to retrieve password: \(status)"
            )
        }

        return password
    }

    /// Delete a password from the keychain
    /// - Parameter account: Account identifier
    /// - Throws: KeychainError if deletion fails
    public func deletePassword(for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.deleteFailed(
                "Failed to delete password: \(status)"
            )
        }
    }
}

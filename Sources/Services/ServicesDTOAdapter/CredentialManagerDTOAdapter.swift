import CoreDTOs
import ErrorHandling
import Foundation
import UmbraCoreTypes

/// An adapter that converts between CredentialManager API and DTOs
public struct CredentialManagerDTOAdapter {
    // MARK: - Properties

    /// Access to the credential manager
    private let credentialManager: any CredentialManaging

    // MARK: - Initialization

    /// Initialize the adapter with a credential manager
    /// - Parameter credentialManager: The credential manager to adapt
    public init(credentialManager: any CredentialManaging) {
        self.credentialManager = credentialManager
    }

    /// Initialize the adapter with the shared credential manager
    public init() {
        // This assumes that CredentialManager conforms to CredentialManaging
        // If it doesn't, this will need to be modified
        credentialManager = CredentialManager.shared
    }

    // MARK: - Public Methods

    /// Store a credential using security configuration
    /// - Parameters:
    ///   - credential: The credential data
    ///   - config: Security configuration for the operation
    /// - Returns: A result indicating success or failure
    public func storeCredential(
        _ credential: [UInt8],
        config: SecurityConfigDTO
    ) async throws -> OperationResultDTO<Void> {
        do {
            // Extract service and account from config options
            guard let service = config.options["service"],
                  let account = config.options["account"]
            else {
                return .failure(
                    .init(
                        error: SecurityErrorDTO.storageError(
                            message: "Missing service or account in configuration",
                            details: ["service": config.options["service"] ?? "missing",
                                      "account": config.options["account"] ?? "missing"]
                        )
                    )
                )
            }

            // Convert [UInt8] to Data
            let credentialData = Data(credential)

            // Store the credential
            try await credentialManager.store(credentialData, service: service, account: account)

            // Return success
            return .success(())
        } catch let error as CredentialError {
            // Map CredentialError to SecurityErrorDTO
            let securityError = mapCredentialError(error)
            return .failure(.init(error: securityError))
        } catch {
            // Map other errors to SecurityErrorDTO
            let securityError = SecurityErrorDTO(
                code: Int32(error._code),
                domain: "credential.unknown",
                message: "Unknown credential error: \(error.localizedDescription)",
                details: ["originalError": "\(error)"]
            )
            return .failure(.init(error: securityError))
        }
    }

    /// Retrieve a credential using security configuration
    /// - Parameter config: Security configuration for the operation
    /// - Returns: A result containing the credential or an error
    public func retrieveCredential(
        config: SecurityConfigDTO
    ) async throws -> OperationResultDTO<[UInt8]> {
        do {
            // Extract service and account from config options
            guard let service = config.options["service"],
                  let account = config.options["account"]
            else {
                return .failure(
                    .init(
                        error: SecurityErrorDTO.storageError(
                            message: "Missing service or account in configuration",
                            details: ["service": config.options["service"] ?? "missing",
                                      "account": config.options["account"] ?? "missing"]
                        )
                    )
                )
            }

            // Retrieve the credential
            let data = try await credentialManager.retrieve(service: service, account: account)

            // Convert Data to [UInt8]
            let credential = [UInt8](data)

            // Return success with the credential
            return .success(credential)
        } catch let error as CredentialError {
            // Map CredentialError to SecurityErrorDTO
            let securityError = mapCredentialError(error)
            return .failure(.init(error: securityError))
        } catch {
            // Map other errors to SecurityErrorDTO
            let securityError = SecurityErrorDTO(
                code: Int32(error._code),
                domain: "credential.unknown",
                message: "Unknown credential error: \(error.localizedDescription)",
                details: ["originalError": "\(error)"]
            )
            return .failure(.init(error: securityError))
        }
    }

    /// Delete a credential using security configuration
    /// - Parameter config: Security configuration for the operation
    /// - Returns: A result indicating success or failure
    public func deleteCredential(
        config: SecurityConfigDTO
    ) async throws -> OperationResultDTO<Void> {
        do {
            // Extract service and account from config options
            guard let service = config.options["service"],
                  let account = config.options["account"]
            else {
                return .failure(
                    .init(
                        error: SecurityErrorDTO.storageError(
                            message: "Missing service or account in configuration",
                            details: ["service": config.options["service"] ?? "missing",
                                      "account": config.options["account"] ?? "missing"]
                        )
                    )
                )
            }

            // Delete the credential
            try await credentialManager.delete(service: service, account: account)

            // Return success
            return .success(())
        } catch let error as CredentialError {
            // Map CredentialError to SecurityErrorDTO
            let securityError = mapCredentialError(error)
            return .failure(.init(error: securityError))
        } catch {
            // Map other errors to SecurityErrorDTO
            let securityError = SecurityErrorDTO(
                code: Int32(error._code),
                domain: "credential.unknown",
                message: "Unknown credential error: \(error.localizedDescription)",
                details: ["originalError": "\(error)"]
            )
            return .failure(.init(error: securityError))
        }
    }

    // MARK: - Private Methods

    /// Map CredentialError to SecurityErrorDTO
    /// - Parameter error: The CredentialError to map
    /// - Returns: A SecurityErrorDTO representation of the error
    private func mapCredentialError(_ error: CredentialError) -> SecurityErrorDTO {
        switch error {
        case let .storeFailed(status):
            SecurityErrorDTO.storageError(
                message: "Failed to store credential",
                details: ["osStatus": "\(status)"]
            )
        case let .retrieveFailed(status):
            SecurityErrorDTO.accessError(
                message: "Failed to retrieve credential",
                details: ["osStatus": "\(status)"]
            )
        case let .deleteFailed(status):
            SecurityErrorDTO.storageError(
                message: "Failed to delete credential",
                details: ["osStatus": "\(status)"]
            )
        case .invalidData:
            SecurityErrorDTO.storageError(
                message: "Invalid credential data",
                details: [:]
            )
        }
    }
}

// MARK: - Factory Methods

public extension SecurityConfigDTO {
    /// Create a configuration for credential operations
    /// - Parameters:
    ///   - service: The service identifier
    ///   - account: The account identifier
    /// - Returns: A SecurityConfigDTO configured for credential operations
    static func credential(service: String, account: String) -> SecurityConfigDTO {
        SecurityConfigDTO(
            algorithm: "Keychain",
            keySizeInBits: 256,
            options: ["service": service, "account": account]
        )
    }
}

// MARK: - Protocol Definition

/// Protocol for credential management
/// This allows us to abstract the CredentialManager for testing and dependency injection
public protocol CredentialManaging: AnyActor {
    /// Store a credential
    /// - Parameters:
    ///   - credential: The credential to store
    ///   - service: The service identifier
    ///   - account: The account identifier
    func store(_ credential: Data, service: String, account: String) throws

    /// Retrieve a credential
    /// - Parameters:
    ///   - service: The service identifier
    ///   - account: The account identifier
    /// - Returns: The credential data
    func retrieve(service: String, account: String) throws -> Data

    /// Delete a credential
    /// - Parameters:
    ///   - service: The service identifier
    ///   - account: The account identifier
    func delete(service: String, account: String) throws
}

// MARK: - CredentialError

/// Errors that can occur during credential operations
public enum CredentialError: LocalizedError {
    /// Failed to store the credential
    case storeFailed(OSStatus)
    /// Failed to retrieve the credential
    case retrieveFailed(OSStatus)
    /// Failed to delete the credential
    case deleteFailed(OSStatus)
    /// The credential data is invalid
    case invalidData

    public var errorDescription: String? {
        switch self {
        case let .storeFailed(status):
            "Failed to store credential: \(status)"
        case let .retrieveFailed(status):
            "Failed to retrieve credential: \(status)"
        case let .deleteFailed(status):
            "Failed to delete credential: \(status)"
        case .invalidData:
            "Invalid credential data"
        }
    }
}

// MARK: - CredentialManager conformance to CredentialManaging

/// Extend CredentialManager to conform to CredentialManaging
public final actor CredentialManager: CredentialManaging {
    /// Shared instance of the credential manager
    public static let shared = CredentialManager()

    private init() {}

    /// Store a credential in the keychain
    /// - Parameters:
    ///   - credential: The credential to store
    ///   - service: The service identifier
    ///   - account: The account identifier
    public func store(_ credential: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: credential,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CredentialError.storeFailed(status)
        }
    }

    /// Retrieve a credential from the keychain
    /// - Parameters:
    ///   - service: The service identifier
    ///   - account: The account identifier
    /// - Returns: The stored credential
    public func retrieve(service: String, account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw CredentialError.retrieveFailed(status)
        }

        guard let data = result as? Data else {
            throw CredentialError.invalidData
        }

        return data
    }

    /// Delete a credential from the keychain
    /// - Parameters:
    ///   - service: The service identifier
    ///   - account: The account identifier
    public func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw CredentialError.deleteFailed(status)
        }
    }
}

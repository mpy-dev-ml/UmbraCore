// CryptoKit removed - cryptography will be handled in ResticBar
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
    private let keychain: any SecureStorageProtocol
    private let config: CryptoConfig

    public init(service: String, config: CryptoConfig) {
        keychain = KeychainAccess(service: service)
        self.config = config
    }

    /// Save a credential securely
    /// - Parameters:
    ///   - identifier: Identifier for the credential
    ///   - data: Data to store
    public func save(_ data: Data, forIdentifier identifier: String) async throws {
        let secureBytes = SecureBytes(bytes: [UInt8](data))
        let result = await keychain.storeSecurely(data: secureBytes, identifier: identifier)

        switch result {
        case .success:
            return
        case let .failure(error):
            throw mapKeyStorageError(error)
        @unknown default:
            throw UmbraErrors.Security.Core.secureStorageFailed(
                operation: "save",
                reason: "Unknown result state"
            )
        }
    }

    /// Retrieve a credential
    /// - Parameter identifier: Identifier for the credential
    /// - Returns: Stored data
    public func retrieve(forIdentifier identifier: String) async throws -> Data {
        let result = await keychain.retrieveSecurely(identifier: identifier)

        switch result {
        case let .success(secureBytes):
            // Convert SecureBytes to Data using Array initializer
            return Data(Array(secureBytes))
        case let .failure(error):
            throw mapKeyStorageError(error)
        @unknown default:
            throw UmbraErrors.Security.Core.secureStorageFailed(
                operation: "retrieve",
                reason: "Unknown result state"
            )
        }
    }

    /// Delete a credential
    /// - Parameter identifier: Identifier for the credential
    public func delete(forIdentifier identifier: String) async throws {
        let result = await keychain.deleteSecurely(identifier: identifier)
        
        switch result {
        case .success:
            return
        case let .failure(error):
            throw mapKeyStorageError(error)
        @unknown default:
            throw UmbraErrors.Security.Core.secureStorageFailed(
                operation: "delete",
                reason: "Unknown result state"
            )
        }
    }
    
    /// Maps KeyStorageError to UmbraErrors.Security.Core
    private func mapKeyStorageError(_ error: KeyStorageError) -> Error {
        switch error {
        case .keyNotFound:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "retrieval",
                reason: "Key not found"
            )
        case .storageFailure:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "storage",
                reason: "Storage operation failed"
            )
        case .unknown:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "unknown",
                reason: "Unknown error occurred"
            )
        @unknown default:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "unknown",
                reason: "Unhandled error type: \(error)"
            )
        }
    }
    
    /// Maps XPCSecurityError to UmbraErrors.Security.Core
    private func mapXPCError(_ error: XPCSecurityError) -> Error {
        switch error {
        case .serviceUnavailable:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "service access",
                reason: "Service unavailable"
            )
        case let .keyNotFound(identifier):
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "retrieval",
                reason: "Key not found: \(identifier)"
            )
        case let .internalError(reason):
            return UmbraErrors.Security.Core.internalError(reason: reason)
        case let .authenticationFailed(reason):
            return UmbraErrors.Security.Core.authenticationFailed(reason: reason)
        case let .invalidState(details):
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "state validation",
                reason: details
            )
        case let .cryptographicError(operation, details):
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: operation,
                reason: details
            )
        default:
            return UmbraErrors.Security.Core.secureStorageFailed(
                operation: "unknown",
                reason: "Unhandled XPC error: \(error)"
            )
        }
    }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageProtocol {
    private let service: String
    private var items: [String: (data: SecureBytes, metadata: [String: String]?)] = [:]

    init(service: String) {
        self.service = service
    }

    func storeSecurely(data: SecureBytes, identifier: String) async -> KeyStorageResult {
        items[identifier] = (data: data, metadata: nil)
        return .success
    }

    func retrieveSecurely(identifier: String) async -> KeyRetrievalResult {
        guard let item = items[identifier] else {
            return .failure(.keyNotFound)
        }
        return .success(item.data)
    }

    func deleteSecurely(identifier: String) async -> KeyDeletionResult {
        guard items.removeValue(forKey: identifier) != nil else {
            return .failure(.keyNotFound)
        }
        return .success
    }
}

// CryptoKit removed - cryptography will be handled in ResticBar
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
    private let keychain: any SecureStorageServiceProtocol
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
        let result = await keychain.storeData(secureBytes, identifier: identifier, metadata: nil)

        switch result {
        case .success:
            return
        case let .failure(error):
            throw mapXPCError(error)
        }
    }

    /// Retrieve a credential
    /// - Parameter identifier: Identifier for the credential
    /// - Returns: Stored data
    public func retrieve(forIdentifier identifier: String) async throws -> Data {
        let result = await keychain.retrieveData(identifier: identifier)

        switch result {
        case let .success(secureBytes):
            // Convert SecureBytes to Data using Array initializer
            return Data(Array(secureBytes))
        case let .failure(error):
            throw mapXPCError(error)
        }
    }

    /// Delete a credential
    /// - Parameter identifier: Identifier for the credential
    public func delete(forIdentifier identifier: String) async throws {
        let result = await keychain.deleteData(identifier: identifier)

        switch result {
        case .success:
            return
        case let .failure(error):
            throw mapXPCError(error)
        }
    }

    /// Maps XPC security errors to UmbraErrors.Security.Core
    private func mapXPCError(_ error: XPCSecurityError) -> Error {
        switch error {
        case let .keyNotFound(identifier):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "retrieval",
                reason: "Item \(identifier) not found"
            )
        case let .internalError(reason):
            UmbraErrors.Security.Core.internalError(reason: reason)
        case let .authorizationDenied(operation):
            UmbraErrors.Security.Core
                .authorizationFailed(reason: "Access denied for operation: \(operation)")
        case let .invalidInput(details):
            UmbraErrors.Security.Core.secureStorageFailed(operation: "validation", reason: details)
        case let .cryptographicError(operation, details):
            UmbraErrors.Security.Core.secureStorageFailed(operation: operation, reason: details)
        case let .authenticationFailed(reason):
            UmbraErrors.Security.Core.authenticationFailed(reason: reason)
        case .connectionInterrupted:
            UmbraErrors.Security.Core.secureConnectionFailed(reason: "Connection interrupted")
        case let .connectionInvalidated(reason):
            UmbraErrors.Security.Core.secureConnectionFailed(reason: reason)
        case .serviceUnavailable:
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "service access",
                reason: "Service unavailable"
            )
        case let .serviceNotReady(reason):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "service access",
                reason: "Service not ready: \(reason)"
            )
        case let .timeout(interval):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "timeout",
                reason: "Operation timed out after \(interval) seconds"
            )
        case let .invalidState(details):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "state validation",
                reason: details
            )
        case let .invalidKeyType(expected, received):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: "key validation",
                reason: "Expected \(expected), received \(received)"
            )
        case let .operationNotSupported(name):
            UmbraErrors.Security.Core.secureStorageFailed(
                operation: name,
                reason: "Operation not supported"
            )
        default:
            UmbraErrors.Security.Core.internalError(reason: "Unexpected XPC error: \(error)")
        }
    }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageServiceProtocol {
    private let service: String
    private var items: [String: (data: SecureBytes, metadata: [String: String]?)] = [:]

    init(service: String) {
        self.service = service
    }

    func storeData(
        _ data: SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, XPCSecurityError> {
        items[identifier] = (data: data, metadata: metadata)
        return .success(())
    }

    func retrieveData(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        guard let item = items[identifier] else {
            return .failure(.keyNotFound(identifier: identifier))
        }
        return .success(item.data)
    }

    func deleteData(identifier: String) async -> Result<Void, XPCSecurityError> {
        guard items.removeValue(forKey: identifier) != nil else {
            return .failure(.keyNotFound(identifier: identifier))
        }
        return .success(())
    }

    func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
        .success(Array(items.keys))
    }

    func getDataMetadata(for identifier: String) async
        -> Result<[String: String]?, XPCSecurityError> {
        guard let item = items[identifier] else {
            return .failure(.keyNotFound(identifier: identifier))
        }
        return .success(item.metadata)
    }
}

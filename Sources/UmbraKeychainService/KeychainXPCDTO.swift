import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// DTOs used for KeychainXPCService operations
public enum KeychainXPCDTO {
    /// Request to store data in keychain
    public struct StoreRequest: Codable, Sendable {
        /// Service identifier
        public let service: String
        /// Data identifier
        public let identifier: String
        /// Access group (optional for testing)
        public let accessGroup: String?
        /// Data to store
        public let data: SecureBytes

        /// Initialize a store request
        /// - Parameters:
        ///   - service: Service identifier
        ///   - identifier: Data identifier
        ///   - accessGroup: Access group (optional for testing)
        ///   - data: Data to store
        public init(service: String, identifier: String, accessGroup: String? = nil, data: SecureBytes) {
            self.service = service
            self.identifier = identifier
            self.accessGroup = accessGroup
            self.data = data
        }
    }

    /// Request to retrieve data from keychain
    public struct RetrieveRequest: Codable, Sendable {
        /// Service identifier
        public let service: String
        /// Data identifier
        public let identifier: String
        /// Access group (optional for testing)
        public let accessGroup: String?

        /// Initialize a retrieve request
        /// - Parameters:
        ///   - service: Service identifier
        ///   - identifier: Data identifier
        ///   - accessGroup: Access group (optional for testing)
        public init(service: String, identifier: String, accessGroup: String? = nil) {
            self.service = service
            self.identifier = identifier
            self.accessGroup = accessGroup
        }
    }

    /// Request to delete data from keychain
    public struct DeleteRequest: Codable, Sendable {
        /// Service identifier
        public let service: String
        /// Data identifier
        public let identifier: String
        /// Access group (optional for testing)
        public let accessGroup: String?

        /// Initialize a delete request
        /// - Parameters:
        ///   - service: Service identifier
        ///   - identifier: Data identifier
        ///   - accessGroup: Access group (optional for testing)
        public init(service: String, identifier: String, accessGroup: String? = nil) {
            self.service = service
            self.identifier = identifier
            self.accessGroup = accessGroup
        }
    }

    /// Result of a keychain operation
    public enum OperationResult: Sendable {
        /// Operation succeeded
        case success
        /// Operation succeeded with data
        case successWithData(SecureBytes)
        /// Operation failed with error
        case failure(KeychainOperationError)
    }

    /// Error type for keychain operations
    public enum KeychainOperationError: Error, Sendable {
        /// Item not found
        case itemNotFound
        /// Duplicate item found
        case duplicateItem
        /// Authentication failed
        case authenticationFailed
        /// Internal error with message
        case internalError(String)
        /// Service unavailable
        case serviceUnavailable
    }
}

/// Protocol extension to convert keychain errors to XPC errors
public extension KeychainXPCDTO.KeychainOperationError {
    /// Convert to XPC security error
    /// - Returns: The XPC security error
    func toSecurityProtocolsError() -> ErrorHandlingDomains.UmbraErrors.Security.Protocols {
        switch self {
        case .duplicateItem:
            return .internalError("Duplicate item exists")
        case .itemNotFound:
            return .missingProtocolImplementation(protocolName: "KeychainOperation")
        case let .internalError(message):
            return .internalError(message)
        case .serviceUnavailable:
            return .invalidState(state: "unavailable", expectedState: "available")
        case .authenticationFailed:
            return .invalidInput("Authentication failed")
        }
    }
}

/// Protocol extension to convert XPC errors to keychain errors
public extension ErrorHandlingDomains.UmbraErrors.Security.Protocols {
    /// Convert to keychain operation error
    /// - Returns: The keychain operation error
    func toKeychainOperationError() -> KeychainXPCDTO.KeychainOperationError {
        switch self {
        case .missingProtocolImplementation:
            return .itemNotFound
        case .invalidInput where description.contains("Authentication"):
            return .authenticationFailed
        case let .invalidState(state, _) where state == "unavailable":
            return .serviceUnavailable
        case let .internalError(description):
            return .internalError(description)
        default:
            return .internalError("Unknown XPC security error: \(self)")
        }
    }
}

/// Extension to map KeyStorageError to KeychainOperationError
public extension KeyStorageError {
    /// Convert to KeychainXPCDTO.KeychainOperationError
    func toKeychainOperationError() -> KeychainXPCDTO.KeychainOperationError {
        switch self {
        case .keyNotFound:
            return .itemNotFound
        case .storageFailure:
            return .authenticationFailed
        case .unknown:
            return .internalError("Unknown storage error")
        @unknown default:
            return .internalError("Unexpected storage error")
        }
    }
}

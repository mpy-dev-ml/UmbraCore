import Foundation
import XPCProtocolsCore
import SecurityProtocolsCore

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

/// Map KeychainXPCDTO.KeychainOperationError to XPCSecurityError
extension KeychainXPCDTO.KeychainOperationError {
    /// Convert to XPCSecurityError
    public func toXPCSecurityError() -> XPCSecurityError {
        switch self {
        case .itemNotFound:
            return .keyNotFound(identifier: "unknown")
        case .duplicateItem:
            return .internalError(reason: "A duplicate item was found")
        case .authenticationFailed:
            return .authenticationFailed(reason: "Authentication failed")
        case .internalError(let message):
            return .internalError(reason: message)
        case .serviceUnavailable:
            return .serviceUnavailable
        }
    }
}

/// Map XPCSecurityError to KeychainXPCDTO.KeychainOperationError
extension XPCSecurityError {
    /// Convert to KeychainXPCDTO.KeychainOperationError
    public func toKeychainOperationError() -> KeychainXPCDTO.KeychainOperationError {
        switch self {
        case .keyNotFound:
            return .itemNotFound
        case .authenticationFailed:
            return .authenticationFailed
        case .serviceUnavailable:
            return .serviceUnavailable
        case .internalError(let reason):
            return .internalError(reason)
        default:
            return .internalError("Unknown XPC security error: \(self)")
        }
    }
}

/// Extension to map KeyStorageError to KeychainOperationError
extension KeyStorageError {
    /// Convert to KeychainXPCDTO.KeychainOperationError
    public func toKeychainOperationError() -> KeychainXPCDTO.KeychainOperationError {
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

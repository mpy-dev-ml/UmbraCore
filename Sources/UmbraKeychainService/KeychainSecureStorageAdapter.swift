import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Adapter that allows KeychainXPCService to conform to SecureStorageProtocol
@available(macOS 14.0, *)
public final class KeychainSecureStorageAdapter: SecureStorageProtocol {
    private let service: KeychainXPCService
    
    /// Initialize the adapter with a KeychainXPCService
    /// - Parameter service: The keychain XPC service to adapt
    public init(service: KeychainXPCService) {
        self.service = service
    }
    
    /// Initialize the adapter with a service identifier
    /// - Parameter service: The service identifier to use for the keychain service
    public convenience init(service: String) {
        self.init(service: KeychainXPCService(serviceIdentifier: service))
    }
    
    /// Stores data securely with the given identifier
    /// - Parameters:
    ///   - data: The data to store as SecureBytes
    ///   - identifier: A unique identifier for later retrieval
    /// - Returns: Result of the storage operation
    public func storeSecurely(data: SecureBytes, identifier: String) async -> KeyStorageResult {
        let result = await service.storeSecureData(data, key: identifier)
        switch result {
        case .success:
            return .success
        case .failure(let error):
            return .failure(mapXPCErrorToKeyStorageError(error))
        }
    }
    
    /// Retrieves data securely by its identifier
    /// - Parameter identifier: The unique identifier for the data
    /// - Returns: The retrieved data or an error
    public func retrieveSecurely(identifier: String) async -> KeyRetrievalResult {
        let result = await service.retrieveSecureData(key: identifier)
        switch result {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return .failure(mapXPCErrorToKeyStorageError(error))
        }
    }
    
    /// Deletes data securely by its identifier
    /// - Parameter identifier: The unique identifier for the data to delete
    /// - Returns: Result of the deletion operation
    public func deleteSecurely(identifier: String) async -> KeyDeletionResult {
        let result = await service.deleteSecureData(key: identifier)
        switch result {
        case .success:
            return .success
        case .failure(let error):
            return .failure(mapXPCErrorToKeyStorageError(error))
        }
    }
    
    /// Maps XPCProtocolsCore.SecurityError to KeyStorageError
    /// - Parameter error: The XPC security error to map
    /// - Returns: The mapped KeyStorageError
    private func mapXPCErrorToKeyStorageError(_ error: XPCProtocolsCore.SecurityError) -> KeyStorageError {
        switch error {
        case .keyNotFound:
            return .keyNotFound
        case .authenticationFailed, .invalidState, .operationNotSupported, .cryptographicError, .invalidKeyType:
            return .storageFailure
        case .serviceUnavailable, .internalError:
            return .unknown
        default:
            return .unknown
        }
    }
}

/// Factory method to create a SecureStorageProtocol instance from a service identifier
/// This allows consumers to get a SecureStorageProtocol without knowing the underlying implementation
@available(macOS 14.0, *)
public func createSecureStorage(serviceIdentifier: String) -> SecureStorageProtocol {
    let service = KeychainXPCService(serviceIdentifier: serviceIdentifier)
    return KeychainSecureStorageAdapter(service: service)
}

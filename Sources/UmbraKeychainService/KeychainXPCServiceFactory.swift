import Foundation
import UmbraCoreTypes
import XPCProtocolsCore
import SecurityProtocolsCore

/// Factory for creating KeychainXPCServiceProtocol implementations
public enum KeychainXPCServiceFactory {
    /// Create a keychain XPC service with the specified service identifier
    /// - Parameter serviceIdentifier: Optional service identifier. If nil, the default identifier is used.
    /// - Returns: A KeychainXPCServiceProtocol implementation
    public static func createService(serviceIdentifier: String? = nil) -> any KeychainXPCServiceProtocol {
        return KeychainXPCServiceAdapter(service: KeychainSecureStorageAdapter(service: serviceIdentifier ?? "com.umbracore.securexpc"))
    }
    
    /// Create an in-memory keychain service for testing
    /// - Returns: A KeychainXPCServiceProtocol implementation backed by an in-memory store
    public static func createInMemoryService() -> any KeychainXPCServiceProtocol {
        return InMemoryKeychainService()
    }
}

/// Adapter that converts between the DTO protocol and the actual service
private final class KeychainXPCServiceAdapter: KeychainXPCServiceProtocol {
    private let adapter: KeychainSecureStorageAdapter
    
    init(service: KeychainSecureStorageAdapter) {
        self.adapter = service
    }
    
    func storeData(_ request: KeychainXPCDTO.StoreRequest) async -> KeychainXPCDTO.OperationResult {
        let result = await adapter.storeSecurely(data: request.data, identifier: request.identifier)
        
        switch result {
        case .success:
            return .success
        case .failure(let error):
            return .failure(error.toKeychainOperationError())
        @unknown default:
            return .failure(.internalError("Unknown storage result case"))
        }
    }
    
    func retrieveData(_ request: KeychainXPCDTO.RetrieveRequest) async -> KeychainXPCDTO.OperationResult {
        let result = await adapter.retrieveSecurely(identifier: request.identifier)
        
        switch result {
        case .success(let data):
            return .successWithData(data)
        case .failure(let error):
            return .failure(error.toKeychainOperationError())
        @unknown default:
            return .failure(.internalError("Unknown retrieval result case"))
        }
    }
    
    func deleteData(_ request: KeychainXPCDTO.DeleteRequest) async -> KeychainXPCDTO.OperationResult {
        let result = await adapter.deleteSecurely(identifier: request.identifier)
        
        switch result {
        case .success:
            return .success
        case .failure(let error):
            return .failure(error.toKeychainOperationError())
        @unknown default:
            return .failure(.internalError("Unknown deletion result case"))
        }
    }
    
    func generateRandomData(length: Int) async -> KeychainXPCDTO.OperationResult {
        // Use SecurityUtils to generate random data
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return .successWithData(SecureBytes(bytes: bytes))
    }
}

/// An in-memory implementation of KeychainXPCServiceProtocol for testing
private actor InMemoryKeychainService: KeychainXPCServiceProtocol {
    private var storage: [String: SecureBytes] = [:]
    
    func storeData(_ request: KeychainXPCDTO.StoreRequest) async -> KeychainXPCDTO.OperationResult {
        let key = "\(request.service)|\(request.identifier)"
        storage[key] = request.data
        return .success
    }
    
    func retrieveData(_ request: KeychainXPCDTO.RetrieveRequest) async -> KeychainXPCDTO.OperationResult {
        let key = "\(request.service)|\(request.identifier)"
        
        if let data = storage[key] {
            return .successWithData(data)
        } else {
            return .failure(.itemNotFound)
        }
    }
    
    func deleteData(_ request: KeychainXPCDTO.DeleteRequest) async -> KeychainXPCDTO.OperationResult {
        let key = "\(request.service)|\(request.identifier)"
        
        if storage.removeValue(forKey: key) != nil {
            return .success
        } else {
            return .failure(.itemNotFound)
        }
    }
    
    func generateRandomData(length: Int) async -> KeychainXPCDTO.OperationResult {
        // Generate random data for testing
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return .successWithData(SecureBytes(bytes: bytes))
    }
}

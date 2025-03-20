import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// Factory for creating SecureStorageProtocol implementations
public enum SecureStorageFactory {
    /// Create a SecureStorageProtocol implementation using the system keychain
    /// - Parameter serviceIdentifier: Service identifier for keychain items
    /// - Returns: A SecureStorageProtocol implementation
    @available(macOS 14.0, *)
    public static func createKeychainStorage(serviceIdentifier: String) -> any SecureStorageProtocol {
        createSecureStorage(serviceIdentifier: serviceIdentifier)
    }
    
    /// Create a SecureStorageProtocol implementation using in-memory storage (for testing)
    /// - Returns: A SecureStorageProtocol implementation
    public static func createInMemoryStorage() -> any SecureStorageProtocol {
        InMemorySecureStorage()
    }
}

/// In-memory implementation of SecureStorageProtocol for testing
private final class InMemorySecureStorage: SecureStorageProtocol {
    // Using an actor to make this thread-safe for Swift 6
    private actor StorageActor {
        var storage: [String: SecureBytes] = [:]
        
        func store(_ data: SecureBytes, for identifier: String) {
            storage[identifier] = data
        }
        
        func retrieve(for identifier: String) -> SecureBytes? {
            return storage[identifier]
        }
        
        func delete(for identifier: String) -> Bool {
            return storage.removeValue(forKey: identifier) != nil
        }
    }
    
    private let storage = StorageActor()
    
    func storeSecurely(data: SecureBytes, identifier: String) async -> KeyStorageResult {
        await storage.store(data, for: identifier)
        return .success
    }
    
    func retrieveSecurely(identifier: String) async -> KeyRetrievalResult {
        if let data = await storage.retrieve(for: identifier) {
            return .success(data)
        } else {
            return .failure(.keyNotFound)
        }
    }
    
    func deleteSecurely(identifier: String) async -> KeyDeletionResult {
        if await storage.delete(for: identifier) {
            return .success
        } else {
            return .failure(.keyNotFound)
        }
    }
}

import Foundation
import SecurityTypes

/// Mock implementation of SecureStorageProvider for testing
public actor MockKeychain: SecureStorageProvider {
    /// Storage for mock keychain data
    private var storage: [String: Data]

    /// Initialize a new mock keychain
    public init() {
        self.storage = [:]
    }

    /// Save data to the mock keychain
    /// - Parameters:
    ///   - data: Data to save
    ///   - key: Key to save under
    public func save(_ data: Data, forKey key: String) async throws {
        storage[key] = data
    }

    /// Load data from the mock keychain
    /// - Parameter key: Key to load data for
    /// - Returns: The stored data
    public func load(forKey key: String) async throws -> Data {
        guard let data = storage[key] else {
            throw SecurityError.itemNotFound(key: key)
        }
        return data
    }

    /// Delete data from the mock keychain
    /// - Parameter key: Key to delete data for
    public func delete(forKey key: String) async throws {
        guard storage.removeValue(forKey: key) != nil else {
            throw SecurityError.itemNotFound(key: key)
        }
    }

    /// Reset the mock keychain
    public func reset() async {
        storage.removeAll()
    }
}

import CryptoTypes
import Foundation
import SecurityTypes

public actor MockKeychain: SecureStorageProvider {
    private var storage: [String: Data] = [:]

    public init() {}

    public func save(_ data: Data, forKey key: String) async throws {
        storage[key] = data
    }

    public func load(forKey key: String) async throws -> Data {
        guard let data = storage[key] else {
            throw CryptoError.keyNotFound(identifier: key)
        }
        return data
    }

    public func delete(forKey key: String) async throws {
        guard storage.removeValue(forKey: key) != nil else {
            throw CryptoError.keyNotFound(identifier: key)
        }
    }

    public func reset() async {
        storage.removeAll()
    }
}

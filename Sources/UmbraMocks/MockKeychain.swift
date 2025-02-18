import CryptoTypes
import CryptoTypes.Types
import Foundation
import SecurityTypes

public actor MockKeychain: SecureStorageProvider {
    private var storage: [String: Data] = [:]
    private var metadata: [String: [String: String]] = [:]

    public init() {}

    public func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws {
        storage[key] = data
        self.metadata[key] = metadata
    }

    public func load(forKey key: String) async throws -> Data {
        guard let data = storage[key] else {
            throw CryptoError.keyNotFound(identifier: key)
        }
        return data
    }

    public func loadWithMetadata(forKey key: String) async throws -> (data: Data, metadata: [String: String]?) {
        let data = try await load(forKey: key)
        return (data: data, metadata: metadata[key])
    }

    public func delete(forKey key: String) async throws {
        guard storage.removeValue(forKey: key) != nil else {
            throw CryptoError.keyNotFound(identifier: key)
        }
        metadata.removeValue(forKey: key)
    }

    public func getMetadata(forKey key: String) async throws -> [String: String]? {
        guard storage[key] != nil else {
            throw CryptoError.keyNotFound(identifier: key)
        }
        return metadata[key]
    }

    public func updateMetadata(_ metadata: [String: String], forKey key: String) async throws {
        guard storage[key] != nil else {
            throw CryptoError.keyNotFound(identifier: key)
        }
        self.metadata[key] = metadata
    }

    public func reset(preserveKeys: Bool) async {
        if preserveKeys {
            storage = storage.mapValues { _ in Data() }
            metadata = metadata.mapValues { _ in [:] }
        } else {
            storage.removeAll()
            metadata.removeAll()
        }
    }

    public func exists(forKey key: String) async -> Bool {
        storage[key] != nil
    }

    public func allKeys() async throws -> [String] {
        Array(storage.keys)
    }
}

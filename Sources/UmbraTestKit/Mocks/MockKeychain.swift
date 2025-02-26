import Foundation
import SecurityTypes
import SecurityTypesProtocols

public actor MockKeychain: SecureStorageProvider {
    private var storage: [String: Data] = [:]
    private var metadata: [String: [String: String]] = [:]

    public init() {}

    public func save(_ data: Data, forKey key: String, metadata: [String: String]? = nil) async throws {
        storage[key] = data
        if let metadata = metadata {
            self.metadata[key] = metadata
        }
    }

    public func load(forKey key: String) async throws -> Data {
        guard let data = storage[key] else {
            throw SecurityError.invalidData(reason: "No data found for key: \(key)")
        }
        return data
    }

    public func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?) {
        guard let data = storage[key] else {
            throw SecurityError.invalidData(reason: "No data found for key: \(key)")
        }
        return (data, metadata[key])
    }

    public func delete(forKey key: String) async throws {
        guard storage.removeValue(forKey: key) != nil else {
            throw SecurityError.invalidData(reason: "No data found for key: \(key)")
        }
        metadata.removeValue(forKey: key)
    }

    public func getMetadata(forKey key: String) async throws -> [String: String]? {
        guard storage[key] != nil else {
            throw SecurityError.invalidData(reason: "No data found for key: \(key)")
        }
        return metadata[key]
    }

    public func updateMetadata(_ metadata: [String: String], forKey key: String) async throws {
        guard storage[key] != nil else {
            throw SecurityError.invalidData(reason: "No data found for key: \(key)")
        }
        self.metadata[key] = metadata
    }

    public func exists(forKey key: String) async -> Bool {
        return storage[key] != nil
    }

    public func allKeys() async throws -> [String] {
        return Array(storage.keys)
    }

    public func reset(preserveKeys: Bool) async {
        if !preserveKeys {
            storage.removeAll()
            metadata.removeAll()
        }
    }
}

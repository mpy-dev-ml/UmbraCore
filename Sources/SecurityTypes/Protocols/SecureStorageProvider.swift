import Foundation

/// Protocol defining requirements for secure storage providers
public protocol SecureStorageProvider: Actor {
    /// Save data securely
    /// - Parameters:
    ///   - data: Data to save
    ///   - key: Key to save the data under
    ///   - metadata: Optional metadata to store with the data
    func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws

    /// Load data from secure storage
    /// - Parameter key: Key to load data for
    /// - Returns: The stored data
    func load(forKey key: String) async throws -> Data

    /// Load data and metadata from secure storage
    /// - Parameter key: Key to load data for
    /// - Returns: Tuple containing the data and any associated metadata
    func loadWithMetadata(forKey key: String) async throws -> (data: Data, metadata: [String: String]?)

    /// Delete data from secure storage
    /// - Parameter key: Key to delete data for
    func delete(forKey key: String) async throws

    /// Check if data exists for a given key
    /// - Parameter key: Key to check
    /// - Returns: Whether data exists for the key
    func exists(forKey key: String) async -> Bool

    /// List all keys in the storage
    /// - Returns: Array of all keys
    func allKeys() async throws -> [String]

    /// Update metadata for a key
    /// - Parameters:
    ///   - metadata: New metadata to store
    ///   - key: Key to update metadata for
    func updateMetadata(_ metadata: [String: String], forKey key: String) async throws

    /// Reset the storage provider
    /// - Parameter preserveKeys: If true, only clear data but preserve keys
    func reset(preserveKeys: Bool) async
}

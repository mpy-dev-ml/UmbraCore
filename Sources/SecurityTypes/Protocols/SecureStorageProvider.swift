import Foundation

/// Protocol defining requirements for secure storage providers
public protocol SecureStorageProvider: Actor {
    /// Save data securely
    /// - Parameters:
    ///   - data: Data to save
    ///   - key: Key to save the data under
    func save(_ data: Data, forKey key: String) async throws

    /// Load data from secure storage
    /// - Parameter key: Key to load data for
    /// - Returns: The stored data
    func load(forKey key: String) async throws -> Data

    /// Delete data from secure storage
    /// - Parameter key: Key to delete data for
    func delete(forKey key: String) async throws

    /// Reset the storage provider
    func reset() async
}

import Foundation

/// Protocol for secure storage operations
public protocol SecureStorageProvider: Sendable {
  /// Save data securely
  /// - Parameters:
  ///   - data: Data to save
  ///   - key: Key to save under
  ///   - metadata: Optional metadata to store with the data
  /// - Throws: SecurityError if save fails
  func save(_ data: Data, forKey key: String, metadata: [String: String]?) async throws

  /// Load data with metadata
  /// - Parameter key: Key to load data for
  /// - Returns: Tuple of data and metadata
  /// - Throws: SecurityError if load fails
  func loadWithMetadata(forKey key: String) async throws -> (Data, [String: String]?)

  /// Delete data
  /// - Parameter key: Key to delete data for
  /// - Throws: SecurityError if deletion fails
  func delete(forKey key: String) async throws

  /// Check if data exists
  /// - Parameter key: Key to check
  /// - Returns: True if data exists
  func exists(forKey key: String) async -> Bool

  /// Get all stored keys
  /// - Returns: Array of stored keys
  /// - Throws: SecurityError if retrieval fails
  func allKeys() async throws -> [String]

  /// Reset storage
  /// - Parameter preserveKeys: Whether to preserve certain keys
  func reset(preserveKeys: Bool) async
}

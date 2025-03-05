/// Foundation-free protocol defining security-related operations for managing secure resource
/// access
public protocol SecurityProviderBase: Sendable {
  // MARK: - Bookmark Management

  /// Create a security-scoped bookmark for a path
  /// - Parameter path: File system path to create bookmark for
  /// - Returns: Bookmark data that can be persisted
  /// - Throws: Error if bookmark creation fails
  func createBookmark(forPath path: String) async throws -> [UInt8]

  /// Resolve a previously created security-scoped bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved path and whether bookmark is stale
  /// - Throws: Error if bookmark resolution fails
  func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

  // MARK: - Resource Access Control

  /// Start accessing a security-scoped resource
  /// - Parameter path: Path to the resource to access
  /// - Returns: A boolean indicating if access was granted
  /// - Throws: Error if access fails or is denied
  func startAccessing(path: String) async throws -> Bool

  /// Stop accessing a security-scoped resource
  /// - Parameter path: Path to the resource to stop accessing
  /// - Note: This method should be called in a defer block after startAccessing
  func stopAccessing(path: String) async

  // MARK: - Credential Management

  /// Store credentials securely
  /// - Parameters:
  ///   - data: Data to store
  ///   - account: Account identifier
  ///   - service: Service identifier
  ///   - metadata: Optional metadata associated with the credentials
  /// - Returns: String identifier for the stored credentials
  func storeCredential(
    data: [UInt8],
    account: String,
    service: String,
    metadata: [String: String]?
  ) async throws -> String

  /// Load credentials
  /// - Parameters:
  ///   - account: Account identifier
  ///   - service: Service identifier
  /// - Returns: The stored credential data
  func loadCredential(
    account: String,
    service: String
  ) async throws -> [UInt8]

  /// Load credentials with associated metadata
  /// - Parameters:
  ///   - account: Account identifier
  ///   - service: Service identifier
  /// - Returns: Tuple containing credential data and optional metadata
  func loadCredentialWithMetadata(
    account: String,
    service: String
  ) async throws -> ([UInt8], [String: String]?)

  /// Delete stored credentials
  /// - Parameters:
  ///   - account: Account identifier
  ///   - service: Service identifier
  func deleteCredential(
    account: String,
    service: String
  ) async throws

  /// Generate random bytes
  /// - Parameter length: Number of random bytes to generate
  /// - Returns: Array of random bytes
  func generateRandomBytes(length: Int) async throws -> [UInt8]
}

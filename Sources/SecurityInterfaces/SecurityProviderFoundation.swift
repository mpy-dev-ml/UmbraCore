import CoreTypes
import SecurityBridge
import SecurityInterfacesBase

/// Protocol defining Foundation-dependent security operations
/// This is a non-Foundation dependent version that delegates to the Foundation bridge
public protocol SecurityProviderFoundation {
  // MARK: - Binary Data Methods

  /// Encrypt binary data using the provider's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: SecurityError if encryption fails
  func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes
    .BinaryData

  /// Decrypt binary data using the provider's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: SecurityError if decryption fails
  func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes
    .BinaryData

  /// Generate a cryptographically secure random key
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key as BinaryData
  /// - Throws: SecurityError if key generation fails
  func generateKey(length: Int) async throws -> CoreTypes.BinaryData

  /// Hash binary data using the provider's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash of the data
  /// - Throws: SecurityError if hashing fails
  func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData

  // MARK: - Resource Access

  /// Create a security-scoped resource identifier
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: Resource bookmark data
  /// - Throws: SecurityError if bookmark creation fails
  func createResourceBookmark(for identifier: String) async throws -> CoreTypes.BinaryData

  /// Resolve a previously created security-scoped resource bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved identifier and whether bookmark is stale
  /// - Throws: SecurityError if bookmark resolution fails
  func resolveResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws
    -> (identifier: String, isStale: Bool)

  /// Validate a resource bookmark to ensure it's still valid
  /// - Parameter bookmarkData: Bookmark data to validate
  /// - Returns: True if bookmark is valid, false otherwise
  /// - Throws: SecurityError if validation fails
  func validateResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool

  // MARK: - Bookmark Management

  /// Create a security-scoped bookmark for a resource
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: Bookmark data that can be persisted
  /// - Throws: SecurityError if bookmark creation fails
  func createBookmark(for identifier: String) async throws -> CoreTypes.BinaryData

  /// Resolve a previously created security-scoped bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved identifier and whether bookmark is stale
  /// - Throws: SecurityError if bookmark resolution fails
  func resolveBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws
    -> (identifier: String, isStale: Bool)

  /// Validate a bookmark to ensure it's still valid
  /// - Parameter bookmarkData: Bookmark data to validate
  /// - Returns: Boolean indicating if the bookmark is valid
  /// - Throws: SecurityError if validation fails
  func validateBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool

  // MARK: - Resource Access Control

  /// Start accessing a security-scoped resource
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: A boolean indicating if access was granted
  /// - Throws: SecurityError if access fails or is denied
  func startAccessingResource(identifier: String) async throws -> Bool

  /// Stop accessing a security-scoped resource
  /// - Parameter identifier: String identifier for the resource to stop accessing
  func stopAccessingResource(identifier: String) async

  /// Stop accessing all security-scoped resources
  func stopAccessingAllResources() async

  /// Check if a security-scoped resource is being accessed
  /// - Parameter identifier: String identifier to check
  /// - Returns: Boolean indicating if the resource is being accessed
  func isAccessingResource(identifier: String) async -> Bool

  /// Get all resource identifiers currently being accessed
  /// - Returns: Set of identifiers being accessed
  func getAccessedResourceIdentifiers() async -> Set<String>

  // MARK: - Keychain Operations

  /// Store data in the keychain
  /// - Parameters:
  ///   - data: Data to store
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Throws: SecurityError if keychain operation fails
  func storeInKeychain(data: CoreTypes.BinaryData, service: String, account: String) async throws

  /// Retrieve data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Retrieved data
  /// - Throws: SecurityError if keychain operation fails
  func retrieveFromKeychain(service: String, account: String) async throws -> CoreTypes.BinaryData

  /// Delete data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Throws: SecurityError if keychain operation fails
  func deleteFromKeychain(service: String, account: String) async throws
}

/// Extension to provide default implementations for SecurityProviderFoundation
extension SecurityProviderFoundation {
  // Default implementations can be added here if needed
}

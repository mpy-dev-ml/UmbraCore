import CoreTypes
import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining Foundation-dependent security operations
/// This is a non-Foundation dependent version that delegates to the Foundation bridge
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderFoundationProtocol instead"
)
public protocol SecurityProviderFoundation {
  // MARK: - Binary Data Methods

  /// Encrypt binary data using the provider's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data or error
  func encrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, SecurityError>

  /// Decrypt binary data using the provider's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data or error
  func decrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, SecurityError>

  /// Generate a cryptographically secure random key
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key as SecureBytes or error
  func generateKey(length: Int) async -> Result<SecureBytes, SecurityError>

  /// Hash binary data using the provider's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash of the data or error
  func hash(_ data: SecureBytes) async -> Result<SecureBytes, SecurityError>

  // MARK: - Resource Access

  /// Create a security-scoped resource identifier
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: Resource bookmark data or error
  func createResourceBookmark(for identifier: String) async -> Result<SecureBytes, SecurityError>

  /// Resolve a previously created security-scoped resource bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved identifier and whether bookmark is stale, or error
  func resolveResourceBookmark(_ bookmarkData: SecureBytes) async -> Result<(identifier: String, isStale: Bool), SecurityError>

  /// Validate a resource bookmark to ensure it's still valid
  /// - Parameter bookmarkData: Bookmark data to validate
  /// - Returns: True if bookmark is valid, false otherwise, or error
  func validateResourceBookmark(_ bookmarkData: SecureBytes) async -> Result<Bool, SecurityError>

  // MARK: - Bookmark Management

  /// Create a security-scoped bookmark for a resource
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: Bookmark data that can be persisted, or error
  func createBookmark(for identifier: String) async -> Result<SecureBytes, SecurityError>

  /// Resolve a previously created security-scoped bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved identifier and whether bookmark is stale, or error
  func resolveBookmark(_ bookmarkData: SecureBytes) async -> Result<(identifier: String, isStale: Bool), SecurityError>

  /// Validate a bookmark to ensure it's still valid
  /// - Parameter bookmarkData: Bookmark data to validate
  /// - Returns: Boolean indicating if the bookmark is valid, or error
  func validateBookmark(_ bookmarkData: SecureBytes) async -> Result<Bool, SecurityError>

  // MARK: - Resource Access Control

  /// Start accessing a security-scoped resource
  /// - Parameter identifier: String identifier for the resource
  /// - Returns: A boolean indicating if access was granted, or error
  func startAccessingResource(identifier: String) async -> Result<Bool, SecurityError>

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
  /// - Returns: Success or error
  func storeInKeychain(data: SecureBytes, service: String, account: String) async -> Result<Void, SecurityError>

  /// Retrieve data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Retrieved data or error
  func retrieveFromKeychain(service: String, account: String) async -> Result<SecureBytes, SecurityError>

  /// Delete data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Success or error
  func deleteFromKeychain(service: String, account: String) async -> Result<Void, SecurityError>
}

/// Extension to provide default implementations for SecurityProviderFoundation
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderFoundationProtocol instead"
)
extension SecurityProviderFoundation {
  // Default implementations can be added here if needed
}

/// Adapter to convert between the legacy and new protocols
@available(
  *,
  deprecated,
  message: "Use SecurityProtocolsCore.SecurityProviderFoundationProtocol directly instead"
)
public struct SecurityProviderFoundationAdapter {
  private let legacy: any SecurityProviderFoundation
  
  public init(legacy: any SecurityProviderFoundation) {
    self.legacy = legacy
  }
  
  // Add implementation methods as needed for backward compatibility
}

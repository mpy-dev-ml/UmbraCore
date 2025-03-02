// Standard modules
import CryptoTypes
import CryptoTypesProtocols
import CryptoTypesTypes
import Foundation
import SecurityInterfaces
import SecurityInterfacesProtocols
import SecurityTypes
import SecurityUtils
import SecurityUtilsProtocols
import SecurityUtilsServices
import SecureBytes
import CoreTypes

// MARK: - Crypto Mock Implementation

/// Basic implementation of CryptoServiceProtocol for use in SecurityService
private final class BasicCryptoService: CryptoTypesProtocols.CryptoServiceProtocol {
    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        // This is a mock implementation - real implementation would come from CryptoTypes
        return data
    }
    
    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        // This is a mock implementation - real implementation would come from CryptoTypes
        return data
    }
    
    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        // This is a mock implementation - real implementation would come from CryptoTypes
        return Data(repeating: 0, count: 32)
    }
    
    public func generateSecureRandomKey(length: Int) async throws -> Data {
        // Generate random data using SecRandomCopyBytes
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            throw CryptoTypesTypes.CryptoError.randomGenerationFailed(status: status)
        }
        return Data(bytes)
    }
    
    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        // This is a mock implementation - real implementation would come from CryptoTypes
        return Data(repeating: 0, count: 32)
    }
}

// MARK: - Type Aliases

/// Use SecureBytes-based BinaryData
public typealias BinaryData = CoreTypes.BinaryData

// MARK: - SecurityService

/// A service that provides security-related functionality.
/// Core functions include:
/// - Encryption and decryption
/// - Hash generation
/// - Secure random data generation
/// - Keychain integration
/// - Security-scoped bookmark management
/// - Handling bookmark persistence and resolution
@MainActor
@preconcurrency
public final class SecurityService: SecurityProvider {
  /// Shared instance of the SecurityService
  public static let shared = SecurityService()
  
  private let cryptoService: CryptoTypesProtocols.CryptoServiceProtocol
  
  /// Initialize the security service
  /// - Parameter cryptoService: Optional crypto service for operations
  public init(cryptoService: CryptoTypesProtocols.CryptoServiceProtocol? = nil) {
    // Create a basic crypto service if none provided
    self.cryptoService = cryptoService ?? BasicCryptoService()
  }
  
  /// The underlying security provider implementation
  nonisolated public var provider: any SecurityInterfacesProtocols.SecurityProviderProtocol {
    return UmbraSecurityProvider(cryptoService: cryptoService)
  }
  
  // MARK: - Binary Data Methods
  
  /// Encrypt data using the supplied key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: SecurityOperationError if encryption fails
  public func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
    // Convert CoreTypes.BinaryData to SecurityInterfacesProtocols.BinaryData
    let protocolData = SecurityInterfacesProtocols.BinaryData(data.bytes())
    let protocolKey = SecurityInterfacesProtocols.BinaryData(key.bytes())
    
    // Call provider with protocol types
    let result = try await provider.encrypt(protocolData, key: protocolKey)
    
    // Convert result back to CoreTypes.BinaryData
    return CoreTypes.BinaryData(result.bytes)
  }
  
  /// Decrypt data using the supplied key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: SecurityOperationError if decryption fails
  public func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
    // Convert CoreTypes.BinaryData to SecurityInterfacesProtocols.BinaryData
    let protocolData = SecurityInterfacesProtocols.BinaryData(data.bytes())
    let protocolKey = SecurityInterfacesProtocols.BinaryData(key.bytes())
    
    // Call provider with protocol types
    let result = try await provider.decrypt(protocolData, key: protocolKey)
    
    // Convert result back to CoreTypes.BinaryData
    return CoreTypes.BinaryData(result.bytes)
  }
  
  /// Hash data using the service's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash result
  /// - Throws: SecurityOperationError if hashing fails
  public func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
    // Convert CoreTypes.BinaryData to SecurityInterfacesProtocols.BinaryData
    let protocolData = SecurityInterfacesProtocols.BinaryData(data.bytes())
    
    // Call provider with protocol type
    let result = try await provider.hash(protocolData)
    
    // Convert result back to CoreTypes.BinaryData
    return CoreTypes.BinaryData(result.bytes)
  }
  
  /// Generate random data of specified length
  /// - Parameter length: Number of bytes to generate
  /// - Returns: Random data
  /// - Throws: SecurityOperationError if generation fails
  public func randomData(length: Int) async throws -> CoreTypes.BinaryData {
    // Generate random data using our own implementation
    // since provider may not implement randomData directly
    let protocolResult = try await provider.generateKey(length: length)
    
    // Convert result to CoreTypes.BinaryData
    return CoreTypes.BinaryData(protocolResult.bytes)
  }
  
  /// Create a new encryption key
  /// - Returns: New encryption key
  /// - Throws: SecurityOperationError if key creation fails
  public func createKey() async throws -> CoreTypes.BinaryData {
    // Generate a key using our own implementation
    // since provider may not implement createKey directly
    let protocolResult = try await provider.generateKey(length: 32) // Default to 256-bit key
    
    // Convert result to CoreTypes.BinaryData
    return CoreTypes.BinaryData(protocolResult.bytes)
  }
  
  // MARK: - Keychain Methods
  
  /// Store data in the keychain
  /// - Parameters:
  ///   - data: Data to store
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Success flag
  /// - Throws: SecurityOperationError if storage fails
  public func storeInKeychain(
    data: CoreTypes.BinaryData,
    service: String,
    account: String
  ) async throws -> Bool {
    let keychainItem = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: Data(data.bytes())
    ] as [String: Any]
    
    // First try to delete any existing item
    SecItemDelete(keychainItem as CFDictionary)
    
    // Now add the new item
    let status = SecItemAdd(keychainItem as CFDictionary, nil)
    return status == errSecSuccess
  }
  
  /// Retrieve data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Retrieved data or nil if not found
  /// - Throws: SecurityOperationError if retrieval fails
  public func retrieveFromKeychain(
    service: String,
    account: String
  ) async throws -> CoreTypes.BinaryData? {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ] as [String: Any]
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
      return CoreTypes.BinaryData([UInt8](retrievedData))
    } else {
      return nil
    }
  }
  
  /// Update data in the keychain
  /// - Parameters:
  ///   - data: Updated data
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Success flag
  /// - Throws: SecurityOperationError if update fails
  public func updateInKeychain(
    data: CoreTypes.BinaryData,
    service: String,
    account: String
  ) async throws -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ] as [String: Any]
    
    let attributes = [
      kSecValueData as String: Data(data.bytes())
    ] as [String: Any]
    
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    return status == errSecSuccess
  }
  
  /// Remove data from the keychain
  /// - Parameters:
  ///   - service: Service identifier
  ///   - account: Account identifier
  /// - Returns: Success flag
  /// - Throws: SecurityOperationError if removal fails
  public func removeFromKeychain(
    service: String,
    account: String
  ) async throws -> Bool {
    let query = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ] as [String: Any]
    
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess || status == errSecItemNotFound
  }
  
  // MARK: - Security-Scoped Bookmark Methods
  
  /// Creates a security-scoped bookmark for the specified URL
  /// Bookmarks allow persistent access to user-selected files/directories
  /// - Parameter url: The URL to create a bookmark for
  /// - Returns: Bookmark data
  /// - Throws: SecurityOperationError if bookmark creation fails
  public func createSecurityScopedBookmark(for url: URL) async throws -> CoreTypes.BinaryData {
    return try await url.createSecurityScopedBookmarkData()
  }
  
  /// Resolves a security-scoped bookmark to its URL
  /// - Parameter bookmarkData: The bookmark data to resolve
  /// - Returns: A tuple containing the resolved URL and a flag indicating if it's stale
  /// - Throws: SecurityOperationError if bookmark resolution fails
  public func resolveSecurityScopedBookmark(
    _ bookmarkData: CoreTypes.BinaryData
  ) async throws -> (URL, Bool) {
    // Convert CoreTypes.BinaryData to Data
    let data = Data(bookmarkData.bytes())
    
    // Resolve the bookmark
    return try await URL.resolveSecurityScopedBookmark(data)
  }
  
  /// Performs an operation with access to a security-scoped resource
  /// Handles properly isolating the operation for concurrency safety
  /// - Parameters:
  ///   - url: The URL to the security-scoped resource
  ///   - operation: The operation to perform while access is granted
  /// - Returns: The result of the operation
  /// - Throws: Any error thrown by the operation
  public func withSecurityScopedAccess<T: Sendable>(
    to url: URL,
    operation: @Sendable () async throws -> T
  ) async throws -> T {
    // Use intermediary function to handle isolation properly
    let wrappedOperation: @Sendable () async throws -> T = { 
      try await operation()
    }
    
    return try await url.withSecurityScopedAccess(wrappedOperation)
  }
}

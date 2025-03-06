import CoreTypesInterfaces
import CoreErrors
import FoundationBridgeTypes
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Bridge protocol that connects security providers to Foundation-free interfaces
/// This helps break circular dependencies between security modules
public protocol SecurityProviderBridge: Sendable {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Encrypt data using the provider's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: Error if encryption fails
  func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

  /// Decrypt data using the provider's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: Error if decryption fails
  func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge

  /// Generate a cryptographically secure random key
  /// - Parameter length: The length of the key in bytes
  /// - Returns: A random key
  /// - Throws: Error if key generation fails
  func generateKey(length: Int) async throws -> DataBridge

  /// Compute a secure hash of the provided data
  /// - Parameter data: The data to hash
  /// - Returns: The hash value
  /// - Throws: Error if hashing fails
  func hash(_ data: DataBridge) async throws -> DataBridge
}

/// Adapter that connects a foundation-free security provider to a Foundation-based interface
/// Implementing the SecurityProviderProtocol while delegating to a foundation-free bridge
public final class SecurityProviderProtocolAdapter: SecurityInterfacesProtocols.SecurityProviderProtocol {
  /// The underlying bridge implementation
  private let adapter: any SecurityProviderBridge
  
  /// Protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.security.provider.adapter"
  }

  /// Wrap any error into a SecurityProtocolError
  private func wrapError(_ error: Error) throws -> Never {
    let errorDescription = if let bridgeError = error as? SecurityBridgeError {
      "Bridge error: \(bridgeError)"
    } else if let secError = error as? SecurityProtocolsCore.SecurityError {
      "Security error: \(secError)"
    } else {
      "Unknown error: \(error)"
    }
    throw SecurityProtocolsCore.SecurityProtocolError.implementationMissing(errorDescription)
  }

  /// Convert binary data to data bridge format
  private func convertData(_ data: CoreTypesInterfaces.BinaryData) -> DataBridge {
    // BinaryData is a SecureData, which has a rawBytes property
    return DataBridge(data.rawBytes)
  }

  /// Convert data bridge back to binary data
  private func convertData(_ bridge: DataBridge) throws -> CoreTypesInterfaces.BinaryData {
    // Create a BinaryData using the bytes property of DataBridge
    return CoreTypesInterfaces.BinaryData(bytes: bridge.bytes)
  }

  /// Create a new adapter with the given bridge
  /// - Parameter bridge: The security provider bridge implementation
  public init(bridge: any SecurityProviderBridge) {
    self.adapter = bridge
  }

  /// Encrypt data using the provider's encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: SecurityProtocolError if encryption fails
  public func encrypt(_ data: CoreTypesInterfaces.BinaryData, 
                      key: CoreTypesInterfaces.BinaryData) async throws -> CoreTypesInterfaces.BinaryData {
    do {
      let bridgeData = convertData(data)
      let bridgeKey = convertData(key)
      
      let result = try await adapter.encrypt(bridgeData, key: bridgeKey)
      return try convertData(result)
    } catch {
      try wrapError(error)
    }
  }

  /// Decrypt data using the provider's decryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: SecurityProtocolError if decryption fails
  public func decrypt(_ data: CoreTypesInterfaces.BinaryData, 
                      key: CoreTypesInterfaces.BinaryData) async throws -> CoreTypesInterfaces.BinaryData {
    do {
      let bridgeData = convertData(data)
      let bridgeKey = convertData(key)
      
      let result = try await adapter.decrypt(bridgeData, key: bridgeKey)
      return try convertData(result)
    } catch {
      try wrapError(error)
    }
  }

  /// Generate a random encryption key
  /// - Parameter length: Length of the key in bytes
  /// - Returns: A randomly generated key
  /// - Throws: SecurityProtocolError if key generation fails
  public func generateKey(length: Int) async throws -> CoreTypesInterfaces.BinaryData {
    do {
      let result = try await adapter.generateKey(length: length)
      return try convertData(result)
    } catch {
      try wrapError(error)
    }
  }

  /// Compute a hash of the provided data
  /// - Parameter data: Data to hash
  /// - Returns: Hash value
  /// - Throws: SecurityProtocolError if hashing fails
  public func hash(_ data: CoreTypesInterfaces.BinaryData) async throws -> CoreTypesInterfaces.BinaryData {
    do {
      let bridgeData = convertData(data)
      let result = try await adapter.hash(bridgeData)
      return try convertData(result)
    } catch {
      try wrapError(error)
    }
  }
}

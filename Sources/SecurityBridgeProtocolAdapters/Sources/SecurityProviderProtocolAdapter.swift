import CoreTypesInterfaces
import FoundationBridgeTypes
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore
import CoreErrors
import UmbraCoreTypes

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
  /// - Returns: Generated key
  /// - Throws: Error if key generation fails
  func generateKey() async throws -> DataBridge

  /// Generate a cryptographically secure random key with specific length
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key
  /// - Throws: Error if key generation fails
  func generateKey(length: Int) async throws -> DataBridge

  /// Generate cryptographically secure random data
  /// - Parameter length: Length of the data in bytes
  /// - Returns: Generated random data
  /// - Throws: Error if data generation fails
  func generateRandomData(length: Int) async throws -> DataBridge

  /// Hash data using the provider's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash of the data
  /// - Throws: Error if hashing fails
  func hash(_ data: DataBridge) async throws -> DataBridge
}

/// Default implementation for SecurityProviderBridge
extension SecurityProviderBridge {
  /// Default protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.security.provider.bridge"
  }
}

/// Implementation of SecurityProviderProtocol that wraps a SecurityProviderBridge
/// Adapts between different interfaces and error types
public final class SecurityProviderProtocolAdapter: SecurityInterfacesProtocols.SecurityProviderProtocol {
  /// The underlying bridge implementation
  private let adapter: any SecurityProviderBridge

  /// Wrap any error into a SecurityProtocolError
  /// - Parameter error: The error to wrap
  /// - Throws: SecurityProtocolError containing the error details
  private func wrapError(_ error: Error) throws -> Never {
    // Generate an appropriate error description based on the error type
    let errorDescription = if let bridgeError = error as? SecurityBridgeError {
      "Bridge error: \(bridgeError)"
    } else if let secError = error as? CoreErrors.SecurityError {
      "Security error: \(secError)"
    } else if let xpcError = error as? XPCProtocolsCore.XPCErrors.SecurityError {
      "XPC error: \(xpcError)"
    } else {
      "Unknown error: \(error)"
    }

    // Map to an appropriate SecurityError type
    throw SecurityInterfacesProtocols.SecurityProtocolError.implementationMissing(errorDescription)
  }

  /// Create a new adapter wrapping a SecurityProviderBridge implementation
  /// - Parameter adapter: Bridge implementation to wrap
  public init(wrapping adapter: any SecurityProviderBridge) {
    self.adapter = adapter
  }

  /// Protocol identifier - used for protocol negotiation
  public static var protocolIdentifier: String {
    "com.umbra.security.provider.adapter"
  }

  /// Encrypt binary data using the provider's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: SecurityProtocolError if encryption fails
  public func encrypt(_ data: BinaryData, key: BinaryData) async throws -> BinaryData {
    do {
      // Convert from BinaryData (SecureBytes) to DataBridge
      let bridgeData = DataBridge(data)
      let bridgeKey = DataBridge(key)

      // Call the adapter with converted types
      let result = try await adapter.encrypt(bridgeData, key: bridgeKey)

      // Convert back to BinaryData for return
      return result.toBinaryData()
    } catch {
      try wrapError(error)
    }
  }

  /// Decrypt binary data using the provider's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: SecurityProtocolError if decryption fails
  public func decrypt(_ data: BinaryData, key: BinaryData) async throws -> BinaryData {
    do {
      // Convert from BinaryData to DataBridge
      let bridgeData = DataBridge(data)
      let bridgeKey = DataBridge(key)

      // Call the adapter with converted types
      let result = try await adapter.decrypt(bridgeData, key: bridgeKey)

      // Convert back to BinaryData for return
      return result.toBinaryData()
    } catch {
      try wrapError(error)
    }
  }

  /// Generate a cryptographically secure random key
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key
  /// - Throws: SecurityProtocolError if key generation fails
  public func generateKey(length: Int) async throws -> BinaryData {
    do {
      let keyData = try await adapter.generateKey(length: length)

      // Convert to BinaryData for return
      return keyData.toBinaryData()
    } catch {
      try wrapError(error)
    }
  }

  /// Hash data using the provider's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash of the data
  /// - Throws: SecurityProtocolError if hashing fails
  public func hash(_ data: BinaryData) async throws -> BinaryData {
    do {
      // Convert from BinaryData to DataBridge
      let bridgeData = DataBridge(data)

      // Call the adapter with converted type
      let hashResult = try await adapter.hash(bridgeData)

      // Convert back to BinaryData for return
      return hashResult.toBinaryData()
    } catch {
      try wrapError(error)
    }
  }
}

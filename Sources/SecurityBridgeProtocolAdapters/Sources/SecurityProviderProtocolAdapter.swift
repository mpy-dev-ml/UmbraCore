import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore

// Re-declare the type aliases to ensure they're available in this file
typealias SPCSecurityError=SecurityError
typealias XPCSecurityError=SecurityError

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

  /// Default implementation for generateKey that calls the length-specific method
  public func generateKey() async throws -> DataBridge {
    try await generateKey(length: 32) // Default to 32 bytes (256 bits)
  }

  /// Default implementation to handle the specific length
  public func generateKey(length: Int) async throws -> DataBridge {
    try await generateRandomData(length: length)
  }
}

/// Adapter class to convert between SecurityProviderProtocol and SecurityProviderBridge
public final class SecurityProviderProtocolAdapter: SecurityInterfacesProtocols
.SecurityProviderProtocol {
  /// The underlying bridge implementation
  private let adapter: any SecurityProviderBridge

  /// Converts any error to a SecurityProtocolError
  private func mapToProtocolError(_ error: Error) -> SecurityInterfacesProtocols
  .SecurityProtocolError {
    // Map the bridged error to a protocol error
    // Since we only have one case in SecurityProtocolError, we convert all errors to that
    let errorDescription=if let bridgeError=error as? SecurityBridgeError {
      "Bridge error: \(bridgeError)"
    } else if let secError=error as? SecurityError {
      "Security error: \(secError)"
    } else if let xpcError=error as? SecurityError {
      "XPC error: \(xpcError)"
    } else {
      "Unknown error: \(String(describing: error))"
    }

    return SecurityInterfacesProtocols.SecurityProtocolError.implementationMissing(errorDescription)
  }

  /// Initialize with a bridge implementation
  /// - Parameter adapter: The bridge implementation
  public init(adapter: any SecurityProviderBridge) {
    self.adapter=adapter
  }

  /// Protocol identifier for service discovery
  public static var protocolIdentifier: String {
    "com.umbra.security.provider.protocol.adapter"
  }

  /// Encrypt data using the provider's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: SecurityProtocolError if encryption fails
  public func encrypt(
    _ data: SecurityInterfacesProtocols.BinaryData,
    key: SecurityInterfacesProtocols.BinaryData
  ) async throws -> SecurityInterfacesProtocols.BinaryData {
    do {
      // Convert from SecurityInterfacesProtocols.BinaryData to DataBridge
      let bridgeData=DataBridge([UInt8](data.bytes))
      let bridgeKey=DataBridge([UInt8](key.bytes))

      // Use the bridge to encrypt
      let encryptedData=try await adapter.encrypt(bridgeData, key: bridgeKey)

      // Convert back to SecurityInterfacesProtocols.BinaryData
      return SecurityInterfacesProtocols.BinaryData(encryptedData.bytes)
    } catch {
      // Map the error to a SecurityProtocolError
      throw mapToProtocolError(error)
    }
  }

  /// Decrypt data using the provider's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: SecurityProtocolError if decryption fails
  public func decrypt(
    _ data: SecurityInterfacesProtocols.BinaryData,
    key: SecurityInterfacesProtocols.BinaryData
  ) async throws -> SecurityInterfacesProtocols.BinaryData {
    do {
      // Convert from SecurityInterfacesProtocols.BinaryData to DataBridge
      let bridgeData=DataBridge([UInt8](data.bytes))
      let bridgeKey=DataBridge([UInt8](key.bytes))

      // Use the bridge to decrypt
      let decryptedData=try await adapter.decrypt(bridgeData, key: bridgeKey)

      // Convert back to SecurityInterfacesProtocols.BinaryData
      return SecurityInterfacesProtocols.BinaryData(decryptedData.bytes)
    } catch {
      // Map the error to a SecurityProtocolError
      throw mapToProtocolError(error)
    }
  }

  /// Generate a cryptographically secure random key
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key
  /// - Throws: SecurityProtocolError if key generation fails
  public func generateKey(length: Int) async throws -> SecurityInterfacesProtocols.BinaryData {
    do {
      let keyData=try await adapter.generateKey(length: length)

      // Convert to SecurityInterfacesProtocols.BinaryData
      return SecurityInterfacesProtocols.BinaryData(keyData.bytes)
    } catch {
      // Map the error to a SecurityProtocolError
      throw mapToProtocolError(error)
    }
  }

  /// Hash data using the provider's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash of the data
  /// - Throws: SecurityProtocolError if hashing fails
  public func hash(
    _ data: SecurityInterfacesProtocols
      .BinaryData
  ) async throws -> SecurityInterfacesProtocols.BinaryData {
    do {
      // Convert from SecurityInterfacesProtocols.BinaryData to DataBridge
      let bridgeData=DataBridge([UInt8](data.bytes))

      // Use the bridge to hash
      let hashedData=try await adapter.hash(bridgeData)

      // Convert back to SecurityInterfacesProtocols.BinaryData
      return SecurityInterfacesProtocols.BinaryData(hashedData.bytes)
    } catch {
      // Map the error to a SecurityProtocolError
      throw mapToProtocolError(error)
    }
  }

  /// Generate cryptographically secure random data
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Generated random data
  /// - Throws: SecurityProtocolError if random data generation fails
  public func generateRandomData(length: Int) async throws -> SecurityInterfacesProtocols
  .BinaryData {
    do {
      let randomData=try await adapter.generateRandomData(length: length)

      // Convert to SecurityInterfacesProtocols.BinaryData
      return SecurityInterfacesProtocols.BinaryData(randomData.bytes)
    } catch {
      // Map the error to a SecurityProtocolError
      throw mapToProtocolError(error)
    }
  }
}

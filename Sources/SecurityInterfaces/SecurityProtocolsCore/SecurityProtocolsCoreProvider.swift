// SecurityProtocolsCoreProvider.swift
// IMPORTANT: This file only imports SecurityProtocolsCore to avoid type conflicts

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

// MARK: - Provider Implementation

/// A wrapper around SecurityProtocolsCore's provider implementation
///
/// This class serves as an adapter between the SecurityProtocolsCore provider interface
/// and the higher-level security interfaces used by the rest of the application.
/// It handles type conversion, error mapping, and operation translation.
public class SecurityProtocolsCoreProvider {
  /// The underlying provider implementation
  private let provider: SecurityProviderProtocol

  /// Initializes a new provider wrapper with the specified concrete provider
  ///
  /// - Parameter provider: The underlying SecurityProviderProtocol implementation
  public init(provider: SecurityProviderProtocol) {
    self.provider=provider
  }

  /// Performs a security operation using the underlying provider
  ///
  /// - Parameters:
  ///   - operation: The security operation to perform
  ///   - config: The configuration for the operation
  /// - Returns: The result of the operation
  /// - Throws: Errors from the underlying implementation
  public func performOperation(
    _ operation: SecurityOperation,
    config: SecurityConfigDTO
  ) async throws -> SecurityResultDTO {
    // Delegate to the underlying provider
    await provider.performSecureOperation(
      operation: operation,
      config: config
    )
  }

  /// Generates a cryptographic key of the specified size and type
  ///
  /// - Parameters:
  ///   - size: The size of the key in bits
  ///   - type: The algorithm or type of key
  /// - Returns: A result containing the generated key or an error
  public func generateKey(
    size: Int,
    type _: String
  ) async -> Result<SecureBytes, SecurityError> {
    // Generate key using crypto service
    await provider.cryptoService.generateRandomData(length: size / 8)
  }

  /// Retrieves a key with the specified identifier
  ///
  /// - Parameter identifier: The identifier of the key to retrieve
  /// - Returns: A result containing the key or an error
  public func retrieveKey(
    withIdentifier identifier: String
  ) async -> Result<SecureBytes, SecurityError> {
    await provider.keyManager.retrieveKey(withIdentifier: identifier)
  }

  /// Stores a cryptographic key with the specified identifier
  ///
  /// - Parameters:
  ///   - key: The key to store
  ///   - identifier: The identifier to associate with the key
  /// - Returns: A result indicating success or an error
  public func storeKey(
    _ key: SecureBytes,
    withIdentifier identifier: String
  ) async -> Result<Void, SecurityError> {
    await provider.keyManager.storeKey(key, withIdentifier: identifier)
  }

  /// Deletes a key with the specified identifier
  ///
  /// - Parameter identifier: The identifier of the key to delete
  /// - Returns: A result indicating success or an error
  public func deleteKey(
    withIdentifier identifier: String
  ) async -> Result<Void, SecurityError> {
    await provider.keyManager.deleteKey(withIdentifier: identifier)
  }

  /// Rotates a key with the specified identifier
  ///
  /// - Parameters:
  ///   - identifier: The identifier of the key to rotate
  ///   - dataToReencrypt: Optional data to re-encrypt with the new key
  /// - Returns: A result containing the new key and re-encrypted data or an error
  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), SecurityError> {
    await provider.keyManager.rotateKey(
      withIdentifier: identifier,
      dataToReencrypt: dataToReencrypt
    )
  }

  /// Lists all available key identifiers
  ///
  /// - Returns: A result containing the list of identifiers or an error
  public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    // Access keyManager directly to get key identifiers
    await provider.keyManager.listKeyIdentifiers()
  }
}

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// KeyManagementAdapter provides a bridge between Foundation-based key management implementations
/// and the Foundation-free KeyManagementProtocol.
///
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent
/// KeyManagementProtocol interface.
public final class KeyManagementAdapter: KeyManagementProtocol, Sendable {
  // MARK: - Properties

  /// The Foundation-dependent key management implementation
  private let implementation: any FoundationKeyManagementImpl

  // MARK: - Initialization

  /// Create a new KeyManagementAdapter
  /// - Parameter implementation: The Foundation-dependent key management implementation
  public init(implementation: any FoundationKeyManagementImpl) {
    self.implementation = implementation
  }

  // MARK: - KeyManagementProtocol Implementation

  public func retrieveKey(withIdentifier identifier: String) async
  -> Result<SecureBytes, SecurityError> {
    let result = await implementation.retrieveKey(withIdentifier: identifier)

    switch result {
      case let .success(keyData):
        return .success(DataAdapter.secureBytes(from: keyData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func storeKey(
    _ key: SecureBytes,
    withIdentifier identifier: String
  ) async -> Result<Void, SecurityError> {
    let keyData = DataAdapter.data(from: key)
    let result = await implementation.storeKey(keyData, withIdentifier: identifier)

    switch result {
      case .success:
        return .success(())
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
    let result = await implementation.deleteKey(withIdentifier: identifier)

    switch result {
      case .success:
        return .success(())
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async -> Result<(
    newKey: SecureBytes,
    reencryptedData: SecureBytes?
  ), SecurityError> {
    // Convert SecureBytes to Data for the Foundation implementation
    let dataToReencryptData = dataToReencrypt.map { DataAdapter.data(from: $0) }

    // Call the implementation
    let result = await implementation.rotateKey(
      withIdentifier: identifier,
      newKey: dataToReencryptData ?? Data()
    )

    // Convert the result back to the protocol's types
    switch result {
      case .success:
        // Need to retrieve the key after rotation
        let keyResult = await implementation.retrieveKey(withIdentifier: identifier)
        switch keyResult {
          case let .success(keyData):
            let newKey = DataAdapter.secureBytes(from: keyData)
            return .success((newKey: newKey, reencryptedData: nil))
          case let .failure(error):
            return .failure(mapError(error))
        }
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    let result = await implementation.listKeyIdentifiers()

    switch result {
      case let .success(identifiers):
        return .success(identifiers)
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  // MARK: - Helper Methods

  /// Maps an error to a SecurityError using the centralised error mapper.
  ///
  /// This method provides a standardised way of handling errors throughout the application.
  /// It uses the centralised error mapper to convert any error into a SecurityError.
  ///
  /// - Parameter error: The error to be mapped.
  /// - Returns: A SecurityError representing the original error.
  private func mapError(_ error: Error) -> SecurityError {
    CoreErrors.SecurityErrorMapper.mapToSPCError(error)
  }
}

/// Protocol for Foundation-dependent key management implementations
/// that can be adapted to the Foundation-free KeyManagementProtocol
public protocol FoundationKeyManagementImpl: Sendable {
  func retrieveKey(withIdentifier identifier: String) async -> Result<Data, Error>
  func storeKey(_ key: Data, withIdentifier identifier: String) async -> Result<Void, Error>
  func deleteKey(withIdentifier identifier: String) async -> Result<Void, Error>
  func rotateKey(withIdentifier identifier: String, newKey: Data) async -> Result<Void, Error>
  func listKeyIdentifiers() async -> Result<[String], Error>
}

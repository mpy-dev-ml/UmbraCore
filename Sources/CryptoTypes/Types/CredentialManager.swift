// CryptoKit removed - cryptography will be handled in ResticBar
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Manages secure storage and retrieval of credentials
public actor CredentialManager {
  private let keychain: any SecureStorageServiceProtocol
  private let config: CryptoConfig

  public init(service: String, config: CryptoConfig) {
    keychain = KeychainAccess(service: service)
    self.config = config
  }

  /// Save a credential securely
  /// - Parameters:
  ///   - identifier: Identifier for the credential
  ///   - data: Data to store
  public func save(_ data: Data, forIdentifier identifier: String) async throws {
    let secureBytes = SecureBytes(bytes: [UInt8](data))
    let result = await keychain.storeData(secureBytes, identifier: identifier, metadata: nil)
    
    switch result {
    case .success:
      return
    case .failure(let error):
      throw mapXPCError(error)
    }
  }

  /// Retrieve a credential
  /// - Parameter identifier: Identifier for the credential
  /// - Returns: Stored data
  public func retrieve(forIdentifier identifier: String) async throws -> Data {
    let result = await keychain.retrieveData(identifier: identifier)
    
    switch result {
    case .success(let secureBytes):
      // Convert SecureBytes to Data using Array initializer
      return Data(Array(secureBytes))
    case .failure(let error):
      throw mapXPCError(error)
    }
  }

  /// Delete a credential
  /// - Parameter identifier: Identifier for the credential
  public func delete(forIdentifier identifier: String) async throws {
    let result = await keychain.deleteData(identifier: identifier)
    
    switch result {
    case .success:
      return
    case .failure(let error):
      throw mapXPCError(error)
    }
  }
  
  /// Maps XPC security errors to UmbraErrors.Security.Core
  private func mapXPCError(_ error: XPCSecurityError) -> Error {
    switch error {
    case .keyNotFound(let identifier):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "retrieval", reason: "Item \(identifier) not found")
    case .internalError(let reason):
      return UmbraErrors.Security.Core.internalError(reason: reason)
    case .authorizationDenied(let operation):
      return UmbraErrors.Security.Core.authorizationFailed(reason: "Access denied for operation: \(operation)")
    case .invalidInput(let details):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "validation", reason: details)
    case .cryptographicError(let operation, let details):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: operation, reason: details)
    case .authenticationFailed(let reason):
      return UmbraErrors.Security.Core.authenticationFailed(reason: reason)
    case .connectionInterrupted:
      return UmbraErrors.Security.Core.secureConnectionFailed(reason: "Connection interrupted")
    case .connectionInvalidated(let reason):
      return UmbraErrors.Security.Core.secureConnectionFailed(reason: reason)
    case .serviceUnavailable:
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "service access", reason: "Service unavailable")
    case .serviceNotReady(let reason):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "service access", reason: "Service not ready: \(reason)")
    case .timeout(let interval):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "timeout", reason: "Operation timed out after \(interval) seconds")
    case .invalidState(let details):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "state validation", reason: details)
    case .invalidKeyType(let expected, let received):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: "key validation", reason: "Expected \(expected), received \(received)")
    case .operationNotSupported(let name):
      return UmbraErrors.Security.Core.secureStorageFailed(operation: name, reason: "Operation not supported")
    }
  }
}

/// Access to the system keychain
private actor KeychainAccess: SecureStorageServiceProtocol {
  private let service: String
  private var items: [String: (data: SecureBytes, metadata: [String: String]?)] = [:]

  init(service: String) {
    self.service = service
  }

  func storeData(
    _ data: SecureBytes,
    identifier: String,
    metadata: [String: String]?
  ) async -> Result<Void, XPCSecurityError> {
    items[identifier] = (data: data, metadata: metadata)
    return .success(())
  }

  func retrieveData(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
    guard let item = items[identifier] else {
      return .failure(.keyNotFound(identifier: identifier))
    }
    return .success(item.data)
  }

  func deleteData(identifier: String) async -> Result<Void, XPCSecurityError> {
    guard items.removeValue(forKey: identifier) != nil else {
      return .failure(.keyNotFound(identifier: identifier))
    }
    return .success(())
  }

  func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
    return .success(Array(items.keys))
  }

  func getDataMetadata(for identifier: String) async -> Result<[String: String]?, XPCSecurityError> {
    guard let item = items[identifier] else {
      return .failure(.keyNotFound(identifier: identifier))
    }
    return .success(item.metadata)
  }
}

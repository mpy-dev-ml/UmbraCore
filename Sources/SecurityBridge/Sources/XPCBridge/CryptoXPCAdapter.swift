import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// CryptoXPCAdapter provides an implementation of CryptoServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles cryptographic operations by delegating to an XPC service,
/// while managing the type conversions between Foundation types and SecureBytes.
public final class CryptoXPCAdapter: NSObject, BaseXPCAdapter {
  // MARK: - Properties

  /// The NSXPCConnection used to communicate with the XPC service
  public let connection: NSXPCConnection

  /// The service proxy for making XPC calls
  private let serviceProxy: any ComprehensiveSecurityServiceProtocol

  // MARK: - Initialisation

  /// Initialise with an NSXPCConnection
  /// - Parameter connection: The connection to the XPC service
  public init(connection: NSXPCConnection, serviceProxy: any ComprehensiveSecurityServiceProtocol) {
    self.connection=connection
    self.serviceProxy=serviceProxy
    super.init()
    setupInvalidationHandler()
  }

  // MARK: - Helper Methods

  /// Maps internal XPC errors to SecurityProtocolsCore error types
  private func mapXPCError(_ error: NSError) -> UmbraErrors.Security.XPC {
    mapSecurityError(error)
  }
}

// MARK: - CryptoServiceProtocol Implementation

extension CryptoXPCAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
  public func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
    // Map XPC error type to Protocols error type for protocol compliance
    let result=await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.getServiceVersion()
        continuation.resume(returning: result != nil)
      }
    }
    return .success(result)
  }

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert internal XPC error type to Protocols error type
    let result=await encrypt(data: data, key: key)
    switch result {
      case let .success(data):
        return .success(data)
      case let .failure(error):
        // Map XPC error to Protocol error
        return .failure(mapToProtocolError(error))
    }
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert internal XPC error type to Protocols error type
    let result=await decrypt(data: data, key: key)
    switch result {
      case let .success(data):
        return .success(data)
      case let .failure(error):
        // Map XPC error to Protocol error
        return .failure(mapToProtocolError(error))
    }
  }

  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert internal XPC error type to Protocols error type
    let result=await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.generateKey()
        continuation.resume(returning: result)
      }
    }

    switch result {
      case let .success(key):
        return .success(key)
      case let .failure(error):
        // Map XPC error to Protocol error
        return .failure(mapToProtocolError(error))
    }
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert internal XPC error type to Protocols error type
    let result=await hash(data: data)
    switch result {
      case let .success(hash):
        return .success(hash)
      case let .failure(error):
        // Map XPC error to Protocol error
        return .failure(mapToProtocolError(error))
    }
  }

  // XPC-specific implementations

  public func encrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    let keyData=key.map { DataAdapter.data(from: $0) }

    return await withCheckedContinuation { continuation in
      Task {
        // Use encryptData instead of encrypt
        let result=await serviceProxy.encryptData(
          data: DataAdapter.data(from: data),
          key: keyData ?? Data()
        )

        // Map the XPC result to the protocol result
        switch result {
          case let .success(data):
            continuation.resume(returning: .success(DataAdapter.secureBytes(from: data)))
          case let .failure(error):
            continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    await encrypt(data: data, key: key)
  }

  public func decrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    let keyData=key.map { DataAdapter.data(from: $0) }

    return await withCheckedContinuation { continuation in
      Task {
        // Use decryptData instead of decrypt
        let result=await serviceProxy.decryptData(
          data: DataAdapter.data(from: data),
          key: keyData ?? Data()
        )

        // Map the XPC result to the protocol result
        switch result {
          case let .success(data):
            continuation.resume(returning: .success(DataAdapter.secureBytes(from: data)))
          case let .failure(error):
            continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    await decrypt(data: data, key: key)
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    await withCheckedContinuation { continuation in
      Task {
        // Use hashData instead of hash
        let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))

        // Map the XPC result to the protocol result
        switch result {
          case let .success(data):
            continuation.resume(returning: .success(DataAdapter.secureBytes(from: data)))
          case let .failure(error):
            continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func hash(
    data: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let result=await hash(data: data)
    switch result {
      case let .success(hashData):
        return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
      case let .failure(error):
        return SecurityProtocolsCore.SecurityResultDTO(success: false, error: error)
    }
  }
}

// MARK: - DataAdapter Utility

/// Utility for handling data conversions
private enum DataAdapter {
  /// Convert SecureBytes to Data
  static func data(from secureBytes: SecureBytes) -> Data {
    Data(secureBytes.bytes)
  }

  /// Convert Data to SecureBytes
  static func secureBytes(from data: Data) -> SecureBytes {
    SecureBytes(bytes: [UInt8](data))
  }
}

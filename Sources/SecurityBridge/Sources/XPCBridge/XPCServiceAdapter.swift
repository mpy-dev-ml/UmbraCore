import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// XPCServiceAdapter provides a bridge for XPC service communication that requires Foundation
/// types.
///
/// This adapter converts between Foundation-dependent XPC service protocols and
/// Foundation-independent security protocols. It handles the serialization/deserialization
/// needed for XPC communication while maintaining the domain-specific type system.
public final class XPCServiceAdapter {
  // MARK: - Properties

  /// The XPC connection to the security service
  private let connection: NSXPCConnection

  /// The remote XPC service proxy
  private let serviceProxy: any FoundationXPCSecurityService

  // MARK: - Initialization

  /// Create a new XPCServiceAdapter
  /// - Parameter connection: The XPC connection to use
  public init(connection: NSXPCConnection) {
    self.connection=connection

    // Configure the connection
    connection.remoteObjectInterface=NSXPCInterface(with: FoundationXPCSecurityService.self)
    connection.resume()

    // Get the service proxy
    serviceProxy=connection.remoteObjectProxy as! any FoundationXPCSecurityService
  }

  // MARK: - Crypto Service Adapter

  /// Create a CryptoServiceProtocol implementation that communicates over XPC
  /// - Returns: A CryptoServiceProtocol implementation
  public func createCryptoService() -> CryptoServiceProtocol {
    XPCCryptoServiceAdapter(serviceProxy: serviceProxy)
  }

  /// Create a KeyManagementProtocol implementation that communicates over XPC
  /// - Returns: A KeyManagementProtocol implementation
  public func createKeyManagement() -> KeyManagementProtocol {
    XPCKeyManagementAdapter(serviceProxy: serviceProxy)
  }
}

/// Protocol for XPC-compatible security services using Foundation types
/// This is the Objective-C compatible portion of the protocol
@objc
public protocol FoundationXPCSecurityService {
  // Basic crypto methods
  func encrypt(data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void)
  func decrypt(data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void)
  func generateKey(completion: @escaping (Data?, Error?) -> Void)
  func generateRandomData(length: Int, completion: @escaping (Data?, Error?) -> Void)

  // Key management methods
  func retrieveKey(identifier: String, completion: @escaping (Data?, Error?) -> Void)
  func storeKey(key: Data, identifier: String, completion: @escaping (Error?) -> Void)
  func deleteKey(identifier: String, completion: @escaping (Error?) -> Void)
  func listKeyIdentifiers(completion: @escaping ([String]?, Error?) -> Void)

  // Extended methods - these use serializable result types for Objective-C compatibility
  func encryptSymmetricXPC(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    optionsJson: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  )

  func decryptSymmetricXPC(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    optionsJson: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  )

  func encryptAsymmetricXPC(
    data: Data,
    publicKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    optionsJson: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  )

  func decryptAsymmetricXPC(
    data: Data,
    privateKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    optionsJson: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  )

  func hashDataXPC(
    data: Data,
    algorithm: String,
    optionsJson: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  )
}

/// Adapter that implements CryptoServiceProtocol using an XPC connection
private final class XPCCryptoServiceAdapter: CryptoServiceProtocol, @unchecked Sendable {
  private let serviceProxy: any FoundationXPCSecurityService

  init(serviceProxy: any FoundationXPCSecurityService) {
    self.serviceProxy=serviceProxy
  }

  func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.encrypt(
        data: DataAdapter.data(from: data),
        key: DataAdapter.data(from: key)
      ) { encryptedData, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let encryptedData else {
          continuation.resume(returning: .failure(.internalError("XPC service returned nil data")))
          return
        }

        continuation.resume(returning: .success(DataAdapter.secureBytes(from: encryptedData)))
      }
    }
  }

  func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.decrypt(
        data: DataAdapter.data(from: data),
        key: DataAdapter.data(from: key)
      ) { decryptedData, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let decryptedData else {
          continuation.resume(returning: .failure(.internalError("XPC service returned nil data")))
          return
        }

        continuation.resume(returning: .success(DataAdapter.secureBytes(from: decryptedData)))
      }
    }
  }

  func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.generateKey { keyData, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let keyData else {
          continuation.resume(returning: .failure(.internalError("XPC service returned nil key")))
          return
        }

        continuation.resume(returning: .success(DataAdapter.secureBytes(from: keyData)))
      }
    }
  }

  func hash(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // For now, we'll use the hash method from the new implementation
    let result=await hashData(
      data: data,
      config: config
    )

    if result.success, let hashData=result.data {
      return .success(hashData)
    } else {
      return .failure(.internalError(result.errorMessage ?? "Unknown hashing error"))
    }
  }

  func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    // Implementation using XPC - for now, compute the hash and compare
    let hashResult=await self.hash(
      data: data,
      config: SecurityConfigDTO(algorithm: "SHA-256", keySizeInBits: 256)
    )

    switch hashResult {
      case let .success(computedHash):
        return computedHash == hash
      case .failure:
        return false
    }
  }

  func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.generateRandomData(length: length) { randomData, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let randomData else {
          continuation.resume(
            returning: .failure(.internalError("XPC service returned nil random data"))
          )
          return
        }

        continuation.resume(returning: .success(DataAdapter.secureBytes(from: randomData)))
      }
    }
  }

  // MARK: - Advanced Crypto Methods

  func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await withCheckedContinuation { continuation in
      // Convert options dictionary to JSON string for XPC compatibility
      let optionsJson=(try? JSONSerialization.data(withJSONObject: config.options, options: []))
        .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

      self.serviceProxy.encryptSymmetricXPC(
        data: DataAdapter.data(from: data),
        key: DataAdapter.data(from: key),
        algorithm: config.algorithm,
        keySizeInBits: config.keySizeInBits,
        iv: config.iv.map { DataAdapter.data(from: $0) },
        aad: config.aad.map { DataAdapter.data(from: $0) },
        optionsJson: optionsJson
      ) { resultData, statusCode, errorMessage in
        let secureData=resultData.map { DataAdapter.secureBytes(from: $0) }
        let success=statusCode?.boolValue ?? false

        continuation.resume(
          returning: SecurityResultDTO(
            success: success,
            data: secureData,
            errorMessage: errorMessage
          )
        )
      }
    }
  }

  func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await withCheckedContinuation { continuation in
      // Convert options dictionary to JSON string for XPC compatibility
      let optionsJson=(try? JSONSerialization.data(withJSONObject: config.options, options: []))
        .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

      self.serviceProxy.decryptSymmetricXPC(
        data: DataAdapter.data(from: data),
        key: DataAdapter.data(from: key),
        algorithm: config.algorithm,
        keySizeInBits: config.keySizeInBits,
        iv: config.iv.map { DataAdapter.data(from: $0) },
        aad: config.aad.map { DataAdapter.data(from: $0) },
        optionsJson: optionsJson
      ) { resultData, statusCode, errorMessage in
        let secureData=resultData.map { DataAdapter.secureBytes(from: $0) }
        let success=statusCode?.boolValue ?? false

        continuation.resume(
          returning: SecurityResultDTO(
            success: success,
            data: secureData,
            errorMessage: errorMessage
          )
        )
      }
    }
  }

  func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await withCheckedContinuation { continuation in
      // Convert options dictionary to JSON string for XPC compatibility
      let optionsJson=(try? JSONSerialization.data(withJSONObject: config.options, options: []))
        .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

      self.serviceProxy.encryptAsymmetricXPC(
        data: DataAdapter.data(from: data),
        publicKey: DataAdapter.data(from: publicKey),
        algorithm: config.algorithm,
        keySizeInBits: config.keySizeInBits,
        optionsJson: optionsJson
      ) { resultData, statusCode, errorMessage in
        let secureData=resultData.map { DataAdapter.secureBytes(from: $0) }
        let success=statusCode?.boolValue ?? false

        continuation.resume(
          returning: SecurityResultDTO(
            success: success,
            data: secureData,
            errorMessage: errorMessage
          )
        )
      }
    }
  }

  func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await withCheckedContinuation { continuation in
      // Convert options dictionary to JSON string for XPC compatibility
      let optionsJson=(try? JSONSerialization.data(withJSONObject: config.options, options: []))
        .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

      self.serviceProxy.decryptAsymmetricXPC(
        data: DataAdapter.data(from: data),
        privateKey: DataAdapter.data(from: privateKey),
        algorithm: config.algorithm,
        keySizeInBits: config.keySizeInBits,
        optionsJson: optionsJson
      ) { resultData, statusCode, errorMessage in
        let secureData=resultData.map { DataAdapter.secureBytes(from: $0) }
        let success=statusCode?.boolValue ?? false

        continuation.resume(
          returning: SecurityResultDTO(
            success: success,
            data: secureData,
            errorMessage: errorMessage
          )
        )
      }
    }
  }

  func hashData(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    await withCheckedContinuation { continuation in
      // Convert options dictionary to JSON string for XPC compatibility
      let optionsJson=(try? JSONSerialization.data(withJSONObject: config.options, options: []))
        .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

      self.serviceProxy.hashDataXPC(
        data: DataAdapter.data(from: data),
        algorithm: config.algorithm,
        optionsJson: optionsJson
      ) { resultData, statusCode, errorMessage in
        let secureData=resultData.map { DataAdapter.secureBytes(from: $0) }
        let success=statusCode?.boolValue ?? false

        continuation.resume(
          returning: SecurityResultDTO(
            success: success,
            data: secureData,
            errorMessage: errorMessage
          )
        )
      }
    }
  }

  // Helper to map XPC errors to XPCSecurityError
  private func mapXPCError(_ error: Error) -> XPCSecurityError {
    // Implement error mapping based on the XPC error types
    .internalError("XPC error: \(error.localizedDescription)")
  }
}

/// Adapter that implements KeyManagementProtocol using an XPC connection
private final class XPCKeyManagementAdapter: KeyManagementProtocol, @unchecked Sendable {
  private let serviceProxy: any FoundationXPCSecurityService

  init(serviceProxy: any FoundationXPCSecurityService) {
    self.serviceProxy=serviceProxy
  }

  func retrieveKey(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.retrieveKey(identifier: identifier) { keyData, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let keyData else {
          continuation.resume(
            returning: .failure(.keyManagementError("Key not found: \(identifier)"))
          )
          return
        }

        continuation.resume(returning: .success(DataAdapter.secureBytes(from: keyData)))
      }
    }
  }

  func storeKey(key: SecureBytes, identifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.storeKey(
        key: DataAdapter.data(from: key),
        identifier: identifier
      ) { error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }

  func deleteKey(identifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.deleteKey(identifier: identifier) { error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }

  func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
    await withCheckedContinuation { continuation in
      self.serviceProxy.listKeyIdentifiers { identifiers, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
          return
        }

        guard let identifiers else {
          continuation.resume(returning: .failure(.internalError("XPC service returned nil list")))
          return
        }

        continuation.resume(returning: .success(identifiers))
      }
    }
  }

  // Helper to map XPC errors to XPCSecurityError
  private func mapXPCError(_ error: Error) -> XPCSecurityError {
    // Implement error mapping based on the XPC error types
    .internalError("XPC error: \(error.localizedDescription)")
  }
}

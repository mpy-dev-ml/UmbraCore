import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

// Removing duplicate type alias that's already defined in other files
// typealias SPCSecurityError=UmbraErrors.Security.Protocols

/// CryptoServiceAdapter provides a bridge between Foundation-based cryptographic implementations
/// and the Foundation-free CryptoServiceProtocol.
///
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent
/// CryptoServiceProtocol interface.
public final class CryptoServiceAdapter: CryptoServiceProtocol, Sendable {
  // MARK: - Properties

  /// The Foundation-dependent cryptographic implementation
  private let implementation: any FoundationCryptoServiceImpl

  // MARK: - Initialization

  /// Create a new CryptoServiceAdapter
  /// - Parameter implementation: The Foundation-dependent crypto implementation
  public init(implementation: any FoundationCryptoServiceImpl) {
    self.implementation=implementation
  }

  // MARK: - CryptoServiceProtocol Implementation

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert SecureBytes to Data for the Foundation implementation
    let dataToEncrypt=DataAdapter.data(from: data)
    let keyData=DataAdapter.data(from: key)

    // Call the implementation
    let result=await implementation.encrypt(data: dataToEncrypt, using: keyData)

    // Convert the result back to the protocol's types
    switch result {
      case let .success(encryptedData):
        return .success(DataAdapter.secureBytes(from: encryptedData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Convert SecureBytes to Data for the Foundation implementation
    let encryptedData=DataAdapter.data(from: data)
    let keyData=DataAdapter.data(from: key)

    // Call the implementation
    let result=await implementation.decrypt(data: encryptedData, using: keyData)

    // Convert the result back to the protocol's types
    switch result {
      case let .success(decryptedData):
        return .success(DataAdapter.secureBytes(from: decryptedData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result=await implementation.generateKey()

    switch result {
      case let .success(keyData):
        return .success(DataAdapter.secureBytes(from: keyData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let dataToHash=DataAdapter.data(from: data)
    let result=await implementation.hash(data: dataToHash)

    switch result {
      case let .success(hashData):
        return .success(DataAdapter.secureBytes(from: hashData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func verify(
    data: SecureBytes,
    against hash: SecureBytes
  ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
    let dataToVerify=DataAdapter.data(from: data)
    let hashData=DataAdapter.data(from: hash)

    // The implementation.verify method doesn't throw errors, so we don't need a try-catch block
    let isValid=await implementation.verify(data: dataToVerify, against: hashData)
    return .success(isValid)
  }

  /// Generate cryptographically secure random data
  /// - Parameter length: Number of random bytes to generate
  /// - Returns: Result containing random data or error
  public func generateRandomData(length: Int) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Call the implementation
    let result=await implementation.generateRandomData(length: length)

    // Convert the result back to the protocol's types
    switch result {
      case let .success(randomData):
        return .success(DataAdapter.secureBytes(from: randomData))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let dataToEncrypt=DataAdapter.data(from: data)
    let keyData=DataAdapter.data(from: key)

    // Extract configuration options if present
    let algorithm=cryptoAlgorithmFrom(config)
    let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
    let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

    // Configure encrypt options
    var options: [String: Any]=[:]
    if let algorithm {
      options["algorithm"]=algorithm
    }
    if let ivData {
      options["iv"]=ivData
    }
    if let aadData {
      options["aad"]=aadData
    }

    let encryptResult=await implementation.encryptSymmetric(
      data: dataToEncrypt,
      key: keyData,
      algorithm: config.algorithm,
      keySizeInBits: config.keySizeInBits,
      iv: ivData,
      aad: aadData,
      options: config.options
    )

    // Process the result without unnecessary try-catch
    if encryptResult.success {
      guard let encryptedData=encryptResult.data else {
        return .failure(.internalError("Encryption succeeded but returned nil data"))
      }
      return .success(DataAdapter.secureBytes(from: encryptedData))
    } else {
      return .failure(mapFoundationSecurityResult(encryptResult))
    }
  }

  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let encryptedData=DataAdapter.data(from: data)
    let keyData=DataAdapter.data(from: key)

    // Extract configuration options if present
    let algorithm=cryptoAlgorithmFrom(config)
    let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
    let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

    // Configure decrypt options
    var options: [String: Any]=[:]
    if let algorithm {
      options["algorithm"]=algorithm
    }
    if let ivData {
      options["iv"]=ivData
    }
    if let aadData {
      options["aad"]=aadData
    }

    let decryptResult=await implementation.decryptSymmetric(
      data: encryptedData,
      key: keyData,
      algorithm: config.algorithm,
      keySizeInBits: config.keySizeInBits,
      iv: ivData,
      aad: aadData,
      options: config.options
    )

    // Process the result without unnecessary try-catch
    if decryptResult.success {
      guard let decryptedData=decryptResult.data else {
        return .failure(.internalError("Decryption succeeded but returned nil data"))
      }
      return .success(DataAdapter.secureBytes(from: decryptedData))
    } else {
      return .failure(mapFoundationSecurityResult(decryptResult))
    }
  }

  public func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let dataToEncrypt=DataAdapter.data(from: data)
    let publicKeyData=DataAdapter.data(from: publicKey)

    // Configure options
    var options: [String: Any]=[:]
    if let algorithm=cryptoAlgorithmFrom(config) {
      options["algorithm"]=algorithm
    }

    let encryptResult=await implementation.encryptAsymmetric(
      data: dataToEncrypt,
      publicKey: publicKeyData,
      algorithm: config.algorithm,
      keySizeInBits: config.keySizeInBits,
      options: config.options
    )

    // Process the result without unnecessary try-catch
    if encryptResult.success {
      guard let encryptedData=encryptResult.data else {
        return .failure(.internalError("Asymmetric encryption succeeded but returned nil data"))
      }
      return .success(DataAdapter.secureBytes(from: encryptedData))
    } else {
      return .failure(mapFoundationSecurityResult(encryptResult))
    }
  }

  public func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let encryptedData=DataAdapter.data(from: data)
    let privateKeyData=DataAdapter.data(from: privateKey)

    // Configure options
    var options: [String: Any]=[:]
    if let algorithm=cryptoAlgorithmFrom(config) {
      options["algorithm"]=algorithm
    }

    let decryptResult=await implementation.decryptAsymmetric(
      data: encryptedData,
      privateKey: privateKeyData,
      algorithm: config.algorithm,
      keySizeInBits: config.keySizeInBits,
      options: config.options
    )

    // Process the result without unnecessary try-catch
    if decryptResult.success {
      guard let decryptedData=decryptResult.data else {
        return .failure(.internalError("Asymmetric decryption succeeded but returned nil data"))
      }
      return .success(DataAdapter.secureBytes(from: decryptedData))
    } else {
      return .failure(mapFoundationSecurityResult(decryptResult))
    }
  }

  public func hash(
    data: SecureBytes,
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let dataToHash=DataAdapter.data(from: data)

    // Extract hash algorithm if specified
    let algorithm=cryptoAlgorithmFrom(config)

    // Configure options
    var options: [String: Any]=[:]
    if let algorithm {
      options["algorithm"]=algorithm
    }

    let hashResult=await implementation.hash(
      data: dataToHash,
      algorithm: config.algorithm,
      options: config.options
    )

    // Process the result without unnecessary try-catch
    if hashResult.success {
      guard let hashData=hashResult.data else {
        return .failure(.internalError("Hashing succeeded but returned nil data"))
      }
      return .success(DataAdapter.secureBytes(from: hashData))
    } else {
      return .failure(mapFoundationSecurityResult(hashResult))
    }
  }

  // MARK: - Helper Methods

  /// Extract the cryptographic algorithm from the security configuration
  /// - Parameter config: Security configuration
  /// - Returns: Algorithm string or nil if not specified
  private func cryptoAlgorithmFrom(_ config: SecurityConfigDTO) -> String? {
    config.algorithm.isEmpty ? nil : config.algorithm
  }

  /// Map any error to a Security.Protocols error
  /// - Parameter error: Original error
  /// - Returns: A Security.Protocols error
  private func mapError(_ error: Error) -> UmbraErrors.Security.Protocols {
    if let securityError=error as? UmbraErrors.Security.Protocols {
      return securityError
    }
    return CoreErrors.SecurityErrorMapper.mapToProtocolError(error)
  }

  /// Map a FoundationSecurityResult to a Security.Protocols error
  /// - Parameter result: The failed result
  /// - Returns: A Security.Protocols error
  private func mapFoundationSecurityResult(_ result: FoundationSecurityResult) -> UmbraErrors
  .Security.Protocols {
    let errorMessage=result.errorMessage ?? "Unknown error"
    let errorCode=result.errorCode ?? -1

    return .internalError("\(errorMessage) (Code: \(errorCode))")
  }
}

/// Protocol for Foundation-dependent cryptographic implementations
/// that can be adapted to the Foundation-free CryptoServiceProtocol
public protocol FoundationCryptoServiceImpl: Sendable, RandomDataGenerating {
  func encrypt(data: Data, using key: Data) async -> Result<Data, Error>
  func decrypt(data: Data, using key: Data) async -> Result<Data, Error>
  func generateKey() async -> Result<Data, Error>
  func hash(data: Data) async -> Result<Data, Error>
  func verify(data: Data, against hash: Data) async -> Bool

  /// Generate cryptographically secure random data
  /// - Parameter length: The length of random data to generate in bytes
  /// - Returns: Result containing the random data or an error
  func generateRandomData(length: Int) async -> Result<Data, Error>

  // Symmetric encryption
  func encryptSymmetric(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    options: [String: String]
  ) async -> FoundationSecurityResult

  // Symmetric decryption
  func decryptSymmetric(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    options: [String: String]
  ) async -> FoundationSecurityResult

  // Asymmetric encryption
  func encryptAsymmetric(
    data: Data,
    publicKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    options: [String: String]
  ) async -> FoundationSecurityResult

  // Asymmetric decryption
  func decryptAsymmetric(
    data: Data,
    privateKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    options: [String: String]
  ) async -> FoundationSecurityResult

  // Hashing
  func hash(
    data: Data,
    algorithm: String,
    options: [String: String]
  ) async -> FoundationSecurityResult
}

/// Foundation-based security operation result
public struct FoundationSecurityResult: Sendable {
  public let success: Bool
  public let data: Data?
  public let errorCode: Int?
  public let errorMessage: String?

  public init(data: Data) {
    success=true
    self.data=data
    errorCode=nil
    errorMessage=nil
  }

  public init() {
    success=true
    data=nil
    errorCode=nil
    errorMessage=nil
  }

  public init(errorCode: Int, errorMessage: String) {
    success=false
    data=nil
    self.errorCode=errorCode
    self.errorMessage=errorMessage
  }
}

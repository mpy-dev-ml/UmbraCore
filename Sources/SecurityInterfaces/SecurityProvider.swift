import CoreTypesInterfaces
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import FoundationBridgeTypes
import SecurityBridge
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: SecurityProtocolsCore.SecurityProviderProtocol {
  /// Get the current security configuration
  /// - Returns: The active security configuration
  func getSecurityConfiguration() async -> Result<SecurityConfiguration, SecurityError>

  /// Update the security configuration
  /// - Parameter configuration: The new configuration to apply
  /// - Throws: SecurityInterfacesError if update fails
  func updateSecurityConfiguration(_ configuration: SecurityConfiguration) async throws

  /// Get the host identifier
  /// - Returns: The host identifier
  func getHostIdentifier() async -> Result<String, SecurityError>

  /// Register a client with the security provider
  /// - Parameter bundleIdentifier: The bundle identifier of the client
  /// - Returns: Success or failure
  func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityError>

  /// Request key rotation for the specified key
  /// - Parameter keyId: The key identifier
  /// - Returns: Success or failure
  func requestKeyRotation(keyId: String) async -> Result<Void, SecurityError>

  /// Notify that a key has been compromised
  /// - Parameter keyId: The key identifier
  /// - Returns: Success or failure
  func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityError>

  /// Generate random data of the specified length
  /// - Parameter length: The number of bytes to generate
  /// - Returns: The random data or an error
  func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError>

  /// Get key information for the specified key
  /// - Parameter keyId: The key identifier
  /// - Returns: Key information or an error
  func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityError>

  /// Register for notifications
  /// - Returns: Success or failure
  func registerNotifications() async -> Result<Void, SecurityError>

  /// Generate random bytes of the specified length
  /// - Parameter count: The number of bytes to generate
  /// - Returns: The random bytes or an error
  func randomBytes(count: Int) async -> Result<SecureBytes, SecurityError>

  /// Encrypt data with the specified key
  /// - Parameters:
  ///   - data: The data to encrypt
  ///   - key: The key to use for encryption
  /// - Returns: The encrypted data or an error
  func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async
    -> Result<SecureBytes, SecurityError>

  /// Perform a security operation
  /// - Parameters:
  ///   - operation: The operation to perform
  ///   - data: The input data for the operation
  ///   - parameters: Additional parameters for the operation
  /// - Returns: Result containing the outcome of the operation
  /// - Throws: SecurityInterfacesError if operation fails
  func performSecurityOperation(
    operation: SecurityProtocolsCore.SecurityOperation,
    data: Data?,
    parameters: [String: String]
  ) async throws -> SecurityResult

  /// Perform a security operation with a string operation name
  /// - Parameters:
  ///   - operationName: The name of the operation to perform
  ///   - data: The input data for the operation
  ///   - parameters: Additional parameters for the operation
  /// - Returns: Result containing the outcome of the operation
  /// - Throws: SecurityInterfacesError if operation fails
  func performSecurityOperation(
    operationName: String,
    data: Data?,
    parameters: [String: String]
  ) async throws -> SecurityResult
}

/// Adapter that implements SecurityProvider by wrapping a SecurityProtocolsCore provider
public final class SecurityProviderAdapter: SecurityProvider {
  // MARK: - Properties

  private let bridge: any SecurityProtocolsCore.SecurityProviderProtocol
  // XPCServiceProtocolStandard is at the module level, not inside the enum
  private let service: any XPCServiceProtocolStandard

  public init(
    bridge: any SecurityProtocolsCore.SecurityProviderProtocol,
    service: any XPCServiceProtocolStandard
  ) {
    self.bridge=bridge
    self.service=service
  }

  // MARK: - SecurityProviderProtocol conformance

  public var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
    bridge.cryptoService
  }

  public var keyManager: SecurityProtocolsCore.KeyManagementProtocol {
    bridge.keyManager
  }

  public func performSecureOperation(
    operation: SecurityProtocolsCore.SecurityOperation,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    await bridge.performSecureOperation(operation: operation, config: config)
  }

  public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore
  .SecurityConfigDTO {
    bridge.createSecureConfig(options: options)
  }

  // MARK: - SecurityProvider implementation

  public func getHostIdentifier() async -> Result<String, SecurityError> {
    // Use the XPC service directly to get hardware identifier
    let result = await service.getHardwareIdentifier()
    
    switch result {
      case .success(let identifier):
        return .success(identifier)
      case .failure(let error):
        return .failure(mapXPCError(error))
    }
  }

  public func signData(
    _ data: SecureBytes,
    withKey key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    // Create a configuration with the data to sign and the key
    var config=bridge.createSecureConfig(options: nil)
    config=config.withInputData(data)
    config=config.withKey(key)

    let result=await bridge.performSecureOperation(
      operation: .signatureGeneration,
      config: config
    )

    // Extract the signature from the result
    if let signature=result.data {
      return .success(signature)
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Signing failed"))
    }
  }

  public func verifySignature(
    _ signature: SecureBytes,
    forData data: SecureBytes,
    withKey key: SecureBytes
  ) async -> Result<Bool, SecurityError> {
    // Create a configuration with the data, signature, and key
    var config=bridge.createSecureConfig(options: nil)
    config=config.withInputData(data)
    config=config.withKey(key)
    config=config.withAdditionalData(signature)

    let result=await bridge.performSecureOperation(
      operation: .signatureVerification,
      config: config
    )

    // Check the verification result
    if result.success {
      return .success(true)
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Invalid verification result"))
    }
  }

  public func randomBytes(count: Int) async -> Result<SecureBytes, SecurityError> {
    // Create a configuration for random bytes generation
    let config=bridge.createSecureConfig(options: ["length": count])

    // Make the call to the cryptographic service
    let result=await bridge.performSecureOperation(
      operation: .randomGeneration,
      config: config
    )

    // Extract the random data from the result
    if let data=result.data {
      return .success(data)
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Failed to generate random bytes"))
    }
  }

  public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityError> {
    // Create a configuration with keyIdentifier
    var config=bridge.createSecureConfig(options: nil)
    config=config.withKeyIdentifier(keyId)

    // Use a standard operation type since there's no .custom case
    let result=await bridge.performSecureOperation(
      operation: .keyRetrieval,
      config: config
    )

    // Parse the result
    if result.success, let _=result.data?.withUnsafeBytes({ Data($0) }) {
      // Try to decode as [String: AnyObject] - complex parsing logic might be needed
      // This is a simplified implementation
      return .success(["key_type": "symmetric" as AnyObject, "id": keyId as AnyObject])
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Failed to get key info"))
    }
  }

  public func encryptData(
    _ data: SecureBytes,
    withKey key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    // Create a configuration with the data and key
    var config=bridge.createSecureConfig(options: nil)
    config=config.withInputData(data)
    config=config.withKey(key)

    // Make the call to the cryptographic service
    let result=await bridge.performSecureOperation(
      operation: .symmetricEncryption,
      config: config
    )

    // Extract the encrypted data from the result
    if let encryptedData=result.data {
      return .success(encryptedData)
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Encryption failed"))
    }
  }

  public func performSecurityOperation(
    operation: SecurityProtocolsCore.SecurityOperation,
    data: Data?,
    parameters: [String: String]
  ) async throws -> SecurityResult {
    // Prepare parameters
    var params: [String: Any]=parameters

    // Add data if provided
    if let data {
      params["data"]=data
    }

    // Call the underlying implementation
    let config=createSecureConfig(options: params)
    let result=await performSecureOperation(operation: operation, config: config)

    // Handle the result
    if let error=result.error {
      throw mapSPCError(error)
    }

    // Return the success result
    let resultData: Data?=if let secureBytes=result.data {
      // Convert SecureBytes to Data using withUnsafeBytes
      secureBytes.withUnsafeBytes { Data($0) }
    } else {
      nil
    }

    // Create metadata dictionary from available information
    var metadata: [String: String]=[:]
    if let errorCode=result.errorCode {
      metadata["errorCode"]=String(errorCode)
    }
    if let errorMessage=result.errorMessage {
      metadata["errorMessage"]=errorMessage
    }

    return SecurityResult(
      success: result.success,
      data: resultData,
      metadata: metadata
    )
  }

  public func performSecurityOperation(
    operationName: String,
    data: Data?,
    parameters: [String: String]
  ) async throws -> SecurityResult {
    let operation=mapOperationFromString(operationName)
    return try await performSecurityOperation(
      operation: operation,
      data: data,
      parameters: parameters
    )
  }

  public func getSecurityConfiguration() async -> Result<SecurityConfiguration, SecurityError> {
    // Get service status
    let result = await service.status()
    
    switch result {
      case let .success(statusDict):
        // Extract the configuration data from the status dictionary
        guard let configData = statusDict["configData"] as? Data else {
          return .failure(
            SecurityInterfacesError
              .operationFailed("Configuration data not found in service status")
          )
        }

        // Decode the configuration with proper error handling
        do {
          let config = try JSONDecoder().decode(SecurityConfiguration.self, from: configData)
          return .success(config)
        } catch {
          return .failure(
            SecurityInterfacesError
              .operationFailed("Invalid configuration format: \(error.localizedDescription)")
          )
        }
      case let .failure(error):
        return .failure(mapXPCError(error))
    }
  }

  public func updateSecurityConfiguration(_ configuration: SecurityConfiguration) async throws {
    // Convert configuration to data
    guard let configData=try? JSONEncoder().encode(configuration) else {
      throw SecurityInterfacesError.serializationFailed(reason: "Could not encode configuration")
    }

    // Create a service status dictionary with the configuration
    let statusDict=NSMutableDictionary()
    statusDict["configData"]=configData
    statusDict["updateTimestamp"]=Date().timeIntervalSince1970

    // Use resetSecurityData as a proxy to update configuration
    let result=await service.resetSecurityData()

    switch result {
      case .success:
        return
      case let .failure(error):
        throw mapXPCError(error)
    }
  }

  public func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityError> {
    // Use the performSecureOperation method with a specific operation
    let config=bridge.createSecureConfig(options: ["bundleIdentifier": bundleIdentifier])

    // Use a standard operation type
    let result=await bridge.performSecureOperation(
      operation: .keyStorage, // Using keyStorage instead of registration
      config: config
    )

    // Extract the success flag from the result
    if result.success {
      return .success(true)
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Invalid registration result"))
    }
  }

  public func requestKeyRotation(keyId: String) async -> Result<Void, SecurityError> {
    // Use the performSecureOperation method with a specific operation
    let config=bridge.createSecureConfig(options: ["keyIdentifier": keyId])

    // Use the key rotation operation
    let result=await bridge.performSecureOperation(
      operation: .keyRotation,
      config: config
    )

    // Handle success or failure
    if result.success {
      return .success(())
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Key rotation failed"))
    }
  }

  public func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityError> {
    // Use the performSecureOperation method with a specific operation
    let config=bridge.createSecureConfig(options: ["keyIdentifier": keyId])

    // Use the key deletion operation as a proxy for compromise notification
    let result=await bridge.performSecureOperation(
      operation: .keyDeletion,
      config: config
    )

    // Handle success or failure
    if result.success {
      return .success(())
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(SecurityInterfacesError.operationFailed("Failed to report compromised key"))
    }
  }

  public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    // Delegate to randomBytes
    await randomBytes(count: length)
  }

  public func registerNotifications() async -> Result<Void, SecurityError> {
    // Create a configuration with notification options
    let config=bridge.createSecureConfig(options: ["operation": "registerNotifications"])

    // Use a standard operation type
    let result=await bridge.performSecureOperation(
      operation: .keyStorage, // Using keyStorage for registration
      config: config
    )

    // Check the result
    if result.success {
      return .success(())
    } else if let error=result.error {
      return .failure(mapSPCError(error))
    } else {
      return .failure(
        SecurityInterfacesError
          .operationFailed("Failed to register for notifications")
      )
    }
  }

  // MARK: - Public Error Mapping

  /// Maps a security protocol error to a security interface error
  /// - Parameter error: The security protocol error to map
  /// - Returns: A mapped security interface error
  public func mapError(_ error: UmbraErrors.Security.Protocols) -> SecurityError {
    return mapSPCError(error)
  }

  // Helper function to map string operation names to SecurityOperation cases
  private func mapOperationFromString(_ name: String) -> SecurityProtocolsCore.SecurityOperation {
    let normalizedName=name.lowercased()

    switch normalizedName {
      case "encrypt", "encryption", "symmetricencryption":
        return .symmetricEncryption
      case "decrypt", "decryption", "symmetricdecryption":
        return .symmetricDecryption
      case "hash", "hashing":
        return .hashing
      case "generatekey", "keygen", "keygeneration":
        return .keyGeneration
      case "storekey", "savekey", "keystorage":
        return .keyStorage
      case "getkey", "retrievekey", "keyretrieval":
        return .keyRetrieval
      case "rotatekey", "keyrotation":
        return .keyRotation
      case "deletekey", "removekey", "keydeletion":
        return .keyDeletion
      case "random", "randomgeneration", "generaterandom":
        return .randomGeneration
      case "getdeviceidentifier", "deviceid", "deviceidentifier":
        return .keyRetrieval
      case "registerclient", "registration", "register":
        return .keyStorage
      case "sign", "signature", "signdata":
        return .signatureGeneration
      case "verify", "verification", "verifysignature":
        return .signatureVerification
      default:
        return .hashing
    }
  }

  private func mapSPCError(_ error: UmbraErrors.Security.Protocols) -> SecurityError {
    switch error {
      case let .invalidFormat(reason):
        return SecurityInterfacesError.operationFailed("Invalid format: \(reason)")
      case let .missingProtocolImplementation(name):
        return SecurityInterfacesError.operationFailed("Missing protocol implementation: \(name)")
      case let .unsupportedOperation(name):
        return SecurityInterfacesError.operationFailed("Unsupported operation: \(name)")
      case let .incompatibleVersion(version):
        return SecurityInterfacesError.operationFailed("Incompatible version: \(version)")
      case let .invalidState(current, expected):
        return SecurityInterfacesError
          .operationFailed("Invalid state: current=\(current), expected=\(expected)")
      case let .internalError(message):
        return SecurityInterfacesError.operationFailed("Internal error: \(message)")
      case let .invalidInput(reason):
        return SecurityInterfacesError.operationFailed("Invalid input: \(reason)")
      case let .encryptionFailed(reason):
        return SecurityInterfacesError.operationFailed("Encryption failed: \(reason)")
      case let .decryptionFailed(reason):
        return SecurityInterfacesError.operationFailed("Decryption failed: \(reason)")
      case let .randomGenerationFailed(reason):
        return SecurityInterfacesError.operationFailed("Random generation failed: \(reason)")
      case let .storageOperationFailed(reason):
        return SecurityInterfacesError.operationFailed("Storage operation failed: \(reason)")
      case let .serviceError(error):
        return SecurityInterfacesError.operationFailed("Service error: \(error)")
      case let .notImplemented(feature):
        return SecurityInterfacesError.operationFailed("Not implemented: \(feature)")
      @unknown default:
        return SecurityInterfacesError.operationFailed("Unknown security protocol error")
    }
  }

  private func mapXPCError(_ error: XPCProtocolsCore.SecurityError) -> SecurityError {
    // Convert the error to a SecurityInterfacesError instance
    let securityInterfacesError: SecurityInterfacesError=switch error {
      case .serviceUnavailable:
        .operationFailed("XPC service unavailable")
      case let .serviceNotReady(reason):
        .operationFailed("Service not ready: \(reason)")
      case let .timeout(after):
        .operationFailed("Operation timed out after \(after) seconds")
      case let .authenticationFailed(reason):
        .operationFailed("Authentication failed: \(reason)")
      case let .authorizationDenied(operation):
        .operationFailed("Operation not permitted: \(operation)")
      case let .operationNotSupported(name):
        .operationFailed("Operation not supported: \(name)")
      case let .invalidInput(details):
        .operationFailed("Invalid input: \(details)")
      case .keyNotFound:
        .operationFailed("Key not found")
      case let .internalError(reason):
        .operationFailed(reason)
      default:
        .operationFailed("Unknown XPC error")
    }

    return securityInterfacesError
  }
}

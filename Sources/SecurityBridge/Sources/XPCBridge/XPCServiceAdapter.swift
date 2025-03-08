import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Constants for XPC service configuration
public enum XPCServiceConstants {
  public static let defaultServiceName="com.umbra.security.xpcservice"
}

/// XPCServiceAdapter provides a bridge for XPC service communication that requires Foundation
/// types.
///
/// This adapter connects to an XPC service and acts as a bridge to
/// Foundation-independent security protocols. It handles the serialization/deserialization
/// needed for XPC communication while maintaining the domain-specific type system.
@objc
public final class XPCServiceAdapter: NSObject, @unchecked Sendable {
  // MARK: - Properties

  public static var protocolIdentifier: String="com.umbra.security.xpc.bridge"

  private let serviceProxy: any ComprehensiveSecurityServiceProtocol
  private let connection: NSXPCConnection

  // MARK: - Initialization

  public init(connection: NSXPCConnection) {
    self.connection=connection

    let interface=NSXPCInterface(with: XPCServiceProtocolBasic.self)
    connection.remoteObjectInterface=interface

    // Set up interruption handler
    connection.interruptionHandler={
      NSLog("XPC connection interrupted")
    }

    // Set up invalidation handler
    connection.invalidationHandler={
      NSLog("XPC connection invalidated")
    }

    // Start the connection
    connection.resume()

    // Get the service proxy
    serviceProxy=connection.remoteObjectProxy as! any ComprehensiveSecurityServiceProtocol
  }

  deinit {
    connection.invalidate()
  }

  // MARK: - XPCServiceProtocolBasic Requirements

  @objc
  public func ping() async -> NSObject? {
    // Implement the @objc version required by XPCServiceProtocolBasic
    await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.getServiceVersion()
        switch result {
          case .success:
            continuation.resume(returning: NSNumber(value: true))
          case let .failure(error):
            continuation.resume(returning: error as NSError)
        }
      }
    }
  }

  @objc
  public func synchroniseKeys(_ syncData: NSData) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        // Convert NSData to SecureBytes
        let secureBytes=convertNSDataToSecureBytes(syncData)

        // Convert SecureBytes to NSData since serviceProxy expects NSData
        let nsData=convertSecureBytesToNSData(secureBytes)
        let result=await serviceProxy.synchroniseKeys(nsData)
        switch result {
          case .success:
            continuation.resume(returning: NSNull())
          case let .failure(error):
            continuation.resume(returning: error as NSError)
        }
      }
    }
  }

  // MARK: - Error Mapping

  private func mapSecurityError(_ error: Error) -> UmbraErrors.Security.Protocols {
    if let securityError=error as? UmbraErrors.Security.Protocols {
      securityError
    } else if let coreError=error as? CoreErrors.SecurityError {
      mapError(coreError)
    } else {
      UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    }
  }

  /// Map CoreErrors.SecurityError to UmbraErrors.Security.Protocols
  private func mapError(_ error: CoreErrors.SecurityError) -> UmbraErrors.Security.Protocols {
    switch error {
      case .encryptionFailed:
        UmbraErrors.Security.Protocols.internalError("Encryption operation failed")
      case .decryptionFailed:
        UmbraErrors.Security.Protocols.internalError("Decryption operation failed")
      case .keyGenerationFailed:
        UmbraErrors.Security.Protocols.internalError("Key generation failed")
      case .invalidData:
        UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data format")
      case .notImplemented:
        UmbraErrors.Security.Protocols.unsupportedOperation(name: "operation")
      case let .general(message):
        UmbraErrors.Security.Protocols.internalError(message)
      // Handle other cases with appropriate UmbraErrors.Security.Protocols types
      default:
        UmbraErrors.Security.Protocols.internalError("Security error: \(error)")
    }
  }

  /// Maps an XPC error to a SecurityError using the centralised error mapper.
  ///
  /// This method provides a consistent way of handling XPC errors throughout the application.
  /// - Parameter error: The XPC error to be mapped.
  /// - Returns: A SecurityError representing the XPC error.
  private func mapXPCError(_ error: Error) -> UmbraErrors.Security.Protocols {
    // Use the central error mapper to convert to UmbraErrors.Security.Protocols
    CoreErrors.SecurityErrorMapper.mapToProtocolError(error)
  }

  /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
  private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
    if error.domain == "com.umbra.security.xpc" {
      if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
        return UmbraErrors.Security.Protocols.internalError(message)
      } else {
        return UmbraErrors.Security.Protocols.internalError("Unknown error: \(error.code)")
      }
    } else {
      return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    }
  }

  /// Process security operation result for Swift-based code
  private func processSecurityResult<T>(
    _ result: NSObject?,
    transform: (NSData) -> T
  ) -> Result<T, UmbraErrors.Security.Protocols> {
    if let error=result as? NSError {
      .failure(mapSecurityError(error))
    } else if let nsData=result as? NSData {
      .success(transform(nsData))
    } else {
      .failure(UmbraErrors.Security.Protocols.internalError("Invalid result format"))
    }
  }
}

// MARK: - SecurityProtocolsCore.SecurityService Implementation

extension XPCServiceAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
  public func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.getServiceVersion()
        // Map the XPC result to the protocol result
        switch result {
          case .success:
            continuation.resume(returning: .success(true))
          case let .failure(error):
            continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func encrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
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
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await encrypt(data: data, key: key)
  }

  public func decrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
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
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await decrypt(data: data, key: key)
  }

  public func hash(data: SecureBytes) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
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

  public func verify(
    data: SecureBytes,
    against signature: SecureBytes
  ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.verify(
          data: DataAdapter.data(from: data),
          signature: DataAdapter.data(from: signature)
        )
        
        switch result {
        case .success(let verified):
          continuation.resume(returning: .success(verified))
        case .failure(let error):
          continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result=await encrypt(data: data, using: key)
    switch result {
      case let .success(encryptedData):
        return .success(encryptedData)
      case let .failure(error):
        return .failure(error)
    }
  }

  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    let result=await decrypt(data: data, using: key)
    switch result {
      case let .success(decryptedData):
        return .success(decryptedData)
      case let .failure(error):
        return .failure(error)
    }
  }

  public func encryptAsymmetric(
    data _: SecureBytes,
    publicKey _: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // XPC service doesn't directly support asymmetric encryption
    // Return error indicating unsupported operation
    .failure(UmbraErrors.Security.Protocols.unsupportedOperation(name: "asymmetric encryption"))
  }

  public func decryptAsymmetric(
    data _: SecureBytes,
    privateKey _: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // XPC service doesn't directly support asymmetric decryption
    // Return error indicating unsupported operation
    .failure(UmbraErrors.Security.Protocols.unsupportedOperation(name: "asymmetric decryption"))
  }

  public func hash(
    data: SecureBytes,
    config _: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await hash(data: data)
  }

  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.generateKey()
        // Map the XPC result to the protocol result
        switch result {
        case .success(let data):
          continuation.resume(returning: .success(DataAdapter.secureBytes(from: data)))
        case .failure(let error):
          continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func generateKeyPair(
    keyType: SecurityProtocolsCore.AsymmetricKeyType,
    keyIdentifier: String? = nil
  ) async -> Result<
    (publicKey: SecureBytes, privateKey: SecureBytes),
    UmbraErrors.Security.Protocols
  > {
    await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.generateKeyPair(
          type: keyType.rawValue,
          identifier: keyIdentifier ?? ""
        )
        
        switch result {
        case .success(let keyPair):
          let publicKey = DataAdapter.secureBytes(from: keyPair.publicKey)
          let privateKey = DataAdapter.secureBytes(from: keyPair.privateKey)
          continuation.resume(returning: .success((publicKey: publicKey, privateKey: privateKey)))
        case .failure(let error):
          continuation.resume(returning: .failure(mapXPCError(error)))
        }
      }
    }
  }

  public func generateRandomData(length: Int) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        // The serviceProxy.generateRandomData should return the correct type
        let result=await serviceProxy.generateRandomData(length: length)

        if let nsObject=result {
          if let nsError=nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let data=nsObject as? NSData {
            // Convert NSData to SecureBytes
            let dataBytes=[UInt8](Data(referencing: data))
            let secureBytes=SecureBytes(bytes: dataBytes)
            continuation.resume(returning: .success(secureBytes))
          } else {
            continuation
              .resume(returning: .failure(
                UmbraErrors.Security.Protocols
                  .internalError("Unknown result type")
              ))
          }
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .internalError("No result returned")
            ))
        }
      }
    }
  }
}

// MARK: - KeyManagementProtocol Implementation

extension XPCServiceAdapter: SecurityProtocolsCore.KeyManagementProtocol {
  public func storeKey(
    _ key: SecureBytes,
    withIdentifier identifier: String
  ) async -> Result<Void, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let dataBytes=DataAdapter.data(from: key)
        // Use storeSecurely which is the correct XPC method name
        let result=await serviceProxy.storeSecurely(
          dataBytes,
          identifier: identifier,
          metadata: nil
        )

        switch result {
          case .success:
            continuation.resume(returning: .success(()))
          case let .failure(error):
            continuation.resume(returning: .failure(self.mapSecurityError(error)))
        }
      }
    }
  }

  public func retrieveKey(withIdentifier identifier: String) async
  -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.retrieveSecurely(identifier: identifier)

        // Handle the result appropriately
        if let nsObject=result {
          if let nsError=nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let data=nsObject as? NSData {
            // Convert NSData to SecureBytes
            let dataBytes=[UInt8](Data(referencing: data))
            let secureBytes=SecureBytes(bytes: dataBytes)
            continuation.resume(returning: .success(secureBytes))
          } else {
            continuation
              .resume(returning: .failure(
                UmbraErrors.Security.Protocols
                  .internalError("Unknown result type")
              ))
          }
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .internalError("Invalid result format")
            ))
        }
      }
    }
  }

  public func deleteKey(withIdentifier identifier: String) async
  -> Result<Void, UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let result=await serviceProxy.deleteSecurely(identifier: identifier)

        switch result {
          case .success:
            continuation.resume(returning: .success(()))
          case let .failure(error):
            continuation.resume(returning: .failure(self.mapSecurityError(error)))
        }
      }
    }
  }

  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async
    -> Result<
      (newKey: SecureBytes, reencryptedData: SecureBytes?),
      UmbraErrors.Security.Protocols
    >
  {
    await withCheckedContinuation { continuation in
      Task {
        // Convert SecureBytes to NSData for the XPC call
        let nsData=dataToReencrypt.map { convertSecureBytesToNSData($0) }

        let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)

        if let nsObject=result {
          if let nsError=nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let newData=nsObject as? NSData {
            // Convert NSData to SecureBytes
            let secureBytes=convertNSDataToSecureBytes(newData)
            continuation.resume(returning: .success((newKey: secureBytes, reencryptedData: nil)))
          } else {
            continuation
              .resume(returning: .failure(
                UmbraErrors.Security.Protocols
                  .internalError("Unknown result type")
              ))
          }
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .internalError("Invalid result format")
            ))
        }
      }
    }
  }

  public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.Protocols> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("listKeyIdentifiers")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? NSArray
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        let identifiers=result.compactMap { $0 as? String }
        continuation.resume(returning: .success(identifiers))
      }
    }
  }
}

// MARK: - XPCServiceProtocolStandard Conformance

extension XPCServiceAdapter: XPCServiceProtocolStandard {
  @objc
  public func generateRandomData(length: Int) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("generateRandomDataWithLength:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: NSNumber(value: length)
        )?.takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("encryptData:keyIdentifier:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: data,
          with: keyIdentifier as NSString?
        )?.takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("decryptData:keyIdentifier:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: data,
          with: keyIdentifier as NSString?
        )?.takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func hashData(_ data: NSData) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("hashData:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?
          .takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("signData:keyIdentifier:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: data,
          with: keyIdentifier
        )?.takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func verifySignature(
    _ signature: NSData,
    for data: NSData,
    keyIdentifier: String
  ) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("verifySignature:forData:keyIdentifier:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: signature,
          with: data,
          with: keyIdentifier
        )?.takeRetainedValue()
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension XPCServiceAdapter: SecureStorageServiceProtocol {
  @objc
  public func storeData(_ data: NSData, withKey key: String) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("storeData:withKey:")
        let data=convertSecureBytesToNSData(self.secureBytes(from: data as Data))
        _=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data, with: key)

        continuation.resume(returning: NSNumber(value: true))
      }
    }
  }

  @objc
  public func retrieveData(withKey key: String) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("retrieveDataWithKey:")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: key)?
            .takeRetainedValue() as? NSData
        else {
          continuation.resume(returning: NSError(
            domain: "com.umbra.security.xpc",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]
          ))
          return
        }

        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func deleteData(withKey key: String) async -> NSObject? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("deleteDataWithKey:")
        _=(connection.remoteObjectProxy as AnyObject).perform(selector, with: key)

        continuation.resume(returning: NSNumber(value: true))
      }
    }
  }

  // Swift protocol method implementations

  public func storeSecurely(
    _ data: SecureBytes,
    identifier: String,
    metadata: [String: String]?
  ) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let nsData=convertSecureBytesToNSData(data)

        let selector=NSSelectorFromString("storeData:withKey:metadata:")
        (connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: nsData,
          with: identifier,
          with: metadata as NSObject?
        )

        continuation.resume(returning: .success(()))
      }
    }
  }

  public func retrieveSecurely(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("retrieveDataWithKey:")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(
            selector,
            with: identifier
          )?.takeRetainedValue() as? NSData
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        let secureBytes=convertNSDataToSecureBytes(result)
        continuation.resume(returning: .success(secureBytes))
      }
    }
  }

  public func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("deleteDataWithKey:")
        _=(connection.remoteObjectProxy as AnyObject).perform(selector, with: identifier)

        continuation.resume(returning: .success(()))
      }
    }
  }

  // Implement the missing required methods

  public func listIdentifiers() async -> Result<[String], XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("listIdentifiers")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? NSArray
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        let identifiers=result.compactMap { $0 as? String }
        continuation.resume(returning: .success(identifiers))
      }
    }
  }

  public func getMetadata(for identifier: String) async
  -> Result<[String: String]?, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("getMetadataForIdentifier:")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(
            selector,
            with: identifier
          )?.takeRetainedValue()
        else {
          // No metadata is a valid result
          continuation.resume(returning: .success(nil))
          return
        }

        if let metadataDict=result as? NSDictionary {
          var metadata: [String: String]=[:]
          for (key, value) in metadataDict {
            if let keyString=key as? String, let valueString=value as? String {
              metadata[keyString]=valueString
            }
          }
          continuation.resume(returning: .success(metadata))
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
        }
      }
    }
  }
}

// MARK: - KeyManagementServiceProtocol Conformance

extension XPCServiceAdapter: KeyManagementServiceProtocol {
  public func generateKey(
    keyType: KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("generateKeyWithType:identifier:metadata:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: keyType.rawValue,
          with: keyIdentifier as NSString?,
          with: metadata as NSDictionary?
        )?.takeRetainedValue() as? NSString

        if let result {
          continuation.resume(returning: .success(result as String))
        } else {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.keyGenerationFailed))
        }
      }
    }
  }

  public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("deleteKeyWithIdentifier:")
        _=(connection.remoteObjectProxy as AnyObject).perform(selector, with: keyIdentifier)

        continuation.resume(returning: .success(()))
      }
    }
  }

  public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("listKeyIdentifiers")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? NSArray
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        let identifiers=result.compactMap { $0 as? String }
        continuation.resume(returning: .success(identifiers))
      }
    }
  }

  public func getKeyMetadata(for keyIdentifier: String) async
  -> Result<[String: String]?, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("getKeyMetadataForIdentifier:")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(
            selector,
            with: keyIdentifier
          )?.takeRetainedValue()
        else {
          // No metadata is a valid result
          continuation.resume(returning: .success(nil))
          return
        }

        if let metadataDict=result as? NSDictionary {
          var metadata: [String: String]=[:]
          for (key, value) in metadataDict {
            if let keyString=key as? String, let valueString=value as? String {
              metadata[keyString]=valueString
            }
          }
          continuation.resume(returning: .success(metadata))
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
        }
      }
    }
  }
}

// MARK: - ComprehensiveSecurityServiceProtocol Conformance

extension XPCServiceAdapter: ComprehensiveSecurityServiceProtocol {
  public func getServiceVersion() async -> Result<String, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("getServiceVersion")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? String
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        continuation.resume(returning: .success(result))
      }
    }
  }

  public func getServiceStatus() async -> Result<ServiceStatus, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("getServiceStatus")
        guard
          let statusString=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? String,
            let status=ServiceStatus(rawValue: statusString)
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        continuation.resume(returning: .success(status))
      }
    }
  }
}

// MARK: - Helper Functions for Security Operations

extension XPCServiceAdapter {
  /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
  private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
    if error.domain == "com.umbra.security.xpc" {
      if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
        return UmbraErrors.Security.Protocols.internalError(message)
      } else {
        return UmbraErrors.Security.Protocols.internalError("Unknown error: \(error.code)")
      }
    } else {
      return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    }
  }

  /// Process security operation result for Swift-based code
  private func processSecurityResult<T>(
    _ result: NSObject?,
    transform: (NSData) -> T
  ) -> Result<T, UmbraErrors.Security.Protocols> {
    if let error=result as? NSError {
      .failure(mapSecurityError(error))
    } else if let nsData=result as? NSData {
      .success(transform(nsData))
    } else {
      .failure(UmbraErrors.Security.Protocols.internalError("Invalid result format"))
    }
  }
}

// This method handles the correct construction of SecurityResultDTO
extension XPCServiceAdapter {
  private func createSecurityResultDTO(data: SecureBytes?) -> SecurityProtocolsCore
  .SecurityResultDTO {
    if let data {
      SecurityProtocolsCore.SecurityResultDTO(data: data)
    } else {
      SecurityProtocolsCore.SecurityResultDTO()
    }
  }

  private func createSecurityResultDTO(
    error: SecurityProtocolsCore
      .SecurityError
  ) -> SecurityProtocolsCore.SecurityResultDTO {
    SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
  }
}

extension XPCServiceAdapter {
  // Helper method to convert Data to SecureBytes
  private func secureBytes(from data: Data) -> SecureBytes {
    let bytes=[UInt8](data)
    return SecureBytes(bytes: bytes)
  }

  // Helper method to convert NSData to SecureBytes
  private func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let bytes=[UInt8](Data(referencing: data))
    return SecureBytes(bytes: bytes)
  }

  // Helper method to convert SecureBytes to NSData
  private func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    // Access bytes directly from SecureBytes
    var byteArray=[UInt8](repeating: 0, count: secureBytes.count)
    for i in 0..<secureBytes.count {
      byteArray[i]=secureBytes[i]
    }
    let data=Data(byteArray)
    return data as NSData
  }
}

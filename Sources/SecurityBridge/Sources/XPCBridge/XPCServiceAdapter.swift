import Foundation
import CoreErrors
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Constants for XPC service configuration
public enum XPCServiceConstants {
  public static let defaultServiceName = "com.umbra.security.xpcservice"
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
  
  public static var protocolIdentifier: String = "com.umbra.security.xpc.bridge"
  
  private let serviceProxy: any ComprehensiveSecurityServiceProtocol
  private let connection: NSXPCConnection
  
  // MARK: - Initialization
  
  public init(connection: NSXPCConnection) {
    self.connection = connection
    
    let interface = NSXPCInterface(with: XPCServiceProtocolBasic.self)
    connection.remoteObjectInterface = interface
    
    // Set up interruption handler
    connection.interruptionHandler = {
      NSLog("XPC connection interrupted")
    }
    
    // Set up invalidation handler
    connection.invalidationHandler = {
      NSLog("XPC connection invalidated")
    }
    
    // Start the connection
    connection.resume()
    
    // Get the service proxy
    self.serviceProxy = connection.remoteObjectProxy as! any ComprehensiveSecurityServiceProtocol
  }
  
  deinit {
    connection.invalidate()
  }
  
  // MARK: - XPCServiceProtocolBasic Requirements
  
  @objc
  public func ping() async -> NSObject? {
    // Implement the @objc version required by XPCServiceProtocolBasic
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.getServiceVersion()
        switch result {
        case .success:
          continuation.resume(returning: NSNumber(value: true))
        case .failure(let error):
          continuation.resume(returning: error as NSError)
        }
      }
    }
  }
  
  @objc
  public func synchroniseKeys(_ syncData: NSData) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        let data = Data(referencing: syncData)
        let bytes = [UInt8](data)
        let secureBytes = SecureBytes(bytes: bytes)
        
        let result = await serviceProxy.synchroniseKeys(secureBytes)
        switch result {
        case .success:
          continuation.resume(returning: NSNull())
        case .failure(let error):
          continuation.resume(returning: error as NSError)
        }
      }
    }
  }
  
  // MARK: - Error Mapping
  
  private func mapSecurityError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
    if let securityError = error as? SecurityProtocolsCore.SecurityError {
      return securityError
    } else if let coreError = error as? CoreErrors.SecurityError {
      return mapError(coreError)
    } else {
      return SecurityProtocolsCore.SecurityError.internalError(error.localizedDescription)
    }
  }
  
  /// Map CoreErrors.SecurityError to SecurityProtocolsCore.SecurityError
  private func mapError(_ error: CoreErrors.SecurityError) -> SecurityProtocolsCore.SecurityError {
    switch error {
    case .encryptionFailed:
      return SecurityProtocolsCore.SecurityError.encryptionFailed
    case .decryptionFailed:
      return SecurityProtocolsCore.SecurityError.decryptionFailed
    case .keyGenerationFailed:
      return SecurityProtocolsCore.SecurityError.keyGenerationFailed
    case .invalidData:
      return SecurityProtocolsCore.SecurityError.invalidData
    case .notImplemented:
      return SecurityProtocolsCore.SecurityError.notImplemented
    case .general(let message):
      return SecurityProtocolsCore.SecurityError.internalError(message)
    case .bookmarkError:
      return SecurityProtocolsCore.SecurityError.internalError("Bookmark error")
    case .accessError:
      return SecurityProtocolsCore.SecurityError.internalError("Access error")
    case .cryptoError:
      return SecurityProtocolsCore.SecurityError.internalError("Crypto error")
    case .bookmarkCreationFailed:
      return SecurityProtocolsCore.SecurityError.internalError("Bookmark creation failed")
    case .bookmarkResolutionFailed:
      return SecurityProtocolsCore.SecurityError.internalError("Bookmark resolution failed")
    }
  }
  
  /// Maps an XPC error to a SecurityError using the centralised error mapper.
  ///
  /// This method provides a consistent way of handling XPC errors throughout the application.
  /// - Parameter error: The XPC error to be mapped.
  /// - Returns: A SecurityError representing the XPC error.
  private func mapXPCError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
    return CoreErrors.SecurityErrorMapper.mapToSPCError(error) as! SecurityProtocolsCore.SecurityError
  }
}

// MARK: - SecurityProtocolsCore.SecurityService Implementation

extension XPCServiceAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
  public func ping() async -> Result<Bool, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.getServiceVersion()
        continuation.resume(returning: result.map { _ in true })
      }
    }
  }
  
  public func encrypt(data: SecureBytes, key: SecureBytes?) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    let keyData = key.map { SecureBytesAdapter.data(from: $0) }

    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.encrypt(data: SecureBytesAdapter.data(from: data), key: keyData ?? Data())
        continuation.resume(returning: result.map { SecureBytesAdapter.secureBytes(from: $0) })
      }
    }
  }

  public func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await encrypt(data: data, key: key)
  }
  
  public func decrypt(data: SecureBytes, key: SecureBytes?) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    let keyData = key.map { SecureBytesAdapter.data(from: $0) }

    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.decrypt(data: SecureBytesAdapter.data(from: data), key: keyData ?? Data())
        continuation.resume(returning: result.map { SecureBytesAdapter.secureBytes(from: $0) })
      }
    }
  }
  
  public func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await decrypt(data: data, key: key)
  }
  
  public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.hash(data: SecureBytesAdapter.data(from: data))
        continuation.resume(returning: result.map { SecureBytesAdapter.secureBytes(from: $0) })
      }
    }
  }
  
  public func hash(
    data: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let result = await hash(data: data)
    switch result {
    case .success(let hashData):
      return SecurityProtocolsCore.SecurityResultDTO(value: hashData, status: .success, error: nil)
    case .failure(let error):
      return SecurityProtocolsCore.SecurityResultDTO(value: nil, status: .failure, error: error)
    }
  }
  
  public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    let dataHash = await self.hash(data: data)
    guard case let .success(computedHash) = dataHash else {
      return false
    }
    
    return computedHash == hash
  }
  
  public func encryptSymmetric(
    data: SecureBytes, 
    key: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let result = await encrypt(data: data, using: key)
    switch result {
    case .success(let encryptedData):
      return SecurityProtocolsCore.SecurityResultDTO(value: encryptedData, status: .success, error: nil)
    case .failure(let error):
      return SecurityProtocolsCore.SecurityResultDTO(value: nil, status: .failure, error: error)
    }
  }
  
  public func decryptSymmetric(
    data: SecureBytes, 
    key: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    let result = await decrypt(data: data, using: key)
    switch result {
    case .success(let decryptedData):
      return SecurityProtocolsCore.SecurityResultDTO(value: decryptedData, status: .success, error: nil)
    case .failure(let error):
      return SecurityProtocolsCore.SecurityResultDTO(value: nil, status: .failure, error: error)
    }
  }
  
  public func encryptAsymmetric(
    data: SecureBytes,
    publicKey: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    // Delegate to symmetric encryption since XPC doesn't directly support asymmetric encryption
    return await encryptSymmetric(data: data, key: publicKey, config: config)
  }
  
  public func decryptAsymmetric(
    data: SecureBytes,
    privateKey: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    // Delegate to symmetric decryption since XPC doesn't directly support asymmetric decryption
    return await decryptSymmetric(data: data, key: privateKey, config: config)
  }

  public func generateKey() async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.generateKey()
        continuation.resume(returning: result.map { SecureBytesAdapter.secureBytes(from: $0) })
      }
    }
  }

  public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        // The serviceProxy.generateRandomData should return the correct type
        let result = await serviceProxy.generateRandomData(length: length) 
        
        if let nsObject = result as? NSObject {
          if let nsError = nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let data = nsObject as? NSData {
            // Convert NSData to SecureBytes
            let dataBytes = [UInt8](Data(referencing: data))
            let secureBytes = SecureBytes(bytes: dataBytes)
            continuation.resume(returning: .success(secureBytes))
          } else {
            continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Unknown result type")))
          }
        } else {
          continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Invalid result format")))
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
  ) async -> Result<Void, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let dataBytes = SecureBytesAdapter.data(from: key)
        // Use storeSecurely which is the correct XPC method name
        let result = await serviceProxy.storeSecurely(dataBytes, identifier: identifier, metadata: nil)
        
        switch result {
        case .success:
          continuation.resume(returning: .success(()))
        case .failure(let error):
          continuation.resume(returning: .failure(self.mapSecurityError(error)))
        }
      }
    }
  }

  public func retrieveKey(withIdentifier identifier: String) async -> Result<SecureBytes, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.retrieveSecurely(identifier: identifier)
        
        // Handle the result appropriately
        if let nsObject = result as? NSObject {
          if let nsError = nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let data = nsObject as? NSData {
            // Convert NSData to SecureBytes
            let dataBytes = [UInt8](Data(referencing: data))
            let secureBytes = SecureBytes(bytes: dataBytes)
            continuation.resume(returning: .success(secureBytes))
          } else {
            continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Unknown result type")))
          }
        } else {
          continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Invalid result format")))
        }
      }
    }
  }
  
  public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.deleteSecurely(identifier: identifier)
        
        switch result {
        case .success:
          continuation.resume(returning: .success(()))
        case .failure(let error):
          continuation.resume(returning: .failure(self.mapSecurityError(error)))
        }
      }
    }
  }
  
  public func rotateKey(
    withIdentifier identifier: String,
    dataToReencrypt: SecureBytes?
  ) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        // Convert SecureBytes to NSData for the XPC call
        let nsData = dataToReencrypt.map { convertSecureBytesToNSData($0) }
        
        let result = await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
        
        if let nsObject = result as? NSObject {
          if let nsError = nsObject as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(nsError)))
          } else if let newData = nsObject as? NSData {
            // Convert NSData to SecureBytes
            let secureBytes = convertNSDataToSecureBytes(newData)
            continuation.resume(returning: .success((newKey: secureBytes, reencryptedData: nil)))
          } else {
            continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Unknown result type")))
          }
        } else {
          continuation.resume(returning: .failure(SecurityProtocolsCore.SecurityError.internalError("Invalid result format")))
        }
      }
    }
  }
  
  public func listKeyIdentifiers() async -> Result<[String], SecurityProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.listKeyIdentifiers()
        
        switch result {
        case .success(let identifiers):
          continuation.resume(returning: .success(identifiers))
        case .failure(let error):
          continuation.resume(returning: .failure(self.mapSecurityError(error)))
        }
      }
    }
  }
}

// MARK: - XPCServiceProtocolStandard Conformance

extension XPCServiceAdapter: XPCServiceProtocolStandard {
  @objc
  public func generateRandomData(length: Int) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("generateRandomDataWithLength:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: NSNumber(value: length))?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate random data"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("encryptData:keyIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: data, with: keyIdentifier as NSString?)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encryption failed"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("decryptData:keyIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: data, with: keyIdentifier as NSString?)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Decryption failed"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func hashData(_ data: NSData) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("hashData:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hashing failed"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("signData:keyIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: data, with: keyIdentifier)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Signing failed"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("verifySignature:forData:keyIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: signature, with: data, with: keyIdentifier)?.takeRetainedValue() as? NSNumber else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Verification failed"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension XPCServiceAdapter: SecureStorageServiceProtocol {
  @objc
  public func storeData(_ data: NSData, withKey key: String) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("storeData:withKey:")
          let data = convertSecureBytesToNSData(self.secureBytes(from: data as Data))
          try (connection.remoteObjectProxy as AnyObject).perform(selector, with: data, with: key)
          
          continuation.resume(returning: NSNumber(value: true))
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func retrieveData(withKey key: String) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("retrieveDataWithKey:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: key)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
            return
          }
          
          continuation.resume(returning: result)
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  @objc
  public func deleteData(withKey key: String) async -> NSObject? {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("deleteDataWithKey:")
          try (connection.remoteObjectProxy as AnyObject).perform(selector, with: key)
          
          continuation.resume(returning: NSNumber(value: true))
        } catch {
          continuation.resume(returning: NSError(domain: "com.umbra.security.xpc", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        }
      }
    }
  }
  
  // Swift protocol method implementations
  
  public func storeSecurely(_ data: SecureBytes, identifier: String, metadata: [String: String]?) async -> Result<Void, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let nsData = convertSecureBytesToNSData(data)
        
        do {
          let selector = NSSelectorFromString("storeData:withKey:metadata:")
          try (connection.remoteObjectProxy as AnyObject).perform(selector, with: nsData, with: identifier, with: metadata as NSObject?)
          
          continuation.resume(returning: .success(()))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func retrieveSecurely(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("retrieveDataWithKey:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: identifier)?.takeRetainedValue() as? NSData else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.invalidData))
            return
          }
          
          let secureBytes = convertNSDataToSecureBytes(result)
          continuation.resume(returning: .success(secureBytes))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("deleteDataWithKey:")
          try (connection.remoteObjectProxy as AnyObject).perform(selector, with: identifier)
          
          continuation.resume(returning: .success(()))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  // Implement the missing required methods
  
  public func listIdentifiers() async -> Result<[String], XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("listIdentifiers")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector)?.takeRetainedValue() as? NSArray else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.invalidData))
            return
          }
          
          let identifiers = result.compactMap { $0 as? String }
          continuation.resume(returning: .success(identifiers))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func getMetadata(for identifier: String) async -> Result<[String: String]?, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("getMetadataForIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: identifier)?.takeRetainedValue() else {
            // No metadata is a valid result
            continuation.resume(returning: .success(nil))
            return
          }
          
          if let metadataDict = result as? NSDictionary {
            var metadata: [String: String] = [:]
            for (key, value) in metadataDict {
              if let keyString = key as? String, let valueString = value as? String {
                metadata[keyString] = valueString
              }
            }
            continuation.resume(returning: .success(metadata))
          } else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.invalidData))
          }
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
}

// MARK: - KeyManagementServiceProtocol Conformance

extension XPCServiceAdapter: KeyManagementServiceProtocol {
  public func generateKey(keyType: KeyType, keyIdentifier: String?, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("generateKeyWithType:identifier:metadata:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(
            selector,
            with: keyType.rawValue,
            with: keyIdentifier as NSString?,
            with: metadata as NSDictionary?
          )?.takeRetainedValue() as? NSString else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.keyGenerationFailed))
            return
          }
          
          continuation.resume(returning: .success(result as String))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("deleteKeyWithIdentifier:")
          try (connection.remoteObjectProxy as AnyObject).perform(selector, with: keyIdentifier)
          
          continuation.resume(returning: .success(()))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("listKeyIdentifiers")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector)?.takeRetainedValue() as? NSArray else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.invalidData))
            return
          }
          
          let identifiers = result.compactMap { $0 as? String }
          continuation.resume(returning: .success(identifiers))
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
  
  public func getKeyMetadata(for keyIdentifier: String) async -> Result<[String: String]?, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        do {
          let selector = NSSelectorFromString("getKeyMetadataForIdentifier:")
          guard let result = try (connection.remoteObjectProxy as AnyObject).perform(selector, with: keyIdentifier)?.takeRetainedValue() else {
            // No metadata is a valid result
            continuation.resume(returning: .success(nil))
            return
          }
          
          if let metadataDict = result as? NSDictionary {
            var metadata: [String: String] = [:]
            for (key, value) in metadataDict {
              if let keyString = key as? String, let valueString = value as? String {
                metadata[keyString] = valueString
              }
            }
            continuation.resume(returning: .success(metadata))
          } else {
            continuation.resume(returning: .failure(CoreErrors.SecurityError.invalidData))
          }
        } catch {
          continuation.resume(returning: .failure(CoreErrors.SecurityError.general(error.localizedDescription)))
        }
      }
    }
  }
}

// MARK: - ComprehensiveSecurityServiceProtocol Conformance

extension XPCServiceAdapter: ComprehensiveSecurityServiceProtocol {
  // Implement other required ComprehensiveSecurityServiceProtocol methods
}

extension XPCServiceAdapter {
  // Helper method to convert Data to SecureBytes
  private func secureBytes(from data: Data) -> SecureBytes {
    let bytes = [UInt8](data)
    return SecureBytes(bytes: bytes)
  }
  
  // Helper method to convert NSData to SecureBytes
  private func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let bytes = [UInt8](Data(referencing: data))
    return SecureBytes(bytes: bytes)
  }
  
  // Helper method to convert SecureBytes to NSData
  private func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    var byteArray: [UInt8] = []
    for i in 0..<secureBytes.count {
      byteArray.append(secureBytes[i])
    }
    let data = Data(byteArray)
    return data as NSData
  }
}

// MARK: - Helper Functions for Security Operations

extension XPCServiceAdapter {
  /// Convert SecurityBridgeErrors to SecurityProtocolsCore.SecurityError
  private func mapSecurityError(_ error: NSError) -> SecurityProtocolsCore.SecurityError {
    // Update to match the actual case structure of XPCSecurityError
    if error.domain == "com.umbra.security.xpc" {
      if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
        return SecurityProtocolsCore.SecurityError.internalError(message)
      } else {
        return SecurityProtocolsCore.SecurityError.internalError("Unknown error: \(error.code)")
      }
    } else {
      return SecurityProtocolsCore.SecurityError.internalError(error.localizedDescription)
    }
  }
  
  /// Process security operation result for Swift-based code
  private func processSecurityResult<T>(_ result: NSObject?, transform: (NSData) -> T) -> Result<T, SecurityProtocolsCore.SecurityError> {
    if let error = result as? NSError {
      return .failure(mapSecurityError(error))
    } else if let nsData = result as? NSData {
      return .success(transform(nsData))
    } else {
      return .failure(SecurityProtocolsCore.SecurityError.internalError("Invalid result format"))
    }
  }
}

// This method handles the correct construction of SecurityResultDTO
private extension XPCServiceAdapter {
  func createSecurityResultDTO(data: SecureBytes?) -> SecurityProtocolsCore.SecurityResultDTO {
    if let data = data {
      return SecurityProtocolsCore.SecurityResultDTO(data: data)
    } else {
      return SecurityProtocolsCore.SecurityResultDTO()
    }
  }
  
  func createSecurityResultDTO(error: SecurityProtocolsCore.SecurityError) -> SecurityProtocolsCore.SecurityResultDTO {
    return SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
  }
}

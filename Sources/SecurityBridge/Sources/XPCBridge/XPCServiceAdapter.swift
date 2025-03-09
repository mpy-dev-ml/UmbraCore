import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// For protocol compatibility - bridging between error types
// This allows us to implement protocols that require Protocols error type
// while maintaining XPC error type internally
extension UmbraErrors.Security {
  typealias ProtocolErrorType=UmbraErrors.Security.Protocols
}

/// Constants for XPC service configuration
public enum XPCServiceConstants {
  public static let defaultServiceName="com.umbra.security.xpcservice"
}

/// XPCServiceAdapter provides a bridge for XPC service communication that requires Foundation
/// types.
///
/// This adapter connects to an XPC service and acts as a bridge to
/// Foundation-independent security protocols. It handles the serialisation/deserialisation
/// needed for XPC communication while maintaining the domain-specific type system.
@objc
public final class XPCServiceAdapter: NSObject, @unchecked Sendable, BaseXPCAdapter {
  // MARK: - Properties

  public static var protocolIdentifier: String="com.umbra.security.xpc.bridge"

  public let connection: NSXPCConnection
  
  // Specialised adapters for each protocol
  private let serviceStandardAdapter: XPCServiceStandardAdapter
  private let secureStorageAdapter: SecureStorageXPCAdapter
  private let cryptoAdapter: CryptoXPCAdapter
  private let keyManagementAdapter: KeyManagementXPCAdapter
  private let comprehensiveSecurityAdapter: ComprehensiveSecurityXPCAdapter

  // MARK: - Initialization

  public init(connection: NSXPCConnection) {
    self.connection=connection
    
    let interface=NSXPCInterface(with: XPCServiceProtocolBasic.self)
    connection.remoteObjectInterface=interface

    // Start the connection
    connection.resume()
    
    // Create child adapters
    self.serviceStandardAdapter = XPCServiceStandardAdapter(connection: connection)
    self.secureStorageAdapter = SecureStorageXPCAdapter(connection: connection)
    self.cryptoAdapter = CryptoXPCAdapter(connection: connection, serviceProxy: connection.remoteObjectProxy as! any ComprehensiveSecurityServiceProtocol)
    self.keyManagementAdapter = KeyManagementXPCAdapter(connection: connection)
    self.comprehensiveSecurityAdapter = ComprehensiveSecurityXPCAdapter(connection: connection)

    super.init()
    setupInvalidationHandler()
  }

  deinit {
    connection.invalidate()
  }
}

// MARK: - XPCServiceProtocolStandard Conformance

extension XPCServiceAdapter: XPCServiceProtocolStandard {
  // Forward all methods to serviceStandardAdapter
  
  @objc
  public func generateRandomBytes(length: Int) async -> NSObject? {
    return await serviceStandardAdapter.generateRandomBytes(length: length)
  }

  @objc
  public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    return await serviceStandardAdapter.encryptData(data, keyIdentifier: keyIdentifier)
  }

  @objc
  public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    return await serviceStandardAdapter.decryptData(data, keyIdentifier: keyIdentifier)
  }

  @objc
  public func hashData(_ data: NSData) async -> NSObject? {
    return await serviceStandardAdapter.hashData(data)
  }

  @objc
  public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
    return await serviceStandardAdapter.signData(data, keyIdentifier: keyIdentifier)
  }

  @objc
  public func verifySignature(
    _ signature: NSData,
    for data: NSData,
    keyIdentifier: String
  ) async -> NSObject? {
    return await serviceStandardAdapter.verifySignature(signature, for: data, keyIdentifier: keyIdentifier)
  }
}

// MARK: - SecurityProtocolsCore.CryptoServiceProtocol Conformance

extension XPCServiceAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
  // Forward all methods to cryptoAdapter
  
  public func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
    return await cryptoAdapter.ping()
  }

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await cryptoAdapter.encrypt(data: data, using: key)
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await cryptoAdapter.decrypt(data: data, using: key)
  }

  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await cryptoAdapter.generateKey()
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    return await cryptoAdapter.hash(data: data)
  }

  // XPC-specific implementations

  public func encrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    return await cryptoAdapter.encrypt(data: data, key: key)
  }

  public func decrypt(
    data: SecureBytes,
    key: SecureBytes?
  ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    return await cryptoAdapter.decrypt(data: data, key: key)
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    return await cryptoAdapter.hash(data: data)
  }

  public func hash(
    data: SecureBytes,
    config: SecurityProtocolsCore.SecurityConfigDTO
  ) async -> SecurityProtocolsCore.SecurityResultDTO {
    return await cryptoAdapter.hash(data: data, config: config)
  }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension XPCServiceAdapter: SecureStorageServiceProtocol {
  // Forward all methods to secureStorageAdapter
  
  @objc
  public func storeData(_ data: NSData, withKey key: String) async -> NSObject? {
    return await secureStorageAdapter.storeData(data, withKey: key)
  }
  
  @objc
  public func retrieveData(withKey key: String) async -> NSObject? {
    return await secureStorageAdapter.retrieveData(withKey: key)
  }
  
  @objc
  public func deleteData(withKey key: String) async -> NSObject? {
    return await secureStorageAdapter.deleteData(withKey: key)
  }
  
  // Swift protocol method implementations
  
  public func storeSecurely(
    _ data: SecureBytes,
    identifier: String,
    metadata: [String: String]?
  ) async -> Result<Void, UmbraErrors.Security.XPC> {
    return await secureStorageAdapter.storeSecurely(data, identifier: identifier, metadata: metadata)
  }
  
  public func retrieveSecurely(identifier: String) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
    return await secureStorageAdapter.retrieveSecurely(identifier: identifier)
  }
  
  public func deleteSecurely(identifier: String) async -> Result<Void, UmbraErrors.Security.XPC> {
    return await secureStorageAdapter.deleteSecurely(identifier: identifier)
  }
  
  public func listIdentifiers() async -> Result<[String], UmbraErrors.Security.XPC> {
    return await secureStorageAdapter.listIdentifiers()
  }
  
  public func getMetadata(for identifier: String) async -> Result<[String: String]?, UmbraErrors.Security.XPC> {
    return await secureStorageAdapter.getMetadata(for: identifier)
  }
}

// MARK: - KeyManagementServiceProtocol Conformance

extension XPCServiceAdapter: KeyManagementServiceProtocol {
  // Forward all methods to keyManagementAdapter
  
  public func generateKey(
    keyType: KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, UmbraErrors.Security.XPC> {
    return await keyManagementAdapter.generateKey(keyType: keyType, keyIdentifier: keyIdentifier, metadata: metadata)
  }

  public func deleteKey(keyIdentifier: String) async -> Result<Void, UmbraErrors.Security.XPC> {
    return await keyManagementAdapter.deleteKey(keyIdentifier: keyIdentifier)
  }

  public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.XPC> {
    return await keyManagementAdapter.listKeyIdentifiers()
  }
  
  public func getKeyMetadata(keyIdentifier: String) async -> Result<[String: String], UmbraErrors.Security.XPC> {
    return await keyManagementAdapter.getKeyMetadata(keyIdentifier: keyIdentifier)
  }
  
  public func updateKeyMetadata(
    keyIdentifier: String,
    metadata: [String: String]
  ) async -> Result<Void, UmbraErrors.Security.XPC> {
    return await keyManagementAdapter.updateKeyMetadata(keyIdentifier: keyIdentifier, metadata: metadata)
  }
}

// MARK: - ComprehensiveSecurityServiceProtocol Conformance

extension XPCServiceAdapter: ComprehensiveSecurityServiceProtocol {
  public func getServiceVersion() async -> Result<String, UmbraErrors.Security.XPC> {
    return await comprehensiveSecurityAdapter.getServiceVersion()
  }

  public func getServiceStatus() async -> Result<ServiceStatus, UmbraErrors.Security.XPC> {
    return await comprehensiveSecurityAdapter.getServiceStatus()
  }
  
  public func encryptData(
      data: Data,
      key: Data
  ) async -> Result<Data, UmbraErrors.Security.XPC> {
      return await comprehensiveSecurityAdapter.encryptData(data: data, key: key)
  }
  
  public func decryptData(
      data: Data,
      key: Data
  ) async -> Result<Data, UmbraErrors.Security.XPC> {
      return await comprehensiveSecurityAdapter.decryptData(data: data, key: key)
  }
  
  public func hashData(data: Data) async -> Result<Data, UmbraErrors.Security.XPC> {
      return await comprehensiveSecurityAdapter.hashData(data: data)
  }
  
  public func verify(
      data: Data,
      signature: Data
  ) async -> Result<Bool, UmbraErrors.Security.XPC> {
      return await comprehensiveSecurityAdapter.verify(data: data, signature: signature)
  }
  
  public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
      return await comprehensiveSecurityAdapter.generateKey()
  }
}

// MARK: - Helper Functions for Security Operations

extension XPCServiceAdapter {
  /// Convert SecurityBridgeErrors to UmbraErrors.Security.XPC
  private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
    if error.domain == "com.umbra.security.xpc" {
      if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
        return UmbraErrors.Security.XPC.internalError(message)
      } else {
        return UmbraErrors.Security.XPC.internalError("Unknown error: \(error.code)")
      }
    } else {
      return UmbraErrors.Security.XPC.internalError(error.localizedDescription)
    }
  }

  /// Process security operation result for Swift-based code
  private func processSecurityResult<T>(
    _ result: NSObject?,
    transform: (NSData) -> T
  ) -> Result<T, UmbraErrors.Security.XPC> {
    if let error=result as? NSError {
      .failure(mapSecurityError(error))
    } else if let nsData=result as? NSData {
      .success(transform(nsData))
    } else {
      .failure(UmbraErrors.Security.XPC.internalError("Invalid result format"))
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

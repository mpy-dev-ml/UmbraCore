import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// KeyManagementXPCAdapter provides an implementation of KeyManagementServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles key management operations by delegating to an XPC service,
/// providing a unified API for key-related operations.
public final class KeyManagementXPCAdapter: NSObject, BaseXPCAdapter, @unchecked Sendable {
  // MARK: - Properties

  /// The NSXPCConnection used to communicate with the XPC service
  public let connection: NSXPCConnection
  
  /// The proxy for making XPC calls
  private let serviceProxy: any KeyManagementServiceProtocol
  
  // MARK: - Initialisation

  /// Initialise with an XPC connection and service interface protocol type
  ///
  /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
  public init(connection: NSXPCConnection) {
    self.connection = connection
    connection.remoteObjectInterface = NSXPCInterface(with: KeyManagementServiceProtocol.self)
    
    // Set the exported interface
    let exportedInterface = NSXPCInterface(with: XPCServiceProtocolBasic.self)
    connection.exportedInterface = exportedInterface
    
    // Resume the connection
    connection.resume()
    
    // Get the remote object proxy
    self.serviceProxy = connection.remoteObjectProxy as! any KeyManagementServiceProtocol
    
    super.init()
    setupInvalidationHandler()
  }
  
  /// Convert NSData to SecureBytes
  public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let length = data.length
    var bytes = [UInt8](repeating: 0, count: length)
    data.getBytes(&bytes, length: length)
    return SecureBytes(bytes: bytes)
  }
  
  /// Convert SecureBytes to NSData
  public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    let bytes = [UInt8](secureBytes)
    return NSData(bytes: bytes, length: bytes.count)
  }
  
  /// Check if the service is available
  public func isServiceAvailable() async -> Bool {
    let result = await listKeyIdentifiers()
    switch result {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  /// Executes a selector on the XPC connection for key management
  private func executeKeyManagementSelector<T>(
    _ selector: String,
    withArguments arguments: [Any]=[]
  ) async -> T? {
    await executeXPCSelector(selector, withArguments: arguments)
  }
}

// MARK: - KeyManagementServiceProtocol Implementation

extension KeyManagementXPCAdapter: KeyManagementServiceProtocol {
  public func generateKey(
    keyType: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.generateKey(
          keyType: keyType,
          keyIdentifier: keyIdentifier,
          metadata: metadata
        )
        continuation.resume(returning: result)
      }
    }
  }
  
  public func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.exportKey(keyIdentifier: keyIdentifier)
        switch result {
        case .success(let nsData):
          if let nsData = nsData as? NSData {
            continuation.resume(returning: .success(convertNSDataToSecureBytes(nsData)))
          } else {
            continuation
              .resume(returning: .failure(
                .serviceError(code: -1, reason: "Expected NSData but got \(type(of: nsData))")
              ))
          }
        case .failure(let error):
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  public func importKey(
    keyData: SecureBytes,
    keyType: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let nsData = convertSecureBytesToNSData(keyData)
        let result = await serviceProxy.importKey(
          keyData: nsData,
          keyType: keyType,
          keyIdentifier: keyIdentifier,
          metadata: metadata
        )
        continuation.resume(returning: result)
      }
    }
  }
  
  public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.deleteKey(keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }
  
  public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.listKeyIdentifiers()
        continuation.resume(returning: result)
      }
    }
  }
  
  public func getKeyMetadata(for keyIdentifier: String) async -> Result<[String: String]?, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.getKeyMetadata(for: keyIdentifier)
        
        switch result {
        case .success(let metadata):
          continuation.resume(returning: .success(metadata))
        case .failure(let error):
          if case .serviceError(_, let reason) = error, 
             reason.contains("metadata format") {
            continuation
              .resume(returning: .failure(
                .serviceError(code: -1, reason: "Invalid metadata format")
              ))
          } else {
            continuation.resume(returning: .failure(error))
          }
        }
      }
    }
  }
}

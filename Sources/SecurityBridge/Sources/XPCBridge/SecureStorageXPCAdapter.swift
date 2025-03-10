import CoreErrors
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// SecureStorageXPCAdapter provides an implementation of SecureStorageServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles secure storage operations by delegating to an XPC service,
/// while managing the type conversions between Foundation types and SecureBytes.
public final class SecureStorageXPCAdapter: NSObject, BaseXPCAdapter, @unchecked Sendable {
  // MARK: - Properties

  /// The NSXPCConnection used to communicate with the XPC service
  public let connection: NSXPCConnection
  
  /// The proxy for making XPC calls
  private let serviceProxy: any SecureStorageServiceProtocol
  
  // MARK: - Initialisation

  /// Initialise with an XPC connection and service interface protocol type
  ///
  /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
  public init(connection: NSXPCConnection) {
    self.connection = connection
    connection.remoteObjectInterface = NSXPCInterface(with: SecureStorageServiceProtocol.self)
    
    // Set the exported interface
    let exportedInterface = NSXPCInterface(with: XPCServiceProtocolBasic.self)
    connection.exportedInterface = exportedInterface
    
    // Resume the connection
    connection.resume()
    
    // Get the remote object proxy
    self.serviceProxy = connection.remoteObjectProxy as! any SecureStorageServiceProtocol
    
    super.init()
    
    // Set up invalidation handler
    connection.invalidationHandler = { [weak self] in
      self?.invalidationHandler?()
    }
  }
  
  /// Convert NSData to SecureBytes
  public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let length = data.length
    let bytes = [UInt8](repeating: 0, count: length)
    data.getBytes(UnsafeMutableRawPointer(mutating: bytes), length: length)
    return SecureBytes(bytes: bytes)
  }
  
  /// Convert SecureBytes to NSData
  public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    let bytes = secureBytes.rawBytes
    return NSData(bytes: bytes, length: bytes.count)
  }
  
  /// Check if the service is available
  public func isServiceAvailable() async -> Bool {
    let result = await listDataIdentifiers()
    switch result {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  // MARK: - Invalidation Handling
  
  /// Handler called when the XPC connection is invalidated
  public var invalidationHandler: (() -> Void)?
  
  // MARK: - Helpers

  /// Handle a continuation with a standard success/failure pattern
  private func handleContinuation<T>(
    _ continuation: CheckedContinuation<Result<T, UmbraErrors.Security.XPC>, Never>,
    result: NSObject?,
    transform: (NSData) -> T
  ) {
    if let error=result as? NSError {
      continuation.resume(returning: .failure(mapSecurityError(error)))
    } else if let nsData=result as? NSData {
      continuation.resume(returning: .success(transform(nsData)))
    } else if result is NSNull {
      // Some operations return NSNull for success with no data
      // We need to handle this case for operations like delete
      // This is a placeholder that needs to be updated based on the actual type T
      fatalError("Unable to convert NSNull to required return type")
    } else {
      continuation
        .resume(returning: .failure(
          UmbraErrors.Security.XPC
            .invalidFormat(reason: "Unexpected result format")
        ))
    }
  }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension SecureStorageXPCAdapter: SecureStorageServiceProtocol {
  public func storeData(_ data: UmbraCoreTypes.SecureBytes, identifier: String, metadata: [String: String]?) async -> Result<Void, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let nsData = convertSecureBytesToNSData(data)
        let result = await serviceProxy.storeData(
          nsData,
          identifier: identifier,
          metadata: metadata
        )
        continuation.resume(returning: result)
      }
    }
  }
  
  public func retrieveData(identifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.retrieveData(identifier: identifier)
        switch result {
        case .success(let nsData):
          if let nsData = nsData as? NSData {
            continuation.resume(returning: .success(convertNSDataToSecureBytes(nsData)))
          } else {
            continuation.resume(returning: .failure(.serviceError(code: -1, reason: "Expected NSData but got \(type(of: nsData))")))
          }
        case .failure(let error):
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  public func deleteData(identifier: String) async -> Result<Void, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.deleteData(identifier: identifier)
        continuation.resume(returning: result)
      }
    }
  }
  
  public func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.listDataIdentifiers()
        continuation.resume(returning: result)
      }
    }
  }
  
  public func getDataMetadata(for identifier: String) async -> Result<[String: String]?, XPCSecurityError> {
    // First check if service is available
    let serviceAvailable = await isServiceAvailable()
    if !serviceAvailable {
      return .failure(.serviceUnavailable)
    }
    
    return await withCheckedContinuation { continuation in
      Task {
        let result = await serviceProxy.getDataMetadata(for: identifier)
        continuation.resume(returning: result)
      }
    }
  }
}

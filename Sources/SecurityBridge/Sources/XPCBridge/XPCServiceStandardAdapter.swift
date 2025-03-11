import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// XPCServiceStandardAdapter provides an implementation of XPCServiceProtocolStandard
/// to handle the direct XPC communication with the security service.
///
/// This adapter handles low-level XPC operations by delegating to an XPC service,
/// providing a clean Objective-C compatible interface.
@objc
public final class XPCServiceStandardAdapter: NSObject, BaseXPCAdapter, @unchecked Sendable {
  // MARK: - Properties

  /// Protocol identifier for XPC service protocol identification
  @objc
  public static var protocolIdentifier: String="com.umbra.xpc.service.standard"

  /// The NSXPCConnection used to communicate with the XPC service
  public let connection: NSXPCConnection

  // MARK: - Initialisation

  /// Initialise with an XPC connection and service interface protocol type
  ///
  /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
  public init(connection: NSXPCConnection) {
    self.connection=connection

    // Set up the XPC interface - use the XPCServiceProtocolStandard protocol
    let protocolObj=XPCServiceProtocolStandard.self as Any as! Protocol
    connection.remoteObjectInterface=NSXPCInterface(with: protocolObj)

    // Resume the connection
    connection.resume()

    super.init()
    setupInvalidationHandler()
  }

  /// Validate the XPC connection and check for service availability
  public func setupInvalidationHandler() {
    connection.invalidationHandler={ [weak self] in
      if self != nil {
        // Handle connection invalidation
        print("XPC connection invalidated")
      }
    }
  }

  /// Handle common error conditions with XPC services
  ///
  /// - Parameter error: The NSError from the XPC service
  /// - Returns: A SecurityError representation of the error
  private func handleXPCError(_ error: NSError) -> XPCSecurityError {
    if let xpcError=error as? XPCSecurityError {
      return xpcError
    }

    // Use different error codes to determine the type of error
    if error.domain == NSCocoaErrorDomain {
      switch error.code {
        case 1001:
          return .internalError(reason: "Network error: \(error.localizedDescription)")
        case 1002:
          return .invalidInput(details: error.localizedDescription)
        case 1003:
          return .serviceUnavailable
        default:
          return .internalError(reason: error.localizedDescription)
      }
    } else {
      return .internalError(reason: error.localizedDescription)
    }
  }

  /// Convert NSData to SecureBytes
  public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let length=data.length
    var bytes=[UInt8](repeating: 0, count: length)
    data.getBytes(&bytes, length: length)
    return SecureBytes(bytes: bytes)
  }

  /// Convert SecureBytes to NSData
  public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    // Access the bytes through the appropriate method or property
    // This needs to be adjusted based on the actual SecureBytes implementation
    let bytes=[UInt8](secureBytes) // Assuming SecureBytes conforms to Sequence
    return NSData(bytes: bytes, length: bytes.count)
  }

  /// Map security errors to UmbraErrors
  public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
    // Check for known error domains and codes
    if error.domain == NSURLErrorDomain {
      return .connectionFailed(reason: error.localizedDescription)
    } else if error.domain == "XPCServiceErrorDomain" {
      // Map specific error codes to appropriate UmbraErrors
      switch error.code {
        case 1001:
          return .connectionFailed(reason: error.localizedDescription)
        case 1002:
          return .invalidMessageFormat(reason: error.localizedDescription)
        case 1003:
          return .serviceUnavailable(serviceName: "XPC Service")
        default:
          return .internalError(error.localizedDescription)
      }
    }

    // Default error mapping
    return .internalError(error.localizedDescription)
  }
}

// MARK: - XPCServiceProtocolStandard Implementation

extension XPCServiceStandardAdapter: XPCServiceProtocolStandard {
  @objc
  public func ping() async -> Bool {
    // Perform the XPC call to ping the service
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolBasic else {
        continuation.resume(returning: false)
        return
      }

      Task {
        let result=await proxy.ping()
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
    // Forward to the correct implementation
    guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolBasic else {
      let error=NSError(
        domain: "com.umbra.xpc.security",
        code: 1003,
        userInfo: [NSLocalizedDescriptionKey: "Service unavailable"]
      )
      completionHandler(error)
      return
    }

    proxy.synchroniseKeys(bytes, completionHandler: completionHandler)
  }

  @objc
  public func generateRandomData(length: Int) async -> NSObject? {
    // Perform the XPC call to generate random data
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.generateRandomData(length: length)
        continuation.resume(returning: result)
      }
    }
  }

  public func generateRandomBytes(length: Int) async -> NSObject? {
    await generateRandomData(length: length)
  }

  @objc
  public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    // Perform the XPC call to encrypt data
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.encryptData(data, keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    // Perform the XPC call to decrypt data
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.decryptData(data, keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func hashData(_ data: NSData) async -> NSObject? {
    // Perform the XPC call to hash data
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.hashData(data)
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
    // Perform the XPC call to sign data
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.signData(data, keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func verifySignature(
    _ signature: NSData,
    for data: NSData,
    keyIdentifier: String
  ) async -> NSNumber? {
    // Perform the XPC call to verify a signature
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.verifySignature(signature, for: data, keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }

  @objc
  public func getServiceStatus() async -> NSDictionary? {
    // Perform the XPC call to get service status
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: nil)
        return
      }

      Task {
        let result=await proxy.getServiceStatus()
        continuation.resume(returning: result)
      }
    }
  }

  // Swift-only methods (not marked with @objc because they use Swift-only types)
  public func generateKey(
    keyType: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCSecurityError> {
    // Perform the XPC call to generate a key
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: .failure(.serviceUnavailable))
        return
      }

      Task {
        let result=await proxy.generateKey(
          keyType: keyType,
          keyIdentifier: keyIdentifier,
          metadata: metadata
        )
        continuation.resume(returning: result)
      }
    }
  }

  public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
    // Perform the XPC call to delete a key
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: .failure(.serviceUnavailable))
        return
      }

      Task {
        let result=await proxy.deleteKey(keyIdentifier: keyIdentifier)
        continuation.resume(returning: result)
      }
    }
  }

  public func listKeys() async -> Result<[String], XPCSecurityError> {
    // Perform the XPC call to list keys
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: .failure(.serviceUnavailable))
        return
      }

      Task {
        let result=await proxy.listKeys()
        continuation.resume(returning: result)
      }
    }
  }

  public func importKey(
    keyData: SecureBytes,
    keyType: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCSecurityError> {
    // Perform the XPC call to import a key
    await withCheckedContinuation { continuation in
      guard let proxy=connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
        continuation.resume(returning: .failure(.serviceUnavailable))
        return
      }

      Task {
        let result=await proxy.importKey(
          keyData: keyData,
          keyType: keyType,
          keyIdentifier: keyIdentifier,
          metadata: metadata
        )
        continuation.resume(returning: result)
      }
    }
  }
}

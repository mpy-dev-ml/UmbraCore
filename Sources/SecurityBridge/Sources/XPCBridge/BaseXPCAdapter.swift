import CoreErrors
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Base protocol for XPC adapters that defines common functionality
/// for handling XPC connections and conversions.
public protocol BaseXPCAdapter {
  /// The NSXPCConnection used to communicate with the XPC service
  var connection: NSXPCConnection { get }

  /// Convert NSData to SecureBytes
  func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes

  /// Convert SecureBytes to NSData
  func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData

  /// Map NSError to UmbraErrors.Security.XPC
  func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC

  /// Handle the XPC connection invalidation
  func setupInvalidationHandler()

  /// Execute a selector on the XPC connection's remote object
  func executeXPCSelector<T>(_ selector: String, withArguments arguments: [Any]) async -> T?
}

/// Default implementations for common adapter functionality
extension BaseXPCAdapter {
  /// Convert NSData to SecureBytes
  public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
    let bytes=[UInt8](Data(referencing: data))
    return SecureBytes(bytes: bytes)
  }

  /// Convert SecureBytes to NSData
  public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    let data=Data(Array(secureBytes))
    return data as NSData
  }

  /// Convert regular Data to SecureBytes
  public func secureBytes(from data: Data) -> SecureBytes {
    let bytes=[UInt8](data)
    return SecureBytes(bytes: bytes)
  }

  /// Process an XPC result with custom transformation
  public func processXPCResult<T>(
    _ result: NSObject?,
    transform: (NSData) -> T
  ) -> Result<T, UmbraErrors.Security.XPC> {
    if let error=result as? NSError {
      .failure(mapSecurityError(error))
    } else if let nsData=result as? NSData {
      .success(transform(nsData))
    } else {
      .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Unexpected result format"))
    }
  }

  /// Set up invalidation handler for the XPC connection
  public func setupInvalidationHandler() {
    connection.invalidationHandler={
      NSLog("XPC connection invalidated")
    }

    connection.interruptionHandler={
      NSLog("XPC connection interrupted")
    }
  }

  /// Execute a selector on the XPC connection's remote object
  public func executeXPCSelector<T>(
    _ selector: String,
    withArguments arguments: [Any]=[]
  ) async -> T? {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString(selector)
        let result: Any?

        switch arguments.count {
          case 0:
            result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
              .takeRetainedValue()
          case 1:
            result=(connection.remoteObjectProxy as AnyObject).perform(
              selector,
              with: arguments[0]
            )?.takeRetainedValue()
          case 2:
            result=(connection.remoteObjectProxy as AnyObject).perform(
              selector,
              with: arguments[0],
              with: arguments[1]
            )?.takeRetainedValue()
          case 3:
            result=(connection.remoteObjectProxy as AnyObject).perform(
              selector,
              with: arguments[0],
              with: arguments[1],
              with: arguments[2]
            )?.takeRetainedValue()
          default:
            NSLog("Warning: Cannot execute XPC selector with more than 3 arguments")
            continuation.resume(returning: nil)
            return
        }

        continuation.resume(returning: result as? T)
      }
    }
  }

  /// Map NSError to UmbraErrors.Security.XPC
  public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
    if error.domain == "com.umbra.security.xpc" {
      if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
        if message.contains("invalid format") || message.contains("Invalid format") {
          return UmbraErrors.Security.XPC.invalidMessageFormat(reason: message)
        } else if message.contains("encryption failed") {
          return UmbraErrors.Security.XPC.serviceError(code: error.code, reason: message)
        } else if message.contains("decryption failed") {
          return UmbraErrors.Security.XPC.serviceError(code: error.code, reason: message)
        } else if message.contains("key not found") {
          return UmbraErrors.Security.XPC.serviceError(code: error.code, reason: message)
        }
      }

      switch error.code {
        case 1001:
          return UmbraErrors.Security.XPC.serviceUnavailable(serviceName: "SecurityService")
        case 1002:
          return UmbraErrors.Security.XPC.insufficientPrivileges(service: "SecurityService", requiredPrivilege: "Operation")
        case 1003:
          return UmbraErrors.Security.XPC.serviceError(code: error.code, reason: "Invalid operation")
        default:
          return UmbraErrors.Security.XPC.internalError(
            "Unknown error (code: \(error.code), message: \(error.localizedDescription))"
          )
      }
    }

    return UmbraErrors.Security.XPC.internalError(
      "External error (domain: \(error.domain), code: \(error.code), message: \(error.localizedDescription))"
    )
  }

  /// Maps UmbraErrors.Security.XPC to UmbraErrors.Security.Protocols
  public func mapToProtocolError(_ error: UmbraErrors.Security.XPC) -> UmbraErrors.Security
  .Protocols {
    // Map XPC error to Protocol error based on case
    switch error {
      case .encryptionFailed:
        .encryptionFailed
      case .decryptionFailed:
        .decryptionFailed
      case .keyGenerationFailed:
        .keyGenerationFailed
      case let .invalidFormat(reason):
        .invalidFormat(reason: reason)
      case .hashingFailed:
        .hashVerificationFailed
      case .serviceUnavailable:
        .serviceError
      case let .internalError(message):
        .internalError(message)
      case .notImplemented:
        .notImplemented
      case let .unsupportedOperation(name):
        .unsupportedOperation(name: name)
      default:
        .internalError("Unknown error: \(error)")
    }
  }
}

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
public final class XPCServiceStandardAdapter: NSObject, BaseXPCAdapter {
  // MARK: - Properties

  /// The NSXPCConnection used to communicate with the XPC service
  public let connection: NSXPCConnection

  // MARK: - Initialisation

  /// Initialise with an NSXPCConnection
  /// - Parameter connection: The connection to the XPC service
  public init(connection: NSXPCConnection) {
    self.connection=connection
    super.init()
    setupInvalidationHandler()
  }
}

// MARK: - XPCServiceProtocolStandard Implementation

extension XPCServiceStandardAdapter: XPCServiceProtocolStandard {
  @objc
  public func generateRandomBytes(length: Int) async -> NSObject? {
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

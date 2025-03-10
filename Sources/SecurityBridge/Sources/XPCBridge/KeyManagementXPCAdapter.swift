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
/// while managing the type conversions between Foundation types and SecureBytes.
public final class KeyManagementXPCAdapter: NSObject, BaseXPCAdapter {
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

  // MARK: - Helper Methods

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
    keyType: KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, UmbraErrors.Security.XPC> {
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
          continuation.resume(returning: .failure(UmbraErrors.Security.XPC.keyGenerationFailed))
        }
      }
    }
  }

  public func deleteKey(keyIdentifier: String) async -> Result<Void, UmbraErrors.Security.XPC> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("deleteKeyWithIdentifier:")
        _=(connection.remoteObjectProxy as AnyObject).perform(selector, with: keyIdentifier)

        continuation.resume(returning: .success(()))
      }
    }
  }

  public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.XPC> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("listKeyIdentifiers")
        guard
          let result=(connection.remoteObjectProxy as AnyObject).perform(selector)?
            .takeRetainedValue() as? NSArray
        else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.XPC
                .invalidFormat(reason: "Invalid data")
            ))
          return
        }

        let identifiers=result.compactMap { $0 as? String }
        continuation.resume(returning: .success(identifiers))
      }
    }
  }

  public func getKeyMetadata(keyIdentifier: String) async
  -> Result<[String: String], UmbraErrors.Security.XPC> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("getKeyMetadataForIdentifier:")
        let result=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: keyIdentifier
        )?.takeRetainedValue() as? NSDictionary

        if let result=result as? [String: String] {
          continuation.resume(returning: .success(result))
        } else {
          continuation
            .resume(returning: .failure(
              UmbraErrors.Security.XPC
                .invalidFormat(reason: "Invalid metadata format")
            ))
        }
      }
    }
  }

  public func updateKeyMetadata(
    keyIdentifier: String,
    metadata: [String: String]
  ) async -> Result<Void, UmbraErrors.Security.XPC> {
    await withCheckedContinuation { continuation in
      Task {
        let selector=NSSelectorFromString("updateKeyMetadata:forIdentifier:")
        _=(connection.remoteObjectProxy as AnyObject).perform(
          selector,
          with: metadata as NSDictionary,
          with: keyIdentifier
        )

        continuation.resume(returning: .success(()))
      }
    }
  }
}

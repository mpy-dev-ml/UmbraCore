import CoreErrors
import ErrorHandlingDomains
import Foundation
import XPCProtocolsCore

/// Custom error for Foundation bridging that doesn't require direct NSError use
public enum FoundationBridgingError: Error, Sendable {
  /// Invalid data format
  case invalidDataFormat(details: String)

  /// Failed to convert data
  case conversionFailed(details: String)

  /// Service connection error
  case serviceConnectionFailed(details: String)

  /// Implementation missing
  case implementationMissing(String)
}

/// Protocol for XPC services in ObjCBridgingTypesFoundation that depends on Foundation
/// This is a standalone protocol that doesn't try to bridge to CoreTypes directly
@objc
public protocol XPCServiceProtocolBaseFoundation: NSObjectProtocol {
  /// Protocol identifier - used for protocol negotiation
  @objc
  static var protocolIdentifier: String { get }

  /// Base method to test connectivity
  @objc
  func ping(withReply reply: @escaping (Bool, Error?) -> Void)

  /// Raw method for synchronising keys with Foundation.Data
  @objc
  optional func synchroniseKeys(_ data: Any, withReply reply: @escaping (Error?) -> Void)
}

/// Default implementation for XPCServiceProtocolBaseFoundation
extension XPCServiceProtocolBaseFoundation {
  /// Default protocol identifier - must be implemented by concrete types
  public static var protocolIdentifierDefault: String {
    "com.umbra.xpc.service.protocol.base.foundation"
  }

  /// Raw implementation for synchronising keys
  public var synchroniseKeysRaw: ((Any, @escaping (Error?) -> Void) -> Void)? {
    self.synchroniseKeys(_:withReply:)
  }

  /// Async ping implementation
  public func ping() async -> Result<Bool, XPCSecurityError> {
    do {
      return try await withCheckedThrowingContinuation { continuation in
        ping { success, error in
          if let error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(returning: .success(success))
          }
        }
      }
    } catch {
      return .failure(
        XPCSecurityError
          .internalError("Crypto operation failed: \(error.localizedDescription)")
      )
    }
  }

  /// Async implementation for synchronising keys with byte array
  public func synchroniseKeys(_ bytes: [UInt8]) async throws {
    let data=Data(bytes) as NSData

    return try await withCheckedThrowingContinuation { continuation in
      guard let synchroniseKeysRaw=self.synchroniseKeysRaw else {
        continuation
          .resume(
            throwing: FoundationBridgingError
              .implementationMissing("synchroniseKeys not implemented")
          )
        return
      }

      synchroniseKeysRaw(data) { error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: ())
        }
      }
    }
  }
}

import Foundation
import XPCProtocolsCore

/// Protocol defining the base XPC service interface with completion handlers - Foundation version
@objc
public protocol XPCServiceProtocolDefinitionBaseFoundation: NSObjectProtocol {
  /// Base method to test connectivity
  @objc
  func ping(withReply reply: @escaping (Bool, Error?) -> Void)
}

/// Extension providing utility methods for Foundation-based XPC service protocols
extension XPCServiceProtocolDefinitionBaseFoundation {
  /// Default version identifier
  public static var serviceVersion: String {
    "1.0.0"
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
      return .failure(XPCSecurityError.cryptoError)
    }
  }
}

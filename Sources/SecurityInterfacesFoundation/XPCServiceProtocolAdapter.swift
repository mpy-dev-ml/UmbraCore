import Foundation
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityInterfacesProtocols
import UmbraCoreTypes
import XPCProtocolsCore

/// Custom error for security interfaces that doesn't require Foundation
public enum XPCServiceProtocolAdapterError: Error, Sendable {
  case implementationMissing(String)
}

/// Adapter that bridges from SecurityInterfacesProtocols.XPCServiceProtocolBase to
/// ObjCBridgingTypesFoundation
public final class CoreTypesToFoundationAdapter: NSObject,
ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation, @unchecked Sendable {
  private let core: any SecurityInterfacesProtocols.XPCServiceProtocolBase

  /// Create a new adapter wrapping a CoreTypes implementation
  public init(wrapping core: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
    self.core=core
    super.init()
  }

  /// Protocol identifier from the CoreTypes implementation
  @objc
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter.coretypes"
  }

  /// Implement ping using the CoreTypes implementation
  @objc
  public func ping(withReply reply: @escaping (Bool, Error?) -> Void) {
    // Capture reply in a local variable to avoid data races
    let localReply=reply
    Task {
      let result=await core.ping()
      switch result {
        case let .success(value):
          localReply(value, nil)
        case let .failure(error):
          localReply(false, error)
      }
    }
  }

  /// Implement synchroniseKeys using the CoreTypes implementation
  @objc
  public func synchroniseKeys(_ data: Any, withReply reply: @escaping (Error?) -> Void) {
    guard let nsData=data as? NSData else {
      reply(XPCServiceProtocolAdapterError.implementationMissing("Data must be NSData"))
      return
    }

    // Capture reply in a local variable to avoid data races
    let localReply=reply
    Task {
      do {
        // Convert NSData to bytes
        let bytes=ObjCBridgingTypesFoundation.DataConverter.convertToBytes(fromNSData: nsData)
        // Convert bytes to SecureBytes
        let binaryData=SecurityInterfacesProtocols.SecureBytes(bytes)
        // Call the CoreTypes implementation
        try await core.synchroniseKeys(binaryData)
        localReply(nil)
      } catch {
        localReply(error)
      }
    }
  }
}

/// Adapter that bridges from ObjCBridgingTypesFoundation to
/// SecurityInterfacesProtocols.XPCServiceProtocolBase
public final class FoundationToCoreTypesAdapter: SecurityInterfacesProtocols
.XPCServiceProtocolBase {
  // Using a class instead of struct to better handle reference semantics of NSObjectProtocol
  private let foundation: any ObjCBridgingTypesFoundation
    .XPCServiceProtocolBaseFoundation

  /// Create a new adapter wrapping a Foundation implementation
  public init(
    wrapping foundation: any ObjCBridgingTypesFoundation
      .XPCServiceProtocolBaseFoundation
  ) {
    self.foundation=foundation
  }

  /// Protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter.foundation"
  }

  /// Implement ping using the Foundation implementation
  public func ping() async -> Result<Bool, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      foundation.ping { success, _ in
        // If there's an error, we'll just return false with cryptoError
        if !success {
          continuation.resume(returning: .failure(.cryptoError))
        } else {
          continuation.resume(returning: .success(success))
        }
      }
    }
  }

  /// Implement synchroniseKeys using the Foundation implementation
  public func synchroniseKeys(_ data: SecurityInterfacesProtocols.SecureBytes) async throws {
    // Convert SecureBytes to byte array
    let bytes=data.bytes

    // Convert byte array to NSData
    let nsData=ObjCBridgingTypesFoundation.DataConverter.convertToNSData(fromBytes: bytes)

    // Call the Foundation implementation
    return try await withCheckedThrowingContinuation { continuation in
      // Check if synchroniseKeys is available
      guard let syncMethod=foundation.synchroniseKeys else {
        continuation
          .resume(
            throwing: XPCServiceProtocolAdapterError
              .implementationMissing("synchroniseKeys not implemented")
          )
        return
      }

      // Call the method with proper unwrapping
      syncMethod(nsData) { error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: ())
        }
      }
    }
  }
}

/// Extension for the Foundation-based XPC protocol
extension ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation {
  /// Implementation for synchronising keys with byte array
  @available(*, unavailable, message: "This method is not available due to protocol limitations")
  func synchroniseKeys(_: [UInt8]) async throws {
    // This method is marked as unavailable to prevent build errors
    // The real implementation would need to be provided by ObjCBridgingTypesFoundation
    fatalError("This method should not be called directly")
  }
}

import Foundation
import UmbraCoreTypes

/// Custom error for security interfaces that doesn't require Foundation
public enum SecurityProtocolError: Error, Sendable, Equatable {
  case implementationMissing(String)

  /// Equatable implementation
  public static func == (lhs: SecurityProtocolError, rhs: SecurityProtocolError) -> Bool {
    switch (lhs, rhs) {
      case let (.implementationMissing(lhsName), .implementationMissing(rhsName)):
        lhsName == rhsName
    }
  }
}

/// Protocol defining the base XPC service interface without Foundation dependencies
@objc
public protocol XPCServiceProtocolBasic: NSObjectProtocol, Sendable {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Test connectivity
  @objc
  func ping() async -> NSObject?

  /// Synchronize keys across processes
  /// - Parameter syncData: The key data to synchronize
  /// - Returns: Result with void success or error
  @objc
  func synchroniseKeys(_ syncData: NSData) async -> NSObject?
}

// MARK: - Extensions

extension XPCServiceProtocolBasic {
  /// Default implementation of protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.base"
  }

  /// Default implementation of ping - can be overridden by conforming types
  public func ping() async -> NSObject? {
    NSNumber(value: true)
  }

  /// Implementation for synchronising keys with byte array (for legacy compatibility)
  public func synchroniseKeys(_ bytes: [UInt8]) async -> Result<Void, SecurityProtocolError> {
    // Convert bytes to NSData
    let nsData=NSData(bytes: bytes, length: bytes.count)

    // Call the @objc protocol method
    let result=await synchroniseKeys(nsData)

    // Handle the result based on the returned NSObject
    if result != nil {
      return .success(())
    } else {
      return .failure(.implementationMissing("Key synchronisation failed"))
    }
  }
}

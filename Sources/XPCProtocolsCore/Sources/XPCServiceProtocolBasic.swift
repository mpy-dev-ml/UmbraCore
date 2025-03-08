import Foundation
import UmbraCoreTypes
import ErrorHandling

/// Protocol defining the base XPC service interface without Foundation dependencies
@objc
public protocol XPCServiceProtocolBasic: NSObjectProtocol, Sendable {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Basic ping method to test if service is responsive
  /// - Returns: YES if the service is responsive
  @objc func ping() async -> Bool

  /// Basic synchronisation of keys between XPC service and client 
  /// - Parameter bytes: Raw byte array for key synchronisation
  /// - Returns: Result with success or failure
  @objc func synchroniseKeys(_ bytes: [UInt8]) async -> Result<Void, UmbraErrors.Security.XPC>
}

/// Default protocol implementation
extension XPCServiceProtocolBasic {
  /// Default protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.protocol.basic"
  }
  
  /// Default implementation of ping - always succeeds
  public func ping() async -> Bool {
    true
  }
}

import Foundation
import ObjCBridgingTypesFoundation
import SecurityInterfacesBase
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining the XPC service interface for key management using Objective-C compatible
/// methods
///
/// **Migration Notice:**
/// This protocol is being deprecated in favour of the modern XPCServiceProtocolComplete and other
/// protocols in the XPCProtocolsCore module. For new implementations, please use
/// XPCProtocolMigrationFactory to create appropriate protocol adapters.
///
/// Migration steps:
/// 1. Replace implementations of XPCServiceProtocolDefinition with XPCServiceProtocolComplete
/// 2. Use XPCProtocolMigrationFactory.createCompleteAdapter() to create a service instance
/// 3. Update client code to use async/await patterns and Result types for error handling
///
/// See also: XPCProtocolMigrationGuide for comprehensive migration documentation
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
@objc
public protocol XPCServiceProtocolDefinition: ObjCBridgingTypesFoundation
.XPCServiceProtocolBaseFoundation {
  /// Synchronize keys across processes with raw bytes using NSData
  /// - Parameter data: The key data to synchronize
  @objc
  func synchroniseKeys(_ data: NSData, withReply reply: @escaping (Error?) -> Void)

  /// Get the XPC service version
  @objc
  func getVersion(withReply reply: @escaping (NSString?, Error?) -> Void)

  /// Get the host identifier
  @objc
  func getHostIdentifier(withReply reply: @escaping (NSString?, Error?) -> Void)

  /// Register a client application
  @objc
  func registerClient(clientID: NSString, withReply reply: @escaping (Bool, Error?) -> Void)

  /// Deregister a client application
  @objc
  func deregisterClient(clientID: NSString, withReply reply: @escaping (Bool, Error?) -> Void)

  /// Check if a client is registered
  @objc
  func isClientRegistered(
    clientID: NSString,
    withReply reply: @escaping (Bool, Error?) -> Void
  )
}

/// Implementation of XPCServiceProtocolBaseFoundation interface
///
/// **Migration Notice:**
/// This implementation is being deprecated in favour of ModernXPCService in the XPCProtocolsCore
/// module. For new implementations, please use XPCProtocolMigrationFactory to create
/// appropriate protocol adapters.
@available(*, deprecated, message: "Use ModernXPCService from XPCProtocolsCore instead")
public class XPCServiceProtocolDefinitionImpl: NSObject,
ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation {
  /// Protocol identifier for XPC service registration
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.protocol"
  }

  /// Creates an instance of the XPC service protocol
  /// - Returns: A protocol-conforming implementation
  public static func createInstance() -> any ObjCBridgingTypesFoundation
  .XPCServiceProtocolBaseFoundation {
    // This implementation would typically connect to the XPC service
    // In a real implementation, this would create an NSXPCConnection and configure it

    // For demonstration purposes, return a dummy implementation
    fatalError("Implementation required")
  }

  /// Base method to test connectivity
  @objc
  public func ping(withReply reply: @escaping (Bool, Error?) -> Void) {
    // Simply return true to indicate the service is available
    reply(true, nil)
  }

  /// Reset all security data
  @objc
  public func resetSecurityData(withReply reply: @escaping (Error?) -> Void) {
    // Implementation would reset security data
    // For demonstration, just return success
    reply(nil)
  }

  /// Get the XPC service version
  @objc
  public func getVersion(withReply reply: @escaping (NSString?, Error?) -> Void) {
    // Return the version
    reply("1.0.0" as NSString, nil)
  }

  /// Get the host identifier
  @objc
  public func getHostIdentifier(withReply reply: @escaping (NSString?, Error?) -> Void) {
    // Return the host identifier
    reply("host-id" as NSString, nil)
  }

  private override init() {} // Prevent instantiation
}

// Add non-Foundation compliant interface implementation
extension XPCServiceProtocolDefinitionImpl {
  public func ping(completion: @escaping (Bool, Error?) -> Void) {
    ping(withReply: completion)
  }

  public func resetSecurityData(completion: @escaping (Error?) -> Void) {
    resetSecurityData(withReply: completion)
  }
}

import CoreErrors
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Type aliases for convenience
public typealias SecureBytes=UmbraCoreTypes.SecureBytes

// MARK: - Legacy Protocol Definition

/// Legacy protocol for XPC services that will be migrated to the new protocol hierarchy
/// This protocol represents the base functionality from the previous implementation
/// and is used only for migration purposes.
public protocol XPCServiceProtocol: Sendable {
  /// Get the protocol identifier for this service
  static var protocolIdentifier: String { get }

  /// Ping the service to check if it's responsive
  func ping() async -> Bool

  /// Get the service version
  func getServiceVersion() async -> String?

  /// Get the service status dictionary
  func getServiceStatus() async -> [String: Any]?

  /// Get the device identifier
  func getDeviceIdentifier() async -> String?

  /// Basic key synchronization mechanism
  func synchronizeKeys(_ data: SecureBytes) async -> Bool
}

// Extension to provide backward compatibility
extension XPCServiceProtocol {
  func getServiceStatus() async -> [String: Any]? {
    nil
  }

  func getServiceVersion() async -> String? {
    nil
  }

  func getDeviceIdentifier() async -> String? {
    nil
  }

  func synchronizeKeys(_: SecureBytes) async -> Bool {
    false
  }
}

// Import error types directly
// Remove the non-existent enum import

// MARK: - Migration Support

///
/// This file provides adapters that implement the new XPC protocols using the legacy protocols.
/// This allows for a smooth migration path from the old protocol definitions to the new ones.
///
/// Adapters implement the `XPCServiceProtocolBasic` and `XPCServiceProtocolStandard` protocols
/// by wrapping instances of the legacy protocols and translating method calls between them.

/// Define XPCServiceProtocolBasic correctly - change to a non-class protocol
public protocol XPCServiceProtocolBasic: Sendable {
  static var protocolIdentifier: String { get }
  func ping() async throws -> Bool
  func synchroniseKeys(_ syncData: SecureBytes) async throws
}

/// Adapter to implement XPCServiceProtocolBasic from XPCServiceProtocol
private final class XPCBasicAdapter: XPCServiceProtocolBasic {
  private let service: any XPCServiceProtocol

  init(wrapping service: any XPCServiceProtocol) {
    self.service=service
  }

  // Static protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter.basic"
  }

  // Required basic methods
  func ping() async throws -> Bool {
    await service.ping()
  }

  func synchroniseKeys(_ syncData: SecureBytes) async throws {
    // Convert SecureBytes correctly
    let bytes=syncData.withUnsafeBytes { Array($0) }
    // Remove the BinaryData reference since it doesn't exist and handle the result
    _=await service.synchronizeKeys(SecureBytes(bytes: bytes))
  }
}

/// Standard protocol for XPC-based security services
public protocol XPCServiceProtocolStandard: Sendable {
  /// Protocol type identifier
  static var protocolIdentifier: String { get }

  /// Get the current service status
  /// - Returns: Dictionary containing status information
  func status() async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError>

  /// Get the device hardware identifier
  /// - Returns: Device hardware identifier
  func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError>

  /// Reset all security data on the device
  /// - Returns: Success or failure
  func resetSecurityData() async -> Result<Void, XPCProtocolsCore.SecurityError>

  /// Generate random bytes
  /// - Parameter count: Number of bytes to generate
  /// - Returns: Random bytes as Data
  func generateRandomBytes(count: Int) async -> Result<Data, XPCProtocolsCore.SecurityError>

  /// Import a key
  /// - Parameters:
  ///   - keyData: Data for the key
  ///   - keyType: Type of key to generate
  ///   - keyIdentifier: Optional identifier for the key
  ///   - metadata: Optional metadata to associate with the key
  func importKey(
    keyData: SecureBytes,
    keyType: XPCProtocolTypeDefs.KeyType,
    keyIdentifier: String?,
    metadata: [String: String]?
  ) async -> Result<String, XPCProtocolsCore.SecurityError>

  /// List all key identifiers
  /// - Returns: Array of key identifiers
  func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError>

  /// Get information about a key
  /// - Parameter keyId: Key identifier
  /// - Returns: Dictionary containing key information
  func getKeyInfo(keyId: String) async
    -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError>

  /// Delete a key
  /// - Parameter keyId: Key identifier
  /// - Returns: Success or failure
  func deleteKey(keyId: String) async -> Result<Void, XPCProtocolsCore.SecurityError>
}

/// Adapter to implement XPCServiceProtocolStandard from XPCServiceProtocol
private final class XPCStandardAdapter: XPCServiceProtocolStandard {
  private let service: any XPCServiceProtocol

  init(_ service: any XPCServiceProtocol) {
    self.service=service
  }

  static var protocolIdentifier: String {
    "legacy.xpc.service"
  }

  func status() async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
    guard let status=await service.getServiceStatus() else {
      return .failure(.internalError(reason: "Failed to get service status"))
    }

    // Convert to AnyObject dictionary
    let result=status.compactMapValues { $0 as AnyObject }
    return .success(result as [String: AnyObject])
  }

  func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
    guard let identifier=await service.getDeviceIdentifier() else {
      return .failure(.internalError(reason: "Failed to get device identifier"))
    }
    return .success(identifier)
  }

  func resetSecurityData() async -> Result<Void, XPCProtocolsCore.SecurityError> {
    // Legacy services don't support this directly
    .failure(.serviceUnavailable)
  }

  func generateRandomBytes(count _: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
    // Legacy services don't fully support this
    .failure(.serviceUnavailable)
  }

  func importKey(
    keyData _: SecureBytes,
    keyType _: XPCProtocolTypeDefs.KeyType,
    keyIdentifier _: String?,
    metadata _: [String: String]?
  ) async -> Result<String, XPCProtocolsCore.SecurityError> {
    // Legacy services don't support this
    .failure(.serviceUnavailable)
  }

  func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError> {
    // Legacy services don't support this
    .failure(.serviceUnavailable)
  }

  func getKeyInfo(keyId _: String) async
  -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
    // Legacy services don't support this
    .failure(.serviceUnavailable)
  }

  func deleteKey(keyId _: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
    // Legacy services don't support this
    .failure(.serviceUnavailable)
  }
}

/// Adapter to implement XPCServiceProtocol from XPCServiceProtocolStandard
private final class LegacyAdapter: XPCServiceProtocol {
  private let service: any XPCServiceProtocolStandard

  static var protocolIdentifier: String {
    "standard.xpc.service"
  }

  init(_ service: any XPCServiceProtocolStandard) {
    self.service=service
  }

  func ping() async -> Bool {
    // Fix the result.success issue - check if status returns successfully
    let result=await service.status()
    switch result {
      case .success:
        return true
      case .failure:
        return false
    }
  }

  func getServiceVersion() async -> String? {
    let result=await service.status()
    if case let .success(status)=result, let version=status["version"] as? String {
      return version
    }
    return nil
  }

  func getServiceStatus() async -> [String: Any]? {
    let result=await service.status()
    if case let .success(status)=result {
      return status as [String: Any]
    }
    return nil
  }

  func getDeviceIdentifier() async -> String? {
    let result=await service.getHardwareIdentifier()
    if case let .success(identifier)=result {
      return identifier
    }
    return nil
  }

  func synchronizeKeys(_: SecureBytes) async -> Bool {
    // Modern services don't have an exact equivalent
    false
  }
}

// MARK: - Adapter Factory

/// Factory for creating adapters between legacy and new XPC protocols
/// This allows for seamless migration between protocol versions
public enum XPCProtocolMigrationFactory {
  /// Create an adapter that implements XPCServiceProtocolBasic from a
  /// XPCServiceProtocol
  /// - Parameter service: The service to adapt
  /// - Returns: An object implementing XPCServiceProtocolBasic
  public static func createBasicAdapter(
    wrapping service: any XPCServiceProtocol
  ) -> any XPCServiceProtocolBasic {
    XPCBasicAdapter(wrapping: service)
  }

  /// Create an adapter that implements XPCServiceProtocolStandard from a
  /// XPCServiceProtocol
  /// - Parameter service: The service to adapt
  /// - Returns: An object implementing XPCServiceProtocolStandard
  public static func createStandardAdapter(
    wrapping service: any XPCServiceProtocol
  ) -> any XPCServiceProtocolStandard {
    XPCStandardAdapter(service)
  }
}

/// Extension to XPCServiceProtocol to add conversion methods
extension XPCServiceProtocol {
  /// Convert this service to an XPCServiceProtocolBasic
  /// - Returns: An adapter implementing XPCServiceProtocolBasic
  public func asXPCServiceProtocolBasic() -> any XPCServiceProtocolBasic {
    XPCProtocolMigrationFactory.createBasicAdapter(wrapping: self)
  }

  /// Convert this service to an XPCServiceProtocolStandard
  /// - Returns: An adapter implementing XPCServiceProtocolStandard
  public func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
    XPCProtocolMigrationFactory.createStandardAdapter(wrapping: self)
  }
}

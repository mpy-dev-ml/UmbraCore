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
public typealias SecureBytes = UmbraCoreTypes.SecureBytes

// MARK: - Legacy Protocol Definition

/// Legacy protocol for XPC services that will be migrated to the new protocol hierarchy
/// This protocol represents the base functionality from the previous implementation
/// and is used only for migration purposes.
///
/// **Migration Notice:**
/// This protocol is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolBasic` from the XPCProtocolsCore module instead.
///
/// Migration steps:
/// 1. Replace implementations of XPCServiceProtocol with XPCServiceProtocolBasic
/// 2. Use XPCProtocolMigrationFactory.createBasicAdapter() to create a service instance
/// 3. Update client code to use async/await patterns with proper error handling
///
/// See `XPCProtocolMigrationGuide` in the XPCProtocolsCore module for comprehensive
/// migration documentation.
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
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
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
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
///
/// **Migration Notice:**
/// This protocol is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolBasic` from the XPCProtocolsCore module instead.
///
/// See `XPCProtocolMigrationGuide` in the XPCProtocolsCore module for comprehensive
/// migration documentation.
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore module instead")
public protocol XPCServiceProtocolBasic: Sendable {
    static var protocolIdentifier: String { get }
    func ping() async throws -> Bool
    func synchroniseKeys(_ syncData: SecureBytes) async throws
}

/// Adapter to implement XPCServiceProtocolBasic from XPCServiceProtocol
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory from XPCProtocolsCore instead")
private final class XPCBasicAdapter: XPCServiceProtocolBasic {
    private let service: any XPCServiceProtocol

    init(wrapping service: any XPCServiceProtocol) {
        self.service = service
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
        let bytes = syncData.withUnsafeBytes { Array($0) }
        // Remove the BinaryData reference since it doesn't exist and handle the result
        _ = await service.synchronizeKeys(SecureBytes(bytes: bytes))
    }
}

/// Standard protocol for XPC-based security services
///
/// **Migration Notice:**
/// This protocol is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolStandard` from the XPCProtocolsCore module instead.
///
/// See `XPCProtocolMigrationGuide` in the XPCProtocolsCore module for comprehensive
/// migration documentation.
@available(*, deprecated, message: "Use XPCServiceProtocolStandard from XPCProtocolsCore module instead")
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

    /// Export a key
    /// - Parameter keyIdentifier: Key identifier
    /// - Returns: Key data and type
    func exportKey(
        keyIdentifier: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCProtocolsCore.SecurityError>

    /// Encrypt secure data
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Key identifier
    /// - Returns: Encrypted data
    func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError>

    /// Decrypt secure data
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Key identifier
    /// - Returns: Decrypted data
    func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError>

    /// Sign data
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Key identifier
    /// - Returns: Signed data
    func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError>

    /// Verify a signature
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Data that was signed
    ///   - keyIdentifier: Key identifier
    /// - Returns: Verification result
    func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError>

    /// Reset security data
    /// - Returns: Success or failure
    func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError>
}

/// Adapter to implement XPCServiceProtocolStandard from XPCServiceProtocol
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory from XPCProtocolsCore instead")
private final class XPCStandardAdapter: XPCServiceProtocolStandard {
    private let service: any XPCServiceProtocol

    init(_ service: any XPCServiceProtocol) {
        self.service = service
    }

    static var protocolIdentifier: String {
        "legacy.xpc.service"
    }

    func status() async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
        guard let status = await service.getServiceStatus() else {
            return .failure(.internalError(reason: "Failed to get service status"))
        }

        // Convert to AnyObject dictionary
        let result = status.compactMapValues { $0 as AnyObject }
        return .success(result as [String: AnyObject])
    }

    func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        guard let identifier = await service.getDeviceIdentifier() else {
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

    func exportKey(
        keyIdentifier _: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Many legacy services don't support signing
        return .failure(.operationNotSupported(name: "sign"))
    }

    func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Many legacy services don't support verification
        return .failure(.operationNotSupported(name: "verify"))
    }

    func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        await resetSecurityData()
    }
}

/// Adapter that implements the legacy XPCServiceProtocol by wrapping an XPCServiceProtocolStandard
/// This allows modern implementations to be used with legacy code during migration.
///
/// **Migration Notice:**
/// This adapter is deprecated and will be removed in a future release.
/// Please use `XPCProtocolMigrationFactory` from the XPCProtocolsCore module instead
/// to create adapters between legacy and modern service implementations.
///
/// See `XPCProtocolMigrationGuide` in the XPCProtocolsCore module for comprehensive
/// migration documentation.
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory from XPCProtocolsCore instead")
private final class LegacyAdapter: XPCServiceProtocol {
    private let service: any XPCServiceProtocolStandard

    static var protocolIdentifier: String {
        "standard.xpc.service"
    }

    init(_ service: any XPCServiceProtocolStandard) {
        self.service = service
    }

    func ping() async -> Bool {
        // Fix the result.success issue - check if status returns successfully
        let result = await service.status()
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    func getServiceVersion() async -> String? {
        let result = await service.status()
        if case let .success(status) = result, let version = status["version"] as? String {
            return version
        }
        return nil
    }

    func getServiceStatus() async -> [String: Any]? {
        let result = await service.status()
        if case let .success(status) = result {
            return status as [String: Any]
        }
        return nil
    }

    func getDeviceIdentifier() async -> String? {
        let result = await service.getHardwareIdentifier()
        if case let .success(identifier) = result {
            return identifier
        }
        return nil
    }

    func synchronizeKeys(_: SecureBytes) async -> Bool {
        // Modern services don't have an exact equivalent
        false
    }
}

/// Adapter to implement XPCServiceProtocolComplete from XPCServiceProtocol
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory from XPCProtocolsCore instead")
private final class CompleteAdapter: XPCServiceProtocolComplete {
    private let legacyService: any XPCServiceProtocol
    private let standardAdapter: XPCStandardAdapter

    init(_ service: any XPCServiceProtocol) {
        self.legacyService = service
        self.standardAdapter = XPCStandardAdapter(service)
    }

    static var protocolIdentifier: String {
        "legacy.xpc.service.complete"
    }

    // MARK: - XPCServiceProtocolBasic Implementation
    
    public func ping() async -> Bool {
        await standardAdapter.ping()
    }
    
    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await standardAdapter.getServiceVersion()
    }
    
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Modern services use an async/await method with Result type
        // This is the bridge implementation
        do {
            let _ = try await standardAdapter.synchronizeKeys(syncData)
        } catch {
            throw XPCProtocolsCore.SecurityError.operationFailed(operation: "synchroniseKeys", reason: error.localizedDescription)
        }
    }

    // MARK: - XPCServiceProtocolStandard Methods
    
    func status() async -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
        await standardAdapter.status()
    }

    func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await standardAdapter.getHardwareIdentifier()
    }
    
    func generateRandomData(length: Int) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Using the random bytes generator from standardAdapter
        let result = await standardAdapter.generateRandomBytes(count: length)
        switch result {
        case .success(let data):
            return .success(SecureBytes(data: data))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.encryptSecureData(data, keyIdentifier: keyIdentifier)
    }
    
    func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.decryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    func resetSecurityData() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        await standardAdapter.resetSecurityData()
    }

    func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        await standardAdapter.importKey(
            keyData: keyData,
            keyType: keyType,
            keyIdentifier: keyIdentifier,
            metadata: metadata
        )
    }

    func listKeys() async -> Result<[String], XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func getKeyInfo(keyId: String) async
        -> Result<[String: AnyObject], XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func deleteKey(keyId: String) async -> Result<Void, XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func exportKey(
        keyIdentifier: String
    ) async -> Result<(SecureBytes, XPCProtocolTypeDefs.KeyType), XPCProtocolsCore.SecurityError> {
        // Legacy services don't support this
        .failure(.serviceUnavailable)
    }

    func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        // Many legacy services don't support signing
        return .failure(.operationNotSupported(name: "sign"))
    }

    func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Many legacy services don't support verification
        return .failure(.operationNotSupported(name: "verify"))
    }

    func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        await standardAdapter.resetSecurity()
    }

    // Additional methods required by XPCServiceProtocolComplete beyond Standard protocol
    func encryptAuthenticated(
        data: SecureBytes,
        keyIdentifier: String,
        associatedData: SecureBytes?
    ) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Authenticated encryption not available in legacy service"))
    }

    func decryptAuthenticated(
        data: SecureBytes,
        keyIdentifier: String,
        associatedData: SecureBytes?
    ) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Authenticated decryption not available in legacy service"))
    }

    func generateKey(
        type: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Key generation not available in legacy service"))
    }

    func generateKeyPair(
        algorithm: String,
        keySize: Int,
        metadata: [String: String]?
    ) async -> Result<String, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Key generation not available in legacy service"))
    }

    func createSecureBackup(password: String) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Secure backup not available in legacy service"))
    }

    func restoreFromSecureBackup(
        backup: SecureBytes,
        password: String
    ) async -> Result<Void, XPCProtocolsCore.SecurityError> {
        return .failure(.operationNotSupported(name: "Secure backup restoration not available in legacy service"))
    }
}

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

    /// Create an adapter that implements XPCServiceProtocolComplete from a
    /// XPCServiceProtocol
    /// - Parameter service: The service to adapt
    /// - Returns: An object implementing XPCServiceProtocolComplete
    public static func createCompleteAdapter(
        wrapping service: any XPCServiceProtocol
    ) -> any XPCServiceProtocolComplete {
        CompleteAdapter(service)
    }
}

/// Extension to XPCServiceProtocol to add conversion methods
public extension XPCServiceProtocol {
    /// Convert this service to an XPCServiceProtocolBasic
    /// - Returns: An adapter implementing XPCServiceProtocolBasic
    func asXPCServiceProtocolBasic() -> any XPCServiceProtocolBasic {
        XPCProtocolMigrationFactory.createBasicAdapter(wrapping: self)
    }

    /// Convert this service to an XPCServiceProtocolStandard
    /// - Returns: An adapter implementing XPCServiceProtocolStandard
    func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
        XPCProtocolMigrationFactory.createStandardAdapter(wrapping: self)
    }
}

// MARK: - Migration Helper Extensions

/// Extension to provide migration guidance for XPCServiceProtocol users
public extension XPCServiceProtocol {
    /// Convert this legacy service to a modern XPCServiceProtocolBasic implementation
    ///
    /// Use this method to bridge from the legacy protocol to the modern protocol
    /// system during migration.
    ///
    /// Example:
    /// ```swift
    /// // Legacy code:
    /// let legacyService: XPCServiceProtocol = getLegacyService()
    ///
    /// // Migration step:
    /// let modernService = legacyService.asModernXPCService()
    /// ```
    @available(*, deprecated, message: "Transitional API - use XPCProtocolMigrationFactory directly")
    func asModernXPCService() -> any XPCServiceProtocolBasic {
        // Use the migration factory to create a properly wrapped service
        XPCProtocolMigrationFactory.createBasicAdapter(wrapping: self)
    }

    /// Convert this legacy service to a modern XPCServiceProtocolComplete implementation
    ///
    /// Use this method to bridge from the legacy protocol to the modern protocol
    /// system during migration.
    @available(*, deprecated, message: "Transitional API - use XPCProtocolMigrationFactory directly")
    func asCompleteXPCService() -> any XPCServiceProtocolComplete {
        // Use the migration factory to create a properly wrapped service
        XPCProtocolMigrationFactory.createCompleteAdapter(wrapping: self)
    }
}

/// Extension to provide migration guide information
public enum XPCProtocolsMigrationGuide {
    /// Primary migration actions required
    public static let migrationSteps = """
    # XPC Protocols Migration Guide

    ## Overview

    The XPC protocol system in UmbraCore has been modernised with a new structure in the XPCProtocolsCore module.
    This guide outlines steps required to migrate from the legacy protocols to the new ones.

    ## Migration Steps

    1. Replace direct usage of legacy protocols (XPCServiceProtocol, etc.) with the equivalent protocols
       from XPCProtocolsCore (XPCServiceProtocolBasic, XPCServiceProtocolStandard, or XPCServiceProtocolComplete)

    2. For legacy service implementations, use the XPCProtocolMigrationFactory to create adapters:
       ```swift
       // Instead of creating a legacy service directly:
       // let service = LegacyXPCService()

       // Use the factory to create an appropriate adapter:
       let service = XPCProtocolMigrationFactory.createCompleteAdapter()
       ```

    3. For client code, update to use async/await and Result types for proper error handling

    4. Remove references to SecurityInterfaces.XPCProtocolsMigration and instead
       import XPCProtocolsCore directly

    ## For Detailed Documentation

    See the comprehensive migration guide in the XPCProtocolsCore module documentation.
    """
}

import CoreErrors
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

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
    func synchronizeKeys(_ data: UmbraCoreTypes.SecureBytes) async -> Bool
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

    func synchronizeKeys(_: UmbraCoreTypes.SecureBytes) async -> Bool {
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

    func status() async -> Result<[String: AnyObject], SecurityInterfacesError> {
        guard let status = await service.getServiceStatus() else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to get service status"))
        }

        // Convert to AnyObject dictionary
        let result = status.compactMapValues { $0 as AnyObject }
        return .success(result as [String: AnyObject])
    }

    func getHardwareIdentifier() async -> Result<String, SecurityInterfacesError> {
        guard let identifier = await service.getDeviceIdentifier() else {
            return .failure(SecurityInterfacesError.operationFailed("Failed to get device identifier"))
        }
        return .success(identifier)
    }

    func resetSecurityData() async -> Result<Void, SecurityInterfacesError> {
        // Legacy services don't support this directly
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func generateRandomBytes(count _: Int) async -> Result<Data, SecurityInterfacesError> {
        // Legacy services don't fully support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func importKey(
        keyData _: UmbraCoreTypes.SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier _: String?,
        metadata _: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func listKeys() async -> Result<[String], SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func getKeyInfo(keyId _: String) async
        -> Result<[String: AnyObject], SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func deleteKey(keyId _: String) async -> Result<Void, SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func exportKey(
        keyIdentifier _: String
    ) async -> Result<(UmbraCoreTypes.SecureBytes, XPCProtocolTypeDefs.KeyType), SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func encryptSecureData(_: UmbraCoreTypes.SecureBytes, keyIdentifier _: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func decryptSecureData(_: UmbraCoreTypes.SecureBytes, keyIdentifier _: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func sign(_: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Many legacy services don't support signing
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: sign"))
    }

    func verify(signature _: UmbraCoreTypes.SecureBytes, for _: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<Bool, SecurityInterfacesError> {
        // Many legacy services don't support verification
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: verify"))
    }

    func resetSecurity() async -> Result<Void, SecurityInterfacesError> {
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

    func synchronizeKeys(_: UmbraCoreTypes.SecureBytes) async -> Bool {
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
        legacyService = service
        standardAdapter = XPCStandardAdapter(service)
    }

    static var protocolIdentifier: String {
        "legacy.xpc.service.complete"
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        await standardAdapter.ping()
    }

    public func getServiceVersion() async -> Result<String, SecurityInterfacesError> {
        await standardAdapter.getServiceVersion()
    }

    public func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async throws {
        // Modern services use an async/await method with Result type
        // This is the bridge implementation
        do {
            _ = try await standardAdapter.synchronizeKeys(syncData)
        } catch {
            throw SecurityInterfacesError.operationFailed(operation: "synchroniseKeys", reason: error.localizedDescription)
        }
    }

    // MARK: - XPCServiceProtocolStandard Methods

    func status() async -> Result<[String: AnyObject], SecurityInterfacesError> {
        await standardAdapter.status()
    }

    func getHardwareIdentifier() async -> Result<String, SecurityInterfacesError> {
        await standardAdapter.getHardwareIdentifier()
    }

    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Using the random bytes generator from standardAdapter
        let result = await standardAdapter.generateRandomBytes(count: length)
        switch result {
        case let .success(data):
            // Convert Data to SecureBytes
            return .success(SecurityProviderUtils.dataToSecureBytes(data))
        case let .failure(error):
            return .failure(error)
        }
    }

    func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        await standardAdapter.encryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        await standardAdapter.decryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    func resetSecurityData() async -> Result<Void, SecurityInterfacesError> {
        await standardAdapter.resetSecurityData()
    }

    func importKey(
        keyData: UmbraCoreTypes.SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        await standardAdapter.importKey(
            keyData: keyData,
            keyType: keyType,
            keyIdentifier: keyIdentifier,
            metadata: metadata
        )
    }

    func listKeys() async -> Result<[String], SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func getKeyInfo(keyId _: String) async
        -> Result<[String: AnyObject], SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func deleteKey(keyId _: String) async -> Result<Void, SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func exportKey(
        keyIdentifier _: String
    ) async -> Result<(UmbraCoreTypes.SecureBytes, XPCProtocolTypeDefs.KeyType), SecurityInterfacesError> {
        // Legacy services don't support this
        .failure(SecurityInterfacesError.operationFailed("Service unavailable"))
    }

    func sign(_: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        // Many legacy services don't support signing
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: sign"))
    }

    func verify(signature _: UmbraCoreTypes.SecureBytes, for _: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<Bool, SecurityInterfacesError> {
        // Many legacy services don't support verification
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: verify"))
    }

    func resetSecurity() async -> Result<Void, SecurityInterfacesError> {
        await standardAdapter.resetSecurity()
    }

    // Additional methods required by XPCServiceProtocolComplete beyond Standard protocol
    func encryptAuthenticated(
        data _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String,
        associatedData _: UmbraCoreTypes.SecureBytes?
    ) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Authenticated encryption not available in legacy service"))
    }

    func decryptAuthenticated(
        data _: UmbraCoreTypes.SecureBytes,
        keyIdentifier _: String,
        associatedData _: UmbraCoreTypes.SecureBytes?
    ) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Authenticated decryption not available in legacy service"))
    }

    func generateKey(
        type _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier _: String?,
        metadata _: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Key generation not available in legacy service"))
    }

    func generateKeyPair(
        algorithm _: String,
        keySize _: Int,
        metadata _: [String: String]?
    ) async -> Result<String, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Key generation not available in legacy service"))
    }

    func createSecureBackup(password _: String) async -> Result<UmbraCoreTypes.SecureBytes, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Secure backup not available in legacy service"))
    }

    func restoreSecureBackup(
        backup _: UmbraCoreTypes.SecureBytes,
        password _: String
    ) async -> Result<Void, SecurityInterfacesError> {
        .failure(SecurityInterfacesError.operationFailed("Operation not supported: Secure backup restoration not available in legacy service"))
    }
}

/// Factory for creating adapters between legacy and new XPC protocols
/// This allows for seamless migration between protocol versions
public enum XPCProtocolMigrationFactory {
    /// Create a standard protocol adapter
    /// - Parameter service: Legacy service to wrap
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
    /// Convert this service to an XPCServiceProtocolStandard
    /// - Returns: An adapter implementing XPCServiceProtocolStandard
    func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
        XPCProtocolMigrationFactory.createStandardAdapter(wrapping: self)
    }
}

// MARK: - Migration Helper Extensions

/// Extension to provide migration guidance for XPCServiceProtocol users
public extension XPCServiceProtocol {
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

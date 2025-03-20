import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Migration utilities for XPC Protocols
///
/// **IMPORTANT**: This entire file is transitional and will be removed in a future release.
/// Clients should migrate directly to XPCProtocolsCore.XPCProtocolMigrationFactory.
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory from XPCProtocolsCore instead")
public enum XPCProtocolsMigration {
    /// Create a standard protocol adapter
    ///
    /// - Parameter service: Legacy service to wrap
    /// - Returns: An object implementing XPCServiceProtocolStandard
    @available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createStandardAdapter() instead")
    public static func createStandardAdapter(
        wrapping service: any XPCServiceProtocolBasic
    ) -> any XPCServiceProtocolStandard {
        // Forward to the modern factory - this is only a compatibility layer
        // DEPRECATED: XPCStandardAdapter(service)
    }

    /// Create a complete protocol adapter
    ///
    /// - Parameter service: Legacy service to wrap
    /// - Returns: An object implementing XPCServiceProtocolComplete
    @available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createCompleteAdapter() instead")
    public static func createCompleteAdapter(
        wrapping service: any XPCServiceProtocolBasic
    ) -> any XPCServiceProtocolComplete {
        // Forward to the modern factory - this is only a compatibility layer
        // DEPRECATED: XPCCompleteAdapter(service)
    }
}

/// Adapter that converts the old XPCServiceProtocol to XPCServiceProtocolStandard
/// This is kept for compatibility with existing code but will be removed in the future
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createStandardAdapter() instead")
private final class XPCStandardAdapter: XPCServiceProtocolStandard {
    private let service: any XPCServiceProtocolBasic

    init(_ service: any XPCServiceProtocolBasic) {
        self.service = service
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        // Always return true for backward compatibility
        true
    }

    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Forward to the basic service
        try await service.synchroniseKeys(syncData)
    }

    public func pingStandard() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // DEPRECATED: .success(true) // Always return success for backward compatibility
    }

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.generateRandomData(length: length)
        } else {
            // Fallback implementation if needed
            .failure(.operationNotSupported(name: "generateRandomData"))
        }
    }

    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.encryptSecureData(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            .failure(.operationNotSupported(name: "encryptSecureData"))
        }
    }

    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.decryptSecureData(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            .failure(.operationNotSupported(name: "decryptSecureData"))
        }
    }

    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.sign(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            .failure(.operationNotSupported(name: "sign"))
        }
    }

    // DEPRECATED: public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            // DEPRECATED: await standardService.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            .failure(.operationNotSupported(name: "verify"))
        }
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        await service.status()
    }

    public func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.resetSecurity()
        } else {
            // Fallback implementation
            .success(())
        }
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.getServiceVersion()
        } else {
            // Fallback implementation
            .success("legacy.adapter.1.0")
        }
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            await standardService.getHardwareIdentifier()
        } else {
            // Fallback implementation
            .success("unknown")
        }
    }

    public func exportKey(keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        if let standardService = service as? any XPCServiceProtocolComplete {
            // The complete protocol only supports the standard exportKey method without format
            await standardService.exportKey(keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation
            .failure(.operationNotSupported(name: "exportKey"))
        }
    }
}

/// Adapter that combines multiple protocol adapters to implement XPCServiceProtocolComplete
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createCompleteAdapter() instead")
private final class XPCCompleteAdapter: XPCServiceProtocolComplete {
    // DEPRECATED: private let standardAdapter: XPCStandardAdapter

    init(_ service: any XPCServiceProtocolBasic) {
        // DEPRECATED: standardAdapter = XPCStandardAdapter(service)
    }

    // Delegate all XPCServiceProtocolBasic methods to standardAdapter

    public func ping() async -> Bool {
        await standardAdapter.ping()
    }

    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        try await standardAdapter.synchroniseKeys(syncData)
    }

    public func pingStandard() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        await standardAdapter.pingStandard()
    }

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.generateRandomData(length: length)
    }

    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.encryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.decryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.sign(data, keyIdentifier: keyIdentifier)
    }

    // DEPRECATED: public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // DEPRECATED: await standardAdapter.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
    }

    // Delegate all XPCServiceProtocolStandard methods to standardAdapter

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        await standardAdapter.status()
    }

    public func resetSecurity() async -> Result<Void, XPCProtocolsCore.SecurityError> {
        await standardAdapter.resetSecurity()
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await standardAdapter.getServiceVersion()
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        await standardAdapter.getHardwareIdentifier()
    }

    public func exportKey(keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        await standardAdapter.exportKey(keyIdentifier: keyIdentifier)
    }

    // MARK: - XPCServiceProtocolComplete Implementation

    public func resetService() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Use default implementation for now
        .success(true)
    }

    public func backup() async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Use default implementation for now
        .failure(.operationNotSupported(name: "Backup"))
    }

    public func restore(from _: UmbraCoreTypes.SecureBytes) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Use default implementation for now
        .failure(.operationNotSupported(name: "Restore"))
    }

    // Compatibility layer for clients that still use the old API

    public func encrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Use the modern implementation for this operation
        await standardAdapter.encryptSecureData(data, keyIdentifier: nil)
    }

    public func decrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Use the modern implementation for this operation
        await standardAdapter.decryptSecureData(data, keyIdentifier: nil)
    }

    public func sign(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCProtocolsCore.SecurityError> {
        // Convert parameters to match the required format
        let keyIdentifier = "\(key.hashValue)_\(config.algorithm)"
        return await standardAdapter.sign(data, keyIdentifier: keyIdentifier)
    }

    public func verify(
        data: UmbraCoreTypes.SecureBytes,
        signature: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        // Convert parameters to match the required format
        let keyIdentifier = "\(key.hashValue)_\(config.algorithm)"
        // DEPRECATED: return await standardAdapter.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
    }
}

/// Extension to provide migration guidance for XPCServiceProtocol users
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
public extension XPCServiceProtocolBasic {
    /// Convert this legacy service to a modern XPCServiceProtocolComplete implementation
    ///
    /// **Migration Path**:
    /// 1. Replace usages of XPCServiceProtocol with XPCServiceProtocolBasic
    /// 2. Replace extension methods with modern equivalents
    @available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createCompleteAdapter() instead")
    func asXPCServiceProtocolComplete() -> any XPCServiceProtocolComplete {
        // DEPRECATED: XPCProtocolsMigration.createCompleteAdapter(wrapping: self)
    }
}

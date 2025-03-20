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
        XPCStandardAdapter(service)
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
        XPCCompleteAdapter(service)
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
        return true
    }
    
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Forward to the basic service
        try await service.synchroniseKeys(syncData)
    }
    
    public func pingStandard() async -> Result<Bool, XPCSecurityError> {
        .success(true) // Always return success for backward compatibility
    }
    
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.generateRandomData(length: length)
        } else {
            // Fallback implementation if needed
            return .failure(.notImplemented(reason: "generateRandomData not implemented"))
        }
    }
    
    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.encryptSecureData(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            return .failure(.notImplemented(reason: "encryptSecureData not implemented"))
        }
    }
    
    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.decryptSecureData(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            return .failure(.notImplemented(reason: "decryptSecureData not implemented"))
        }
    }
    
    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.sign(data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            return .failure(.notImplemented(reason: "sign not implemented"))
        }
    }
    
    public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation if needed
            return .failure(.notImplemented(reason: "verify not implemented"))
        }
    }
    
    // MARK: - XPCServiceProtocolStandard Implementation
    
    public func status() async -> Result<[String: Any], XPCSecurityError> {
        await service.status()
    }
    
    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.resetSecurity()
        } else {
            // Fallback implementation 
            return .success(())
        }
    }
    
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.getServiceVersion()
        } else {
            // Fallback implementation
            return .success("legacy.adapter.1.0")
        }
    }
    
    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolStandard {
            return await standardService.getHardwareIdentifier()
        } else {
            // Fallback implementation
            return .success("unknown")
        }
    }
    
    public func exportKey(keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        if let standardService = service as? any XPCServiceProtocolComplete {
            // The complete protocol only supports the standard exportKey method without format
            return await standardService.exportKey(keyIdentifier: keyIdentifier)
        } else {
            // Fallback implementation
            return .failure(.notImplemented(reason: "exportKey not implemented"))
        }
    }
}

/// Adapter that combines multiple protocol adapters to implement XPCServiceProtocolComplete
@available(*, deprecated, message: "Use XPCProtocolMigrationFactory.createCompleteAdapter() instead")
private final class XPCCompleteAdapter: XPCServiceProtocolComplete {
    private let standardAdapter: XPCStandardAdapter
    
    init(_ service: any XPCServiceProtocolBasic) {
        standardAdapter = XPCStandardAdapter(service)
    }
    
    // Delegate all XPCServiceProtocolBasic methods to standardAdapter
    
    public func ping() async -> Bool {
        await standardAdapter.ping()
    }
    
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        try await standardAdapter.synchroniseKeys(syncData)
    }
    
    public func pingStandard() async -> Result<Bool, XPCSecurityError> {
        await standardAdapter.pingStandard()
    }
    
    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await standardAdapter.generateRandomData(length: length)
    }
    
    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await standardAdapter.encryptSecureData(data, keyIdentifier: keyIdentifier)
    }
    
    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await standardAdapter.decryptSecureData(data, keyIdentifier: keyIdentifier)
    }
    
    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await standardAdapter.sign(data, keyIdentifier: keyIdentifier)
    }
    
    public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        await standardAdapter.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
    }
    
    // Delegate all XPCServiceProtocolStandard methods to standardAdapter
    
    public func status() async -> Result<[String: Any], XPCSecurityError> {
        await standardAdapter.status()
    }
    
    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        await standardAdapter.resetSecurity()
    }
    
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        await standardAdapter.getServiceVersion()
    }
    
    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        await standardAdapter.getHardwareIdentifier()
    }
    
    public func exportKey(keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await standardAdapter.exportKey(keyIdentifier: keyIdentifier)
    }
    
    // MARK: - XPCServiceProtocolComplete Implementation
    
    public func resetService() async -> Result<Bool, XPCSecurityError> {
        // Use default implementation for now
        .success(true)
    }
    
    public func backup() async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Use default implementation for now
        .failure(.notImplemented(reason: "Backup not implemented"))
    }
    
    public func restore(from backup: UmbraCoreTypes.SecureBytes) async -> Result<Bool, XPCSecurityError> {
        // Use default implementation for now
        .failure(.notImplemented(reason: "Restore not implemented"))
    }
    
    // Compatibility layer for clients that still use the old API
    
    public func encrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Use the modern implementation for this operation
        await standardAdapter.encryptSecureData(data, keyIdentifier: nil)
    }
    
    public func decrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Use the modern implementation for this operation
        await standardAdapter.decryptSecureData(data, keyIdentifier: nil)
    }
    
    public func sign(
        data: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Convert parameters to match the required format
        let keyIdentifier = "\(key.hashValue)_\(config.algorithm)"
        return await standardAdapter.sign(data, keyIdentifier: keyIdentifier)
    }
    
    public func verify(
        data: UmbraCoreTypes.SecureBytes,
        signature: UmbraCoreTypes.SecureBytes,
        key: UmbraCoreTypes.SecureBytes,
        config: SecurityConfig
    ) async -> Result<Bool, XPCSecurityError> {
        // Convert parameters to match the required format
        let keyIdentifier = "\(key.hashValue)_\(config.algorithm)"
        return await standardAdapter.verify(signature: signature, for: data, keyIdentifier: keyIdentifier)
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
        XPCProtocolsMigration.createCompleteAdapter(wrapping: self)
    }
}

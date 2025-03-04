// XPCProtocolsMigration.swift
// SecurityInterfaces
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import XPCProtocolsCore
import SecurityInterfacesBase
import UmbraCoreTypes

/// Migration support for XPC protocols
/// 
/// This file provides:
/// 1. Type aliases mapping old protocol types to new XPCProtocolsCore types
/// 2. Extensions to make protocols compatible with the new XPCProtocolsCore hierarchy
/// 3. Adapter types to bridge between protocol versions
///
/// This allows for a gradual migration away from the legacy protocols
/// while maintaining backward compatibility.

// MARK: - Type Aliases for Deprecation Path

@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolBasic instead")
public typealias DeprecatedXPCServiceProtocolBase = XPCProtocolsCore.XPCServiceProtocolBasic

@available(*, deprecated, message: "Use XPCProtocolsCore.XPCServiceProtocolStandard instead")
public typealias DeprecatedXPCServiceProtocol = XPCProtocolsCore.XPCServiceProtocolStandard

// MARK: - Protocol Extensions

/// Extension to bring XPCProtocolsCore methods to SecurityInterfacesBase.XPCServiceProtocolBase
extension SecurityInterfacesBase.XPCServiceProtocolBase {
    /// Adapter to convert to XPCProtocolsCore.XPCServiceProtocolBasic
    public func asXPCProtocolsCoreBasic() -> any XPCServiceProtocolBasic {
        return XPCBasicAdapter(wrapping: self)
    }
}

/// Extension to bring XPCProtocolsCore methods to SecurityInterfaces.XPCServiceProtocol
extension SecurityInterfaces.XPCServiceProtocol {
    /// Adapter to convert to XPCProtocolsCore.XPCServiceProtocolStandard
    public func asXPCProtocolsCoreStandard() -> any XPCServiceProtocolStandard {
        return XPCStandardAdapter(wrapping: self)
    }
}

// MARK: - Adapters

/// Adapter to implement XPCServiceProtocolBasic from SecurityInterfacesBase.XPCServiceProtocolBase
private struct XPCBasicAdapter: XPCServiceProtocolBasic {
    private let base: any SecurityInterfacesBase.XPCServiceProtocolBase
    
    init(wrapping base: any SecurityInterfacesBase.XPCServiceProtocolBase) {
        self.base = base
    }
    
    func pingBasic() async -> Result<Bool, XPCSecurityError> {
        do {
            let result = try await base.ping()
            return .success(result)
        } catch {
            return .failure(.accessError)
        }
    }
    
    func getServiceVersion() async -> Result<String, XPCSecurityError> {
        do {
            let version = try await base.getVersion()
            return .success(version)
        } catch {
            return .failure(.accessError)
        }
    }
    
    func getDeviceIdentifier() async -> Result<String, XPCSecurityError> {
        do {
            let hostId = try await base.getHostIdentifier()
            return .success(hostId)
        } catch {
            return .failure(.accessError)
        }
    }
}

/// Adapter to implement XPCServiceProtocolStandard from SecurityInterfaces.XPCServiceProtocol
private struct XPCStandardAdapter: XPCServiceProtocolStandard {
    private let service: any SecurityInterfaces.XPCServiceProtocol
    
    init(wrapping service: any SecurityInterfaces.XPCServiceProtocol) {
        self.service = service
    }
    
    // Implement XPCServiceProtocolBasic methods
    func pingBasic() async -> Result<Bool, XPCSecurityError> {
        do {
            let result = try await service.ping()
            return .success(result)
        } catch {
            return .failure(.accessError)
        }
    }
    
    func getServiceVersion() async -> Result<String, XPCSecurityError> {
        do {
            let version = try await service.getVersion()
            return .success(version)
        } catch {
            return .failure(.accessError)
        }
    }
    
    func getDeviceIdentifier() async -> Result<String, XPCSecurityError> {
        do {
            let hostId = try await service.getHostIdentifier()
            return .success(hostId)
        } catch {
            return .failure(.accessError)
        }
    }
    
    // Implement XPCServiceProtocolStandard methods
    func resetSecurity() async -> Result<Void, XPCSecurityError> {
        do {
            try await service.resetSecurityData()
            return .success(())
        } catch {
            return .failure(.accessError)
        }
    }
    
    func pingStandard() async -> Result<Bool, XPCSecurityError> {
        return await pingBasic()
    }
    
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        do {
            try await service.synchroniseKeys(Array(syncData.bytes))
            return .success(())
        } catch {
            return .failure(.accessError)
        }
    }
}

// MARK: - Adapter Factory

/// Factory to create standard adapters
public enum XPCProtocolMigrationFactory {
    /// Create an adapter that implements XPCServiceProtocolStandard from a legacy XPCServiceProtocol
    /// - Parameter service: Legacy service to adapt
    /// - Returns: Adapter implementing XPCServiceProtocolStandard
    public static func createStandardAdapter(from service: any SecurityInterfaces.XPCServiceProtocol) -> any XPCServiceProtocolStandard {
        return XPCStandardAdapter(wrapping: service)
    }
    
    /// Create an adapter that implements XPCServiceProtocolBasic from a legacy XPCServiceProtocolBase
    /// - Parameter service: Legacy service to adapt
    /// - Returns: Adapter implementing XPCServiceProtocolBasic
    public static func createBasicAdapter(from service: any SecurityInterfacesBase.XPCServiceProtocolBase) -> any XPCServiceProtocolBasic {
        return XPCBasicAdapter(wrapping: service)
    }
}

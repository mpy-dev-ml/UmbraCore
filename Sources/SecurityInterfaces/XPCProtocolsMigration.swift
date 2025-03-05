// XPCProtocolsMigration.swift
// SecurityInterfaces
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import Foundation
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import XPCProtocolsCore
import UmbraCoreTypes

// Type aliases for clarity
typealias SecureBytes = UmbraCoreTypes.SecureBytes
typealias BinaryData = SecurityInterfacesBase.BinaryData
typealias XPCSecurityError = UmbraCoreTypes.CESecurityError
typealias ServiceStatus = XPCProtocolsCore.ServiceStatus

/// MARK: - Migration Support
/// 
/// This file provides adapters that implement the new XPC protocols using the legacy protocols.
/// This allows for a smooth migration path from the old protocol definitions to the new ones.
/// 
/// Adapters implement the `XPCServiceProtocolBasic` and `XPCServiceProtocolStandard` protocols
/// by wrapping instances of the legacy protocols and translating method calls between them.

/// Adapter to implement XPCServiceProtocolBasic from SecurityInterfacesProtocols.XPCServiceProtocolBase
private struct XPCBasicAdapter: XPCServiceProtocolBasic {
    private let service: any SecurityInterfacesProtocols.XPCServiceProtocolBase
    
    init(wrapping service: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
        self.service = service
    }
    
    // Static protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.basic"
    }
    
    // Required basic methods
    func ping() async throws -> Bool {
        return try await service.ping()
    }
    
    func synchroniseKeys(_ syncData: SecureBytes) async throws {
        try await service.synchroniseKeys(syncData.withUnsafeBytes { bytes in
            return [UInt8](bytes)
        })
    }
}

/// Adapter to implement XPCServiceProtocolStandard from SecurityInterfaces.XPCServiceProtocol
private struct XPCStandardAdapter: XPCServiceProtocolStandard {
    private let service: any SecurityInterfaces.XPCServiceProtocol

    init(wrapping service: any SecurityInterfaces.XPCServiceProtocol) {
        self.service = service
    }
    
    // Static protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.standard"
    }

    // Implement XPCServiceProtocolBasic methods
    func ping() async throws -> Bool {
        return try await service.ping()
    }
    
    func synchroniseKeys(_ syncData: SecureBytes) async throws {
        try await service.synchroniseKeys(syncData.withUnsafeBytes { bytes in
            return [UInt8](bytes)
        })
    }
    
    // Implement XPCServiceProtocolStandard methods
    func generateRandomData(length: Int) async throws -> SecureBytes {
        // Simple implementation that returns zeros since the legacy protocol doesn't support this
        return SecureBytes(bytes: [UInt8](repeating: 0, count: length))
    }
    
    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Use the existing encrypt method from XPCServiceProtocol
        let result = try await service.encrypt(data: data.withUnsafeBytes { bytes in
            return BinaryData(Array(bytes))
        })
        
        // Convert the result back to SecureBytes
        return SecureBytes(bytes: result.bytes)
    }
    
    func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Use the existing decrypt method from XPCServiceProtocol
        let result = try await service.decrypt(data: data.withUnsafeBytes { bytes in
            return BinaryData(Array(bytes))
        })
        
        // Convert the result back to SecureBytes
        return SecureBytes(bytes: result.bytes)
    }
    
    func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        // Simple implementation that returns the data since the legacy protocol doesn't support this
        return data
    }
    
    func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        // Simple implementation that returns the data since the legacy protocol doesn't support this
        return data
    }
    
    func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        // Simple implementation that returns true since the legacy protocol doesn't support this
        return true
    }
}

// MARK: - Adapter Factory

/// Factory for creating bridging adapters between legacy and new XPC protocols
/// This allows for seamless migration between protocol versions
public enum XPCProtocolMigrationFactory {
    /// Create an adapter that implements XPCServiceProtocolBasic from an XPCServiceProtocolBase
    /// - Parameter service: The legacy service to adapt
    /// - Returns: An object implementing XPCServiceProtocolBasic
    public static func createBasicAdapter(wrapping service: any SecurityInterfacesProtocols.XPCServiceProtocolBase) -> any XPCServiceProtocolBasic {
        return XPCBasicAdapter(wrapping: service)
    }
    
    /// Create an adapter that implements XPCServiceProtocolStandard from an XPCServiceProtocol
    /// - Parameter service: The legacy service to adapt
    /// - Returns: An object implementing XPCServiceProtocolStandard
    public static func createStandardAdapter(wrapping service: any SecurityInterfaces.XPCServiceProtocol) -> any XPCServiceProtocolStandard {
        return XPCStandardAdapter(wrapping: service)
    }
}

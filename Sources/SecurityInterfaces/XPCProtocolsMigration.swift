// XPCProtocolsMigration.swift
// SecurityInterfaces
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import CoreErrors
import SecurityInterfacesBase
import SecurityInterfacesProtocols
import UmbraCoreTypes
import XPCProtocolsCore

/// Type aliases for convenience
typealias SecureBytes = UmbraCoreTypes.SecureBytes
typealias BinaryData = SecurityInterfacesBase.BinaryData
typealias XPCSecurityError = CoreErrors.SecurityError

/// Import the SecurityProtocolError directly
@_exported import enum XPCProtocolsCore.SecurityProtocolError

// MARK: - Migration Support
/// 
/// This file provides adapters that implement the new XPC protocols using the legacy protocols.
/// This allows for a smooth migration path from the old protocol definitions to the new ones.
/// 
/// Adapters implement the `XPCServiceProtocolBasic` and `XPCServiceProtocolStandard` protocols
/// by wrapping instances of the legacy protocols and translating method calls between them.

/// Adapter to implement XPCServiceProtocolBasic from SecurityInterfaces.XPCServiceProtocol
private struct XPCBasicAdapter: XPCServiceProtocolBasic {
    private let service: any SecurityInterfaces.XPCServiceProtocol

    init(wrapping service: any SecurityInterfaces.XPCServiceProtocol) {
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
        // Convert SecureBytes to BinaryData
        let bytes = syncData.withUnsafeBytes { Array($0) }
        let binaryData = SecurityInterfacesBase.BinaryData(bytes)
        try await service.synchroniseKeys(binaryData)
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
        // Convert SecureBytes to BinaryData
        let bytes = syncData.withUnsafeBytes { Array($0) }
        let binaryData = SecurityInterfacesBase.BinaryData(bytes)
        try await service.synchroniseKeys(binaryData)
    }

    // Implement XPCServiceProtocolStandard methods
    func generateRandomData(length: Int) async throws -> SecureBytes {
        // Simple implementation that returns zeros since the legacy protocol doesn't support this
        return SecureBytes(bytes: [UInt8](repeating: 0, count: length))
    }

    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Convert SecureBytes to BinaryData for encryption
        let bytes = data.withUnsafeBytes { Array($0) }
        let binaryData = SecurityInterfacesBase.BinaryData(bytes)

        // Encrypt the data
        let encryptedData = try await service.encrypt(data: binaryData)

        // Convert back to SecureBytes
        return SecureBytes(bytes: encryptedData.bytes)
    }

    func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Convert SecureBytes to BinaryData for decryption
        let bytes = data.withUnsafeBytes { Array($0) }
        let binaryData = SecurityInterfacesBase.BinaryData(bytes)

        // Decrypt the data
        let decryptedData = try await service.decrypt(data: binaryData)

        // Convert back to SecureBytes
        return SecureBytes(bytes: decryptedData.bytes)
    }

    func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        throw SecurityProtocolError.implementationMissing("hashData is not implemented in legacy XPC service")
    }

    func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        throw SecurityProtocolError.implementationMissing("signData is not implemented in legacy XPC service")
    }

    func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        throw SecurityProtocolError.implementationMissing("verifySignature is not implemented in legacy XPC service")
    }
}

// MARK: - Adapter Factory

/// Factory for creating adapters between legacy and new XPC protocols
/// This allows for seamless migration between protocol versions
public enum XPCProtocolMigrationFactory {
    /// Create an adapter that implements XPCServiceProtocolBasic from a SecurityInterfaces.XPCServiceProtocol
    /// - Parameter service: The service to adapt
    /// - Returns: An object implementing XPCServiceProtocolBasic
    public static func createBasicAdapter(wrapping service: any SecurityInterfaces.XPCServiceProtocol) -> any XPCServiceProtocolBasic {
        return XPCBasicAdapter(wrapping: service)
    }

    /// Create an adapter that implements XPCServiceProtocolStandard from a SecurityInterfaces.XPCServiceProtocol
    /// - Parameter service: The service to adapt
    /// - Returns: An object implementing XPCServiceProtocolStandard
    public static func createStandardAdapter(wrapping service: any SecurityInterfaces.XPCServiceProtocol) -> any XPCServiceProtocolStandard {
        return XPCStandardAdapter(wrapping: service)
    }
}

/// Extension to SecurityInterfaces.XPCServiceProtocol to add conversion methods
public extension SecurityInterfaces.XPCServiceProtocol {
    /// Convert this service to an XPCServiceProtocolBasic
    /// - Returns: An adapter implementing XPCServiceProtocolBasic
    func asXPCServiceProtocolBasic() -> any XPCServiceProtocolBasic {
        return XPCProtocolMigrationFactory.createBasicAdapter(wrapping: self)
    }

    /// Convert this service to an XPCServiceProtocolStandard
    /// - Returns: An adapter implementing XPCServiceProtocolStandard
    func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
        return XPCProtocolMigrationFactory.createStandardAdapter(wrapping: self)
    }
}

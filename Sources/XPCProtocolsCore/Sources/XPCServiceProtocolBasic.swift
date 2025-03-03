// XPCServiceProtocolBasic.swift
// XPCProtocolsCore
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import SecureBytes

/// Custom error for security interfaces that doesn't require Foundation
public enum SecurityProtocolError: Error, Sendable, Equatable {
    case implementationMissing(String)
    
    /// Equatable implementation
    public static func == (lhs: SecurityProtocolError, rhs: SecurityProtocolError) -> Bool {
        switch (lhs, rhs) {
        case (.implementationMissing(let lhsName), .implementationMissing(let rhsName)):
            return lhsName == rhsName
        }
    }
}

/// Protocol defining the base XPC service interface without Foundation dependencies
public protocol XPCServiceProtocolBasic: Sendable {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test connectivity
    func ping() async throws -> Bool

    /// Synchronize keys across processes
    /// - Parameter syncData: The key data to synchronize
    func synchroniseKeys(_ syncData: SecureBytes) async throws
}

// MARK: - Extensions

extension XPCServiceProtocolBasic {
    /// Default implementation of protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.base"
    }
    
    /// Default implementation of ping - can be overridden by conforming types
    public func ping() async throws -> Bool {
        return true
    }
    
    /// Implementation for synchronising keys with byte array (for legacy compatibility)
    public func synchroniseKeys(_ bytes: [UInt8]) async throws {
        let secureBytes = SecureBytes(bytes)
        try await synchroniseKeys(secureBytes)
    }
}

// XPCServiceProtocolCore.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import SecureBytes

/// Protocol defining core XPC service functionality without Foundation dependencies.
/// This protocol uses SecureBytes for binary data to avoid custom type definitions
/// and ensure compatibility with the rest of the security architecture.
public protocol XPCServiceProtocolCore: Sendable {
    /// Protocol identifier used for service discovery and protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test connectivity with the XPC service
    /// - Returns: Boolean indicating whether the service is responsive
    func ping() async -> Result<Bool, SecurityError>

    /// Synchronize encryption keys across processes
    /// - Parameter syncData: Key synchronization data
    /// - Returns: Success or a descriptive error
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, SecurityError>

    /// Encrypt data using the service's encryption implementation
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data or error
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError>

    /// Decrypt data using the service's decryption implementation
    /// - Parameter data: Data to decrypt
    /// - Returns: Decrypted data or error
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError>

    /// Generate a cryptographic key using the service
    /// - Returns: Generated key or error
    func generateKey() async -> Result<SecureBytes, SecurityError>

    /// Hash data using the service's hashing implementation
    /// - Parameter data: Data to hash
    /// - Returns: Hash value or error
    func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError>
}

// MARK: - Default Implementations

public extension XPCServiceProtocolCore {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.core"
    }

    /// Default ping implementation - always successful in the base protocol
    func ping() async -> Result<Bool, SecurityError> {
        return .success(true)
    }

    /// Default implementation that returns a not implemented error
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, SecurityError> {
        return .failure(.notImplemented)
    }

    /// Default implementation that returns a not implemented error
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .failure(.notImplemented)
    }

    /// Default implementation that returns a not implemented error
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .failure(.notImplemented)
    }

    /// Default implementation that returns a not implemented error
    func generateKey() async -> Result<SecureBytes, SecurityError> {
        return .failure(.notImplemented)
    }

    /// Default implementation that returns a not implemented error
    func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .failure(.notImplemented)
    }
}

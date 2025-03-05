// XPCServiceProtocolComplete.swift
// XPCProtocolsCore
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import UmbraCoreTypes

/// @available(*, deprecated, message: "Use XPCSecurityError instead")
/// SecurityError is now deprecated. Use XPCSecurityError from the XPCProtocolsCore module instead.
@available(*, deprecated, message: "Use XPCSecurityError instead")
public enum SecurityError: Error, Sendable, Equatable {
    case notImplemented
    case invalidData
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case hashingFailed
    case serviceFailed
    case general(String)
    case cryptoError

    /// Equatable implementation for SecurityError
    public static func == (lhs: SecurityError, rhs: SecurityError) -> Bool {
        switch (lhs, rhs) {
        case (.notImplemented, .notImplemented),
             (.invalidData, .invalidData),
             (.encryptionFailed, .encryptionFailed),
             (.decryptionFailed, .decryptionFailed),
             (.keyGenerationFailed, .keyGenerationFailed),
             (.hashingFailed, .hashingFailed),
             (.serviceFailed, .serviceFailed),
             (.cryptoError, .cryptoError):
            return true
        case (.general(let lhsMessage), .general(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// Protocol defining core XPC service functionality without Foundation dependencies.
/// This protocol uses SecureBytes for binary data to avoid custom type definitions
/// and ensure compatibility with the rest of the security architecture.
public protocol XPCServiceProtocolComplete: XPCServiceProtocolStandard {
    /// Protocol identifier used for service discovery and protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test connectivity with the XPC service
    /// - Returns: Boolean indicating whether the service is responsive
    func pingComplete() async -> Result<Bool, XPCSecurityError>

    /// Synchronize encryption keys across processes
    /// - Parameter syncData: Key synchronization data
    /// - Returns: Success or a descriptive error
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError>

    /// Encrypt data using the service's encryption implementation
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data or error
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Decrypt data using the service's decryption implementation
    /// - Parameter data: Data to decrypt
    /// - Returns: Decrypted data or error
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Generate a cryptographic key using the service
    /// - Returns: Generated key or error
    func generateKey() async -> Result<SecureBytes, XPCSecurityError>

    /// Hash data using the service's hashing implementation
    /// - Parameter data: Data to hash
    /// - Returns: Hash value or error
    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>
}

// MARK: - Default Implementations

public extension XPCServiceProtocolComplete {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.complete"
    }

    /// Default ping implementation - always successful in the base protocol
    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        return .success(true)
    }

    /// Default implementation that returns a not implemented error
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        return .failure(.cryptoError)
    }

    /// Default implementation that returns a not implemented error
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .failure(.cryptoError)
    }

    /// Default implementation that returns a not implemented error
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .failure(.cryptoError)
    }

    /// Default implementation that returns a not implemented error
    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        return .failure(.cryptoError)
    }

    /// Default implementation that returns a not implemented error
    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .failure(.cryptoError)
    }

    /// Bridge method to implement XPCServiceProtocolBasic.ping() using pingComplete()
    func ping() async throws -> Bool {
        let result = await pingComplete()
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    /// Bridge method to implement XPCServiceProtocolBasic.synchroniseKeys() using synchronizeKeys()
    func synchroniseKeys(_ syncData: SecureBytes) async throws {
        let result = await synchronizeKeys(syncData)
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

/**
 # Complete XPC Service Protocol

 This file defines the most comprehensive protocol for XPC services in UmbraCore,
 building upon the standard protocol to provide a complete suite of cryptographic
 and security functionality.

 ## Features

 * Advanced cryptographic operations
 * Key management and derivation
 * Digital signature creation and verification
 * Status reporting and monitoring
 * Asynchronous operation with detailed error reporting

 ## Protocol Inheritance

 This protocol inherits from XPCServiceProtocolStandard and adds additional
 functionality. Services implement this protocol when they need to provide
 the full suite of cryptographic capabilities.
 */

import Foundation
import UmbraCoreTypes

/// The most comprehensive XPC service protocol that provides a complete suite
/// of cryptographic operations and security functionality. This protocol builds
/// upon the standard protocol to offer advanced features for sophisticated
/// security needs.
///
/// Services that implement this protocol provide the full range of cryptographic
/// capabilities including encryption, decryption, key generation, digital
/// signatures, and secure storage.
public protocol XPCServiceProtocolComplete: XPCServiceProtocolStandard {
    /// Ping the service with an asynchronous Result response that supports
    /// detailed errors.
    /// - Returns: Success with a boolean indicating service health, or error
    ///   with detailed failure information.
    func pingComplete() async -> Result<Bool, XPCSecurityError>

    /// Synchronise keys with the service.
    /// - Parameter syncData: Key synchronisation data.
    /// - Returns: Success or error with detailed failure information.
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError>

    /// Encrypt data using the service.
    /// - Parameter data: Data to encrypt.
    /// - Returns: Encrypted data or error with detailed failure information.
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Decrypt data using the service.
    /// - Parameter data: Data to decrypt.
    /// - Returns: Decrypted data or error with detailed failure information.
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Generate a cryptographic key.
    /// - Returns: Key data or error with detailed failure information.
    func generateKey() async -> Result<SecureBytes, XPCSecurityError>

    /// Generate a cryptographic key of specific type and bits.
    /// - Parameters:
    ///   - type: Type of key to generate.
    ///   - bits: Key size in bits.
    /// - Returns: Key data or error with detailed failure information.
    func generateKey(
        type: XPCProtocolTypeDefs.KeyType,
        bits: Int
    ) async -> Result<SecureBytes, XPCSecurityError>

    /// Hash data using the service's hashing implementation.
    /// - Parameter data: Data to hash.
    /// - Returns: Hash value or error with detailed failure information.
    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Export a key from the service in secure format.
    /// - Parameter keyIdentifier: Key to export.
    /// - Returns: Secure data containing exported key or error with detailed
    ///   failure information.
    func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError>

    /// Import a previously exported key.
    /// - Parameters:
    ///   - keyData: Key data to import.
    ///   - keyIdentifier: Optional identifier to assign to the imported key.
    /// - Returns: Success or error with detailed failure information.
    func importKey(
        keyData: SecureBytes,
        keyIdentifier: String?
    ) async -> Result<Void, XPCSecurityError>

    /// Sign data using a key managed by the service.
    /// - Parameters:
    ///   - data: Data to sign.
    ///   - keyIdentifier: Identifier of the key to use for signing.
    /// - Returns: Signature data or error with detailed failure information.
    func sign(
        data: SecureBytes,
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError>

    /// Verify a signature for data.
    /// - Parameters:
    ///   - signature: Signature to verify.
    ///   - data: Original data that was signed.
    ///   - keyIdentifier: Identifier of the key to use for verification.
    /// - Returns: Verification result or error with detailed failure information.
    func verify(
        signature: SecureBytes,
        data: SecureBytes,
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError>

    /// Get the current status of the service.
    /// - Returns: Service status or error with detailed failure information.
    func getStatus() async -> Result<ServiceStatus, XPCSecurityError>
}

/// Default implementations for the complete XPC service protocol
public extension XPCServiceProtocolComplete {
    /// Default protocol identifier for the complete protocol.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.complete"
    }

    /// Default implementation of the ping complete method that delegates to the
    /// basic ping.
    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        let result = await ping()
        return .success(result)
    }

    /// Default implementation of synchroniseKeys that returns success.
    func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    /// Default implementation of encrypt that returns a not implemented error.
    func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Encryption not implemented"))
    }

    /// Default implementation of decrypt that returns a not implemented error.
    func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Decryption not implemented"))
    }

    /// Default implementation of generateKey that returns a not implemented error.
    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Key generation not implemented"))
    }

    /// Default implementation of generateKey(type:bits:) that returns a not
    /// implemented error.
    func generateKey(
        type _: XPCProtocolTypeDefs.KeyType,
        bits _: Int
    ) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Custom key generation not implemented"))
    }

    /// Default implementation of hash that returns a not implemented error.
    func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Hashing not implemented"))
    }

    /// Default implementation of exportKey that returns a not implemented error.
    func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Key export not implemented"))
    }

    /// Default implementation of importKey that returns a not implemented error.
    func importKey(
        keyData _: SecureBytes,
        keyIdentifier _: String?
    ) async -> Result<Void, XPCSecurityError> {
        .failure(.internalError(reason: "Key import not implemented"))
    }

    /// Default implementation that returns a not implemented error.
    func sign(
        data _: SecureBytes,
        keyIdentifier _: String
    ) async -> Result<SecureBytes, XPCSecurityError> {
        .failure(.internalError(reason: "Signing not implemented"))
    }

    /// Default implementation that returns a not implemented error.
    func verify(
        signature _: SecureBytes,
        data _: SecureBytes,
        keyIdentifier _: String
    ) async -> Result<Bool, XPCSecurityError> {
        .failure(.internalError(reason: "Verification not implemented"))
    }

    /// Default implementation that returns a not implemented error.
    func getStatus() async -> Result<ServiceStatus, XPCSecurityError> {
        .failure(.internalError(reason: "Get status not implemented"))
    }
}

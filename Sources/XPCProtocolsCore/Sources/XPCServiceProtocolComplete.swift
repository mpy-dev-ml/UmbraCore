/**
 # Complete XPC Service Protocol

 This file defines the most comprehensive protocol for XPC services in UmbraCore,
 building upon the standard protocol to provide a complete suite of cryptographic
 and security functionality.

 ## Features

 * Advanced cryptographic operations with SecureBytes
 * Comprehensive key management and derivation
 * Digital signature creation and verification with modern interfaces
 * Status reporting and monitoring with structured return types
 * Fully async/await-based API with Result return types for detailed error handling

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

    /// Get the service's current status with detailed information
    /// - Returns: Structured status information or error details on failure
    func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError>

    /// Generate a cryptographic key
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the generated key or error on failure
    func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier of key to delete
    /// - Returns: Success or error with detailed failure information
    func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError>

    /// List all key identifiers
    /// - Returns: Array of key identifiers or error with detailed failure information
    func listKeys() async -> Result<[String], XPCSecurityError>

    /// Import a key
    /// - Parameters:
    ///   - keyData: Key data to import as SecureBytes
    ///   - keyType: Type of key
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the imported key or error with detailed failure information
    func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Export a key
    /// - Parameter keyIdentifier: Identifier of the key to export
    /// - Returns: Key data as SecureBytes or error with detailed failure information
    func exportKey(
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError>

    /// Derive a key from another key or password
    /// - Parameters:
    ///   - sourceKeyIdentifier: Identifier of the source key or password
    ///   - salt: Salt data as SecureBytes
    ///   - iterations: Number of iterations for key derivation
    ///   - keyLength: Length of the derived key in bytes
    ///   - targetKeyIdentifier: Optional identifier for the derived key
    /// - Returns: Identifier for the derived key or error with detailed failure information
    func deriveKey(
        from sourceKeyIdentifier: String,
        salt: SecureBytes,
        iterations: Int,
        keyLength: Int,
        targetKeyIdentifier: String?
    ) async -> Result<String, XPCSecurityError>
}

/// Default implementations for the complete XPC service protocol
public extension XPCServiceProtocolComplete {
    /// Default protocol identifier for the complete protocol.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.complete"
    }

    /// Default implementation of pingComplete that delegates to the basic ping method
    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        let isResponding = await ping()
        return .success(isResponding)
    }

    /// Helper function to convert throwing operations to Result
    private func withErrorHandling<T>(_ operation: () throws -> T) -> Result<T, XPCSecurityError> {
        do {
            let result = try operation()
            return .success(result)
        } catch {
            if let xpcError = error as? XPCSecurityError {
                return .failure(xpcError)
            } else {
                return .failure(.internalError(reason: "\(error)"))
            }
        }
    }

    /// Default implementation for generating secure random data
    func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        withErrorHandling {
            let randomBytes = Array(0 ..< length).map { _ in UInt8.random(in: 0 ... 255) }
            return SecureBytes(bytes: randomBytes)
        }
    }

    /// Default implementation for encrypting secure data
    func encryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // This is just a placeholder. Actual implementations should override this.
        .failure(.notImplemented(reason: "Encryption not implemented in base protocol"))
    }

    /// Default implementation for decrypting secure data
    func decryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // This is just a placeholder. Actual implementations should override this.
        .failure(.notImplemented(reason: "Decryption not implemented in base protocol"))
    }

    /// Default implementation for hashing secure data
    func hashSecureData(_: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // This is just a placeholder. Actual implementations should override this.
        .failure(.notImplemented(reason: "Hashing not implemented in base protocol"))
    }

    /// Default implementation for signing secure data
    func signSecureData(_: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        // This is just a placeholder. Actual implementations should override this.
        .failure(.notImplemented(reason: "Signing not implemented in base protocol"))
    }

    /// Default implementation for verifying secure signatures
    func verifySecureSignature(_: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        // This is just a placeholder. Actual implementations should override this.
        .failure(.notImplemented(reason: "Verification not implemented in base protocol"))
    }

    /// Default implementation for getting service status
    func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError> {
        let isActive = await ping()
        return .success(XPCServiceStatus(isActive: isActive, version: "1.0", serviceType: "XPC"))
    }
}

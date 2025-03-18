/**
 # Standard XPC Service Protocol

 This file defines the standard protocol for XPC services in UmbraCore, building upon the basic
 protocol to provide more comprehensive cryptographic and security functionality.

 ## Features

 * Extends the basic XPC service protocol with cryptographic functions
 * Support for encryption, decryption, and key management
 * Status reporting and health checking capabilities
 * Support for modern SecureBytes for better memory safety and security

 ## Protocol Inheritance

 This protocol inherits from XPCServiceProtocolBasic and adds additional functionality.
 Services can choose to implement this protocol if they need to provide standard
 cryptographic capabilities.
 */

import CoreErrors
import Foundation
import UmbraCoreTypes

/// Protocol defining a standard set of cryptographic operations for XPC services
public protocol XPCServiceProtocolStandard: XPCServiceProtocolBasic {
    /// Generate random data of specified length
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or XPCSecurityError on failure
    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>

    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with encrypted SecureBytes on success or XPCSecurityError on failure
    func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>

    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with decrypted SecureBytes on success or XPCSecurityError on failure
    func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>

    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: SecureBytes to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Result with signature as SecureBytes on success or XPCSecurityError on failure
    func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>

    /// Verify signature for data
    /// - Parameters:
    ///   - signature: SecureBytes containing the signature
    ///   - data: SecureBytes containing the data to verify
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Result with boolean indicating verification result or XPCSecurityError on failure
    func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError>

    /// Standard protocol ping - extends basic ping with better error handling
    /// - Returns: Result with boolean indicating service status or XPCSecurityError on failure
    func pingStandard() async -> Result<Bool, XPCSecurityError>

    /// Reset the security state of the service
    /// - Returns: Result with void on success or XPCSecurityError on failure
    func resetSecurity() async -> Result<Void, XPCSecurityError>

    /// Get the service version
    /// - Returns: Result with version string on success or XPCSecurityError on failure
    func getServiceVersion() async -> Result<String, XPCSecurityError>

    /// Get the hardware identifier
    /// - Returns: Result with identifier string on success or XPCSecurityError on failure
    func getHardwareIdentifier() async -> Result<String, XPCSecurityError>

    /// Get the service status
    /// - Returns: Result with status dictionary on success or XPCSecurityError on failure
    func status() async -> Result<[String: Any], XPCSecurityError>
}

/// Default implementations for the standard protocol methods
public extension XPCServiceProtocolStandard {
    /// Default protocol identifier for the standard protocol.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.standard"
    }

    /// Default implementation forwards to the basic ping
    func pingStandard() async -> Result<Bool, XPCSecurityError> {
        do {
            let pingResult = try await ping()
            return .success(pingResult)
        } catch {
            return .failure(.serviceUnavailable)
        }
    }

    /// Default service status implementation
    func status() async -> Result<[String: Any], XPCSecurityError> {
        let versionResult = await getServiceVersion()

        var statusDict: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "protocol": Self.protocolIdentifier
        ]

        if case .success(let version) = versionResult {
            statusDict["version"] = version
        }

        return .success(statusDict)
    }

    /// Encrypt data with default implementation
    func encrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await encryptSecureData(data, keyIdentifier: nil)
    }

    /// Decrypt data with default implementation
    func decrypt(data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await decryptSecureData(data, keyIdentifier: nil)
    }
}

/// Key management protocol extension for services that handle cryptographic keys
public protocol KeyManagementServiceProtocol: Sendable {
    /// Generate a new key
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata for the key
    /// - Returns: Result with key identifier on success or XPCSecurityError on failure
    func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier for the key to delete
    /// - Returns: Result with void on success or XPCSecurityError on failure
    func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError>

    /// List all keys
    /// - Returns: Result with array of key identifiers on success or XPCSecurityError on failure
    func listKeys() async -> Result<[String], XPCSecurityError>

    /// Import a key
    /// - Parameters:
    ///   - keyData: SecureBytes containing the key data
    ///   - keyType: Type of key being imported
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata for the key
    /// - Returns: Result with key identifier on success or XPCSecurityError on failure
    func importKey(
        keyData: UmbraCoreTypes.SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Export a key
    /// - Parameters:
    ///   - keyIdentifier: Identifier for the key to export
    ///   - format: Format to export the key in
    /// - Returns: Result with key data as SecureBytes on success or XPCSecurityError on failure
    func exportKey(
        keyIdentifier: String,
        format: XPCProtocolTypeDefs.KeyFormat
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>
}

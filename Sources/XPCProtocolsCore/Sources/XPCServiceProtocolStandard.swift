/**
 # Standard XPC Service Protocol

 This file defines the standard protocol for XPC services in UmbraCore, building upon the basic
 protocol to provide more comprehensive cryptographic and security functionality.

 ## Features

 * Extends the basic XPC service protocol with cryptographic functions
 * Support for encryption, decryption, and key management
 * Status reporting and health checking capabilities
 * Support for both modern SecureBytes and legacy NSObject-based API for backward compatibility

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
    /// - Returns: Random data as NSObject (typically NSData) or nil if generation failed
    func generateRandomData(length: Int) async -> NSObject?

    /// Modern version that returns SecureBytes instead of NSObject
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or XPCSecurityError on failure
    func generateSecureRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError>

    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Encrypted data as NSObject (typically NSData) or nil if encryption failed
    func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?

    /// Modern version that uses SecureBytes instead of NSData
    /// - Parameters:
    ///   - data: SecureBytes to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with encrypted SecureBytes on success or XPCSecurityError on failure
    func encryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError>

    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Decrypted data as NSObject (typically NSData) or nil if decryption failed
    func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?

    /// Modern version that uses SecureBytes instead of NSData
    /// - Parameters:
    ///   - data: SecureBytes to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with decrypted SecureBytes on success or XPCSecurityError on failure
    func decryptSecureData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError>

    /// Hash data using the service's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash value as NSObject (typically NSData) or nil if hashing failed
    func hashData(_ data: NSData) async -> NSObject?

    /// Modern version that uses SecureBytes instead of NSData
    /// - Parameter data: SecureBytes to hash
    /// - Returns: Result with hash as SecureBytes on success or XPCSecurityError on failure
    func hashSecureData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Signature as NSObject (typically NSData) or nil if signing failed
    func signData(_ data: NSData, keyIdentifier: String) async -> NSObject?

    /// Modern version that uses SecureBytes instead of NSData
    /// - Parameters:
    ///   - data: SecureBytes to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Result with signature as SecureBytes on success or XPCSecurityError on failure
    func signSecureData(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError>

    /// Verify a signature for the given data
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Data that was signed
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Verification result as NSObject (typically NSNumber containing a boolean) or nil if verification failed
    func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) async -> NSObject?

    /// Modern version that uses SecureBytes instead of NSData
    /// - Parameters:
    ///   - signature: SecureBytes containing the signature to verify
    ///   - data: SecureBytes containing the data that was signed
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Result with boolean verification result on success or XPCSecurityError on failure
    func verifySecureSignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError>
}

/// Default implementation for the standard XPC service protocol to bridge between
/// legacy NSObject-based methods and modern SecureBytes-based methods
public extension XPCServiceProtocolStandard {
    /// Default protocol identifier for the standard protocol.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.standard"
    }

    /// Default implementation for random data generation that bridges to the modern version
    func generateRandomData(length: Int) async -> NSObject? {
        let result = await generateSecureRandomData(length: length)
        switch result {
        case let .success(secureBytes):
            return convertSecureBytesToNSData(secureBytes)
        case .failure:
            return nil
        }
    }

    /// Default implementation for data encryption that bridges to the modern version
    func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        let secureData = convertNSDataToSecureBytes(data)
        let result = await encryptSecureData(secureData, keyIdentifier: keyIdentifier)
        switch result {
        case let .success(encryptedData):
            return convertSecureBytesToNSData(encryptedData)
        case .failure:
            return nil
        }
    }

    /// Default implementation for data decryption that bridges to the modern version
    func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        let secureData = convertNSDataToSecureBytes(data)
        let result = await decryptSecureData(secureData, keyIdentifier: keyIdentifier)
        switch result {
        case let .success(decryptedData):
            return convertSecureBytesToNSData(decryptedData)
        case .failure:
            return nil
        }
    }

    /// Default implementation for data hashing that bridges to the modern version
    func hashData(_ data: NSData) async -> NSObject? {
        let secureData = convertNSDataToSecureBytes(data)
        let result = await hashSecureData(secureData)
        switch result {
        case let .success(hashData):
            return convertSecureBytesToNSData(hashData)
        case .failure:
            return nil
        }
    }

    /// Default implementation for data signing that bridges to the modern version
    func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        let secureData = convertNSDataToSecureBytes(data)
        let result = await signSecureData(secureData, keyIdentifier: keyIdentifier)
        switch result {
        case let .success(signature):
            return convertSecureBytesToNSData(signature)
        case .failure:
            return nil
        }
    }

    /// Default implementation for signature verification that bridges to the modern version
    func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) async -> NSObject? {
        let secureSignature = convertNSDataToSecureBytes(signature)
        let secureData = convertNSDataToSecureBytes(data)
        let result = await verifySecureSignature(secureSignature, for: secureData, keyIdentifier: keyIdentifier)
        switch result {
        case let .success(isValid):
            return NSNumber(value: isValid)
        case .failure:
            return nil
        }
    }
}

/// Extended functionality for key management
public protocol KeyManagementServiceProtocol: Sendable {
    /// Generate a new key
    /// - Parameters:
    ///   - keyType: Type of key to generate
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the generated key
    func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Export a key
    /// - Parameter keyIdentifier: Identifier for the key to export
    /// - Returns: Exported key data
    func exportKey(
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError>

    /// Import a key
    /// - Parameters:
    ///   - keyData: Key data to import
    ///   - keyType: Type of key
    ///   - keyIdentifier: Optional identifier for the key
    ///   - metadata: Optional metadata to associate with the key
    /// - Returns: Identifier for the imported key
    func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError>

    /// Delete a key
    /// - Parameter keyIdentifier: Identifier for the key to delete
    /// - Returns: Success or failure
    func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError>

    /// List all key identifiers
    /// - Returns: Array of key identifiers
    func listKeyIdentifiers() async -> Result<[String], XPCSecurityError>

    /// Get metadata for a key
    /// - Parameter keyIdentifier: Identifier for the key
    /// - Returns: Associated metadata
    func getKeyMetadata(
        for keyIdentifier: String
    ) async -> Result<[String: String]?, XPCSecurityError>
}

/// Secure storage functionality for the XPC service
public protocol SecureStorageServiceProtocol: Sendable {
    /// Store data securely
    /// - Parameters:
    ///   - data: Data to store
    ///   - identifier: Unique identifier for the data
    ///   - metadata: Optional metadata to associate with the data
    /// - Returns: Success or failure
    func storeData(
        _ data: SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, XPCSecurityError>

    /// Retrieve securely stored data
    /// - Parameter identifier: Identifier for the data to retrieve
    /// - Returns: The stored data
    func retrieveData(
        identifier: String
    ) async -> Result<SecureBytes, XPCSecurityError>

    /// Delete securely stored data
    /// - Parameter identifier: Identifier for the data to delete
    /// - Returns: Success or failure
    func deleteData(
        identifier: String
    ) async -> Result<Void, XPCSecurityError>

    /// List all data identifiers
    /// - Returns: Array of data identifiers
    func listDataIdentifiers() async -> Result<[String], XPCSecurityError>

    /// Get metadata for stored data
    /// - Parameter identifier: Identifier for the data
    /// - Returns: Associated metadata
    func getDataMetadata(
        for identifier: String
    ) async -> Result<[String: String]?, XPCSecurityError>
}

/// Comprehensive security service protocol that combines multiple security capabilities
public protocol ComprehensiveSecurityServiceProtocol: XPCServiceProtocolStandard,
    SecureStorageServiceProtocol, KeyManagementServiceProtocol
{
    /// Get the service version
    /// - Returns: Version string
    func getServiceVersion() async -> String

    /// Check if a specific feature is supported
    /// - Parameter featureIdentifier: Identifier for the feature to check
    /// - Returns: Bool indicating support
    func isFeatureSupported(featureIdentifier: String) async -> Bool
}

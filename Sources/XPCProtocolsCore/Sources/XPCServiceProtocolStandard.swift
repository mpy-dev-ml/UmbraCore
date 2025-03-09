/**
 # Standard XPC Service Protocol
 
 This file defines the standard protocol for XPC services in UmbraCore, building upon the basic
 protocol to provide more comprehensive cryptographic and security functionality.
 
 ## Features
 
 * Extends the basic XPC service protocol with cryptographic functions
 * Support for encryption, decryption, and key management
 * Status reporting and health checking capabilities
 * Support for NSObject-based API for backward compatibility
 
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
  
  /// Encrypt data using the service's encryption mechanism
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - keyIdentifier: Optional identifier for the key to use
  /// - Returns: Encrypted data as NSObject (typically NSData) or nil if encryption failed
  func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?
  
  /// Decrypt data using the service's decryption mechanism
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - keyIdentifier: Optional identifier for the key to use
  /// - Returns: Decrypted data as NSObject (typically NSData) or nil if decryption failed
  func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject?
  
  /// Hash data using the service's hashing mechanism
  /// - Parameter data: Data to hash
  /// - Returns: Hash value as NSObject (typically NSData) or nil if hashing failed
  func hashData(_ data: NSData) async -> NSObject?
  
  /// Sign data using the service's signing mechanism
  /// - Parameters:
  ///   - data: Data to sign
  ///   - keyIdentifier: Identifier for the key to use
  /// - Returns: Signature as NSObject (typically NSData) or nil if signing failed
  func signData(_ data: NSData, keyIdentifier: String) async -> NSObject?
  
  /// Verify signature for data
  /// - Parameters:
  ///   - signature: Signature to verify
  ///   - data: Original data that was signed
  ///   - keyIdentifier: Identifier for the key to use
  /// - Returns: NSNumber containing a boolean indicating if signature is valid,
  ///   or nil if verification failed
  func verifySignature(_ signature: NSData,
                       for data: NSData,
                       keyIdentifier: String) async -> NSNumber?
  
  /// Get the service's current status
  /// - Returns: Status information as NSDictionary or nil if status couldn't be retrieved
  func getServiceStatus() async -> NSDictionary?
  
  /// Generate a cryptographic key
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
  
  /// Delete a key
  /// - Parameter keyIdentifier: Identifier of key to delete
  /// - Returns: Success or error
  func deleteKey(
    keyIdentifier: String
  ) async -> Result<Void, XPCSecurityError>
  
  /// List all key identifiers
  /// - Returns: Array of key identifiers
  func listKeys() async -> Result<[String], XPCSecurityError>
  
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
  SecureStorageServiceProtocol, KeyManagementServiceProtocol {
  /// Get the service version
  /// - Returns: Version string
  func getServiceVersion() async -> String
  
  /// Check if a specific feature is supported
  /// - Parameter featureIdentifier: Identifier for the feature to check
  /// - Returns: Bool indicating support
  func isFeatureSupported(featureIdentifier: String) async -> Bool
}

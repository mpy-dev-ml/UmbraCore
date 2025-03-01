// KeyManagementImpl.swift
// SecurityImplementation
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import CryptoSwiftFoundationIndependent
import SecureBytes
import SecurityProtocolsCore

/// In-memory implementation of KeyManagementProtocol
/// This is a basic implementation that stores keys in memory for demonstration purposes
/// In a real implementation, keys would be stored securely in a platform-specific secure storage
public final class KeyManagementImpl: KeyManagementProtocol {
    
    // MARK: - Properties
    
    /// In-memory storage of keys
    private var keyStore: [String: SecureBytes] = [:]
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - KeyManagementProtocol Implementation
    
    public func retrieveKey(withIdentifier identifier: String) async -> Result<SecureBytes, SecurityError> {
        guard let key = keyStore[identifier] else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }
        return .success(key)
    }
    
    public func storeKey(_ key: SecureBytes, withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        keyStore[identifier] = key
        return .success(())
    }
    
    public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        guard keyStore[identifier] != nil else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }
        
        keyStore.removeValue(forKey: identifier)
        return .success(())
    }
    
    public func rotateKey(withIdentifier identifier: String, 
                          dataToReencrypt: SecureBytes?) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), SecurityError> {
        // Check if the old key exists
        guard let oldKey = keyStore[identifier] else {
            return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
        }
        
        // Generate a new key
        let newKey = CryptoWrapper.generateRandomKeySecure()
        
        // Re-encrypt data if provided
        var reencryptedData: SecureBytes? = nil
        if let dataToReencrypt = dataToReencrypt {
            do {
                // First decrypt with old key
                let iv = CryptoWrapper.generateRandomIVSecure()
                let decryptedData = try CryptoWrapper.decryptAES_GCM(data: dataToReencrypt, key: oldKey, iv: iv)
                
                // Then encrypt with new key
                let newIv = CryptoWrapper.generateRandomIVSecure()
                let encryptedData = try CryptoWrapper.encryptAES_GCM(data: decryptedData, key: newKey, iv: newIv)
                
                // Combine IV with encrypted data
                reencryptedData = try SecureBytes.combine(newIv, encryptedData)
            } catch {
                return .failure(.storageOperationFailed(reason: "Failed to re-encrypt data: \(error.localizedDescription)"))
            }
        }
        
        // Store the new key
        keyStore[identifier] = newKey
        
        return .success((newKey: newKey, reencryptedData: reencryptedData))
    }
    
    public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
        return .success(Array(keyStore.keys))
    }
}

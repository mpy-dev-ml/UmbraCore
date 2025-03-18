import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// A mock implementation of CryptoServiceProtocol for testing
/// Replaces the deprecated DummyCryptoService
@available(macOS 14.0, *)
public final class MockCryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
    public init() {}

    public func encryptSymmetric(data: SecureBytes, key: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Simple mock implementation to XOR data with key
        var bytes = [UInt8]()
        
        // Extract key bytes
        var keyBytes = [UInt8]()
        do {
            for i in 0..<key.count {
                keyBytes.append(try key.byte(at: i))
            }
        } catch {
            return .failure(.encryptionFailed("Error accessing key bytes"))
        }
        
        // XOR data with key
        for i in 0..<data.count {
            do {
                let keyByte = keyBytes[i % keyBytes.count]
                bytes.append(try data.byte(at: i) ^ keyByte)
            } catch {
                return .failure(.encryptionFailed("Error accessing data bytes"))
            }
        }
        
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSymmetric(data: SecureBytes, key: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // For XOR, encryption and decryption are the same operation
        var bytes = [UInt8]()
        
        // Extract key bytes
        var keyBytes = [UInt8]()
        do {
            for i in 0..<key.count {
                keyBytes.append(try key.byte(at: i))
            }
        } catch {
            return .failure(.decryptionFailed("Error accessing key bytes"))
        }
        
        // XOR data with key
        for i in 0..<data.count {
            do {
                let keyByte = keyBytes[i % keyBytes.count]
                bytes.append(try data.byte(at: i) ^ keyByte)
            } catch {
                return .failure(.decryptionFailed("Error accessing data bytes"))
            }
        }
        
        return .success(SecureBytes(bytes: bytes))
    }

    public func encryptAsymmetric(data: SecureBytes, publicKey: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Just return the data with some transformation for testing
        var bytes = [UInt8]()
        
        // Simple mock transformation - reverse the bytes
        for i in (0..<data.count).reversed() {
            do {
                bytes.append(try data.byte(at: i))
            } catch {
                return .failure(.encryptionFailed("Error accessing data bytes"))
            }
        }
        
        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptAsymmetric(data: SecureBytes, privateKey: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Reverse the bytes back
        var bytes = [UInt8]()
        
        for i in (0..<data.count).reversed() {
            do {
                bytes.append(try data.byte(at: i))
            } catch {
                return .failure(.decryptionFailed("Error accessing data bytes"))
            }
        }
        
        return .success(SecureBytes(bytes: bytes))
    }

    public func sign(data: SecureBytes, privateKey: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Generate a simple signature (for testing only)
        var signatureBytes = [UInt8](repeating: 0, count: 64)

        // Mix in some data from the original data
        for i in 0..<min(data.count, 32) {
            do {
                signatureBytes[i] = try data.byte(at: i)
            } catch {
                return .failure(.signingFailed("Error accessing data bytes"))
            }
        }
        
        // Add a simple signature pattern
        for i in 32..<64 {
            signatureBytes[i] = UInt8(i)
        }
        
        return .success(SecureBytes(bytes: signatureBytes))
    }

    public func verify(signature: SecureBytes, data: SecureBytes, publicKey: SecureBytes, config: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // For mock purposes, verify that the signature has our pattern
        var isValid = true
        
        if signature.count < 64 {
            return .failure(.verificationFailed("Signature too short"))
        }
        
        // Check the pattern in the last part of the signature
        for i in 32..<64 {
            do {
                if try signature.byte(at: i) != UInt8(i) {
                    isValid = false
                    break
                }
            } catch {
                return .failure(.verificationFailed("Error accessing signature bytes"))
            }
        }
        
        return .success(isValid)
    }
}

/// A mock implementation of KeyManagementProtocol for testing
/// Replaces the deprecated DummyKeyManager
@available(macOS 14.0, *)
public final class MockKeyManager: SecurityProtocolsCore.KeyManagementProtocol {
    // Thread-safe access to keys using an actor for Sendable conformance
    private actor KeyStorage {
        var keys: [String: SecureBytes] = [:]
        
        func storeKey(_ key: SecureBytes, withIdentifier identifier: String) {
            keys[identifier] = key
        }
        
        func retrieveKey(withIdentifier identifier: String) -> SecureBytes? {
            keys[identifier]
        }
        
        func deleteKey(withIdentifier identifier: String) {
            keys.removeValue(forKey: identifier)
        }
        
        func hasKey(forIdentifier identifier: String) -> Bool {
            keys[identifier] != nil
        }
        
        func getAllKeyIdentifiers() -> [String] {
            Array(keys.keys)
        }
    }
    
    private let storage = KeyStorage()
    
    public init() {}
    
    public func generateKey(
        type: SecurityProtocolsCore.KeyType,
        metadata: SecurityProtocolsCore.KeyMetadata
    ) async -> Result<(key: SecureBytes, identifier: String), UmbraErrors.Security.Protocols> {
        // Generate a mock key for testing
        let keyLength = type == .symmetric ? 32 : 64
        var keyBytes = [UInt8](repeating: 0, count: keyLength)
        for i in 0..<keyLength {
            keyBytes[i] = UInt8.random(in: 0...255)
        }
        
        let key = SecureBytes(bytes: keyBytes)
        let identifier = "key-\(UUID().uuidString)"
        
        // Store the key
        await storage.storeKey(key, withIdentifier: identifier)
        
        return .success((key: key, identifier: identifier))
    }
    
    public func storeKey(
        _ key: SecureBytes,
        identifier: String?,
        metadata: SecurityProtocolsCore.KeyMetadata
    ) async -> Result<String, UmbraErrors.Security.Protocols> {
        let actualIdentifier = identifier ?? "key-\(UUID().uuidString)"
        
        // Store the key
        await storage.storeKey(key, withIdentifier: actualIdentifier)
        
        return .success(actualIdentifier)
    }
    
    public func retrieveKey(
        identifier: String
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        if let key = await storage.retrieveKey(withIdentifier: identifier) {
            return .success(key)
        } else {
            return .failure(.keyManagementFailed("No key found with identifier: \(identifier)"))
        }
    }
    
    public func deleteKey(
        identifier: String
    ) async -> Result<Void, UmbraErrors.Security.Protocols> {
        await storage.deleteKey(withIdentifier: identifier)
        return .success(())
    }
    
    public func rotateKey(
        identifier: String,
        data: SecureBytes?
    ) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), UmbraErrors.Security.Protocols> {
        // First check if we have the original key
        guard await storage.hasKey(forIdentifier: identifier) else {
            return .failure(.storageOperationFailed("Cannot rotate nonexistent key with identifier: \(identifier)"))
        }
        
        // Generate a new key (same length as original)
        let originalKey = await storage.retrieveKey(withIdentifier: identifier)!
        var newKeyBytes = [UInt8](repeating: 0, count: originalKey.count)
        for i in 0..<originalKey.count {
            newKeyBytes[i] = UInt8.random(in: 0...255)
        }
        
        let newKey = SecureBytes(bytes: newKeyBytes)
        
        // Store the new key with the same identifier (replacing old one)
        await storage.storeKey(newKey, withIdentifier: identifier)
        
        // Re-encrypt data if provided
        var reencryptedData: SecureBytes? = nil
        if let data = data {
            // For this mock implementation, we'll just XOR the data with both old and new keys
            var bytes = [UInt8]()
            
            // Decrypt with old key (XOR)
            for i in 0..<data.count {
                do {
                    let dataByte = try data.byte(at: i)
                    let keyByte = try originalKey.byte(at: i % originalKey.count)
                    bytes.append(dataByte ^ keyByte)
                } catch {
                    return .failure(.encryptionFailed("Error during re-encryption"))
                }
            }
            
            // Encrypt with new key (XOR)
            for i in 0..<bytes.count {
                do {
                    let keyByte = try newKey.byte(at: i % newKey.count)
                    bytes[i] = bytes[i] ^ keyByte
                } catch {
                    return .failure(.encryptionFailed("Error during re-encryption"))
                }
            }
            
            reencryptedData = SecureBytes(bytes: bytes)
        }
        
        return .success((newKey: newKey, reencryptedData: reencryptedData))
    }
}

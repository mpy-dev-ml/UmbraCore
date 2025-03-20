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

    // Required protocol methods
    public func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Simple mock implementation to XOR data with key
        var bytes = [UInt8]()

        // Extract key bytes
        var keyBytes = [UInt8]()
        do {
            // DEPRECATED: for i in 0 ..< key.count {
                try keyBytes.append(key.byte(at: i))
            }
        } catch {
            return .failure(.encryptionFailed("Error accessing key bytes"))
        }

        // XOR data with key
        // DEPRECATED: for i in 0 ..< data.count {
            do {
                let keyByte = keyBytes[i % keyBytes.count]
                try bytes.append(data.byte(at: i) ^ keyByte)
            } catch {
                return .failure(.encryptionFailed("Error accessing data bytes"))
            }
        }

        return .success(SecureBytes(bytes: bytes))
    }

    public func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // For XOR, encryption and decryption are the same operation
        await encrypt(data: data, using: key)
    }

    public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Generate a random key
        var keyBytes = [UInt8](repeating: 0, count: 32)
        // DEPRECATED: for i in 0 ..< keyBytes.count {
            keyBytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(SecureBytes(bytes: keyBytes))
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Very simple "hash" for example purposes - NOT a real hash
        var hash = [UInt8](repeating: 0, count: 32)

        do {
            // DEPRECATED: for i in 0 ..< data.count {
                let byte = try data.byte(at: i)
                hash[i % 32] ^= byte
            }

            // Add some minimal avalanche effect
            // DEPRECATED: for i in 0 ..< hash.count - 1 {
                hash[i + 1] ^= hash[i]
            }

            return .success(SecureBytes(bytes: hash))
        } catch {
            return .failure(.internalError("Error accessing data bytes during hashing"))
        }
    }

    public func hash(data: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Use the same implementation as the simpler hash method
        await hash(data: data)
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Generate random data
        var randomBytes = [UInt8](repeating: 0, count: length)
        // DEPRECATED: for i in 0 ..< length {
            randomBytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(SecureBytes(bytes: randomBytes))
    }

    public func verify(data: SecureBytes, against hash: SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // Compute the hash of the data
        let hashResult = await self.hash(data: data)

        // Compare with the provided hash
        switch hashResult {
        case let .success(computedHash):
            // Compare the hashes
            if computedHash.count != hash.count {
                return .success(false)
            }

            do {
                // DEPRECATED: for i in 0 ..< computedHash.count {
                    if try computedHash.byte(at: i) != hash.byte(at: i) {
                        return .success(false)
                    }
                }
                return .success(true)
            } catch {
                return .failure(.invalidInput("Error comparing hash bytes"))
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    // Additional convenience methods
    public func encryptSymmetric(data: SecureBytes, key: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Simple mock implementation to XOR data with key
        var bytes = [UInt8]()

        // Extract key bytes
        var keyBytes = [UInt8]()
        do {
            // DEPRECATED: for i in 0 ..< key.count {
                try keyBytes.append(key.byte(at: i))
            }
        } catch {
            return .failure(.encryptionFailed("Error accessing key bytes"))
        }

        // XOR data with key
        // DEPRECATED: for i in 0 ..< data.count {
            do {
                let keyByte = keyBytes[i % keyBytes.count]
                try bytes.append(data.byte(at: i) ^ keyByte)
            } catch {
                return .failure(.encryptionFailed("Error accessing data bytes"))
            }
        }

        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptSymmetric(data: SecureBytes, key: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // For XOR, encryption and decryption are the same operation
        var bytes = [UInt8]()

        // Extract key bytes
        var keyBytes = [UInt8]()
        do {
            // DEPRECATED: for i in 0 ..< key.count {
                try keyBytes.append(key.byte(at: i))
            }
        } catch {
            return .failure(.decryptionFailed("Error accessing key bytes"))
        }

        // XOR data with key
        // DEPRECATED: for i in 0 ..< data.count {
            do {
                let keyByte = keyBytes[i % keyBytes.count]
                try bytes.append(data.byte(at: i) ^ keyByte)
            } catch {
                return .failure(.decryptionFailed("Error accessing data bytes"))
            }
        }

        return .success(SecureBytes(bytes: bytes))
    }

    public func encryptAsymmetric(data: SecureBytes, publicKey _: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Just return the data with some transformation for testing
        var bytes = [UInt8]()

        // Simple mock transformation - reverse the bytes
        // DEPRECATED: for i in (0 ..< data.count).reversed() {
            do {
                try bytes.append(data.byte(at: i))
            } catch {
                return .failure(.encryptionFailed("Error accessing data bytes"))
            }
        }

        return .success(SecureBytes(bytes: bytes))
    }

    public func decryptAsymmetric(data: SecureBytes, privateKey _: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Reverse the bytes back
        var bytes = [UInt8]()

        // DEPRECATED: for i in (0 ..< data.count).reversed() {
            do {
                try bytes.append(data.byte(at: i))
            } catch {
                return .failure(.decryptionFailed("Error accessing data bytes"))
            }
        }

        return .success(SecureBytes(bytes: bytes))
    }

    public func sign(data: SecureBytes, privateKey _: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Generate a simple signature (for testing only)
        var signatureBytes = [UInt8](repeating: 0, count: 64)

        // Mix in some data from the original data
        // DEPRECATED: for i in 0 ..< min(data.count, 32) {
            do {
                signatureBytes[i] = try data.byte(at: i)
            } catch {
                return .failure(.internalError("Error accessing data bytes during signing"))
            }
        }

        // Add a simple signature pattern
        // DEPRECATED: for i in 32 ..< 64 {
            signatureBytes[i] = UInt8(i)
        }

        return .success(SecureBytes(bytes: signatureBytes))
    }

    public func verify(signature: SecureBytes, data _: SecureBytes, publicKey _: SecureBytes, config _: SecurityProtocolsCore.SecurityConfigDTO) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // For mock purposes, verify that the signature has our pattern
        var isValid = true

        if signature.count < 64 {
            return .failure(.invalidInput("Signature too short"))
        }

        // Check the pattern in the last part of the signature
        // DEPRECATED: for i in 32 ..< 64 {
            do {
                if try signature.byte(at: i) != UInt8(i) {
                    isValid = false
                    break
                }
            } catch {
                return .failure(.invalidInput("Error accessing signature bytes"))
            }
        }

        return .success(isValid)
    }
}

/// Mock implementation of KeyManagementProtocol for testing
@available(macOS 14.0, *)
public final class MockKeyManager: @unchecked Sendable, SecurityProtocolsCore.KeyManagementProtocol {
    private var keyStore: [String: SecureBytes] = [:]

    public init() {}

    public func retrieveKey(withIdentifier identifier: String) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        if let key = keyStore[identifier] {
            .success(key)
        } else {
            .failure(.storageOperationFailed("Key not found with identifier: \(identifier)"))
        }
    }

    public func storeKey(_ key: SecureBytes, withIdentifier identifier: String) async -> Result<Void, UmbraErrors.Security.Protocols> {
        keyStore[identifier] = key
        return .success(())
    }

    public func deleteKey(withIdentifier identifier: String) async -> Result<Void, UmbraErrors.Security.Protocols> {
        if keyStore.removeValue(forKey: identifier) != nil {
            .success(())
        } else {
            .failure(.storageOperationFailed("Key not found with identifier: \(identifier)"))
        }
    }

    public func rotateKey(withIdentifier identifier: String, dataToReencrypt: SecureBytes?) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), UmbraErrors.Security.Protocols> {
        // Check if the key exists
        if keyStore[identifier] == nil {
            return .failure(.storageOperationFailed("Key not found with identifier: \(identifier)"))
        }

        // Generate a new key
        var keyBytes = [UInt8](repeating: 0, count: 32)
        // DEPRECATED: for i in 0 ..< keyBytes.count {
            keyBytes[i] = UInt8.random(in: 0 ... 255)
        }
        let newKey = SecureBytes(bytes: keyBytes)

        // Store the new key
        keyStore[identifier] = newKey

        // Re-encrypt data if provided
        if let dataToReencrypt {
            var reencryptedBytes = [UInt8]()

            do {
                // Extract bytes from data
                var dataBytes = [UInt8]()
                // DEPRECATED: for i in 0 ..< dataToReencrypt.count {
                    try dataBytes.append(dataToReencrypt.byte(at: i))
                }

                // Simple XOR encryption with new key
                // DEPRECATED: for i in 0 ..< dataBytes.count {
                    reencryptedBytes.append(dataBytes[i] ^ keyBytes[i % keyBytes.count])
                }

                return .success((newKey: newKey, reencryptedData: SecureBytes(bytes: reencryptedBytes)))
            } catch {
                // DEPRECATED: return .failure(.encryptionFailed("Error accessing data bytes for rotation"))
            }
        }

        return .success((newKey: newKey, reencryptedData: nil))
    }

    public func listKeyIdentifiers() async -> Result<[String], UmbraErrors.Security.Protocols> {
        .success(Array(keyStore.keys))
    }
}

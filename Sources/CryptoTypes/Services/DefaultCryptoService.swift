import Foundation
import CryptoKit
import CryptoTypes_Types
import CryptoTypes_Protocols

/// Default implementation of CryptoService using CryptoKit
public actor DefaultCryptoServiceImpl: CryptoService {
    public init() {}
    
    public func generateSecureRandomKey(length: Int) async throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            throw CryptoError.randomGenerationFailed(status: status)
        }
        return Data(bytes)
    }
    
    public func generateSecureRandomBytes(length: Int) async throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            throw CryptoError.randomGenerationFailed(status: status)
        }
        return Data(bytes)
    }
    
    public func encrypt(_ data: Data, withKey key: Data, iv: Data) async throws -> Data {
        guard key.count == 32 else {
            throw CryptoError.encryptionFailed(reason: "Invalid key length")
        }
        guard iv.count == 12 else {
            throw CryptoError.encryptionFailed(reason: "Invalid IV length")
        }
        
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)
            // Combine IV and ciphertext
            var combined = Data()
            combined.append(iv)
            combined.append(sealedBox.ciphertext)
            combined.append(sealedBox.tag)
            return combined
        } catch {
            throw CryptoError.encryptionFailed(reason: "encryption failed")
        }
    }
    
    public func decrypt(_ data: Data, withKey key: Data, iv: Data) async throws -> Data {
        guard key.count == 32 else {
            throw CryptoError.decryptionFailed(reason: "decryption failed")
        }
        guard iv.count == 12 else {
            throw CryptoError.decryptionFailed(reason: "decryption failed")
        }
        guard data.count >= 12 + 16 else { // At least IV (12) + tag (16)
            throw CryptoError.decryptionFailed(reason: "decryption failed")
        }
        
        let symmetricKey = SymmetricKey(data: key)
        
        do {
            // Extract components
            let storedIV = data.prefix(12)
            guard storedIV == iv else {
                throw CryptoError.decryptionFailed(reason: "decryption failed")
            }
            
            let ciphertext = data.dropFirst(12).dropLast(16)
            let tag = data.suffix(16)
            
            let sealedBox = try AES.GCM.SealedBox(
                nonce: AES.GCM.Nonce(data: iv),
                ciphertext: ciphertext,
                tag: tag
            )
            
            return try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            throw CryptoError.decryptionFailed(reason: "decryption failed")
        }
    }
}

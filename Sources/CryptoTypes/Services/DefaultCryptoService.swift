import Foundation
import CryptoKit

/// Default implementation of CryptoService using CryptoKit
actor DefaultCryptoService: CryptoService {
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
        let symmetricKey = SymmetricKey(data: key)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: AES.GCM.Nonce(data: iv))
            guard let combined = sealedBox.combined else {
                throw CryptoError.encryptionFailed(reason: "Failed to combine sealed box")
            }
            return combined
        } catch {
            throw CryptoError.encryptionFailed(reason: error.localizedDescription)
        }
    }
    
    public func decrypt(_ data: Data, withKey key: Data, iv: Data) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            throw CryptoError.decryptionFailed(reason: error.localizedDescription)
        }
    }
}

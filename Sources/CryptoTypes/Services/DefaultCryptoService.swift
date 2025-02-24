import CommonCrypto
import CryptoKit
import CryptoTypes_Protocols
import CryptoTypes_Types
import Foundation
import SecurityTypes

/// Default implementation of CryptoService
/// This implementation uses CryptoKit for cryptographic operations
/// Note: This implementation is specifically for the main app context and should not
/// be used directly in XPC services. For XPC cryptographic operations, use CryptoXPCService.
public actor DefaultCryptoServiceImpl: CryptoServiceProtocol {
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

    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        guard key.count == 32 else {
            throw CryptoError.encryptionFailed(reason: "Invalid key length")
        }
        guard iv.count == 12 else {
            throw CryptoError.encryptionFailed(reason: "Invalid IV length")
        }

        let symmetricKey = SymmetricKey(data: key)

        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: .init(data: iv))
            var combined = Data()
            combined.append(contentsOf: sealedBox.nonce.withUnsafeBytes { Data($0) })
            combined.append(contentsOf: sealedBox.ciphertext)
            combined.append(contentsOf: sealedBox.tag)
            return combined
        } catch {
            throw CryptoError.encryptionFailed(reason: "encryption failed")
        }
    }

    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
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
            let storedIV = data.prefix(12)
            guard storedIV == iv else {
                throw CryptoError.decryptionFailed(reason: "decryption failed")
            }

            let ciphertext = data.dropFirst(12).dropLast(16)
            let tag = data.suffix(16)

            let sealedBox = try AES.GCM.SealedBox(
                nonce: .init(data: iv),
                ciphertext: ciphertext,
                tag: tag
            )

            return try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            throw CryptoError.decryptionFailed(reason: "decryption failed")
        }
    }

    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        guard let passwordData = password.data(using: .utf8) else {
            throw CryptoError.encryptionFailed(reason: "Invalid password encoding")
        }

        let keyLength = 32 // 256 bits
        var derivedKeyData = Data(count: keyLength)

        let result = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes -> Int32 in
            passwordData.withUnsafeBytes { passwordBytes -> Int32 in
                salt.withUnsafeBytes { saltBytes -> Int32 in
                    let algorithm = CCPBKDFAlgorithm(kCCPBKDF2)
                    let prf = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)

                    return CCKeyDerivationPBKDF(
                        algorithm,
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passwordBytes.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        saltBytes.count,
                        prf,
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        derivedKeyBytes.count
                    )
                }
            }
        }

        guard result == kCCSuccess else {
            throw CryptoError.encryptionFailed(reason: "Key derivation failed")
        }

        return derivedKeyData
    }

    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey)
        return Data(hmac)
    }
}

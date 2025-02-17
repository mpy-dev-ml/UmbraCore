import CryptoSwift
import Foundation
import SecurityTypes

/// A service providing cryptographic operations using CryptoSwift
public final class CryptoService: CryptoServiceProtocol {
    private let config: CryptoConfiguration

    public init(config: CryptoConfiguration = .default) {
        self.config = config
    }

    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        guard key.count == config.keyLength / 8 else {
            throw CryptoError.invalidKeyLength(
                expected: config.keyLength / 8,
                got: key.count
            )
        }

        guard iv.count == config.ivLength else {
            throw CryptoError.invalidIVLength(
                expected: config.ivLength,
                got: iv.count
            )
        }

        let aes = try AES(key: key.bytes, blockMode: GCM(iv: iv.bytes, mode: .combined))
        let encrypted = try aes.encrypt(data.bytes)
        return Data(encrypted)
    }

    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        guard key.count == config.keyLength / 8 else {
            throw CryptoError.invalidKeyLength(
                expected: config.keyLength / 8,
                got: key.count
            )
        }

        guard iv.count == config.ivLength else {
            throw CryptoError.invalidIVLength(
                expected: config.ivLength,
                got: iv.count
            )
        }

        let aes = try AES(key: key.bytes, blockMode: GCM(iv: iv.bytes, mode: .combined))
        let decrypted = try aes.decrypt(data.bytes)
        return Data(decrypted)
    }

    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        guard iterations >= config.minimumPBKDF2Iterations else {
            throw CryptoError.invalidIterationCount(
                expected: config.minimumPBKDF2Iterations,
                got: iterations
            )
        }

        let keyLength = config.keyLength / 8
        let derivedKey = try PKCS5.PBKDF2(
            password: Array(password.utf8),
            salt: salt.bytes,
            iterations: iterations,
            keyLength: keyLength,
            variant: .sha2(.sha256)
        ).calculate()

        return Data(derivedKey)
    }

    public func generateSecureRandomKey(length: Int) async throws -> Data {
        guard length > 0 else {
            throw CryptoError.invalidKeyLength(
                expected: 1,
                got: length
            )
        }

        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)

        guard status == errSecSuccess else {
            throw CryptoError.randomGenerationFailed(reason: "SecRandomCopyBytes failed with status \(status)")
        }

        return Data(bytes)
    }

    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        let hmac = HMAC(key: key.bytes, variant: .sha2(.sha256))
        let result = try hmac.authenticate(data.bytes)
        return Data(result)
    }
}

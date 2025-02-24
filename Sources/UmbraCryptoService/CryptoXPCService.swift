import Core
import CryptoSwift
import CryptoTypes
import CryptoTypes_Services
import Foundation
import UmbraXPC

/// Extension to generate random data using SecRandomCopyBytes
extension Data {
    static func random(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }
}

/// XPC service for cryptographic operations
///
/// This service uses CryptoSwift to provide platform-independent cryptographic
/// operations across process boundaries. It is specifically designed for:
/// - Cross-process encryption/decryption via XPC
/// - Platform-independent cryptographic operations
/// - Flexible implementation for XPC service requirements
///
/// Note: This implementation uses CryptoSwift instead of CryptoKit to ensure
/// reliable cross-process operations. For main app cryptographic operations,
/// use DefaultCryptoService which provides hardware-backed security.
@available(macOS 14.0, *)
@MainActor
public final class CryptoXPCService: NSObject, Core.CryptoXPCServiceProtocol {
    private let cryptoQueue = DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)

    public override init() {
        super.init()
    }

    // MARK: - XPCServiceProtocol

    public func validateConnection() async throws {
        // Basic validation - could be extended with more checks
        return
    }

    public func getServiceVersion() async throws -> String {
        return "1.0.0"
    }

    // MARK: - CryptoXPCServiceProtocol

    public func encrypt(_ data: Data, key: Data) async throws -> Data {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            cryptoQueue.async {
                do {
                    let result = try self.encryptData(data, key: key)
                    continuation.resume(returning: result)
                } catch {
                    let xpcError = XPCError.serviceError(
                        category: .crypto,
                        underlying: error,
                        message: "Encryption failed"
                    )
                    continuation.resume(throwing: xpcError)
                }
            }
        }
    }

    public func decrypt(_ data: Data, key: Data) async throws -> Data {
        try Task.checkCancellation()
        guard data.count > 28 else {
            throw XPCError.invalidRequest(message: "Data too short for decryption")
        }

        return try await withCheckedThrowingContinuation { continuation in
            cryptoQueue.async {
                do {
                    let decrypted = try self.decryptData(data, key: key)
                    continuation.resume(returning: decrypted)
                } catch {
                    let xpcError = XPCError.serviceError(
                        category: .crypto,
                        underlying: error,
                        message: "Decryption failed"
                    )
                    continuation.resume(throwing: xpcError)
                }
            }
        }
    }

    public func generateKey(bits: Int) async throws -> Data {
        try Task.checkCancellation()
        guard bits == 128 || bits == 256 else {
            throw XPCError.invalidRequest(message: "Key size must be 128 or 256 bits")
        }

        let bytes = bits / 8
        var key = [UInt8](repeating: 0, count: bytes)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes, &key)

        guard result == errSecSuccess else {
            let error = NSError(domain: "CryptoXPCService", code: Int(result))
            throw XPCError.serviceError(category: .crypto, underlying: error, message: "Failed to generate random key")
        }

        return Data(key)
    }

    public func generateSecureRandomKey(length: Int) async throws -> Data {
        try Task.checkCancellation()
        guard length > 0 else {
            throw XPCError.invalidRequest(message: "Key length must be greater than 0")
        }

        var salt = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, length, &salt)

        guard result == errSecSuccess else {
            let error = NSError(domain: "CryptoXPCService", code: Int(result))
            throw XPCError.serviceError(category: .crypto, underlying: error, message: "Failed to generate random salt")
        }

        return Data(salt)
    }

    public func generateInitializationVector() async throws -> Data {
        try Task.checkCancellation()
        return Data.random(count: 12)
    }

    public func storeCredential(_ credential: Data, identifier: String) async throws {
        try Task.checkCancellation()
        guard !identifier.isEmpty else {
            throw XPCError.invalidRequest(message: "Credential identifier cannot be empty")
        }
        let error = NSError(domain: "CryptoXPCService", code: -1)
        throw XPCError.serviceError(category: .credentials, underlying: error, message: "Credential storage not implemented")
    }

    public func retrieveCredential(identifier: String) async throws -> Data {
        try Task.checkCancellation()
        guard !identifier.isEmpty else {
            throw XPCError.invalidRequest(message: "Credential identifier cannot be empty")
        }
        let error = NSError(domain: "CryptoXPCService", code: -1)
        throw XPCError.serviceError(category: .credentials, underlying: error, message: "Credential retrieval not implemented")
    }

    public func deleteCredential(identifier: String) async throws {
        try Task.checkCancellation()
        guard !identifier.isEmpty else {
            throw XPCError.invalidRequest(message: "Credential identifier cannot be empty")
        }
        let error = NSError(domain: "CryptoXPCService", code: -1)
        throw XPCError.serviceError(category: .credentials, underlying: error, message: "Credential deletion not implemented")
    }

    private nonisolated func encryptData(_ data: Data, key: Data) throws -> Data {
        // Generate random IV
        let iv = Data.random(count: 12)

        // Create AES-GCM cipher
        let gcm = GCM(iv: iv.bytes, mode: .detached)
        let aes = try AES(key: key.bytes, blockMode: gcm)

        // Encrypt data
        let ciphertext = try aes.encrypt(data.bytes)

        // Get authentication tag
        let tag = gcm.authenticationTag ?? []

        // Combine IV + ciphertext + tag
        var result = Data()
        result.append(iv)
        result.append(Data(ciphertext))
        result.append(Data(tag))

        return result
    }

    private nonisolated func decryptData(_ data: Data, key: Data) throws -> Data {
        // Split data into IV, ciphertext, and tag
        let iv = data.prefix(12)
        let tag = data.suffix(16)
        let ciphertext = data.dropFirst(12).dropLast(16)

        // Create AES-GCM cipher
        let gcm = GCM(iv: iv.bytes, authenticationTag: tag.bytes, mode: .detached)
        let aes = try AES(key: key.bytes, blockMode: gcm)

        // Decrypt data
        let decrypted = try aes.decrypt(ciphertext.bytes)
        return Data(decrypted)
    }
}

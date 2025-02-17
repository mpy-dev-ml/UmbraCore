import Foundation
import UmbraXPC
import CryptoSwift
import Security

extension Data {
    static func random(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }
}

@available(macOS 14.0, *)
@MainActor
public final class CryptoXPCService: NSObject, CryptoXPCServiceProtocol {
    private let cryptoQueue = DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)
    
    public override init() {
        super.init()
    }
    
    public func encrypt(_ data: Data, key: Data) async throws -> Data {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            cryptoQueue.async {
                do {
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
                    
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: XPCError.serviceError(
                        category: XPCError.Category.crypto,
                        underlying: error,
                        message: "Encryption failed"
                    ))
                }
            }
        }
    }
    
    public func decrypt(_ data: Data, key: Data) async throws -> Data {
        try Task.checkCancellation()
        guard data.count > 28 else { // 12 (IV) + 16 (minimum tag size)
            throw XPCError.invalidRequest(message: "Invalid encrypted data format")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            cryptoQueue.async {
                do {
                    // Split data into IV, ciphertext, and tag
                    let iv = data.prefix(12)
                    let tag = data.suffix(16)
                    let ciphertext = data.dropFirst(12).dropLast(16)
                    
                    // Create AES-GCM cipher
                    let gcm = GCM(iv: iv.bytes, authenticationTag: tag.bytes, mode: .detached)
                    let aes = try AES(key: key.bytes, blockMode: gcm)
                    
                    // Decrypt data
                    let decrypted = try aes.decrypt(ciphertext.bytes)
                    continuation.resume(returning: Data(decrypted))
                } catch {
                    continuation.resume(throwing: XPCError.serviceError(
                        category: XPCError.Category.crypto,
                        underlying: error,
                        message: "Decryption failed"
                    ))
                }
            }
        }
    }
    
    public func generateKey(bits: Int) async throws -> Data {
        try Task.checkCancellation()
        guard bits == 128 || bits == 256 else {
            throw XPCError.invalidRequest(message: "Key size must be 128 or 256 bits")
        }
        
        return Data.random(count: bits / 8)
    }
    
    public func generateSecureRandomKey(length: Int) async throws -> Data {
        try Task.checkCancellation()
        guard length > 0 else {
            throw XPCError.invalidRequest(message: "Key length must be greater than 0")
        }
        
        return Data.random(count: length)
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
        
        guard credential.count > 0 else {
            throw XPCError.invalidRequest(message: "Credential data cannot be empty")
        }
        
        // TODO: Implement actual keychain storage
    }
    
    public func retrieveCredential(identifier: String) async throws -> Data {
        try Task.checkCancellation()
        guard !identifier.isEmpty else {
            throw XPCError.invalidRequest(message: "Credential identifier cannot be empty")
        }
        
        // TODO: Implement actual keychain retrieval
        throw XPCError.serviceError(
            category: XPCError.Category.credentials,
            underlying: NSError(domain: "CryptoXPCService", code: -1),
            message: "Credential retrieval not implemented"
        )
    }
    
    public func deleteCredential(identifier: String) async throws {
        try Task.checkCancellation()
        guard !identifier.isEmpty else {
            throw XPCError.invalidRequest(message: "Credential identifier cannot be empty")
        }
        
        // TODO: Implement actual keychain deletion
    }
}

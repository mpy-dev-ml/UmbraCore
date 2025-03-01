import CryptoSwift
import SecureBytes

/// A Foundation-independent wrapper for CryptoSwift functionality
/// This helps break circular dependencies between Foundation and CryptoSwift
public enum CryptoWrapper {
    
    // MARK: - AES-GCM Operations
    
    /// Encrypt data using AES-GCM
    /// - Parameters:
    ///   - data: Raw data to encrypt
    ///   - key: Encryption key
    ///   - iv: Initialization vector
    /// - Returns: Encrypted data
    public static func encryptAES_GCM(data: [UInt8], key: [UInt8], iv: [UInt8]) throws -> [UInt8] {
        let gcm = GCM(iv: iv, mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
        return try aes.encrypt(data)
    }
    
    /// Encrypt data using AES-GCM with SecureBytes
    /// - Parameters:
    ///   - data: SecureBytes data to encrypt
    ///   - key: SecureBytes encryption key
    ///   - iv: SecureBytes initialization vector
    /// - Returns: SecureBytes containing encrypted data
    public static func encryptAES_GCM(data: SecureBytes, key: SecureBytes, iv: SecureBytes) throws -> SecureBytes {
        let encryptedBytes = try data.withUnsafeBytes { dataBytes in
            try key.withUnsafeBytes { keyBytes in
                try iv.withUnsafeBytes { ivBytes in
                    try encryptAES_GCM(
                        data: [UInt8](dataBytes),
                        key: [UInt8](keyBytes),
                        iv: [UInt8](ivBytes)
                    )
                }
            }
        }
        return SecureBytes(bytes: encryptedBytes)
    }
    
    /// Decrypt data using AES-GCM
    /// - Parameters:
    ///   - data: Encrypted data
    ///   - key: Decryption key
    ///   - iv: Initialization vector
    /// - Returns: Decrypted data
    public static func decryptAES_GCM(data: [UInt8], key: [UInt8], iv: [UInt8]) throws -> [UInt8] {
        let gcm = GCM(iv: iv, mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
        return try aes.decrypt(data)
    }
    
    /// Decrypt data using AES-GCM with SecureBytes
    /// - Parameters:
    ///   - data: SecureBytes encrypted data
    ///   - key: SecureBytes decryption key
    ///   - iv: SecureBytes initialization vector
    /// - Returns: SecureBytes containing decrypted data
    public static func decryptAES_GCM(data: SecureBytes, key: SecureBytes, iv: SecureBytes) throws -> SecureBytes {
        let decryptedBytes = try data.withUnsafeBytes { dataBytes in
            try key.withUnsafeBytes { keyBytes in
                try iv.withUnsafeBytes { ivBytes in
                    try decryptAES_GCM(
                        data: [UInt8](dataBytes),
                        key: [UInt8](keyBytes),
                        iv: [UInt8](ivBytes)
                    )
                }
            }
        }
        return SecureBytes(bytes: decryptedBytes)
    }
    
    // MARK: - Random Generation
    
    /// Generate a random initialization vector
    /// - Parameter size: Size of the IV in bytes
    /// - Returns: Random IV bytes
    public static func generateRandomIV(size: Int = 12) -> [UInt8] {
        // Use CryptoSwift's random method to generate IV
        return (0..<size).map { _ in UInt8.random(in: 0...255) }
    }
    
    /// Generate a random initialization vector as SecureBytes
    /// - Parameter size: Size of the IV in bytes
    /// - Returns: SecureBytes containing random IV
    public static func generateRandomIVSecure(size: Int = 12) -> SecureBytes {
        return SecureBytes(bytes: generateRandomIV(size: size))
    }
    
    /// Generate a random key
    /// - Parameter size: Size of the key in bytes (16, 24, or 32 for AES-128, AES-192, or AES-256)
    /// - Returns: Random key bytes
    public static func generateRandomKey(size: Int = 32) -> [UInt8] {
        // Use CryptoSwift's random method to generate key
        return (0..<size).map { _ in UInt8.random(in: 0...255) }
    }
    
    /// Generate a random key as SecureBytes
    /// - Parameter size: Size of the key in bytes (16, 24, or 32 for AES-128, AES-192, or AES-256)
    /// - Returns: SecureBytes containing random key
    public static func generateRandomKeySecure(size: Int = 32) -> SecureBytes {
        return SecureBytes(bytes: generateRandomKey(size: size))
    }
    
    // MARK: - Hashing Operations
    
    /// Calculate SHA-256 hash
    /// - Parameter data: Input data
    /// - Returns: SHA-256 hash
    public static func sha256(_ data: [UInt8]) -> [UInt8] {
        return data.sha256()
    }
    
    /// Calculate SHA-256 hash with SecureBytes
    /// - Parameter data: SecureBytes input data
    /// - Returns: SecureBytes containing SHA-256 hash
    public static func sha256(_ data: SecureBytes) -> SecureBytes {
        let hashBytes = data.withUnsafeBytes { dataBytes in
            [UInt8](dataBytes).sha256()
        }
        return SecureBytes(bytes: hashBytes)
    }
    
    /// Calculate HMAC using SHA-256
    /// - Parameters:
    ///   - data: Input data
    ///   - key: HMAC key
    /// - Returns: HMAC result
    public static func hmacSHA256(data: [UInt8], key: [UInt8]) -> [UInt8] {
        return try! HMAC(key: key, variant: .sha256).authenticate(data)
    }
    
    /// Calculate HMAC using SHA-256 with SecureBytes
    /// - Parameters:
    ///   - data: SecureBytes input data
    ///   - key: SecureBytes HMAC key
    /// - Returns: SecureBytes containing HMAC result
    public static func hmacSHA256(data: SecureBytes, key: SecureBytes) -> SecureBytes {
        let hmacBytes = data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                try! HMAC(key: [UInt8](keyBytes), variant: .sha256).authenticate([UInt8](dataBytes))
            }
        }
        return SecureBytes(bytes: hmacBytes)
    }
}

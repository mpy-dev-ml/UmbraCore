import Foundation
import CryptoSwift

/// Configuration for cryptographic operations
public struct CryptoConfig {
    /// Key size in bits
    public let keySize: Int
    
    /// Initialization vector size in bits
    public let ivSize: Int
    
    /// Number of PBKDF2 iterations
    public let iterations: Int
    
    public init(keySize: Int = 256, ivSize: Int = 128, iterations: Int = 10000) {
        self.keySize = keySize
        self.ivSize = ivSize
        self.iterations = iterations
    }
}

/// Handles cryptographic operations
public actor CryptoService: UmbraService {
    public static let serviceIdentifier = "com.umbracore.crypto"
    
    private var _state: ServiceState = .uninitialized
    public nonisolated(unsafe) private(set) var state: ServiceState = .uninitialized
    
    private let config: CryptoConfig
    
    /// Initialize with the specified configuration
    /// - Parameter config: Cryptographic configuration
    public init(config: CryptoConfig = CryptoConfig()) {
        self.config = config
    }
    
    /// Initialize the service
    public func initialize() async throws {
        guard _state == .uninitialized else {
            throw ServiceError.configurationError("Service already initialized")
        }
        
        state = .initializing
        _state = .initializing
        
        // Validate configuration
        guard config.keySize > 0, config.ivSize > 0, config.iterations > 0 else {
            state = .error
            _state = .error
            throw ServiceError.configurationError("Invalid crypto configuration")
        }
        
        state = .ready
        _state = .ready
    }
    
    /// Gracefully shut down the service
    public func shutdown() async {
        if _state == .ready {
            state = .shuttingDown
            _state = .shuttingDown
            // Perform any cleanup if needed
            state = .uninitialized
            _state = .uninitialized
        }
    }
    
    /// Generate a random key of the configured size
    /// - Returns: Random bytes for use as a key
    /// - Throws: CryptoError if key generation fails
    public func generateKey() throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }
        
        return AES.randomIV(config.keySize / 8)
    }
    
    /// Generate a random initialization vector
    /// - Returns: Random bytes for use as an IV
    /// - Throws: CryptoError if IV generation fails
    public func generateIV() throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }
        
        return AES.randomIV(config.ivSize / 8)
    }
    
    /// Encrypt data using AES-GCM
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data with IV and tag
    /// - Throws: CryptoError on failure
    public func encrypt(_ data: [UInt8], using key: [UInt8]) throws -> (encrypted: [UInt8], iv: [UInt8], tag: [UInt8]) {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }
        
        let iv = try generateIV()
        let gcm = GCM(iv: iv, mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .pkcs7)
        
        let encrypted = try aes.encrypt(data)
        let tag = gcm.authenticationTag ?? []
        
        return (encrypted: encrypted, iv: iv, tag: tag)
    }
    
    /// Decrypt data using AES-GCM
    /// - Parameters:
    ///   - encrypted: Encrypted data
    ///   - iv: Initialization vector used for encryption
    ///   - tag: Authentication tag
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: CryptoError on failure
    public func decrypt(encrypted: [UInt8], iv: [UInt8], tag: [UInt8], using key: [UInt8]) throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }
        
        let gcm = GCM(iv: iv, authenticationTag: tag, mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .pkcs7)
        
        return try aes.decrypt(encrypted)
    }
    
    /// Derive a key from a password using PBKDF2
    /// - Parameters:
    ///   - password: Password to derive key from
    ///   - salt: Salt for key derivation
    /// - Returns: Derived key
    /// - Throws: CryptoError on failure
    public func deriveKey(from password: String, salt: [UInt8]) throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }
        
        return try PKCS5.PBKDF2(
            password: Array(password.utf8),
            salt: salt,
            iterations: config.iterations,
            keyLength: config.keySize / 8,
            variant: .sha2(.sha256)
        ).calculate()
    }
}

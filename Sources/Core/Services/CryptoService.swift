import CryptoSwift
import Foundation

/// Configuration options for cryptographic operations.
///
/// This struct defines the parameters used for key derivation, encryption,
/// and other cryptographic operations. Default values are chosen to provide
/// a good balance of security and performance.
public struct CryptoConfig {
    /// The size of cryptographic keys in bits.
    ///
    /// Common values are 128, 192, or 256 bits.
    public let keySize: Int

    /// The size of initialization vectors in bits.
    ///
    /// For most block ciphers, this should be equal to the block size.
    public let ivSize: Int

    /// The number of iterations for key derivation.
    ///
    /// Higher values increase security but also increase processing time.
    public let iterations: Int

    /// Creates a new crypto configuration.
    ///
    /// - Parameters:
    ///   - keySize: Key size in bits. Defaults to 256.
    ///   - ivSize: IV size in bits. Defaults to 128.
    ///   - iterations: PBKDF2 iterations. Defaults to 10,000.
    public init(
        keySize: Int = 256,
        ivSize: Int = 128,
        iterations: Int = 10_000
    ) {
        self.keySize = keySize
        self.ivSize = ivSize
        self.iterations = iterations
    }
}

/// The result of an encryption operation.
///
/// Contains the encrypted data, initialization vector, and authentication tag.
public struct EncryptionResult: Sendable {
    /// The encrypted data
    public let encrypted: [UInt8]

    /// The initialization vector used for encryption
    public let initializationVector: [UInt8]

    /// The authentication tag for verifying data integrity
    public let tag: [UInt8]
}

/// A service that provides cryptographic operations.
///
/// `CryptoService` handles encryption, decryption, and key derivation operations
/// in a thread-safe manner. It uses industry-standard algorithms and practices
/// to ensure data security.
///
/// Example:
/// ```swift
/// let service = CryptoService()
/// try await service.initialize()
/// let encrypted = try await service.encrypt(data: myData, key: myKey)
/// ```
public actor CryptoService: UmbraService {
    /// The unique identifier for this service.
    public static let serviceIdentifier = "com.umbracore.crypto"

    /// The internal state of the service.
    private var _state: ServiceState = .uninitialized

    /// The current state of the service, accessible from any context.
    public nonisolated(unsafe) private(set) var state: ServiceState = .uninitialized

    /// The configuration for cryptographic operations.
    private let config: CryptoConfig

    /// Creates a new crypto service with the specified configuration.
    ///
    /// - Parameter config: The configuration to use for cryptographic operations.
    ///                    Defaults to standard secure parameters.
    public init(config: CryptoConfig = CryptoConfig()) {
        self.config = config
    }

    /// Initializes the service and validates its configuration.
    ///
    /// - Throws: `ServiceError.configurationError` if the service is already
    ///           initialized or if the configuration is invalid.
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

    /// Gracefully shuts down the service.
    ///
    /// - Throws: No errors are thrown by this method.
    public func shutdown() async {
        if _state == .ready {
            state = .shuttingDown
            _state = .shuttingDown
            // Perform any cleanup if needed
            state = .uninitialized
            _state = .uninitialized
        }
    }

    /// Generates a random key of the configured size.
    ///
    /// - Returns: Random bytes for use as a key.
    /// - Throws: `CryptoError` if key generation fails.
    public func generateKey() throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }

        return AES.randomIV(config.keySize / 8)
    }

    /// Generates a random initialization vector.
    ///
    /// - Returns: Random bytes for use as an IV.
    /// - Throws: `CryptoError` if IV generation fails.
    public func generateIV() throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }

        return AES.randomIV(config.ivSize / 8)
    }

    /// Encrypts data using AES-GCM.
    ///
    /// - Parameters:
    ///   - data: Data to encrypt.
    ///   - key: Encryption key.
    /// - Returns: Encrypted data with IV and tag.
    /// - Throws: `CryptoError` on failure.
    public func encrypt(
        _ data: [UInt8],
        using key: [UInt8]
    ) throws -> EncryptionResult {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }

        let initializationVector = try generateIV()
        let gcm = GCM(iv: initializationVector, mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .pkcs7)

        let encrypted = try aes.encrypt(data)
        let tag = gcm.authenticationTag ?? []

        return EncryptionResult(encrypted: encrypted, initializationVector: initializationVector, tag: tag)
    }

    /// Decrypts data using AES-GCM.
    ///
    /// - Parameters:
    ///   - encryptedData: The encrypted data and associated cryptographic parameters.
    ///   - key: Decryption key.
    /// - Returns: Decrypted data.
    /// - Throws: `CryptoError` on failure.
    public func decrypt(
        _ encryptedData: EncryptionResult,
        using key: [UInt8]
    ) throws -> [UInt8] {
        guard _state == .ready else {
            throw ServiceError.invalidState("Service not ready")
        }

        let gcm = GCM(iv: encryptedData.initializationVector,
                      authenticationTag: encryptedData.tag,
                      additionalAuthenticatedData: nil,
                      mode: .combined)
        let aes = try AES(key: key, blockMode: gcm, padding: .pkcs7)
        return try aes.decrypt(encryptedData.encrypted)
    }

    /// Derives a key from a password using PBKDF2.
    ///
    /// - Parameters:
    ///   - password: Password to derive key from.
    ///   - salt: Salt for key derivation.
    /// - Returns: Derived key.
    /// - Throws: `CryptoError` on failure.
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

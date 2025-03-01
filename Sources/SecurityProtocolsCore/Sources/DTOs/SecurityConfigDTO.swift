// SecurityConfigDTO.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import SecureBytes

/// FoundationIndependent configuration for security operations.
/// This struct provides configuration options for various security operations
/// without using any Foundation types.
public struct SecurityConfigDTO: Sendable, Equatable {

    // MARK: - Configuration Properties

    /// The algorithm to use for the operation
    public let algorithm: String

    /// Key size in bits
    public let keySizeInBits: Int

    /// Initialization vector or nonce if required
    public let initializationVector: SecureBytes?

    /// Additional authenticated data for AEAD ciphers
    public let additionalAuthenticatedData: SecureBytes?

    /// Iteration count for key derivation functions
    public let iterations: Int?

    /// Options dictionary for algorithm-specific parameters
    public let options: [String: String]

    // MARK: - Initializers

    /// Full initializer with all configuration options
    /// - Parameters:
    ///   - algorithm: The algorithm identifier (e.g., "AES-GCM", "RSA", "PBKDF2")
    ///   - keySizeInBits: Key size in bits
    ///   - initializationVector: Optional initialization vector
    ///   - additionalAuthenticatedData: Optional AAD for AEAD ciphers
    ///   - iterations: Optional iteration count for KDFs
    ///   - options: Additional algorithm-specific options
    public init(
        algorithm: String,
        keySizeInBits: Int,
        initializationVector: SecureBytes? = nil,
        additionalAuthenticatedData: SecureBytes? = nil,
        iterations: Int? = nil,
        options: [String: String] = [:]
    ) {
        self.algorithm = algorithm
        self.keySizeInBits = keySizeInBits
        self.initializationVector = initializationVector
        self.additionalAuthenticatedData = additionalAuthenticatedData
        self.iterations = iterations
        self.options = options
    }

    // MARK: - Factory Methods

    /// Create a configuration for AES-GCM symmetric encryption
    /// - Parameters:
    ///   - keySizeInBits: Key size in bits (128, 192, or 256)
    ///   - iv: Optional initialization vector (if nil, one will be generated)
    ///   - aad: Optional additional authenticated data
    /// - Returns: Configuration for AES-GCM
    public static func aesGCM(
        keySizeInBits: Int = 256,
        iv: SecureBytes? = nil,
        aad: SecureBytes? = nil
    ) -> SecurityConfigDTO {
        SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: keySizeInBits,
            initializationVector: iv,
            additionalAuthenticatedData: aad
        )
    }

    /// Create a configuration for RSA asymmetric encryption
    /// - Parameter keySizeInBits: Key size in bits (2048, 3072, or 4096)
    /// - Returns: Configuration for RSA
    public static func rsa(keySizeInBits: Int = 2_048) -> SecurityConfigDTO {
        SecurityConfigDTO(
            algorithm: "RSA",
            keySizeInBits: keySizeInBits
        )
    }

    /// Create a configuration for PBKDF2 key derivation
    /// - Parameters:
    ///   - iterations: Number of iterations
    ///   - outputKeySizeInBits: Size of the derived key in bits
    /// - Returns: Configuration for PBKDF2
    public static func pbkdf2(
        iterations: Int = 10_000,
        outputKeySizeInBits: Int = 256
    ) -> SecurityConfigDTO {
        SecurityConfigDTO(
            algorithm: "PBKDF2",
            keySizeInBits: outputKeySizeInBits,
            iterations: iterations
        )
    }
}

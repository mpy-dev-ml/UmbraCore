/**
 # CryptoError

 Defines the error types specific to cryptographic operations.

 ## Responsibilities

 * Provide specific error types for cryptographic operations
 * Ensure consistent error handling across the cryptographic services
 */

import Foundation

/// Errors that can occur during cryptographic operations
public enum CryptoError: Error, Equatable {
    /// Error during encryption operation
    case encryptionError(String)

    /// Error during decryption operation
    case decryptionError(String)

    /// Error during hashing operation
    case hashingError(String)

    /// Error during key generation
    case keyGenerationError(String)

    /// Error during key derivation
    case keyDerivationError(String)

    /// Error due to invalid key size
    case invalidKeySize(Int)

    /// Error due to invalid data length
    case invalidLength(Int)

    /// Error due to unsupported algorithm
    case unsupportedAlgorithm(String)

    /// Error during asymmetric encryption
    case asymmetricEncryptionError(String)

    /// Error during asymmetric decryption
    case asymmetricDecryptionError(String)

    /// Error during random data generation
    case randomDataGenerationError(String)
}

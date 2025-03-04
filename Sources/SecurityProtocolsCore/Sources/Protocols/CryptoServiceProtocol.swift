// CryptoServiceProtocol.swift
// SecurityProtocolsCore
//
// Created on 28/02/2025.
//

import UmbraCoreTypes
/// Protocol defining cryptographic operations in a FoundationIndependent manner.
/// This protocol uses only primitive types and FoundationIndependent custom types.
public protocol CryptoServiceProtocol: Sendable {
    /// Encrypts binary data using the provided key.
    /// - Parameters:
    ///   - data: The data to encrypt as `SecureBytes`.
    ///   - key: The encryption key as `SecureBytes`.
    /// - Returns: The encrypted data as `SecureBytes` or an error.
    func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError>

    /// Decrypts binary data using the provided key.
    /// - Parameters:
    ///   - data: The encrypted data as `SecureBytes`.
    ///   - key: The decryption key as `SecureBytes`.
    /// - Returns: The decrypted data as `SecureBytes` or an error.
    func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError>

    /// Generates a secure cryptographic key suitable for encryption/decryption operations.
    /// - Returns: A new cryptographic key as `SecureBytes` or an error.
    func generateKey() async -> Result<SecureBytes, SecurityError>

    /// Hashes the provided data using a cryptographically strong algorithm.
    /// - Parameter data: The data to hash as `SecureBytes`.
    /// - Returns: The resulting hash as `SecureBytes` or an error.
    func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError>

    /// Verifies the integrity of data against a known hash.
    /// - Parameters:
    ///   - data: The data to verify as `SecureBytes`.
    ///   - hash: The expected hash value as `SecureBytes`.
    /// - Returns: Boolean indicating whether the hash matches.
    func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool

    // MARK: - Symmetric Encryption

    /// Encrypt data using a symmetric key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Symmetric key for encryption
    ///   - config: Configuration options
    /// - Returns: Result containing encrypted data or error
    func encryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO

    /// Decrypt data using a symmetric key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Symmetric key for decryption
    ///   - config: Configuration options
    /// - Returns: Result containing decrypted data or error
    func decryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO

    // MARK: - Asymmetric Encryption

    /// Encrypt data using an asymmetric public key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - publicKey: Public key for encryption
    ///   - config: Configuration options
    /// - Returns: Result containing encrypted data or error
    func encryptAsymmetric(
        data: SecureBytes,
        publicKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO

    /// Decrypt data using an asymmetric private key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - privateKey: Private key for decryption
    ///   - config: Configuration options
    /// - Returns: Result containing decrypted data or error
    func decryptAsymmetric(
        data: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO

    // MARK: - Hashing

    /// Generate a cryptographic hash of data
    /// - Parameters:
    ///   - data: Data to hash
    ///   - config: Configuration options including algorithm selection
    /// - Returns: Result containing hash or error
    func hash(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO

    // MARK: - Random Data Generation

    /// Generate cryptographically secure random data
    /// - Parameter length: The length of random data to generate in bytes
    /// - Returns: Result containing random data or error
    func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError>
}

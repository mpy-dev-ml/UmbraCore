// CryptoServiceAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import UmbraCoreTypes
import SecurityProtocolsCore

/// CryptoServiceAdapter provides a bridge between Foundation-based cryptographic implementations
/// and the Foundation-free CryptoServiceProtocol.
///
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent
/// CryptoServiceProtocol interface.
public final class CryptoServiceAdapter: CryptoServiceProtocol, Sendable {
    // MARK: - Properties

    /// The Foundation-dependent cryptographic implementation
    private let implementation: any FoundationCryptoServiceImpl

    // MARK: - Initialization

    /// Create a new CryptoServiceAdapter
    /// - Parameter implementation: The Foundation-dependent crypto implementation
    public init(implementation: any FoundationCryptoServiceImpl) {
        self.implementation = implementation
    }

    // MARK: - CryptoServiceProtocol Implementation

    public func encrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // Convert SecureBytes to Data for the Foundation implementation
        let dataToEncrypt = DataAdapter.data(from: data)
        let keyData = DataAdapter.data(from: key)

        // Call the implementation
        let result = await implementation.encrypt(data: dataToEncrypt, using: keyData)

        // Convert the result back to the protocol's types
        switch result {
        case .success(let encryptedData):
            return .success(DataAdapter.secureBytes(from: encryptedData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }

    public func decrypt(data: SecureBytes, using key: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // Convert SecureBytes to Data for the Foundation implementation
        let encryptedData = DataAdapter.data(from: data)
        let keyData = DataAdapter.data(from: key)

        // Call the implementation
        let result = await implementation.decrypt(data: encryptedData, using: keyData)

        // Convert the result back to the protocol's types
        switch result {
        case .success(let decryptedData):
            return .success(DataAdapter.secureBytes(from: decryptedData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }

    public func generateKey() async -> Result<SecureBytes, SecurityError> {
        let result = await implementation.generateKey()

        switch result {
        case .success(let keyData):
            return .success(DataAdapter.secureBytes(from: keyData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        let dataToHash = DataAdapter.data(from: data)
        let result = await implementation.hash(data: dataToHash)

        switch result {
        case .success(let hashData):
            return .success(DataAdapter.secureBytes(from: hashData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }

    public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
        let dataToVerify = DataAdapter.data(from: data)
        let hashData = DataAdapter.data(from: hash)

        return await implementation.verify(data: dataToVerify, against: hashData)
    }

    /// Generate cryptographically secure random data
    /// - Parameter length: Number of random bytes to generate
    /// - Returns: Result containing random data or error
    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
        // Call the implementation
        let result = await implementation.generateRandomData(length: length)

        // Convert the result back to the protocol's types
        switch result {
        case .success(let randomData):
            return .success(DataAdapter.secureBytes(from: randomData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }

    public func encryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert SecureBytes to Data for the Foundation implementation
        let dataToEncrypt = DataAdapter.data(from: data)
        let keyData = DataAdapter.data(from: key)

        // Convert config to Foundation types
        let ivData = config.initializationVector.map { DataAdapter.data(from: $0) }
        let aadData = config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

        // Call the implementation
        let result = await implementation.encryptSymmetric(
            data: dataToEncrypt,
            key: keyData,
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            iv: ivData,
            aad: aadData,
            options: config.options
        )

        // Process the result
        if result.success, let resultData = result.data {
            return SecurityResultDTO(data: DataAdapter.secureBytes(from: resultData))
        } else {
            return SecurityResultDTO(
                errorCode: result.errorCode ?? -1,
                errorMessage: result.errorMessage ?? "Unknown error during symmetric encryption"
            )
        }
    }

    public func decryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert SecureBytes to Data for the Foundation implementation
        let encryptedData = DataAdapter.data(from: data)
        let keyData = DataAdapter.data(from: key)

        // Convert config to Foundation types
        let ivData = config.initializationVector.map { DataAdapter.data(from: $0) }
        let aadData = config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

        // Call the implementation
        let result = await implementation.decryptSymmetric(
            data: encryptedData,
            key: keyData,
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            iv: ivData,
            aad: aadData,
            options: config.options
        )

        // Process the result
        if result.success, let resultData = result.data {
            return SecurityResultDTO(data: DataAdapter.secureBytes(from: resultData))
        } else {
            return SecurityResultDTO(
                errorCode: result.errorCode ?? -1,
                errorMessage: result.errorMessage ?? "Unknown error during symmetric decryption"
            )
        }
    }

    public func encryptAsymmetric(
        data: SecureBytes,
        publicKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert SecureBytes to Data for the Foundation implementation
        let dataToEncrypt = DataAdapter.data(from: data)
        let publicKeyData = DataAdapter.data(from: publicKey)

        // Call the implementation
        let result = await implementation.encryptAsymmetric(
            data: dataToEncrypt,
            publicKey: publicKeyData,
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            options: config.options
        )

        // Process the result
        if result.success, let resultData = result.data {
            return SecurityResultDTO(data: DataAdapter.secureBytes(from: resultData))
        } else {
            return SecurityResultDTO(
                errorCode: result.errorCode ?? -1,
                errorMessage: result.errorMessage ?? "Unknown error during asymmetric encryption"
            )
        }
    }

    public func decryptAsymmetric(
        data: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert SecureBytes to Data for the Foundation implementation
        let encryptedData = DataAdapter.data(from: data)
        let privateKeyData = DataAdapter.data(from: privateKey)

        // Call the implementation
        let result = await implementation.decryptAsymmetric(
            data: encryptedData,
            privateKey: privateKeyData,
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            options: config.options
        )

        // Process the result
        if result.success, let resultData = result.data {
            return SecurityResultDTO(data: DataAdapter.secureBytes(from: resultData))
        } else {
            return SecurityResultDTO(
                errorCode: result.errorCode ?? -1,
                errorMessage: result.errorMessage ?? "Unknown error during asymmetric decryption"
            )
        }
    }

    public func hash(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert SecureBytes to Data for the Foundation implementation
        let dataToHash = DataAdapter.data(from: data)

        // Call the implementation
        let result = await implementation.hash(
            data: dataToHash,
            algorithm: config.algorithm,
            options: config.options
        )

        // Process the result
        if result.success, let resultData = result.data {
            return SecurityResultDTO(data: DataAdapter.secureBytes(from: resultData))
        } else {
            return SecurityResultDTO(
                errorCode: result.errorCode ?? -1,
                errorMessage: result.errorMessage ?? "Unknown error during hashing"
            )
        }
    }

    // MARK: - Helper Methods

    /// Map Foundation-specific errors to SecurityError
    private func mapError(_ error: Error) -> SecurityError {
        // If the error is already a SecurityError, return it
        if let securityError = error as? SecurityError {
            return securityError
        }

        // Map Foundation-specific errors to SecurityError types
        // This would be expanded based on the specific error types used
        return SecurityError.internalError("Foundation crypto error: \(error.localizedDescription)")
    }
}

/// Protocol for Foundation-dependent cryptographic implementations
/// that can be adapted to the Foundation-free CryptoServiceProtocol
public protocol FoundationCryptoServiceImpl: Sendable, RandomDataGenerating {
    func encrypt(data: Data, using key: Data) async -> Result<Data, Error>
    func decrypt(data: Data, using key: Data) async -> Result<Data, Error>
    func generateKey() async -> Result<Data, Error>
    func hash(data: Data) async -> Result<Data, Error>
    func verify(data: Data, against hash: Data) async -> Bool

    /// Generate cryptographically secure random data
    /// - Parameter length: The length of random data to generate in bytes 
    /// - Returns: Result containing the random data or an error
    func generateRandomData(length: Int) async -> Result<Data, Error>

    // Symmetric encryption
    func encryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult

    // Symmetric decryption
    func decryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult

    // Asymmetric encryption
    func encryptAsymmetric(
        data: Data,
        publicKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult

    // Asymmetric decryption
    func decryptAsymmetric(
        data: Data,
        privateKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult

    // Hashing
    func hash(
        data: Data,
        algorithm: String,
        options: [String: String]
    ) async -> FoundationSecurityResult
}

/// Foundation-based security operation result
public struct FoundationSecurityResult: Sendable {
    public let success: Bool
    public let data: Data?
    public let errorCode: Int?
    public let errorMessage: String?

    public init(data: Data) {
        self.success = true
        self.data = data
        self.errorCode = nil
        self.errorMessage = nil
    }

    public init() {
        self.success = true
        self.data = nil
        self.errorCode = nil
        self.errorMessage = nil
    }

    public init(errorCode: Int, errorMessage: String) {
        self.success = false
        self.data = nil
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// SecureStorageProtocol.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import UmbraCoreTypes
/// Result type for key storage operations
public enum KeyStorageResult: Sendable {
    case success
    case failure(KeyStorageError)
}

/// Result type for key retrieval operations
public enum KeyRetrievalResult: Sendable {
    case success(SecureBytes)
    case failure(KeyStorageError)
}

/// Result type for key deletion operations
public enum KeyDeletionResult: Sendable {
    case success
    case failure(KeyStorageError)
}

/// Error type for secure storage operations
public enum KeyStorageError: Sendable {
    case keyNotFound
    case storageFailure
    case unknown
}

/// Protocol defining secure storage operations in a FoundationIndependent manner.
/// This protocol is used for securely storing cryptographic keys and sensitive data.
public protocol SecureStorageProtocol: Sendable {
    /// Stores data securely with the given identifier
    /// - Parameters:
    ///   - data: The data to store as SecureBytes
    ///   - identifier: A unique identifier for later retrieval
    /// - Returns: Result of the storage operation
    func storeSecurely(data: SecureBytes, identifier: String) async -> KeyStorageResult

    /// Retrieves data securely by its identifier
    /// - Parameter identifier: The unique identifier for the data
    /// - Returns: The retrieved data or an error
    func retrieveSecurely(identifier: String) async -> KeyRetrievalResult

    /// Deletes data securely by its identifier
    /// - Parameter identifier: The unique identifier for the data to delete
    /// - Returns: Result of the deletion operation
    func deleteSecurely(identifier: String) async -> KeyDeletionResult
}

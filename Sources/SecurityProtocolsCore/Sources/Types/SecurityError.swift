// SecurityError.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// Foundation-free error type for security operations.
/// Designed to be used throughout the security interface without
/// relying on Foundation-specific error types.
public enum SecurityError: Error, Sendable, Equatable {
    /// General encryption failure
    case encryptionFailed(reason: String)

    /// General decryption failure
    case decryptionFailed(reason: String)

    /// Key generation failed
    case keyGenerationFailed(reason: String)

    /// Provided key is invalid or in an incorrect format
    case invalidKey

    /// Hash verification failed
    case hashVerificationFailed

    /// Secure random number generation failed
    case randomGenerationFailed(reason: String)

    /// Input data is in an invalid format
    case invalidInput(reason: String)

    /// Secure storage operation failed
    case storageOperationFailed(reason: String)

    /// Security operation timed out
    case timeout

    /// General security service error
    case serviceError(code: Int, reason: String)

    /// Internal error within the security system
    case internalError(String)

    /// Operation not implemented
    case notImplemented
}

// MARK: - CustomStringConvertible Extension

extension SecurityError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        case .keyGenerationFailed(let reason):
            return "Key generation failed: \(reason)"
        case .invalidKey:
            return "Invalid key"
        case .hashVerificationFailed:
            return "Hash verification failed"
        case .randomGenerationFailed(let reason):
            return "Secure random number generation failed: \(reason)"
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        case .storageOperationFailed(let reason):
            return "Storage operation failed: \(reason)"
        case .timeout:
            return "Security operation timed out"
        case .serviceError(let code, let reason):
            return "Security service error (\(code)): \(reason)"
        case .internalError(let message):
            return "Internal security error: \(message)"
        case .notImplemented:
            return "Operation not implemented"
        }
    }
}

import Foundation

/// CryptoError error type
public enum CryptoError: Error, LocalizedError, Sendable {
    /// Invalid key length
    case invalidKeyLength(expected: Int, got: Int)
    /// Invalid initialization vector length
    case invalidIVLength(expected: Int, got: Int)
    /// Invalid salt length
    case invalidSaltLength(expected: Int, got: Int)
    /// Invalid iteration count
    case invalidIterationCount(expected: Int, got: Int)
    /// Failed to generate a cryptographic key
    case keyGenerationFailed
    /// Failed to generate an initialization vector
    case ivGenerationFailed
    /// General encryption error with reason
    case encryptionFailed(reason: String)
    /// General decryption error with reason
    case decryptionFailed(reason: String)
    /// Failed to generate an authentication tag
    case tagGenerationFailed
    /// Key derivation error with reason
    case keyDerivationFailed(reason: String)
    /// Authentication failed
    case authenticationFailed(reason: String)
    /// Random number generation failed
    case randomGenerationFailed(status: OSStatus)
    /// Key not found
    case keyNotFound(identifier: String)
    /// Key already exists
    case keyExists(identifier: String)
    /// Keychain operation failed
    case keychainError(status: OSStatus)
    /// Invalid key data
    case invalidKey(reason: String)
    /// Invalid key size
    case invalidKeySize(reason: String)
    /// Invalid key format
    case invalidKeyFormat(reason: String)
    /// Invalid credential identifier
    case invalidCredentialIdentifier(reason: String)

    /// Localized description of the error
    public var errorDescription: String? {
        switch self {
        case let .invalidKeyLength(expected, got):
            "Invalid key length: expected \(expected), got \(got)"
        case let .invalidIVLength(expected, got):
            "Invalid initialization vector length: expected \(expected), got \(got)"
        case let .invalidSaltLength(expected, got):
            "Invalid salt length: expected \(expected), got \(got)"
        case let .invalidIterationCount(expected, got):
            "Invalid iteration count: expected at least \(expected), got \(got)"
        case .keyGenerationFailed:
            "Failed to generate cryptographic key"
        case .ivGenerationFailed:
            "Failed to generate initialization vector"
        case let .encryptionFailed(reason):
            "Encryption failed: \(reason)"
        case let .decryptionFailed(reason):
            "Decryption failed: \(reason)"
        case .tagGenerationFailed:
            "Failed to generate authentication tag"
        case let .keyDerivationFailed(reason):
            "Key derivation failed: \(reason)"
        case let .authenticationFailed(reason):
            "Authentication failed: \(reason)"
        case let .randomGenerationFailed(status):
            "Random number generation failed: \(status)"
        case let .keyNotFound(identifier):
            "Key not found: \(identifier)"
        case let .keyExists(identifier):
            "Key already exists: \(identifier)"
        case let .keychainError(status):
            "Keychain operation failed with status: \(status)"
        case let .invalidKey(reason):
            "Invalid key: \(reason)"
        case let .invalidKeySize(reason):
            "Invalid key size: \(reason)"
        case let .invalidKeyFormat(reason):
            "Invalid key format: \(reason)"
        case let .invalidCredentialIdentifier(reason):
            "Invalid credential identifier: \(reason)"
        }
    }
}

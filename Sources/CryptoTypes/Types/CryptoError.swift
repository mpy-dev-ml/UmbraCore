import Foundation

/// Errors that can occur during cryptographic operations
@frozen public enum CryptoError: LocalizedError, Sendable {
    /// Invalid key length
    case invalidKeyLength(expected: Int, got: Int)
    /// Invalid initialization vector length
    case invalidIVLength(expected: Int, got: Int)
    /// Invalid salt length
    case invalidSaltLength(expected: Int, got: Int)
    /// Invalid iteration count
    case invalidIterationCount(expected: Int, got: Int)
    /// General encryption error
    case encryptionFailed(reason: String)
    /// General decryption error
    case decryptionFailed(reason: String)
    /// Key derivation error
    case keyDerivationFailed(reason: String)
    /// Authentication failed
    case authenticationFailed(reason: String)
    /// Random number generation failed
    case randomGenerationFailed(reason: String)
    /// Key not found
    case keyNotFound(identifier: String)
    /// Key already exists
    case keyExists(identifier: String)
    /// Keychain operation failed
    case keychainError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .invalidKeyLength(let expected, let got):
            return "Invalid key length: expected \(expected) bytes, got \(got) bytes"
        case .invalidIVLength(let expected, let got):
            return "Invalid IV length: expected \(expected) bytes, got \(got) bytes"
        case .invalidSaltLength(let expected, let got):
            return "Invalid salt length: expected \(expected) bytes, got \(got) bytes"
        case .invalidIterationCount(let expected, let got):
            return "Invalid iteration count: expected at least \(expected), got \(got)"
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        case .keyDerivationFailed(let reason):
            return "Key derivation failed: \(reason)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .randomGenerationFailed(let reason):
            return "Random number generation failed: \(reason)"
        case .keyNotFound(let identifier):
            return "Key not found: \(identifier)"
        case .keyExists(let identifier):
            return "Key already exists: \(identifier)"
        case .keychainError(let status):
            return "Keychain operation failed with status: \(status)"
        }
    }
}

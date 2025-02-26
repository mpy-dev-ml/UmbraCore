import Foundation

/// Errors that can occur during cryptographic operations
public enum CryptoError: LocalizedError, Sendable {
    /// Failed to generate a cryptographic key
    case keyGenerationFailed

    /// Failed to generate an initialization vector
    case ivGenerationFailed

    /// Failed to encrypt data
    case encryptionFailed

    /// Failed to decrypt data
    case decryptionFailed

    /// Failed to generate an authentication tag
    case tagGenerationFailed

    /// Failed to derive a key from a password
    case keyDerivationFailed

    /// Invalid key size
    case invalidKeySize

    /// Invalid initialization vector
    case invalidIV

    /// Invalid authentication tag
    case invalidAuthenticationTag

    /// Failed to generate random data
    case randomGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:
            return "Failed to generate cryptographic key"
        case .ivGenerationFailed:
            return "Failed to generate initialization vector"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .tagGenerationFailed:
            return "Failed to generate authentication tag"
        case .keyDerivationFailed:
            return "Failed to derive key from password"
        case .invalidKeySize:
            return "Invalid key size"
        case .invalidIV:
            return "Invalid initialization vector"
        case .invalidAuthenticationTag:
            return "Invalid authentication tag"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        }
    }
}

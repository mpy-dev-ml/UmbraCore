import Foundation

/// CryptoError error type
public enum CryptoError: Error {
    case keyGenerationFailed
    case ivGenerationFailed
    case encryptionFailed
    case decryptionFailed
    case tagGenerationFailed
}

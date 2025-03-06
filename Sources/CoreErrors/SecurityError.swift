import Foundation

/// SecurityError error type for XPC and security-related operations
public enum SecurityError: Error, Sendable, Equatable {
  /// Error creating or accessing bookmarks
  case bookmarkError
  /// Access error or permission denied
  case accessError
  /// General cryptographic error
  case cryptoError
  /// Bookmark creation failed
  case bookmarkCreationFailed
  /// Bookmark resolution failed
  case bookmarkResolutionFailed
  /// Encryption failed
  case encryptionFailed
  /// Decryption failed
  case decryptionFailed
  /// Key generation failed
  case keyGenerationFailed
  /// Invalid data format
  case invalidData
  /// Hashing operation failed
  case hashingFailed
  /// Service operation failed
  case serviceFailed
  /// Operation not implemented
  case notImplemented
  /// General error with message
  case general(String)
}

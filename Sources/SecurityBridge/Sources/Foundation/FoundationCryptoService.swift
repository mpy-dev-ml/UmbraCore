import Foundation
import SecurityProtocolsCore

/// Protocol for Foundation-based cryptographic services
public protocol FoundationCryptoService: Sendable {
  /// Encrypt data using the provided key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Result containing encrypted data or error
  func encrypt(data: Data, using key: Data) async -> Result<Data, Error>

  /// Decrypt data using the provided key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Result containing decrypted data or error
  func decrypt(data: Data, using key: Data) async -> Result<Data, Error>

  /// Generate a new cryptographic key
  /// - Returns: Result containing the generated key or error
  func generateKey() async -> Result<Data, Error>

  /// Generate cryptographic hash of data
  /// - Parameter data: Data to hash
  /// - Returns: Result containing the hash value or error
  func hash(data: Data) async -> Result<Data, Error>

  /// Verify that data matches a hash
  /// - Parameters:
  ///   - data: Original data
  ///   - hash: Hash to verify against
  /// - Returns: True if the hash matches, false otherwise
  func verify(data: Data, against hash: Data) async -> Bool

  /// Generate secure random data
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Result containing random data or error
  func generateRandomData(length: Int) async -> Result<Data, Error>

  /// Encrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - algorithm: Encryption algorithm
  ///   - keySizeInBits: Key size in bits
  ///   - iv: Initialization vector (optional)
  ///   - aad: Additional authenticated data (optional)
  ///   - options: Additional options for encryption
  /// - Returns: Result containing encrypted data
  func encryptSymmetric(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    options: [String: String]
  ) async -> FoundationCryptoResult

  /// Decrypt data using symmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - algorithm: Decryption algorithm
  ///   - keySizeInBits: Key size in bits
  ///   - iv: Initialization vector (optional)
  ///   - aad: Additional authenticated data (optional)
  ///   - options: Additional options for decryption
  /// - Returns: Result containing decrypted data
  func decryptSymmetric(
    data: Data,
    key: Data,
    algorithm: String,
    keySizeInBits: Int,
    iv: Data?,
    aad: Data?,
    options: [String: String]
  ) async -> FoundationCryptoResult

  /// Encrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - publicKey: Public key for encryption
  ///   - algorithm: Encryption algorithm
  ///   - keySizeInBits: Key size in bits
  ///   - options: Additional options for encryption
  /// - Returns: Result containing encrypted data
  func encryptAsymmetric(
    data: Data,
    publicKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    options: [String: String]
  ) async -> FoundationCryptoResult

  /// Decrypt data using asymmetric encryption
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - privateKey: Private key for decryption
  ///   - algorithm: Decryption algorithm
  ///   - keySizeInBits: Key size in bits
  ///   - options: Additional options for decryption
  /// - Returns: Result containing decrypted data
  func decryptAsymmetric(
    data: Data,
    privateKey: Data,
    algorithm: String,
    keySizeInBits: Int,
    options: [String: String]
  ) async -> FoundationCryptoResult

  /// Create a hash of data using specified algorithm
  /// - Parameters:
  ///   - data: Data to hash
  ///   - algorithm: Hash algorithm
  ///   - options: Additional options for hashing
  /// - Returns: Result containing hash value
  func hash(
    data: Data,
    algorithm: String,
    options: [String: String]
  ) async -> FoundationCryptoResult
}

/// Result type for security operations
public struct FoundationCryptoResult {
  /// The operation result data
  public let data: Data?

  /// Error if operation failed
  public let error: Error?

  /// Initialize with data
  /// - Parameter data: Result data
  public init(data: Data?) {
    self.data = data
    error = nil
  }

  /// Initialize with error
  /// - Parameter error: Result error
  public init(error: Error) {
    data = nil
    self.error = error
  }

  /// Convert to Swift Result type
  /// - Returns: Swift Result containing data or error
  public func toResult() -> Result<Data, Error> {
    if let error {
      .failure(error)
    } else if let data {
      .success(data)
    } else {
      .failure(NSError(
        domain: "com.umbrasecurity",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "No data or error provided"]
      ))
    }
  }
}

/// Extension to make Result convertible to FoundationCryptoResult
extension Result where Success == Data, Failure == Error {
  /// Convert to FoundationCryptoResult
  /// - Returns: FoundationCryptoResult
  public func toFoundationResult() -> FoundationCryptoResult {
    switch self {
      case let .success(data):
        FoundationCryptoResult(data: data)
      case let .failure(error):
        FoundationCryptoResult(error: error)
    }
  }
}

/// Extension to make FoundationCryptoResult convertible to Result
extension Result where Success == Data, Failure == Error {
  /// Create from FoundationCryptoResult
  /// - Parameter result: FoundationCryptoResult
  /// - Returns: Result<Data, Error>
  public static func from(_ result: FoundationCryptoResult) -> Result<Data, Error> {
    result.toResult()
  }
}

extension SecurityBridge {
  /// Helper to convert a Foundation.Result to a domain result
  static func mapResult<T>(_ result: Result<T, Error>) -> Result<T, SecurityError> {
    switch result {
      case let .success(value):
        .success(value)
      case let .failure(error):
        .failure(SecurityError.internalError(error.localizedDescription))
    }
  }
}

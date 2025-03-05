import Core
import CoreErrors
import CryptoSwift
import CryptoTypes
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraXPC

/// Extension to generate random data using SecRandomCopyBytes
extension Data {
  static func random(count: Int) -> Data {
    var bytes=[UInt8](repeating: 0, count: count)
    _=SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    return Data(bytes)
  }
}

/// XPC service for cryptographic operations
///
/// This service uses CryptoSwift to provide platform-independent cryptographic
/// operations across process boundaries. It is specifically designed for:
/// - Cross-process encryption/decryption via XPC
/// - Platform-independent cryptographic operations
/// - Flexible implementation for XPC service requirements
///
/// Note: This implementation uses CryptoSwift instead of CryptoKit to ensure
/// reliable cross-process operations. For main app cryptographic operations,
/// use DefaultCryptoService which provides hardware-backed security.
@available(macOS 14.0, *)
@MainActor
public final class CryptoXPCService: NSObject, CryptoXPCServiceProtocol {
  /// Dependencies for the crypto service
  private let dependencies: CryptoXPCServiceDependencies

  /// Queue for cryptographic operations
  private let cryptoQueue=DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)

  /// XPC connection for the service
  var connection: NSXPCConnection?

  /// Initialize the crypto service with dependencies
  /// - Parameter dependencies: Dependencies required by the service
  public init(dependencies: CryptoXPCServiceDependencies) {
    self.dependencies=dependencies
    super.init()
  }

  /// Encrypt data using AES-256-GCM
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data
  /// - Throws: CoreErrors.CryptoError if encryption fails
  public func encrypt(_ data: Data, key: Data) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()

    return try await withCheckedThrowingContinuation { continuation in
      cryptoQueue.async {
        do {
          // Generate random IV
          let iv=Data.random(count: 12)

          // Create AES-GCM
          let aes=try AES(key: key.bytes, blockMode: GCM(iv: iv.bytes))

          // Encrypt
          let encrypted=try aes.encrypt(data.bytes)

          // Combine IV and ciphertext
          var result=Data()
          result.append(iv)
          result.append(Data(encrypted))

          continuation.resume(returning: result)
        } catch {
          continuation
            .resume(
              throwing: CoreErrors.CryptoError
                .encryptionFailed(reason: error.localizedDescription)
            )
        }
      }
    }
  }

  /// Decrypt data using AES-256-GCM
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data
  /// - Throws: CoreErrors.CryptoError if decryption fails
  public func decrypt(_ data: Data, key: Data) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()

    return try await withCheckedThrowingContinuation { continuation in
      cryptoQueue.async {
        do {
          // Extract IV and ciphertext
          let iv=data.prefix(12)
          let ciphertext=data.dropFirst(12)

          // Create AES-GCM
          let aes=try AES(key: key.bytes, blockMode: GCM(iv: iv.bytes))

          // Decrypt
          let decrypted=try aes.decrypt(ciphertext.bytes)

          continuation.resume(returning: Data(decrypted))
        } catch {
          continuation
            .resume(
              throwing: CoreErrors.CryptoError
                .decryptionFailed(reason: error.localizedDescription)
            )
        }
      }
    }
  }

  /// Generates a random key of the specified bit length
  /// - Parameter bits: Bit length (128 or 256 bits)
  /// - Returns: Generated key data
  /// - Throws: CoreErrors.CryptoError if bit length is invalid
  public func generateKey(bits: Int) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()

    guard bits == 128 || bits == 256 else {
      throw CoreErrors.CryptoError.invalidKeySize(reason: "Key size must be 128 or 256 bits")
    }

    // Convert bits to bytes
    let bytes=bits / 8
    return Data.random(count: bytes)
  }

  /// Generates a random salt of the specified length
  /// - Parameter length: Length in bytes
  /// - Returns: Generated salt data
  /// - Throws: CoreErrors.CryptoError if length is invalid
  public func generateSalt(length: Int) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()

    guard length > 0 && length <= 64 else {
      throw CoreErrors.CryptoError.invalidSaltLength(expected: 64, got: length)
    }

    return Data.random(count: length)
  }

  /// Generate a secure random key of specified length
  /// - Parameter length: Length of the key in bytes
  /// - Returns: Generated key as Data
  /// - Throws: CoreErrors.CryptoError if generation fails
  @MainActor
  public func generateSecureRandomKey(length: Int) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()
    return Data.random(count: length)
  }

  /// Generate an initialization vector for AES-GCM
  /// - Returns: Generated IV as Data
  /// - Throws: CoreErrors.CryptoError if generation fails
  @MainActor
  public func generateInitializationVector() async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()
    return Data.random(count: 12) // 12 bytes is standard for GCM mode
  }

  /// Store a credential securely
  /// - Parameters:
  ///   - credential: Credential to store
  ///   - identifier: Unique identifier for the credential
  /// - Throws: CoreErrors.CryptoError if storage fails
  public func storeCredential(_ credential: Data, forIdentifier identifier: String) async throws {
    try Task.checkCancellation()

    guard !identifier.isEmpty else {
      throw CoreErrors.CryptoError
        .invalidCredentialIdentifier(reason: "Credential identifier cannot be empty")
    }

    // Generate a random key for the credential
    let key=try await generateKey(bits: 256)

    // Encrypt the credential
    _=try await encrypt(credential, key: key)

    // Store the key in the keychain
    try dependencies.keychain.store(
      password: key.base64EncodedString(),
      for: identifier
    )

    // TODO: Store encrypted credential in secure storage
  }

  /// Retrieve a credential
  /// - Parameter forIdentifier: Identifier of the credential to retrieve
  /// - Returns: Retrieved credential
  /// - Throws: CoreErrors.CryptoError if retrieval fails
  public func retrieveCredential(forIdentifier identifier: String) async -> Result<Data , XPCSecurityError>{
    try Task.checkCancellation()

    guard !identifier.isEmpty else {
      throw CoreErrors.CryptoError
        .invalidCredentialIdentifier(reason: "Credential identifier cannot be empty")
    }

    // Retrieve the key from the keychain
    let keyString=try dependencies.keychain.retrievePassword(for: identifier)
    guard Data(base64Encoded: keyString) != nil else {
      throw CoreErrors.CryptoError.invalidKeyFormat(reason: "Invalid key format")
    }

    // TODO: Retrieve encrypted credential from secure storage
    // For now, return empty data
    return Data()
  }

  /// Delete a credential
  /// - Parameter forIdentifier: Identifier of the credential to delete
  /// - Throws: CoreErrors.CryptoError if deletion fails
  public func deleteCredential(forIdentifier identifier: String) async throws {
    try Task.checkCancellation()

    guard !identifier.isEmpty else {
      throw CoreErrors.CryptoError
        .invalidCredentialIdentifier(reason: "Credential identifier cannot be empty")
    }

    // Delete the key from the keychain
    try dependencies.keychain.deletePassword(for: identifier)

    // TODO: Delete encrypted credential from secure storage
  }
}

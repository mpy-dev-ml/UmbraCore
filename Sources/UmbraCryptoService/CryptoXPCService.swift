import Core
import CoreErrors
import CryptoSwift
import CryptoTypes
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraXPC
import UmbraCoreTypes
import XPCProtocolsCore

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
  /// - Returns: Encrypted data as Result with Data or XPCSecurityError
  public func encrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError> {
    do {
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

            continuation.resume(returning: .success(result))
          } catch {
            continuation.resume(returning: .failure(.encryptionFailed))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Decrypt data using AES-256-GCM
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data as Result with Data or XPCSecurityError
  public func decrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError> {
    do {
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
            
            continuation.resume(returning: .success(Data(decrypted)))
          } catch {
            continuation.resume(returning: .failure(.decryptionFailed))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Generate a random encryption key
  /// - Returns: Random key data of 32 bytes (256 bits)
  /// - Throws: CoreErrors.CryptoError if key generation fails
  public func generateKey() async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()
      return .success(Data.random(count: 32))
    } catch {
      return .failure(.keyGenerationFailed)
    }
  }

  /// Hash data using SHA-256
  /// - Parameter data: Data to hash
  /// - Returns: SHA-256 hash of the data
  /// - Throws: CoreErrors.CryptoError if hashing fails
  public func hash(_ data: Data) async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()
      
      return try await withCheckedThrowingContinuation { continuation in
        cryptoQueue.async {
          do {
            let digest = SHA2(variant: .sha256)
            let hash = try digest.calculate(for: data.bytes)
            continuation.resume(returning: .success(Data(hash)))
          } catch {
            continuation.resume(returning: .failure(.hashingFailed))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Store credential in keychain
  /// - Parameters:
  ///   - credential: Credential data to store
  ///   - identifier: Identifier for the credential
  /// - Throws: CoreErrors.CryptoError if storage fails
  public func storeCredential(_ credential: Data, forIdentifier identifier: String) async -> Result<Void, XPCSecurityError> {
    do {
      try Task.checkCancellation()
      
      guard !identifier.isEmpty else {
        return .failure(.invalidData)
      }
      
      try await dependencies.keychain.save(data: credential, forKey: identifier)
      return .success(())
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Retrieve credential from keychain
  /// - Parameter identifier: Identifier for the credential
  /// - Returns: Credential data
  /// - Throws: CoreErrors.CryptoError if retrieval fails
  public func retrieveCredential(forIdentifier identifier: String) async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()
      
      guard !identifier.isEmpty else {
        return .failure(.invalidData)
      }
      
      let credential = try await dependencies.keychain.getData(forKey: identifier)
      return .success(credential)
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Delete credential from keychain
  /// - Parameter identifier: Identifier for the credential
  /// - Throws: CoreErrors.CryptoError if deletion fails
  public func deleteCredential(forIdentifier identifier: String) async -> Result<Void, XPCSecurityError> {
    do {
      try Task.checkCancellation()
      
      guard !identifier.isEmpty else {
        return .failure(.invalidData)
      }
      
      try await dependencies.keychain.delete(forKey: identifier)
      return .success(())
    } catch {
      return .failure(.serviceFailed)
    }
  }
}

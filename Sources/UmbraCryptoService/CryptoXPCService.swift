import Core
import CoreErrors
import CryptoSwift
import CryptoTypes
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraCoreTypes
import UmbraXPC
import XPC
import XPCProtocolsCore

/// Extension to generate random data using SecRandomCopyBytes
extension Data {
  static func random(count: Int) -> Data {
    var bytes = [UInt8](repeating: 0, count: count)
    _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
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
public final class CryptoXPCService: NSObject, ModernCryptoXPCServiceProtocol {
  /// Dependencies for the crypto service
  private let dependencies: CryptoXPCServiceDependencies

  /// Queue for cryptographic operations
  private let cryptoQueue = DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)

  /// XPC connection for the service
  var connection: NSXPCConnection?

  /// Protocol identifier for XPC service
  public static var protocolIdentifier: String {
    "com.umbracore.xpc.crypto"
  }

  /// Initialize the crypto service with dependencies
  /// - Parameter dependencies: Dependencies required by the service
  public init(dependencies: CryptoXPCServiceDependencies) {
    self.dependencies = dependencies
    super.init()
  }

  /// Implementation of ping from XPCServiceProtocolBasic
  public func ping() async -> Result<Bool, XPCSecurityError> {
    .success(true)
  }

  /// Implementation of synchronizeKeys from XPCServiceProtocolBasic
  public func synchronizeKeys(_ data: UmbraCoreTypes.SecureBytes) async -> Result<Void, XPCSecurityError> {
    guard !data.isEmpty else {
      return .failure(.invalidInput)
    }
    return .success(())
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
            let iv = Data.random(count: 12)

            // Create AES-GCM
            let aes = try AES(key: key.bytes, blockMode: GCM(iv: iv.bytes))

            // Encrypt
            let encrypted = try aes.encrypt(data.bytes)

            // Combine IV and ciphertext
            var result = Data()
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
            let iv = data.prefix(12)
            let ciphertext = data.dropFirst(12)

            // Create AES-GCM
            let aes = try AES(key: key.bytes, blockMode: GCM(iv: [UInt8](iv)))

            // Decrypt
            let decrypted = try aes.decrypt([UInt8](ciphertext))

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

  /// Generate a cryptographic key of the specified bit length
  /// - Parameter bits: Key length in bits (128, 256)
  /// - Returns: Generated key data
  public func generateKey(bits: Int) async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()

      // Validate bit length
      guard bits == 128 || bits == 256 else {
        return .failure(.invalidInput)
      }

      // Convert bits to bytes
      let keyLength = bits / 8

      // Generate random key
      let key = Data.random(count: keyLength)
      return .success(key)
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Generate secure random data of the specified length
  /// - Parameter length: Length of the random data in bytes
  /// - Returns: Random data
  public func generateSecureRandomData(length: Int) async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()

      // Validate length
      guard length > 0 else {
        return .failure(.invalidInput)
      }

      // Generate random data
      let randomData = Data.random(count: length)
      return .success(randomData)
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Store a credential securely
  /// - Parameters:
  ///   - credential: Credential to store
  ///   - identifier: Unique identifier for the credential
  /// - Returns: Success or error
  public func storeSecurely(_ credential: Data, identifier: String) async -> Result<Void, XPCSecurityError> {
    do {
      try Task.checkCancellation()

      guard !identifier.isEmpty else {
        return .failure(.invalidInput)
      }

      return try await withCheckedThrowingContinuation { continuation in
        dependencies.keychain.store(data: credential, forKey: identifier) { _ in
          if let error {
            continuation.resume(returning: .failure(.keychainError))
          } else {
            continuation.resume(returning: .success(()))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Retrieve a securely stored credential
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: Retrieved credential data
  public func retrieveSecurely(identifier: String) async -> Result<Data, XPCSecurityError> {
    do {
      try Task.checkCancellation()

      guard !identifier.isEmpty else {
        return .failure(.invalidInput)
      }

      return try await withCheckedThrowingContinuation { continuation in
        dependencies.keychain.retrieve(forKey: identifier) { data, _ in
          if let error {
            continuation.resume(returning: .failure(.keychainError))
          } else if let data {
            continuation.resume(returning: .success(data))
          } else {
            continuation.resume(returning: .failure(.itemNotFound))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }

  /// Delete a securely stored credential
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: Success or error
  public func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError> {
    do {
      try Task.checkCancellation()

      guard !identifier.isEmpty else {
        return .failure(.invalidInput)
      }

      return try await withCheckedThrowingContinuation { continuation in
        dependencies.keychain.delete(forKey: identifier) { _ in
          if let error {
            continuation.resume(returning: .failure(.keychainError))
          } else {
            continuation.resume(returning: .success(()))
          }
        }
      }
    } catch {
      return .failure(.serviceFailed)
    }
  }
}

import Core
import CoreErrors
import CryptoSwiftFoundationIndependent
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
    var bytes=[UInt8](repeating: 0, count: count)
    _=SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    return Data(bytes)
  }
}

/// Custom GCM format for CryptoXPCService
/// Format: <iv (12 bytes)><ciphertext>
enum CryptoFormat {
  static let ivSize=12

  static func packEncryptedData(iv: [UInt8], ciphertext: [UInt8]) -> [UInt8] {
    iv + ciphertext
  }

  static func unpackEncryptedData(data: [UInt8]) -> (iv: [UInt8], ciphertext: [UInt8])? {
    guard data.count > ivSize else { return nil }
    let iv=Array(data[0..<ivSize])
    let ciphertext=Array(data[ivSize...])
    return (iv, ciphertext)
  }
}

/// XPC service for cryptographic operations
///
/// This service uses CryptoSwiftFoundationIndependent to provide platform-independent cryptographic
/// operations across process boundaries. It is specifically designed for:
/// - Cross-process encryption/decryption via XPC
/// - Platform-independent cryptographic operations
/// - Flexible implementation for XPC service requirements
///
/// Note: This implementation uses CryptoSwift instead of CryptoKit to ensure
/// reliable cross-process operations. For main app cryptographic operations,
/// use DefaultCryptoService which provides hardware-backed security.
@available(macOS 14.0, *)
@objc(CryptoXPCService)
public final class CryptoXPCService: NSObject {
  /// Dependencies for the crypto service
  private let dependencies: CryptoXPCServiceDependencies

  /// Queue for cryptographic operations
  private let cryptoQueue=DispatchQueue(label: "com.umbracore.crypto", qos: .userInitiated)

  /// XPC connection for the service
  var connection: NSXPCConnection?

  /// Protocol identifier for XPC service
  public static var protocolIdentifier: String {
    "com.umbracore.xpc.crypto"
  }

  /// Initialize the crypto service with dependencies
  /// - Parameter dependencies: Dependencies required by the service
  public init(dependencies: CryptoXPCServiceDependencies) {
    self.dependencies=dependencies
    super.init()
  }

  /// Validate the XPC connection
  /// - Parameter reply: Completion handler with validation result
  @objc
  public func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void) {
    reply(true, nil)
  }

  /// Gets the service version
  /// - Parameter reply: Completion handler with version string
  @objc
  public func getServiceVersion(withReply reply: @escaping (String) -> Void) {
    reply("1.0.0")
  }

  /// Encrypt data using the specified key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - completion: Completion handler with encrypted data or error
  @objc
  public func encrypt(
    _ data: Data,
    key: Data,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    cryptoQueue.async { [weak self] in
      guard self != nil else {
        completion(nil, XPCSecurityError.invalidInput(details: "Service is no longer available"))
        return
      }

      do {
        // Generate a random IV for AES-GCM
        let iv=CryptoWrapper.generateRandomIV(size: CryptoFormat.ivSize)

        // Use AES-GCM encryption from CryptoSwiftFoundationIndependent
        let ciphertext=try CryptoWrapper.encryptAES_GCM(
          data: [UInt8](data),
          key: [UInt8](key),
          iv: iv
        )

        // Pack the IV and ciphertext together
        let packedData=CryptoFormat.packEncryptedData(iv: iv, ciphertext: ciphertext)

        completion(Data(packedData), nil)
      } catch {
        completion(
          nil,
          XPCSecurityError.invalidInput(details: "Encryption failed: \(error.localizedDescription)")
        )
      }
    }
  }

  /// Decrypt data using the specified key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - completion: Completion handler with decrypted data or error
  @objc
  public func decrypt(
    _ data: Data,
    key: Data,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    cryptoQueue.async { [weak self] in
      guard self != nil else {
        completion(nil, XPCSecurityError.invalidInput(details: "Service is no longer available"))
        return
      }

      do {
        let dataBytes=[UInt8](data)

        // Unpack the IV and ciphertext
        guard let (iv, ciphertext)=CryptoFormat.unpackEncryptedData(data: dataBytes) else {
          completion(nil, XPCSecurityError.invalidInput(details: "Invalid encrypted data format"))
          return
        }

        // Use AES-GCM decryption with the extracted IV
        let decrypted=try CryptoWrapper.decryptAES_GCM(
          data: ciphertext,
          key: [UInt8](key),
          iv: iv
        )

        completion(Data(decrypted), nil)
      } catch {
        completion(
          nil,
          XPCSecurityError.invalidInput(details: "Decryption failed: \(error.localizedDescription)")
        )
      }
    }
  }

  /// Generate a cryptographic key of the specified bit length
  /// - Parameters:
  ///   - bits: Key length in bits (typically 128, 256)
  ///   - completion: Completion handler with generated key data or error
  @objc
  public func generateKey(bits: Int, completion: @escaping (Data?, Error?) -> Void) {
    let bytes=bits / 8
    let key=Data.random(count: bytes)
    completion(key, nil)
  }

  /// Generate random data of the specified length
  /// - Parameters:
  ///   - length: Length of random data in bytes
  ///   - completion: Completion handler with random data or error
  @objc
  public func generateRandomData(length: Int, completion: @escaping (Data?, Error?) -> Void) {
    let data=Data.random(count: length)
    completion(data, nil)
  }

  /// Store a key in the keychain
  /// - Parameters:
  ///   - key: Key data to store
  ///   - identifier: Key identifier
  ///   - completion: Completion handler with status or error
  @objc
  public func storeKey(
    _ key: Data,
    identifier: String,
    completion: @escaping (Bool, Error?) -> Void
  ) {
    guard !identifier.isEmpty else {
      completion(false, XPCSecurityError.invalidInput(details: "Empty identifier"))
      return
    }

    // Convert Data to base64 string for storage
    let keyString=key.base64EncodedString()

    do {
      try dependencies.keychain.store(password: keyString, for: identifier)
      completion(true, nil)
    } catch {
      completion(
        false,
        XPCSecurityError
          .invalidInput(details: "Keychain storage failed: \(error.localizedDescription)")
      )
    }
  }

  /// Retrieve a key from the keychain
  /// - Parameters:
  ///   - identifier: Key identifier
  ///   - completion: Completion handler with key data or error
  @objc
  public func retrieveKey(identifier: String, completion: @escaping (Data?, Error?) -> Void) {
    guard !identifier.isEmpty else {
      completion(nil, XPCSecurityError.invalidInput(details: "Empty identifier"))
      return
    }

    do {
      let keyString=try dependencies.keychain.retrievePassword(for: identifier)
      if let keyData=Data(base64Encoded: keyString) {
        completion(keyData, nil)
      } else {
        completion(nil, XPCSecurityError.invalidInput(details: "Invalid key data format"))
      }
    } catch {
      completion(
        nil,
        XPCSecurityError
          .invalidInput(details: "Keychain retrieval failed: \(error.localizedDescription)")
      )
    }
  }

  /// Delete a key from the keychain
  /// - Parameters:
  ///   - identifier: Key identifier
  ///   - completion: Completion handler with status or error
  @objc
  public func deleteKey(identifier: String, completion: @escaping (Bool, Error?) -> Void) {
    guard !identifier.isEmpty else {
      completion(false, XPCSecurityError.invalidInput(details: "Empty identifier"))
      return
    }

    do {
      try dependencies.keychain.deletePassword(for: identifier)
      completion(true, nil)
    } catch {
      completion(
        false,
        XPCSecurityError
          .invalidInput(details: "Keychain deletion failed: \(error.localizedDescription)")
      )
    }
  }
}

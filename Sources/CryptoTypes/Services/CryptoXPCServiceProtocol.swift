import Foundation
import XPC

@available(macOS 14.0, *)
@objc
public protocol CryptoXPCServiceProtocol {
  /// Generates a random key of the specified bit length (128 or 256 bits)
  func generateKey(bits: Int) async throws -> Data

  /// Generates a random salt of the specified length
  func generateSalt(length: Int) async throws -> Data

  /// Stores a credential in the system keychain
  func storeCredential(_ credential: Data, forIdentifier identifier: String) async throws

  /// Retrieves a credential from the system keychain
  func retrieveCredential(forIdentifier identifier: String) async throws -> Data

  /// Deletes a credential from the system keychain
  func deleteCredential(forIdentifier identifier: String) async throws

  /// Encrypts data using the specified key
  func encrypt(_ data: Data, key: Data) async throws -> Data

  /// Decrypts data using the specified key
  func decrypt(_ data: Data, key: Data) async throws -> Data
}

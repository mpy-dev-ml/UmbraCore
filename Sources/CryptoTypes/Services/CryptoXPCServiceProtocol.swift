import Foundation
import XPC
import XPCProtocolsCore
import UmbraCoreTypes

/// Legacy crypto XPC service protocol - being replaced by ModernCryptoXPCServiceProtocol
/// @available for backward compatibility only, will be removed in future versions
@available(macOS 14.0, *)
@available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol instead for improved type safety and error handling")
@objc
public protocol CryptoXPCServiceProtocol {
  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.generateKey() instead")
  /// Generates a random key of the specified bit length (128 or 256 bits)
  func generateKey(bits: Int) async throws -> Data

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.generateSalt() instead")
  /// Generates a random salt of the specified length
  func generateSalt(length: Int) async throws -> Data

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.storeSecurely() instead")
  /// Stores a credential in the system keychain
  func storeCredential(_ credential: Data, forIdentifier identifier: String) async throws

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.retrieveSecurely() instead")
  /// Retrieves a credential from the system keychain
  func retrieveCredential(forIdentifier identifier: String) async throws -> Data

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.deleteSecurely() instead")
  /// Deletes a credential from the system keychain
  func deleteCredential(forIdentifier identifier: String) async throws

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.encrypt() instead")
  /// Encrypts data using the specified key
  func encrypt(_ data: Data, key: Data) async throws -> Data

  @available(*, deprecated, message: "Use ModernCryptoXPCServiceProtocol.decrypt() instead")
  /// Decrypts data using the specified key
  func decrypt(_ data: Data, key: Data) async throws -> Data
}

/// Modern replacement for CryptoXPCServiceProtocol that follows the XPCProtocolsCore standards
/// This protocol conforms to the standard XPC service protocol and secure storage protocol
/// providing cryptographic operations with enhanced type safety and error handling
@available(macOS 14.0, *)
public protocol ModernCryptoXPCServiceProtocol: XPCServiceProtocolStandard, SecureStorageServiceProtocol {
  /// Generates a random key of the specified bit length (128 or 256 bits)
  /// - Parameter bits: Bit length (128 or 256)
  /// - Returns: Result containing the generated key data or an error
  func generateKey(bits: Int) async -> Result<SecureBytes, XPCSecurityError>

  /// Generates a random salt of the specified length
  /// - Parameter length: Length of the salt in bytes
  /// - Returns: Result containing the generated salt data or an error
  func generateSalt(length: Int) async -> Result<SecureBytes, XPCSecurityError>

  /// Encrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Result containing the encrypted data or an error
  func encrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>

  /// Decrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Result containing the decrypted data or an error
  func decrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>
}

/// Migration adapter that bridges the legacy CryptoXPCServiceProtocol to the new ModernCryptoXPCServiceProtocol
/// This adapter helps transition from the legacy protocol to the modern protocol while maintaining
/// backward compatibility. It converts throw-based error handling to Result-based error handling
/// and raw Data to SecureBytes.
@available(macOS 14.0, *)
public class CryptoXPCServiceAdapter: ModernCryptoXPCServiceProtocol {
  private let legacyService: CryptoXPCServiceProtocol
  
  /// Initialize the adapter with a legacy service implementation
  /// - Parameter legacyService: The legacy crypto XPC service to adapt
  public init(legacyService: CryptoXPCServiceProtocol) {
    self.legacyService = legacyService
  }
  
  public func generateKey(bits: Int) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let keyData = try await legacyService.generateKey(bits: bits)
      return .success(SecureBytes(data: keyData))
    } catch {
      return .failure(.operationFailed)
    }
  }
  
  public func generateSalt(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let saltData = try await legacyService.generateSalt(length: length)
      return .success(SecureBytes(data: saltData))
    } catch {
      return .failure(.operationFailed)
    }
  }
  
  public func encrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let dataAsData = data.asData()
      let keyAsData = key.asData()
      let encryptedData = try await legacyService.encrypt(dataAsData, key: keyAsData)
      return .success(SecureBytes(data: encryptedData))
    } catch {
      return .failure(.encryptionFailed)
    }
  }
  
  public func decrypt(_ data: SecureBytes, key: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let dataAsData = data.asData()
      let keyAsData = key.asData()
      let decryptedData = try await legacyService.decrypt(dataAsData, key: keyAsData)
      return .success(SecureBytes(data: decryptedData))
    } catch {
      return .failure(.decryptionFailed)
    }
  }
  
  // MARK: - XPCServiceProtocolBasic implementation
  
  public func ping() async throws -> Bool {
    return true
  }
  
  public func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
    // No direct equivalent in legacy protocol, this is a no-op
    return .success(())
  }
  
  // MARK: - XPCServiceProtocolStandard implementation
  
  public func generateRandomData(length: Int) async throws -> SecureBytes {
    let result = await generateSalt(length: length)
    switch result {
    case .success(let data):
      return data
    case .failure(let error):
      throw error
    }
  }
  
  public func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
    guard let keyId = keyIdentifier else {
      throw SecurityProtocolError.implementationMissing("Key identifier required")
    }
    
    do {
      let keyData = try await legacyService.retrieveCredential(forIdentifier: keyId)
      let keyBytes = SecureBytes(data: keyData)
      
      let result = await encrypt(data, key: keyBytes)
      switch result {
      case .success(let encryptedData):
        return encryptedData
      case .failure(let error):
        throw error
      }
    } catch {
      throw SecurityProtocolError.implementationMissing("Encryption failed")
    }
  }
  
  public func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
    guard let keyId = keyIdentifier else {
      throw SecurityProtocolError.implementationMissing("Key identifier required")
    }
    
    do {
      let keyData = try await legacyService.retrieveCredential(forIdentifier: keyId)
      let keyBytes = SecureBytes(data: keyData)
      
      let result = await decrypt(data, key: keyBytes)
      switch result {
      case .success(let decryptedData):
        return decryptedData
      case .failure(let error):
        throw error
      }
    } catch {
      throw SecurityProtocolError.implementationMissing("Decryption failed")
    }
  }
  
  public func hashData(_ data: SecureBytes) async throws -> SecureBytes {
    // Not implemented in legacy protocol
    throw SecurityProtocolError.implementationMissing("Hashing not implemented")
  }
  
  public func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
    // Not implemented in legacy protocol
    throw SecurityProtocolError.implementationMissing("Signing not implemented")
  }
  
  public func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
    // Not implemented in legacy protocol
    throw SecurityProtocolError.implementationMissing("Signature verification not implemented")
  }
  
  // MARK: - SecureStorageServiceProtocol implementation
  
  public func storeSecurely(_ data: SecureBytes, identifier: String, metadata: [String : String]?) async throws {
    try await legacyService.storeCredential(data.asData(), forIdentifier: identifier)
  }
  
  public func retrieveSecurely(identifier: String) async throws -> SecureBytes {
    let data = try await legacyService.retrieveCredential(forIdentifier: identifier)
    return SecureBytes(data: data)
  }
  
  public func deleteSecurely(identifier: String) async throws {
    try await legacyService.deleteCredential(forIdentifier: identifier)
  }
  
  public func listIdentifiers() async throws -> [String] {
    // Not implemented in legacy protocol
    throw SecurityProtocolError.implementationMissing("Listing identifiers not implemented")
  }
  
  public func exists(identifier: String) async throws -> Bool {
    do {
      _ = try await legacyService.retrieveCredential(forIdentifier: identifier)
      return true
    } catch {
      return false
    }
  }
}

import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Base protocol for all XPC services
@objc
public protocol XPCServiceProtocol {
  /// Validates the connection with the service
  func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void)

  /// Gets the service version
  func getServiceVersion(withReply reply: @escaping (String) -> Void)
}

/// Modern crypto XPC service protocol that conforms to XPCServiceProtocolStandard
/// Uses Result types with proper error handling
@objc(ModernCryptoXPCServiceProtocol)
public protocol ModernCryptoXPCServiceProtocol: XPCServiceProtocolStandard {
  /// Encrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  /// - Returns: Encrypted data or error
  func encrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError>

  /// Decrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  /// - Returns: Decrypted data or error
  func decrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError>

  /// Generates a cryptographic key of the specified bit length
  /// - Parameter bits: Key length in bits (typically 128, 256)
  /// - Returns: Generated key data or error
  func generateKey(bits: Int) async -> Result<Data, XPCSecurityError>

  /// Generates secure random data of the specified length
  /// - Parameter length: Length of random data in bytes
  /// - Returns: Random data or error
  func generateSecureRandomData(length: Int) async -> Result<Data, XPCSecurityError>

  /// Stores a credential securely
  /// - Parameters:
  ///   - credential: Credential data to store
  ///   - identifier: Unique identifier for the credential
  /// - Returns: Success or error
  func storeSecurely(_ credential: Data, identifier: String) async -> Result<Void, XPCSecurityError>

  /// Retrieves a credential stored securely
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: Retrieved credential data or error
  func retrieveSecurely(identifier: String) async -> Result<Data, XPCSecurityError>

  /// Deletes a securely stored credential
  /// - Parameter identifier: Unique identifier for the credential
  /// - Returns: Success or error
  func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError>
}

/// Security XPC service protocol that extends XPCServiceProtocolStandard with objc compatibility
@objc(SecurityXPCServiceProtocol)
public protocol SecurityXPCServiceProtocol: XPCServiceProtocolStandard {
  /// Creates a security-scoped bookmark
  func createBookmark(
    forPath path: String,
    withReply reply: @escaping ([UInt8]?, Error?) -> Void
  )

  /// Resolves a security-scoped bookmark
  func resolveBookmark(
    _ bookmarkData: [UInt8],
    withReply reply: @escaping (String?, Bool, Error?) -> Void
  )

  /// Validates a security-scoped bookmark
  func validateBookmark(
    _ bookmarkData: [UInt8],
    withReply reply: @escaping (Bool, Error?) -> Void
  )

  func validateAccess(forResource resource: String) async throws -> Bool
  func requestPermission(forResource resource: String) async throws -> Bool
  func revokePermission(forResource resource: String) async throws
  func getCurrentPermissions() async throws -> [String: Bool]
}

/// Adapter to bridge between SecurityXPCServiceProtocol and XPCServiceProtocolStandard
public class SecurityXPCServiceAdapter {
  private let standardService: any XPCServiceProtocolStandard

  public init(standardService: any XPCServiceProtocolStandard) {
    self.standardService=standardService
  }

  // Bridge implementations between the protocols can be added here
}

/// Extension adding support for Swift concurrency to the legacy objective-C compatible protocol
extension SecurityXPCServiceProtocol {
  public func createBookmarkAsync(forPath path: String) async throws -> [UInt8] {
    try await withCheckedThrowingContinuation { continuation in
      createBookmark(forPath: path) { data, error in
        if let error {
          continuation.resume(throwing: error)
        } else if let data {
          continuation.resume(returning: data)
        } else {
          continuation.resume(throwing: NSError(
            domain: "SecurityXPCService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unknown error creating bookmark"]
          ))
        }
      }
    }
  }

  public func resolveBookmarkAsync(_ bookmarkData: [UInt8]) async throws
  -> (path: String, isStale: Bool) {
    try await withCheckedThrowingContinuation { continuation in
      resolveBookmark(bookmarkData) { path, isStale, error in
        if let error {
          continuation.resume(throwing: error)
        } else if let path {
          continuation.resume(returning: (path, isStale))
        } else {
          continuation.resume(throwing: NSError(
            domain: "SecurityXPCService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unknown error resolving bookmark"]
          ))
        }
      }
    }
  }

  public func validateBookmarkAsync(_ bookmarkData: [UInt8]) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      validateBookmark(bookmarkData) { isValid, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: isValid)
        }
      }
    }
  }

  public func validateConnectionAsync() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      validateConnection { isValid, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: isValid)
        }
      }
    }
  }

  public func getServiceVersionAsync() async -> String {
    await withCheckedContinuation { continuation in
      getServiceVersion { version in
        continuation.resume(returning: version)
      }
    }
  }
}

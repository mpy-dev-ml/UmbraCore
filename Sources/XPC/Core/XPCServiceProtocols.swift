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
/// Uses Objective-C compatible method signatures with completion handlers
@objc(ModernCryptoXPCServiceProtocol)
public protocol ModernCryptoXPCServiceProtocol: XPCServiceProtocol {
  /// Encrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - key: Encryption key
  ///   - completion: Completion handler with encrypted data or error
  func encrypt(_ data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void)

  /// Decrypts data using the specified key
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - key: Decryption key
  ///   - completion: Completion handler with decrypted data or error
  func decrypt(_ data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void)

  /// Generates a cryptographic key of the specified bit length
  /// - Parameters:
  ///   - bits: Key length in bits (typically 128, 256)
  ///   - completion: Completion handler with generated key data or error
  func generateKey(bits: Int, completion: @escaping (Data?, Error?) -> Void)

  /// Generates secure random data of the specified length
  /// - Parameters:
  ///   - length: Length of random data in bytes
  ///   - completion: Completion handler with random data or error
  func generateSecureRandomData(length: Int, completion: @escaping (Data?, Error?) -> Void)

  /// Stores a credential securely
  /// - Parameters:
  ///   - credential: Credential data to store
  ///   - identifier: Unique identifier for the credential
  ///   - completion: Completion handler with success or error
  func storeSecurely(_ credential: Data, identifier: String, completion: @escaping (Error?) -> Void)

  /// Retrieves a credential stored securely
  /// - Parameters:
  ///   - identifier: Unique identifier for the credential
  ///   - completion: Completion handler with retrieved credential data or error
  func retrieveSecurely(identifier: String, completion: @escaping (Data?, Error?) -> Void)

  /// Deletes a securely stored credential
  /// - Parameters:
  ///   - identifier: Unique identifier for the credential
  ///   - completion: Completion handler with success or error
  func deleteSecurely(identifier: String, completion: @escaping (Error?) -> Void)

  /// Validate the connection to the XPC service
  func validateConnection(completion: @escaping (Bool, Error?) -> Void)

  /// Get the version of the XPC service
  func getServiceVersion(completion: @escaping (String, Error?) -> Void)
}

/// Extension to provide async/await wrappers for the Objective-C compatible methods
public extension ModernCryptoXPCServiceProtocol {
  /// Async wrapper for encrypt
  func encrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      encrypt(data, key: key) { data, error in
        if let data = data {
          continuation.resume(returning: .success(data))
        } else if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .failure(.general(error?.localizedDescription ?? "Unknown error")))
        }
      }
    }
  }

  /// Async wrapper for decrypt
  func decrypt(_ data: Data, key: Data) async -> Result<Data, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      decrypt(data, key: key) { data, error in
        if let data = data {
          continuation.resume(returning: .success(data))
        } else if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .failure(.general(error?.localizedDescription ?? "Unknown error")))
        }
      }
    }
  }

  /// Async wrapper for generateKey
  func generateKey(bits: Int) async -> Result<Data, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      generateKey(bits: bits) { data, error in
        if let data = data {
          continuation.resume(returning: .success(data))
        } else if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .failure(.general(error?.localizedDescription ?? "Unknown error")))
        }
      }
    }
  }

  /// Async wrapper for generateSecureRandomData
  func generateSecureRandomData(length: Int) async -> Result<Data, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      generateSecureRandomData(length: length) { data, error in
        if let data = data {
          continuation.resume(returning: .success(data))
        } else if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .failure(.general(error?.localizedDescription ?? "Unknown error")))
        }
      }
    }
  }

  /// Async wrapper for storeSecurely
  func storeSecurely(_ credential: Data, identifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      storeSecurely(credential, identifier: identifier) { error in
        if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else if let error = error {
          continuation.resume(returning: .failure(.general(error.localizedDescription)))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }

  /// Async wrapper for retrieveSecurely
  func retrieveSecurely(identifier: String) async -> Result<Data, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      retrieveSecurely(identifier: identifier) { data, error in
        if let data = data {
          continuation.resume(returning: .success(data))
        } else if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .failure(.general(error?.localizedDescription ?? "Unknown error")))
        }
      }
    }
  }

  /// Async wrapper for deleteSecurely
  func deleteSecurely(identifier: String) async -> Result<Void, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      deleteSecurely(identifier: identifier) { error in
        if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else if let error = error {
          continuation.resume(returning: .failure(.general(error.localizedDescription)))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }

  /// Async wrapper for validateConnection
  func validateConnection() async -> Result<Bool, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      validateConnection { isValid, error in
        if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else if let error = error {
          continuation.resume(returning: .failure(.general(error.localizedDescription)))
        } else {
          continuation.resume(returning: .success(isValid))
        }
      }
    }
  }

  /// Async wrapper for getServiceVersion
  func getServiceVersion() async -> Result<String, XPCSecurityError> {
    await withCheckedContinuation { continuation in
      getServiceVersion { version, error in
        if let error = error as? XPCSecurityError {
          continuation.resume(returning: .failure(error))
        } else if let error = error {
          continuation.resume(returning: .failure(.general(error.localizedDescription)))
        } else {
          continuation.resume(returning: .success(version))
        }
      }
    }
  }
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
  
  /// Validates the connection to the XPC service
  func validateConnection(completion: @escaping (Bool, Error?) -> Void)
  
  /// Gets the version of the XPC service
  func getServiceVersion(completion: @escaping (String?, Error?) -> Void)

  func validateAccess(forResource resource: String) async throws -> Bool
  func requestPermission(forResource resource: String) async throws -> Bool
  func revokePermission(forResource resource: String) async throws
  func getCurrentPermissions() async throws -> [String: Bool]
}

/// Adapter to bridge between SecurityXPCServiceProtocol and XPCServiceProtocolStandard
public class SecurityXPCServiceAdapter {
  private let standardService: any XPCServiceProtocolStandard

  public init(standardService: any XPCServiceProtocolStandard) {
    self.standardService = standardService
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

  public func getServiceVersionAsync() async throws -> String? {
    try await withCheckedThrowingContinuation { continuation in
      getServiceVersion { version, error in
        if let error {
          continuation.resume(throwing: error)
        } else if let version {
          continuation.resume(returning: version)
        } else {
          continuation.resume(returning: nil)
        }
      }
    }
  }
}

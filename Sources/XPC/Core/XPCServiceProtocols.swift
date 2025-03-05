import Foundation
import XPCProtocolsCore

/// Base protocol for all XPC services
@objc
public protocol XPCServiceProtocol {
  /// Validates the connection with the service
  func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void)

  /// Gets the service version
  func getServiceVersion(withReply reply: @escaping (String) -> Void)
}

@objc(CryptoXPCServiceProtocol)
public protocol CryptoXPCServiceProtocol {
  func encrypt(_ data: Data, key: Data) async throws -> Data
  func decrypt(_ data: Data, key: Data) async throws -> Data
  func generateKey(bits: Int) async throws -> Data
  func generateSecureRandomKey(length: Int) async throws -> Data
  func generateInitializationVector() async throws -> Data
  func storeCredential(_ credential: Data, identifier: String) async throws
  func retrieveCredential(identifier: String) async throws -> Data
  func deleteCredential(identifier: String) async throws
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
    self.standardService = standardService
  }
  
  // Bridge implementations between the protocols can be added here
}

/// Extension adding support for Swift concurrency to the legacy objective-C compatible protocol
public extension SecurityXPCServiceProtocol {
  func createBookmarkAsync(forPath path: String) async throws -> [UInt8] {
    return try await withCheckedThrowingContinuation { continuation in
      createBookmark(forPath: path) { data, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let data = data {
          continuation.resume(returning: data)
        } else {
          continuation.resume(throwing: NSError(domain: "SecurityXPCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error creating bookmark"]))
        }
      }
    }
  }
  
  func resolveBookmarkAsync(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
    return try await withCheckedThrowingContinuation { continuation in
      resolveBookmark(bookmarkData) { path, isStale, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let path = path {
          continuation.resume(returning: (path, isStale))
        } else {
          continuation.resume(throwing: NSError(domain: "SecurityXPCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error resolving bookmark"]))
        }
      }
    }
  }
  
  func validateBookmarkAsync(_ bookmarkData: [UInt8]) async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
      validateBookmark(bookmarkData) { isValid, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: isValid)
        }
      }
    }
  }
  
  func validateConnectionAsync() async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
      validateConnection { isValid, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: isValid)
        }
      }
    }
  }
  
  func getServiceVersionAsync() async -> String {
    return await withCheckedContinuation { continuation in
      getServiceVersion { version in
        continuation.resume(returning: version)
      }
    }
  }
}

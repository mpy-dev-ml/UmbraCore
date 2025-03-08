import CoreErrors
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// Type alias to disambiguate SecurityError types
typealias SPCSecurityError=SecurityProtocolsCore.SecurityError

/// LegacyXPCServiceAdapter
///
/// This adapter class provides a bridge between legacy XPC service implementations
/// and the new XPCProtocolsCore protocols. It allows existing code to continue working
/// while gradually migrating to the new protocol hierarchy.
///
/// Usage:
/// ```swift
/// // Legacy implementation
/// class MyLegacyXPCService: SomeOldProtocol {
///     // Legacy implementation
/// }
///
/// // Adapter usage
/// let adapter = LegacyXPCServiceAdapter(service: MyLegacyXPCService())
/// let result = await adapter.encrypt(data: secureBytes)
/// ```
public final class LegacyXPCServiceAdapter: @unchecked Sendable {
  /// The legacy service being adapted
  private let service: Any

  /// Type erasure constructor for any legacy XPC service
  /// - Parameter service: The legacy service to adapt
  public init(service: Any) {
    self.service=service
  }

  /// Maps from legacy error types to the standardised XPCSecurityError domain
  ///
  /// This method provides a centralised way of handling legacy errors throughout the XPC service.
  /// It delegates to the centralised mapper for consistent error handling across the codebase.
  ///
  /// - Parameter error: Any legacy error type
  /// - Returns: A properly mapped XPCSecurityError
  public static func mapError(_ error: Error) -> XPCSecurityError {
    CoreErrors.SecurityErrorMapper.mapToXPCError(error)
  }

  /// Maps from XPCSecurityError to the legacy SecurityError domain
  ///
  /// This method provides bidirectional conversion capability for backward compatibility.
  /// It delegates to the centralised mapper for consistent error handling.
  ///
  /// - Parameter error: A standardised XPCSecurityError
  /// - Returns: A legacy SecurityError from the SecurityProtocolsCore module
  @available(*, deprecated, message: "Use XPCSecurityError instead")
  public static func mapToLegacyError(_ error: XPCSecurityError) -> SecurityError {
    CoreErrors.SecurityErrorMapper.mapToSPCError(error)
  }

  /// Convert SecureBytes to legacy SecureBytes
  /// - Parameter bytes: SecureBytes to convert
  /// - Returns: Legacy SecureBytes
  private func convertToSecureBytes(_ bytes: SecureBytes) -> Any {
    // If the legacy service implements conversion, use that
    if let legacyEncryptor=service as? LegacyEncryptor {
      return legacyEncryptor.createSecureBytes(from: bytes.withUnsafeBytes { Array($0) })
    }

    // Otherwise, just return the bytes array directly
    return bytes.withUnsafeBytes { Array($0) }
  }

  /// Convert legacy SecureBytes to SecureBytes
  /// - Parameter binaryData: Legacy SecureBytes to convert
  /// - Returns: SecureBytes
  private func convertToSecureBytes(_ binaryData: Any) -> SecureBytes {
    // Try to extract bytes using a protocol extension
    if let legacyEncryptor=service as? LegacyEncryptor {
      return legacyEncryptor.extractBytesFromSecureBytes(binaryData)
    }

    // If we can extract the bytes directly
    if let bytesArray=binaryData as? [UInt8] {
      return SecureBytes(bytes: bytesArray)
    }

    // Default: Empty bytes if we can't convert
    return SecureBytes()
  }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolComplete {
  public static var protocolIdentifier: String {
    "com.umbra.legacy.adapter.xpc.service"
  }

  public func pingComplete() async -> Result<Bool, XPCSecurityError> {
    // If the legacy service supports ping, use it
    if let pingable=service as? PingableService {
      let result=await pingable.ping()
      switch result {
        case let .success(value):
          return .success(value)
        case let .failure(error):
          return .failure(Self.mapError(error))
      }
    } else if let legacyBase=service as? LegacyXPCBase {
      // Try the legacy XPC base protocol
      do {
        let pingResult=try await legacyBase.ping()
        return .success(pingResult)
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation always succeeds
    return .success(true)
  }

  public func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
    if let legacyBase=service as? LegacyXPCBase {
      do {
        // Convert SecureBytes to legacy SecureBytes
        let binaryData=convertToSecureBytes(syncData)
        try await legacyBase.synchroniseKeys(binaryData)
        return .success(())
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation if not supported
    return .failure(.cryptoError)
  }

  public func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    if let encryptor=service as? LegacyEncryptor {
      do {
        // Convert SecureBytes to legacy SecureBytes
        let binaryData=convertToSecureBytes(data)
        let encryptedData=try await encryptor.encrypt(data: binaryData)

        // Convert result back to SecureBytes
        let secureBytes=convertToSecureBytes(encryptedData)
        return .success(secureBytes)
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation if not supported
    return .failure(.cryptoError)
  }

  public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    if let encryptor=service as? LegacyEncryptor {
      do {
        // Convert SecureBytes to legacy SecureBytes
        let binaryData=convertToSecureBytes(data)
        let decryptedData=try await encryptor.decrypt(data: binaryData)

        // Convert result back to SecureBytes
        let secureBytes=convertToSecureBytes(decryptedData)
        return .success(secureBytes)
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation if not supported
    return .failure(.cryptoError)
  }

  public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    if let keyGenerator=service as? LegacyKeyGenerator {
      do {
        let keyData=try await keyGenerator.generateKey()
        let secureBytes=convertToSecureBytes(keyData)
        return .success(secureBytes)
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation if not supported
    return .failure(.cryptoError)
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    if let hasher=service as? LegacyHasher {
      do {
        // Convert SecureBytes to legacy SecureBytes
        let binaryData=convertToSecureBytes(data)
        let hashedData=try await hasher.hash(data: binaryData)

        // Convert result back to SecureBytes
        let secureBytes=convertToSecureBytes(hashedData)
        return .success(secureBytes)
      } catch {
        return .failure(Self.mapError(error))
      }
    }

    // Default implementation if not supported
    return .failure(.cryptoError)
  }
}

// MARK: - XPCServiceProtocolStandard Conformance Extension

extension LegacyXPCServiceAdapter: XPCServiceProtocolStandard {
  public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
    if let randomGenerator=service as? LegacyRandomGenerator {
      let randomData=try await randomGenerator.generateRandomData(length: length)
      return convertToSecureBytes(randomData)
    }

    // If we don't have a legacy implementation, throw
    return .failure(.cryptoError)
  }

  public func encryptData(
    _ data: SecureBytes,
    keyIdentifier: String?
  ) async -> Result<SecureBytes, XPCSecurityError> {
    if let encryptor=service as? LegacyAdvancedEncryptor {
      let binaryData=convertToSecureBytes(data)
      let encryptedData=try await encryptor.encryptData(binaryData, keyIdentifier: keyIdentifier)
      return convertToSecureBytes(encryptedData)
    }

    // Fall back to basic encryption if advanced is not available
    let result=await encrypt(data: data)
    switch result {
      case let .success(secureBytes):
        return secureBytes
      case let .failure(error):
        throw error
    }
  }

  public func decryptData(
    _ data: SecureBytes,
    keyIdentifier: String?
  ) async -> Result<SecureBytes, XPCSecurityError> {
    if let encryptor=service as? LegacyAdvancedEncryptor {
      let binaryData=convertToSecureBytes(data)
      let decryptedData=try await encryptor.decryptData(binaryData, keyIdentifier: keyIdentifier)
      return convertToSecureBytes(decryptedData)
    }

    // Fall back to basic decryption if advanced is not available
    let result=await decrypt(data: data)
    switch result {
      case let .success(secureBytes):
        return secureBytes
      case let .failure(error):
        throw error
    }
  }

  public func hashData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    let result=await hash(data: data)
    switch result {
      case let .success(secureBytes):
        return secureBytes
      case let .failure(error):
        throw error
    }
  }

  public func signData(
    _ data: SecureBytes,
    keyIdentifier: String
  ) async -> Result<SecureBytes, XPCSecurityError> {
    if let signer=service as? LegacySigner {
      let binaryData=convertToSecureBytes(data)
      let signatureData=try await signer.signData(binaryData, keyIdentifier: keyIdentifier)
      return convertToSecureBytes(signatureData)
    }

    return .failure(.cryptoError)
  }

  public func verifySignature(
    _ signature: SecureBytes,
    for data: SecureBytes,
    keyIdentifier: String
  ) async throws -> Bool {
    if let verifier=service as? LegacyVerifier {
      let signatureSecureBytes=convertToSecureBytes(signature)
      let dataSecureBytes=convertToSecureBytes(data)
      return try await verifier.verifySignature(
        signatureSecureBytes,
        for: dataSecureBytes,
        keyIdentifier: keyIdentifier
      )
    }

    return .failure(.cryptoError)
  }
}

// MARK: - Legacy Protocol Definitions

/// Protocol for services that support ping operations
protocol PingableService {
  func ping() async -> Result<Bool, Error>
}

/// Protocol for legacy XPC base functionality
protocol LegacyXPCBase {
  func ping() async -> Result<Bool, XPCSecurityError>
  func synchroniseKeys(_ syncData: Any) async throws
}

/// Protocol for legacy encryption/decryption
protocol LegacyEncryptor {
  func encrypt(data: Any) async -> Result<Any, XPCSecurityError>
  func decrypt(data: Any) async -> Result<Any, XPCSecurityError>
  // Helper methods for type conversion
  func createSecureBytes(from bytes: [UInt8]) -> Any
  func extractBytesFromSecureBytes(_ binaryData: Any) -> SecureBytes
}

/// Protocol for legacy advanced encryption/decryption
protocol LegacyAdvancedEncryptor {
  func encryptData(_ data: Any, keyIdentifier: String?) async -> Result<Any, XPCSecurityError>
  func decryptData(_ data: Any, keyIdentifier: String?) async -> Result<Any, XPCSecurityError>
}

/// Protocol for legacy key generation
protocol LegacyKeyGenerator {
  func generateKey() async -> Result<Any, XPCSecurityError>
}

/// Protocol for legacy hashing
protocol LegacyHasher {
  func hash(data: Any) async -> Result<Any, XPCSecurityError>
}

/// Protocol for legacy random data generation
protocol LegacyRandomGenerator {
  func generateRandomData(length: Int) async -> Result<Any, XPCSecurityError>
}

/// Protocol for legacy signing
protocol LegacySigner {
  func signData(_ data: Any, keyIdentifier: String) async -> Result<Any, XPCSecurityError>
}

/// Protocol for legacy signature verification
protocol LegacyVerifier {
  func verifySignature(_ signature: Any, for data: Any, keyIdentifier: String) async
    -> Result<Bool, XPCSecurityError>
}

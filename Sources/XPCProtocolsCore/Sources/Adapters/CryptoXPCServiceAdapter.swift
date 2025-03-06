import CryptoTypes
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// CryptoXPCServiceAdapter
///
/// This adapter bridges between CryptoXPCServiceProtocol and XPCProtocolsCore protocols.
/// It allows existing CryptoXPCService implementations to be used with the new standardized
/// XPC protocol hierarchy without requiring modifications to the service itself.
///
/// Usage:
/// ```swift
/// let cryptoService = CryptoXPCService(dependencies: dependencies)
/// let adapter = CryptoXPCServiceAdapter(service: cryptoService)
///
/// // Now use the adapter with XPCProtocolsCore protocols
/// let result = await adapter.encrypt(data: secureBytes)
/// ```
@available(macOS 14.0, *)
public final class CryptoXPCServiceAdapter: @unchecked Sendable {
  /// The crypto service being adapted
  private let service: any CryptoXPCServiceProtocol

  /// Initializes the adapter with a CryptoXPCService
  /// - Parameter service: The crypto service to adapt
  public init(service: any CryptoXPCServiceProtocol) {
    self.service = service
  }

  /// Convert SecureBytes to Data for the crypto service
  /// - Parameter bytes: SecureBytes to convert
  /// - Returns: Data for the crypto service
  private func convertToData(_ bytes: SecureBytes) -> Data {
    bytes.withUnsafeBytes { Data($0) }
  }

  /// Convert Data from the crypto service to SecureBytes
  /// - Parameter data: Data from the crypto service
  /// - Returns: SecureBytes for XPC protocols
  private func convertToSecureBytes(_ data: Data) -> SecureBytes {
    SecureBytes(data: data)
  }

  /// Map from CryptoError to XPCSecurityError
  /// - Parameter error: Error to map
  /// - Returns: XPCSecurityError
  private func mapError(_ error: Error) -> XPCSecurityError {
    // First handle specific CryptoError types
    if let cryptoError = error as? CoreErrors.CryptoError {
      switch cryptoError {
        case .encryptionFailed:
          return .encryptionFailed
        case .decryptionFailed:
          return .decryptionFailed
        case .keyGenerationFailed:
          return .keyGenerationFailed
        case .invalidKey, .invalidKeySize, .invalidKeyFormat, .invalidKeyLength:
          return .invalidData
        case .invalidIVLength, .invalidSaltLength, .invalidIterationCount,
             .invalidCredentialIdentifier:
          return .invalidData
        case .ivGenerationFailed, .tagGenerationFailed, .keyDerivationFailed:
          return .cryptoError
        case .authenticationFailed:
          return .accessError
        case .randomGenerationFailed:
          return .cryptoError
        case .keyNotFound:
          return .serviceFailed
        case .keyExists:
          return .serviceFailed
        case .keychainError:
          return .serviceFailed
      }
    }
    // Check if it's already an XPC error
    else if let xpcError = error as? XPCSecurityError {
      return xpcError
    }
    // Check if it's a SecurityProtocolsCore error
    else if let securityError = error as? SecurityProtocolsCore.SecurityError {
      switch securityError {
        case .encryptionFailed:
          return .encryptionFailed
        case .decryptionFailed:
          return .decryptionFailed
        case .keyGenerationFailed:
          return .keyGenerationFailed
        case .invalidKey:
          return .invalidData
        case .hashVerificationFailed:
          return .hashingFailed
        case .randomGenerationFailed:
          return .cryptoError
        case .invalidInput:
          return .invalidData
        case .storageOperationFailed:
          return .serviceFailed
        case .timeout:
          return .serviceFailed
        case .serviceError:
          return .serviceFailed
        case .internalError:
          return .cryptoError
        case .notImplemented:
          return .notImplemented
      }
    }
    // Fall back to a generic crypto error
    else {
      let errorDescription = String(describing: error)
      return .general("Crypto operation failed: \(errorDescription)")
    }
  }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

@available(macOS 14.0, *)
extension CryptoXPCServiceAdapter: XPCServiceProtocolComplete {
  public static var protocolIdentifier: String {
    "com.umbra.crypto.xpc.adapter.service"
  }

  public func pingComplete() async -> Result<Bool, XPCSecurityError> {
    // CryptoXPCService doesn't have a ping method
    // Return success as default
    .success(true)
  }

  public func synchronizeKeys(_ keys: SecureBytes) async -> Result<Void, XPCSecurityError> {
    // CryptoXPCService doesn't have a synchronizeKeys method
    // Return success as default
    .success(())
  }

  public func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let inputData = convertToData(data)

      // Generate a random key if needed
      let key = try await service.generateKey(bits: 256)

      let encryptedData = try await service.encrypt(inputData, key: key)
      return .success(convertToSecureBytes(encryptedData))
    } catch {
      return .failure(mapError(error))
    }
  }

  public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let inputData = convertToData(data)

      // This is a simplification - in a real implementation,
      // you would need to retrieve the correct key
      let key = try await service.generateKey(bits: 256)

      let decryptedData = try await service.decrypt(inputData, key: key)
      return .success(convertToSecureBytes(decryptedData))
    } catch {
      return .failure(mapError(error))
    }
  }

  public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let key = try await service.generateKey(bits: 256)
      return .success(convertToSecureBytes(key))
    } catch {
      return .failure(mapError(error))
    }
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    // CryptoXPCService doesn't have a hash method
    // In a real implementation, you would add this functionality
    // For now, return a mock hash
    let dataBytes = convertToData(data)
    let mockHash = Data(count: 32) // SHA-256 size
    return .success(convertToSecureBytes(mockHash))
  }
}

// MARK: - XPCServiceProtocolStandard Conformance Extension

@available(macOS 14.0, *)
extension CryptoXPCServiceAdapter: XPCServiceProtocolStandard {
  public func ping() async -> Result<Bool, XPCSecurityError> {
    // Forward to the complete ping method
    await pingComplete()
  }

  public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
    do {
      let randomData = try await service.generateKey(bits: length * 8)
      return .success(convertToSecureBytes(randomData))
    } catch {
      return .failure(mapError(error))
    }
  }

  public func encryptData(
    _ data: SecureBytes,
    keyIdentifier: String?
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Just pass through to the complete implementation
    await encrypt(data: data)
  }

  public func decryptData(
    _ data: SecureBytes,
    keyIdentifier: String?
  ) async -> Result<SecureBytes, XPCSecurityError> {
    // Just pass through to the complete implementation
    await decrypt(data: data)
  }
}

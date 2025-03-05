// LegacyXPCServiceAdapter.swift
// XPCProtocolsCore
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import Foundation
import UmbraCoreTypes

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
        self.service = service
    }

    /// Map from legacy error types to XPCSecurityError
    /// - Parameter error: Legacy error
    /// - Returns: Standard XPCSecurityError
    public static func mapError(_ error: Error) -> XPCSecurityError {
        // Handle legacy SecurityError types
        if let legacyError = error as? SecurityError {
            switch legacyError {
            case .notImplemented:
                return .cryptoError
            case .invalidData:
                return .cryptoError
            case .encryptionFailed:
                return .cryptoError
            case .decryptionFailed:
                return .cryptoError
            case .keyGenerationFailed:
                return .cryptoError
            case .hashingFailed:
                return .cryptoError
            case .serviceFailed:
                return .cryptoError
            case .general:
                return .cryptoError
            case .cryptoError:
                return .cryptoError
            }
        }

        // Handle NSError
        let nsError = error as NSError
        switch nsError.domain {
        case "com.umbra.security":
            return .cryptoError
        case "com.umbra.keychain":
            return .accessError
        case "com.umbra.bookmark":
            return .bookmarkError
        default:
            return .cryptoError
        }
    }

    /// Map from XPCSecurityError to legacy SecurityError
    /// - Parameter error: Standard XPCSecurityError
    /// - Returns: Legacy SecurityError
    @available(*, deprecated, message: "Use XPCSecurityError instead")
    public static func mapToLegacyError(_ error: XPCSecurityError) -> SecurityError {
        switch error {
        case .cryptoError:
            return .encryptionFailed
        case .accessError:
            return .serviceFailed
        case .bookmarkError, .bookmarkCreationFailed, .bookmarkResolutionFailed:
            return .invalidData
        @unknown default:
            return .serviceFailed
        }
    }

    /// Convert SecureBytes to legacy BinaryData
    /// - Parameter bytes: SecureBytes to convert
    /// - Returns: Legacy BinaryData
    private func convertToBinaryData(_ bytes: SecureBytes) -> Any {
        // If the legacy service implements conversion, use that
        if let legacyEncryptor = service as? LegacyEncryptor {
            return legacyEncryptor.createBinaryData(from: bytes.withUnsafeBytes { Array($0) })
        }

        // Otherwise, just return the bytes array directly
        return bytes.withUnsafeBytes { Array($0) }
    }

    /// Convert legacy BinaryData to SecureBytes
    /// - Parameter binaryData: Legacy BinaryData to convert
    /// - Returns: SecureBytes
    private func convertToSecureBytes(_ binaryData: Any) -> SecureBytes {
        // Try to extract bytes using a protocol extension
        if let legacyEncryptor = service as? LegacyEncryptor {
            return legacyEncryptor.extractBytesFromBinaryData(binaryData)
        }

        // If we can extract the bytes directly
        if let bytesArray = binaryData as? [UInt8] {
            return SecureBytes(bytes: bytesArray)
        }

        // Default: Empty bytes if we can't convert
        return SecureBytes()
    }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolComplete {
    public static var protocolIdentifier: String {
        return "com.umbra.legacy.adapter.xpc.service"
    }

    public func pingComplete() async -> Result<Bool, XPCSecurityError> {
        // If the legacy service supports ping, use it
        if let pingable = service as? PingableService {
            let result = await pingable.ping()
            switch result {
            case .success(let value):
                return .success(value)
            case .failure(let error):
                return .failure(Self.mapError(error))
            }
        } else if let legacyBase = service as? LegacyXPCBase {
            // Try the legacy XPC base protocol
            do {
                let pingResult = try await legacyBase.ping()
                return .success(pingResult)
            } catch {
                return .failure(Self.mapError(error))
            }
        }

        // Default implementation always succeeds
        return .success(true)
    }

    public func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        if let legacyBase = service as? LegacyXPCBase {
            do {
                // Convert SecureBytes to legacy BinaryData
                let binaryData = convertToBinaryData(syncData)
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
        if let encryptor = service as? LegacyEncryptor {
            do {
                // Convert SecureBytes to legacy BinaryData
                let binaryData = convertToBinaryData(data)
                let encryptedData = try await encryptor.encrypt(data: binaryData)

                // Convert result back to SecureBytes
                let secureBytes = convertToSecureBytes(encryptedData)
                return .success(secureBytes)
            } catch {
                return .failure(Self.mapError(error))
            }
        }

        // Default implementation if not supported
        return .failure(.cryptoError)
    }

    public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        if let encryptor = service as? LegacyEncryptor {
            do {
                // Convert SecureBytes to legacy BinaryData
                let binaryData = convertToBinaryData(data)
                let decryptedData = try await encryptor.decrypt(data: binaryData)

                // Convert result back to SecureBytes
                let secureBytes = convertToSecureBytes(decryptedData)
                return .success(secureBytes)
            } catch {
                return .failure(Self.mapError(error))
            }
        }

        // Default implementation if not supported
        return .failure(.cryptoError)
    }

    public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        if let keyGenerator = service as? LegacyKeyGenerator {
            do {
                let keyData = try await keyGenerator.generateKey()
                let secureBytes = convertToSecureBytes(keyData)
                return .success(secureBytes)
            } catch {
                return .failure(Self.mapError(error))
            }
        }

        // Default implementation if not supported
        return .failure(.cryptoError)
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        if let hasher = service as? LegacyHasher {
            do {
                // Convert SecureBytes to legacy BinaryData
                let binaryData = convertToBinaryData(data)
                let hashedData = try await hasher.hash(data: binaryData)

                // Convert result back to SecureBytes
                let secureBytes = convertToSecureBytes(hashedData)
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
    public func generateRandomData(length: Int) async throws -> SecureBytes {
        if let randomGenerator = service as? LegacyRandomGenerator {
            let randomData = try await randomGenerator.generateRandomData(length: length)
            return convertToSecureBytes(randomData)
        }

        // If we don't have a legacy implementation, throw
        throw XPCSecurityError.cryptoError
    }

    public func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        if let encryptor = service as? LegacyAdvancedEncryptor {
            let binaryData = convertToBinaryData(data)
            let encryptedData = try await encryptor.encryptData(binaryData, keyIdentifier: keyIdentifier)
            return convertToSecureBytes(encryptedData)
        }

        // Fall back to basic encryption if advanced is not available
        let result = await encrypt(data: data)
        switch result {
        case .success(let secureBytes):
            return secureBytes
        case .failure(let error):
            throw error
        }
    }

    public func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        if let encryptor = service as? LegacyAdvancedEncryptor {
            let binaryData = convertToBinaryData(data)
            let decryptedData = try await encryptor.decryptData(binaryData, keyIdentifier: keyIdentifier)
            return convertToSecureBytes(decryptedData)
        }

        // Fall back to basic decryption if advanced is not available
        let result = await decrypt(data: data)
        switch result {
        case .success(let secureBytes):
            return secureBytes
        case .failure(let error):
            throw error
        }
    }

    public func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        let result = await hash(data: data)
        switch result {
        case .success(let secureBytes):
            return secureBytes
        case .failure(let error):
            throw error
        }
    }

    public func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        if let signer = service as? LegacySigner {
            let binaryData = convertToBinaryData(data)
            let signatureData = try await signer.signData(binaryData, keyIdentifier: keyIdentifier)
            return convertToSecureBytes(signatureData)
        }

        throw XPCSecurityError.cryptoError
    }

    public func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        if let verifier = service as? LegacyVerifier {
            let signatureBinaryData = convertToBinaryData(signature)
            let dataBinaryData = convertToBinaryData(data)
            return try await verifier.verifySignature(signatureBinaryData, for: dataBinaryData, keyIdentifier: keyIdentifier)
        }

        throw XPCSecurityError.cryptoError
    }
}

// MARK: - Legacy Protocol Definitions

/// Protocol for services that support ping operations
protocol PingableService {
    func ping() async -> Result<Bool, Error>
}

/// Protocol for legacy XPC base functionality
protocol LegacyXPCBase {
    func ping() async throws -> Bool
    func synchroniseKeys(_ syncData: Any) async throws
}

/// Protocol for legacy encryption/decryption
protocol LegacyEncryptor {
    func encrypt(data: Any) async throws -> Any
    func decrypt(data: Any) async throws -> Any

    // Helper methods for type conversion
    func createBinaryData(from bytes: [UInt8]) -> Any
    func extractBytesFromBinaryData(_ binaryData: Any) -> SecureBytes
}

/// Protocol for legacy advanced encryption/decryption
protocol LegacyAdvancedEncryptor {
    func encryptData(_ data: Any, keyIdentifier: String?) async throws -> Any
    func decryptData(_ data: Any, keyIdentifier: String?) async throws -> Any
}

/// Protocol for legacy key generation
protocol LegacyKeyGenerator {
    func generateKey() async throws -> Any
}

/// Protocol for legacy hashing
protocol LegacyHasher {
    func hash(data: Any) async throws -> Any
}

/// Protocol for legacy random data generation
protocol LegacyRandomGenerator {
    func generateRandomData(length: Int) async throws -> Any
}

/// Protocol for legacy signing
protocol LegacySigner {
    func signData(_ data: Any, keyIdentifier: String) async throws -> Any
}

/// Protocol for legacy signature verification
protocol LegacyVerifier {
    func verifySignature(_ signature: Any, for data: Any, keyIdentifier: String) async throws -> Bool
}

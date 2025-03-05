// CryptoXPCServiceAdapter.swift
// CryptoTypes/Adapters
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

@preconcurrency import CryptoTypesServices
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Adapter factory for creating adapters between CryptoXPCServiceProtocol and XPCProtocolsCore protocols
/// This allows existing crypto services to work with the new XPC protocol hierarchy
@available(macOS 14.0, *)
public enum CryptoXPCServiceAdapterFactory {
    /// Create an adapter that implements XPCServiceProtocolStandard from a CryptoXPCServiceProtocol
    /// - Parameter service: The crypto service to adapt
    /// - Returns: An object implementing XPCServiceProtocolStandard
    public static func createStandardAdapter(wrapping service: any CryptoXPCServiceProtocol) -> any XPCServiceProtocolStandard {
        return CryptoXPCServiceAdapter(wrapping: service)
    }
}

/// Adapter to implement XPCServiceProtocolStandard from CryptoXPCServiceProtocol
/// This allows crypto services to be used with the new XPC protocol hierarchy
@available(macOS 14.0, *)
private final class CryptoXPCServiceAdapter: XPCServiceProtocolStandard, @unchecked Sendable {
    private let service: any CryptoXPCServiceProtocol

    init(wrapping service: any CryptoXPCServiceProtocol) {
        self.service = service
    }

    // MARK: - XPCServiceProtocolBasic Methods

    /// Protocol identifier for this service
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.crypto.adapter"
    }

    /// Ping the service to test connectivity
    /// - Returns: True if the service is responding
    public func ping() async throws -> Bool {
        // Try to generate a small key as a ping test
        do {
            _ = try await service.generateKey(bits: 128)
            return true
        } catch {
            return false
        }
    }

    /// Synchronize keys across services
    /// - Parameter syncData: Key data to synchronize
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Not supported in base crypto service, would need to be implemented
        throw SecurityProtocolError.implementationMissing("synchroniseKeys is not supported by CryptoXPCService")
    }

    // MARK: - XPCServiceProtocolStandard Methods

    /// Generate random data of the specified length
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Random data
    public func generateRandomData(length: Int) async throws -> SecureBytes {
        let salt = try await service.generateSalt(length: length)
        return SecureBytes(bytes: [UInt8](salt))
    }

    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - keyIdentifier: Optional key identifier to use
    /// - Returns: Encrypted data
    public func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Generate or retrieve key based on identifier
        let key: Data
        if let keyId = keyIdentifier {
            // Retrieve stored key if identifier provided
            key = try await service.retrieveCredential(forIdentifier: keyId)
        } else {
            // Generate a temporary key if no identifier
            key = try await service.generateKey(bits: 256)
        }

        // Convert SecureBytes to Data for the service
        let dataToEncrypt = Data(data.withUnsafeBytes { Array($0) })

        // Encrypt the data
        let encryptedData = try await service.encrypt(dataToEncrypt, key: key)

        // Return the encrypted data as SecureBytes
        return SecureBytes(bytes: [UInt8](encryptedData))
    }

    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - keyIdentifier: Optional key identifier to use
    /// - Returns: Decrypted data
    public func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Get the key using the identifier
        guard let keyId = keyIdentifier else {
            throw SecurityProtocolError.implementationMissing("Key identifier is required for decryption")
        }

        // Retrieve the key
        let key = try await service.retrieveCredential(forIdentifier: keyId)

        // Convert SecureBytes to Data for the service
        let dataToDecrypt = Data(data.withUnsafeBytes { Array($0) })

        // Decrypt the data
        let decryptedData = try await service.decrypt(dataToDecrypt, key: key)

        // Return the decrypted data as SecureBytes
        return SecureBytes(bytes: [UInt8](decryptedData))
    }

    /// Hash data using the service's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hash result
    public func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        // Not directly supported by CryptoXPCServiceProtocol
        // We would implement a simple hash here if needed
        throw SecurityProtocolError.implementationMissing("Hashing is not supported by CryptoXPCService")
    }

    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: Data to sign
    ///   - keyIdentifier: Key identifier to use for signing
    /// - Returns: Signature data
    public func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        // Not directly supported by CryptoXPCServiceProtocol
        throw SecurityProtocolError.implementationMissing("Signing is not supported by CryptoXPCService")
    }

    /// Verify signature for data
    /// - Parameters:
    ///   - signature: Signature to verify
    ///   - data: Original data
    ///   - keyIdentifier: Key identifier to use for verification
    /// - Returns: True if signature is valid
    public func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        // Not directly supported by CryptoXPCServiceProtocol
        throw SecurityProtocolError.implementationMissing("Signature verification is not supported by CryptoXPCService")
    }
}

/// Extension that adds a convenience method to CryptoXPCServiceProtocol
/// to convert it to an XPCServiceProtocolStandard
@available(macOS 14.0, *)
extension CryptoXPCServiceProtocol {
    /// Convert this crypto service to an XPCServiceProtocolStandard
    /// - Returns: An adapter implementing XPCServiceProtocolStandard
    public func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
        return CryptoXPCServiceAdapterFactory.createStandardAdapter(wrapping: self)
    }
}

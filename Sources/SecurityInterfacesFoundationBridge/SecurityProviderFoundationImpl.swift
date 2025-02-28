import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityBridgeCore
import SecurityInterfacesBase
import SecurityInterfacesFoundationBase
import SecurityInterfacesProtocols
import SecurityObjCProtocols

/// This adapter class bridges between the Foundation-dependent implementation and the Foundation-free interfaces
public final class SecurityProviderFoundationAdapter {
    private let impl: any SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl

    public init(impl: any SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl) {
        self.impl = impl
    }

    // MARK: - Foundation Data Methods

    /// Encrypt Data using the provider's encryption mechanism
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: SecurityError if encryption fails
    public func encryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        // Convert DataBridge to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data.bytes)
        let nsKey = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: key.bytes)

        // Call implementation with NSData
        let encryptedNSData = try await impl.encryptData(nsData, key: nsKey)

        // Convert back to DataBridge
        return DataBridge(SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: encryptedNSData))
    }

    /// Decrypt Data using the provider's decryption mechanism
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    /// - Throws: SecurityError if decryption fails
    public func decryptData(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        // Convert DataBridge to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data.bytes)
        let nsKey = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: key.bytes)

        // Call implementation with NSData
        let decryptedNSData = try await impl.decryptData(nsData, key: nsKey)

        // Convert back to DataBridge
        return DataBridge(SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: decryptedNSData))
    }

    /// Generate a cryptographically secure random key as Data
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key as Data
    /// - Throws: SecurityError if key generation fails
    public func generateDataKey(length: Int) async throws -> DataBridge {
        let keyNSData = try await impl.generateDataKey(length: length)
        return DataBridge(SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: keyNSData))
    }

    /// Hash Data using the provider's hashing mechanism
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    /// - Throws: SecurityError if hashing fails
    public func hashData(_ data: DataBridge) async throws -> DataBridge {
        // Convert DataBridge to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data.bytes)

        // Call implementation with NSData
        let hashedNSData = try await impl.hashData(nsData)

        // Convert back to DataBridge
        return DataBridge(SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: hashedNSData))
    }

    // MARK: - Bridge Methods

    /// Convert from BinaryData to Data and encrypt
    /// - Parameters:
    ///   - data: BinaryData to encrypt
    ///   - key: Encryption key as BinaryData
    /// - Returns: Encrypted data as BinaryData
    /// - Throws: SecurityError if encryption fails
    public func encryptBinaryData(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Convert BinaryData to DataBridge
        let dataToEncrypt = DataBridge(data.bytes)
        let keyData = DataBridge(key.bytes)

        // Encrypt using Foundation implementation
        let encryptedData = try await encryptData(dataToEncrypt, key: keyData)

        // Convert back to BinaryData
        return SecurityInterfacesProtocols.BinaryData(encryptedData.bytes)
    }

    /// Convert from BinaryData to Data and decrypt
    /// - Parameters:
    ///   - data: BinaryData to decrypt
    ///   - key: Decryption key as BinaryData
    /// - Returns: Decrypted data as BinaryData
    /// - Throws: SecurityError if decryption fails
    public func decryptBinaryData(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Convert BinaryData to DataBridge
        let dataToDecrypt = DataBridge(data.bytes)
        let keyData = DataBridge(key.bytes)

        // Decrypt using Foundation implementation
        let decryptedData = try await decryptData(dataToDecrypt, key: keyData)

        // Convert back to BinaryData
        return SecurityInterfacesProtocols.BinaryData(decryptedData.bytes)
    }
}

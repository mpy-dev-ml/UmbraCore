import CoreTypes
import Foundation
import SecurityInterfacesFoundationBase
import SecurityInterfacesMinimalBridge

/// Factory implementation that creates security providers without circular dependencies
public final class SecurityProviderFactoryBridgeImpl: SecurityProviderFactoryBridge {
    /// Initialize the factory
    public init() {}

    /// Create a security provider that works with binary data
    /// - Returns: A security provider that can encrypt, decrypt, and hash binary data
    public func createBinarySecurityProvider() -> any SecurityProviderMinimalBridge {
        // Create the Foundation implementation
        let foundationImpl = DefaultSecurityProviderFoundationImpl()

        // Create a minimal adapter that doesn't depend on SecurityInterfacesFoundationBridge
        return SecurityProviderMinimalBridgeImpl(foundationImpl: foundationImpl)
    }
}

/// Implementation of SecurityProviderMinimalBridge that directly uses the Foundation implementation
/// This avoids importing SecurityInterfacesFoundationBridge to break circular dependencies
final class SecurityProviderMinimalBridgeImpl: SecurityProviderMinimalBridge {
    private let foundationImpl: SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl

    init(foundationImpl: SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl) {
        self.foundationImpl = foundationImpl
    }

    func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = data.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        let nsKey = key.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        // Encrypt using the Foundation implementation
        let encryptedData = try await foundationImpl.encryptData(nsData, key: nsKey)

        // Convert back to BinaryData
        let encryptedBytes = [UInt8](Data(referencing: encryptedData))
        return CoreTypes.BinaryData(encryptedBytes)
    }

    func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = data.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        let nsKey = key.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        // Decrypt using the Foundation implementation
        let decryptedData = try await foundationImpl.decryptData(nsData, key: nsKey)

        // Convert back to BinaryData
        let decryptedBytes = [UInt8](Data(referencing: decryptedData))
        return CoreTypes.BinaryData(decryptedBytes)
    }

    func generateKey(length: Int) async throws -> CoreTypes.BinaryData {
        // Generate key using the Foundation implementation
        let keyData = try await foundationImpl.generateDataKey(length: length)

        // Convert to BinaryData
        let keyBytes = [UInt8](Data(referencing: keyData))
        return CoreTypes.BinaryData(keyBytes)
    }

    func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = data.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        // Hash using the Foundation implementation
        let hashedData = try await foundationImpl.hashData(nsData)

        // Convert back to BinaryData
        let hashedBytes = [UInt8](Data(referencing: hashedData))
        return CoreTypes.BinaryData(hashedBytes)
    }
}

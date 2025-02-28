import CoreTypes
import Foundation
import SecurityBridgeCore
import SecurityInterfacesFoundationBase

/// Implementation of the core security provider that uses Foundation
/// This implementation directly bridges to the Foundation implementation
/// without importing SecurityInterfacesFoundationBridge
public final class SecurityProviderCoreImpl: SecurityProviderCore {
    private let foundationImpl: SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl

    /// Initialize with a Foundation implementation
    public init(foundationImpl: SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl) {
        self.foundationImpl = foundationImpl
    }

    /// Encrypt binary data
    public func encryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
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

    /// Decrypt binary data
    public func decryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
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

    /// Generate a cryptographically secure random key
    public func generateBinaryKey(length: Int) async throws -> CoreTypes.BinaryData {
        // Generate key using the Foundation implementation
        let keyData = try await foundationImpl.generateDataKey(length: length)

        // Convert to BinaryData
        let keyBytes = [UInt8](Data(referencing: keyData))
        return CoreTypes.BinaryData(keyBytes)
    }

    /// Hash binary data
    public func hashBinary(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
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

/// Factory for creating security providers
public final class SecurityProviderFactoryCoreImpl: SecurityProviderFactoryCore {
    /// Initialize the factory
    public init() {}

    /// Create a security provider that works with binary data
    public func createSecurityProvider() -> any SecurityProviderCore {
        // Create a minimal security provider that doesn't depend on Foundation
        // This is a placeholder implementation - in a real app we would use a proper implementation
        return MinimalSecurityProviderCore()
    }
}

/// Minimal implementation of SecurityProviderCore that doesn't depend on Foundation
private final class MinimalSecurityProviderCore: SecurityProviderCore {
    /// Initialize the provider
    init() {}

    /// Encrypt binary data
    func encryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // This is a placeholder implementation
        return data
    }

    /// Decrypt binary data
    func decryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // This is a placeholder implementation
        return data
    }

    /// Generate a key
    func generateBinaryKey(length: Int) async throws -> CoreTypes.BinaryData {
        // This is a placeholder implementation - in a real app we would generate a secure random key
        return CoreTypes.BinaryData([UInt8](repeating: 0, count: length))
    }

    /// Hash binary data
    func hashBinary(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // This is a placeholder implementation
        return data
    }
}

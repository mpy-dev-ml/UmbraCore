import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityBridgeCore
import SecurityInterfacesBase
import SecurityInterfacesFoundationBase

/// Adapter that converts between SecurityProviderCore and SecurityProviderFoundationAdapter
public final class SecurityProviderCoreAdapter: SecurityProviderCore {
    private let foundationAdapter: SecurityProviderFoundationImpl

    /// Initialize with a foundation adapter
    public init(foundationAdapter: SecurityProviderFoundationImpl) {
        self.foundationAdapter = foundationAdapter
    }

    /// Encrypt binary data using the foundation adapter
    public func encryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBinaryData: data)
        let nsKey = SecurityBridgeCore.DataConverter.convertToNSData(fromBinaryData: key)

        // Encrypt using the foundation adapter
        let encryptedData = try await foundationAdapter.encryptData(nsData, key: nsKey)

        // Convert back to BinaryData
        return SecurityBridgeCore.DataConverter.convertToBinaryData(fromNSData: encryptedData)
    }

    /// Decrypt binary data using the foundation adapter
    public func decryptBinary(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBinaryData: data)
        let nsKey = SecurityBridgeCore.DataConverter.convertToNSData(fromBinaryData: key)

        // Decrypt using the foundation adapter
        let decryptedData = try await foundationAdapter.decryptData(nsData, key: nsKey)

        // Convert back to BinaryData
        return SecurityBridgeCore.DataConverter.convertToBinaryData(fromNSData: decryptedData)
    }

    /// Generate a cryptographically secure random key
    public func generateBinaryKey(length: Int) async throws -> CoreTypes.BinaryData {
        // Generate key using the foundation adapter
        let keyData = try await foundationAdapter.generateDataKey(length: length)

        // Convert to BinaryData
        return SecurityBridgeCore.DataConverter.convertToBinaryData(fromNSData: keyData)
    }

    /// Hash binary data
    public func hashBinary(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Convert BinaryData to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBinaryData: data)

        // Hash using the foundation adapter
        let hashedData = try await foundationAdapter.hashData(nsData)

        // Convert back to BinaryData
        return SecurityBridgeCore.DataConverter.convertToBinaryData(fromNSData: hashedData)
    }
}

/// Factory for creating security providers from foundation adapters
public final class SecurityProviderCoreFactoryAdapter: SecurityProviderFactoryCore {
    private let foundationAdapter: SecurityProviderFoundationImpl

    /// Initialize with a foundation adapter
    public init(foundationAdapter: SecurityProviderFoundationImpl) {
        self.foundationAdapter = foundationAdapter
    }

    /// Create a security provider that works with binary data
    public func createSecurityProvider() -> any SecurityProviderCore {
        return SecurityProviderCoreAdapter(foundationAdapter: foundationAdapter)
    }
}

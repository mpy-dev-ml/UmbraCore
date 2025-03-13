import Foundation
import SecurityProtocolsCore

public extension SecurityBridge {
    /// Adapter for converting between Foundation-dependent SecurityProvider and
    /// the Foundation-free SecurityProviderProtocol
    final class SecurityProviderFoundationAdapter: Sendable {
        // MARK: - Properties

        /// The Foundation-dependent implementation
        private let implementation: FoundationSecurityProvider

        // MARK: - Initialization

        /// Initialize with a Foundation-dependent implementation
        /// - Parameter implementation: The Foundation-based implementation
        public init(implementation: FoundationSecurityProvider) {
            self.implementation = implementation
        }

        // MARK: - SecurityProviderFoundationProtocol Implementation

        /// Encrypt data using the Foundation implementation
        /// - Parameters:
        ///   - data: Data to encrypt
        ///   - key: Encryption key
        /// - Returns: Encrypted data
        public func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
            let foundationData = data.toFoundationData()
            let foundationKey = key.toFoundationData()

            let result = await implementation.cryptoService.encrypt(
                data: foundationData,
                using: foundationKey
            )

            switch result {
            case let .success(encryptedData):
                return DataBridge(encryptedData)
            case let .failure(error):
                throw SecurityBridgeErrorMapper.mapToBridgeError(error)
            }
        }

        /// Decrypt data using the Foundation implementation
        /// - Parameters:
        ///   - data: Data to decrypt
        ///   - key: Decryption key
        /// - Returns: Decrypted data
        public func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
            let foundationData = data.toFoundationData()
            let foundationKey = key.toFoundationData()

            let result = await implementation.cryptoService.decrypt(
                data: foundationData,
                using: foundationKey
            )

            switch result {
            case let .success(decryptedData):
                return DataBridge(decryptedData)
            case let .failure(error):
                throw SecurityBridgeErrorMapper.mapToBridgeError(error)
            }
        }

        /// Generate a new encryption key
        /// - Returns: The generated key
        public func generateKey() async throws -> DataBridge {
            let result = await implementation.cryptoService.generateKey()

            switch result {
            case let .success(keyData):
                return DataBridge(keyData)
            case let .failure(error):
                throw SecurityBridgeErrorMapper.mapToBridgeError(error)
            }
        }

        /// Generate secure random data
        /// - Parameter length: Length of random data to generate
        /// - Returns: Random data
        public func generateRandomData(length: Int) async throws -> DataBridge {
            let result = await implementation.cryptoService.generateRandomData(length: length)

            switch result {
            case let .success(randomData):
                return DataBridge(randomData)
            case let .failure(error):
                throw SecurityBridgeErrorMapper.mapToBridgeError(error)
            }
        }
    }
}

/// Protocol for random data generation capability
public protocol RandomDataGenerating {
    /// Generate cryptographically secure random data
    /// - Parameter length: The length in bytes of random data to generate
    /// - Returns: Random data or error
    func generateRandomData(length: Int) async -> Result<Data, Error>
}

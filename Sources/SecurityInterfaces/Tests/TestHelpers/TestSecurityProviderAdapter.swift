// DEPRECATED: // DEPRECATED: TestSecurityProviderAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import Foundation

// Import SecurityInterfaces first as it contains the protocol we need to implement
import SecurityInterfaces

// Then import the other modules we need
import ErrorHandling
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// A test-specific adapter that allows the bridge pattern to work in tests
/// This adapter mimics the real SecurityProviderAdapter but works with our
/// SecurityProviderBridge type instead of directly with SecurityProtocolsCore.
// DEPRECATED: // DEPRECATED: public final class TestSecurityProviderAdapter: SecurityInterfaces.SecurityProvider {
    // MARK: - Properties

    // DEPRECATED: private let bridge: SecurityProviderBridge
    private let service: any SecurityInterfaces.XPCServiceProtocolStandard

    // MARK: - Initialization

    public init(
        // DEPRECATED: bridge: SecurityProviderBridge,
        service: any SecurityInterfaces.XPCServiceProtocolStandard
    ) {
        self.bridge = bridge
        self.service = service
    }

    // MARK: - SecurityProvider Properties

    public var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
        bridge.cryptoService
    }

    public var keyManager: SecurityProtocolsCore.KeyManagementProtocol {
        bridge.keyManager
    }

    // MARK: - SecurityProviderProtocol Methods

    public func performSecureOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        await bridge.performSecureOperation(operation: operation, config: config)
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore
        .SecurityConfigDTO
    {
        bridge.createSecureConfig(options: options)
    }

    // MARK: - SecurityProvider Implementation

    public func getSecurityLevel() async -> Result<SecurityInterfaces.SecurityLevel, SecurityInterfacesError> {
        // For testing, return a standard security level
        .success(.standard)
    }

    public func getSecurityConfiguration() async -> Result<SecurityInterfaces.SecurityConfiguration, SecurityInterfacesError> {
        // Return a default configuration for testing
        let config = SecurityInterfaces.SecurityConfiguration(
            securityLevel: .standard,
            encryptionAlgorithm: "AES-256",
            hashAlgorithm: "SHA-256",
            options: nil
        )
        return .success(config)
    }

    public func updateSecurityConfiguration(_: SecurityInterfaces.SecurityConfiguration) async throws {
        // No-op for testing
    }

    public func getHostIdentifier() async -> Result<String, SecurityInterfacesError> {
        // For testing, just return a dummy host ID
        .success("test-host-identifier-123")
    }

    public func registerClient(bundleIdentifier _: String) async -> Result<Bool, SecurityInterfacesError> {
        // For testing, always return success
        .success(true)
    }

    public func requestKeyRotation(keyId _: String) async -> Result<Void, SecurityInterfacesError> {
        // For testing, always succeed
        .success(())
    }

    public func notifyKeyCompromise(keyId _: String) async -> Result<Void, SecurityInterfacesError> {
        // For testing, always succeed
        .success(())
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Generate simple test data
        var bytes = [UInt8](repeating: 0, count: length)
        // DEPRECATED: for i in 0 ..< length {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(SecureBytes(bytes: bytes))
    }

    public func getKeyInfo(keyId: String) async -> Result<[String: AnyObject], SecurityInterfacesError> {
        // Return some dummy key info
        let info: [String: AnyObject] = [
            "algorithm": "AES-256" as NSString,
            "created": Date() as NSDate,
            "keyId": keyId as NSString,
        ]
        return .success(info)
    }

    public func registerNotifications() async -> Result<Void, SecurityInterfacesError> {
        // No-op for testing
        .success(())
    }

    public func randomBytes(count: Int) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Reuse the generateRandomData implementation
        await generateRandomData(length: count)
    }

    public func encryptData(
        _ data: SecureBytes,
        withKey key: SecureBytes
    ) async -> Result<SecureBytes, SecurityInterfacesError> {
        // Simple mock implementation - in a real system this would use actual encryption
        var bytes = [UInt8](repeating: 0, count: data.count)
        // DEPRECATED: for i in 0 ..< data.count {
            bytes[i] = data[i] ^ (i < key.count ? key[i] : 0)
        }
        return .success(SecureBytes(bytes: bytes))
    }

    public func performSecurityOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        // Convert the data to secure bytes if provided
        var secureBytes: SecureBytes?
        if let data {
            secureBytes = SecureBytes(bytes: [UInt8](data))
        }

        // Create a configuration with the parameters
        var options = [String: Any]()
        // DEPRECATED: for (key, value) in parameters {
            options[key] = value
        }

        // Add the data to the options
        if let secureBytes {
            let config = bridge.createSecureConfig(options: options)
                .withInputData(secureBytes)

            // Perform the operation
            let result = await bridge.performSecureOperation(operation: operation, config: config)

            // Convert the result
            let metadata: [String: String] = result.error != nil ? ["error": "Operation failed"] : [:]
            return SecurityInterfaces.SecurityResult(
                success: result.success,
                data: result.data != nil ? Data([UInt8](result.data!)) : nil,
                metadata: metadata
            )
        } else {
            // No data provided
            return SecurityInterfaces.SecurityResult(
                success: true,
                data: nil,
                metadata: [:]
            )
        }
    }

    public func performSecurityOperation(
        operationName: String,
        data: Data?,
        parameters: [String: String]
    ) async throws -> SecurityInterfaces.SecurityResult {
        // Map the operation name to an enum case
        let operation: SecurityProtocolsCore.SecurityOperation = switch operationName.lowercased() {
        case "encrypt", "encryption", "symmetricencryption":
            .symmetricEncryption
        case "decrypt", "decryption", "symmetricdecryption":
            .symmetricDecryption
        case "asymmetricencrypt", "asymmetricencryption":
            .asymmetricEncryption
        case "asymmetricdecrypt", "asymmetricdecryption":
            .asymmetricDecryption
        case "hash", "hashing":
            .hashing
        case "sign", "signature":
            .signatureGeneration
        case "verify", "verification":
            .signatureVerification
        case "mac", "macgeneration":
            .macGeneration
        case "keygen", "keygeneration":
            .keyGeneration
        case "keystore", "keystorage":
            .keyStorage
        case "keyretrieve", "keyretrieval":
            .keyRetrieval
        case "keyrotate", "keyrotation":
            .keyRotation
        case "keydelete", "keydeletion":
            .keyDeletion
        case "random", "randomgeneration":
            .randomGeneration
        default:
            throw SecurityInterfacesError.operationFailed("Unknown operation: \(operationName)")
        }

        // Use the enum-based method
        return try await performSecurityOperation(
            operation: operation,
            data: data,
            parameters: parameters
        )
    }
}

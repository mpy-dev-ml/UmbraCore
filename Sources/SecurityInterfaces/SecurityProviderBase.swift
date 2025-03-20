import ErrorHandlingDomains
import SecurityProtocolsCore
import UmbraCoreTypes

/// Base protocol defining core security operations that don't require Foundation
/// @Warning: This protocol is maintained for backward compatibility only.
/// New code should use SecurityProtocolsCore.SecurityProviderProtocol instead.
@available(
    *,
    deprecated,
    message: "Use SecurityProtocolsCore.SecurityProviderProtocol instead"
)
public protocol SecurityProviderBase: Sendable {
    /// Reset all security data
    func resetSecurityData() async -> Result<Void, SecurityInterfacesError>

    /// Get the host identifier
    func getHostIdentifier() async -> Result<String, SecurityInterfacesError>

    /// Register a client application
    /// - Parameter bundleIdentifier: The bundle identifier of the client application
    func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError>

    /// Request key rotation
    /// - Parameter keyId: The ID of the key to rotate
    func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfacesError>

    /// Notify about a potentially compromised key
    /// - Parameter keyId: The ID of the compromised key
    func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfacesError>
}

/// Extension to provide adapters between the legacy and new protocols
@available(
    *,
    deprecated,
    message: "Use SecurityProtocolsCore.SecurityProviderProtocol instead"
)
extension SecurityProviderBase {
    /// Create a modern protocol adapter from this legacy protocol
    /// - Returns: An object conforming to SecurityProviderProtocol that delegates to this object
    public func asModernProvider() -> any SecurityProtocolsCore.SecurityProviderProtocol {
        SecurityProviderBaseAdapter(provider: self)
    }
}

/// Adapter that implements SecurityProviderProtocol from SecurityProviderBase
@available(
    *,
    deprecated,
    message: "Use SecurityProtocolsCore.SecurityProviderProtocol directly instead"
)
private struct SecurityProviderBaseAdapter: SecurityProtocolsCore.SecurityProviderProtocol {
    private let provider: any SecurityProviderBase

    // MARK: - Required Properties for SecurityProtocolsCore.SecurityProviderProtocol

    public var cryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
        // Create and return a dummy crypto service
        InternalDummyCryptoService()
    }

    public var keyManager: SecurityProtocolsCore.KeyManagementProtocol {
        // Create and return a dummy key manager
        DummyKeyManager()
    }

    init(provider: any SecurityProviderBase) {
        self.provider = provider
    }

    // MARK: - Required Methods for SecurityProtocolsCore.SecurityProviderProtocol

    public func performSecureOperation(
        operation _: SecurityProtocolsCore.SecurityOperation,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        // Default implementation that returns a dummy result
        SecurityProtocolsCore.SecurityResultDTO(success: true)
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityProtocolsCore
        .SecurityConfigDTO
    {
        // Create a default config with the required algorithm and key size parameters
        SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: "AES",
            keySizeInBits: 256,
            options: options as? [String: String] ?? [:]
        )
    }

    // MARK: - Methods from SecurityProviderBase

    func resetSecurityData() async -> Result<Void, SecurityInterfacesError> {
        await provider.resetSecurityData()
    }

    func getHostIdentifier() async -> Result<String, SecurityInterfacesError> {
        await provider.getHostIdentifier()
    }

    func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityInterfacesError> {
        await provider.registerClient(bundleIdentifier: bundleIdentifier)
    }

    func requestKeyRotation(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        await provider.requestKeyRotation(keyId: keyId)
    }

    func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityInterfacesError> {
        await provider.notifyKeyCompromise(keyId: keyId)
    }
}

// MARK: - Helper Classes for Adapter

/// Simple implementation of CryptoServiceProtocol for use in the adapter
private final class InternalDummyCryptoService: SecurityProtocolsCore.CryptoServiceProtocol {
    // MARK: - Required methods from CryptoServiceProtocol

    func generateKey() async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }

    func hash(data _: UmbraCoreTypes.SecureBytes) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Generate a dummy hash
        .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }

    func verify(data _: UmbraCoreTypes.SecureBytes, against _: UmbraCoreTypes.SecureBytes) async
        -> Result<Bool, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Always verify as true
        .success(true)
    }

    func encryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(data)
    }

    func decryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(data)
    }

    func encryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        publicKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(data)
    }

    func decryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        privateKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(data)
    }

    func hash(
        data _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }

    // MARK: - Additional methods

    func encrypt(data: UmbraCoreTypes.SecureBytes, using _: UmbraCoreTypes.SecureBytes) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Simple mock implementation
        .success(data)
    }

    func decrypt(data: UmbraCoreTypes.SecureBytes, using _: UmbraCoreTypes.SecureBytes) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Simple mock implementation
        .success(data)
    }

    func sign(data _: UmbraCoreTypes.SecureBytes, using _: UmbraCoreTypes.SecureBytes) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Generate a dummy signature
        .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 64)))
    }

    func verify(
        signature _: UmbraCoreTypes.SecureBytes,
        // DEPRECATED: for _: UmbraCoreTypes.SecureBytes,
        using _: UmbraCoreTypes.SecureBytes
    ) async
        -> Result<Bool, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Always verify as true
        .success(true)
    }

    func mac(data _: UmbraCoreTypes.SecureBytes, key _: UmbraCoreTypes.SecureBytes) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        // Generate a dummy MAC
        .success(UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32)))
    }

    func generateRandomData(length: Int) async
        -> Result<UmbraCoreTypes.SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
    {
        let bytes = [UInt8](repeating: 0, count: length)
        return .success(UmbraCoreTypes.SecureBytes(bytes: bytes))
    }

    // Legacy methods with DTO responses

    func encryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
    }

    func decryptSymmetric(
        data: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
    }

    func encryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        publicKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
    }

    func decryptAsymmetric(
        data: UmbraCoreTypes.SecureBytes,
        privateKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        SecurityProtocolsCore.SecurityResultDTO(success: true, data: data)
    }

    func hash(
        data _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        let hashBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32))
        return SecurityProtocolsCore.SecurityResultDTO(success: true, data: hashBytes)
    }

    func mac(
        data _: UmbraCoreTypes.SecureBytes,
        key _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        let macBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 32))
        return SecurityProtocolsCore.SecurityResultDTO(success: true, data: macBytes)
    }

    func sign(
        data _: UmbraCoreTypes.SecureBytes,
        privateKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        let signatureBytes = UmbraCoreTypes.SecureBytes(bytes: [UInt8](repeating: 0, count: 64))
        return SecurityProtocolsCore.SecurityResultDTO(success: true, data: signatureBytes)
    }

    func verify(
        signature _: UmbraCoreTypes.SecureBytes,
        data _: UmbraCoreTypes.SecureBytes,
        publicKey _: UmbraCoreTypes.SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> SecurityProtocolsCore.SecurityResultDTO {
        // Use a valid constructor and return the result as a Boolean value
        SecurityProtocolsCore.SecurityResultDTO(success: true)
    }
}

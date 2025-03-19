import CoreDTOs
import SecurityBridge
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Modern version of the SecurityProvider that uses Foundation-independent DTOs
/// This protocol provides the same functionality as SecurityProvider but with
/// types from CoreDTOs instead of Foundation-dependent types.
public protocol SecurityProviderDTO: SecurityProtocolsCore.SecurityProviderProtocol {
    /// Get the current security configuration
    /// - Returns: The active security configuration as a DTO
    func getSecurityConfigDTO() async -> Result<SecurityConfigDTO, SecurityErrorDTO>

    /// Update the security configuration
    /// - Parameter configuration: The new configuration to apply
    /// - Returns: Success or an error DTO describing the failure
    func updateSecurityConfigDTO(_ configuration: SecurityConfigDTO) async -> Result<Void, SecurityErrorDTO>

    /// Get the host identifier
    /// - Returns: The host identifier or an error
    func getHostIdentifier() async -> Result<String, SecurityErrorDTO>

    /// Register a client with the security provider
    /// - Parameter bundleIdentifier: The bundle identifier of the client
    /// - Returns: Success or an error
    func registerClient(bundleIdentifier: String) async -> Result<Bool, SecurityErrorDTO>

    /// Request key rotation for the specified key
    /// - Parameter keyId: The key identifier
    /// - Returns: Success or an error
    func requestKeyRotation(keyId: String) async -> Result<Void, SecurityErrorDTO>

    /// Notify that a key has been compromised
    /// - Parameter keyId: The key identifier
    /// - Returns: Success or an error
    func notifyKeyCompromise(keyId: String) async -> Result<Void, SecurityErrorDTO>

    /// Generate random data of the specified length
    /// - Parameter length: The number of bytes to generate
    /// - Returns: The random data or an error
    func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityErrorDTO>

    /// Generate random bytes of the specified length
    /// - Parameter count: The number of bytes to generate
    /// - Returns: The random bytes or an error
    func randomBytes(count: Int) async -> Result<SecureBytes, SecurityErrorDTO>

    /// Encrypt data with the specified key
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - key: The key to use for encryption
    /// - Returns: The encrypted data or an error
    func encryptData(_ data: SecureBytes, withKey key: SecureBytes) async
        -> Result<SecureBytes, SecurityErrorDTO>

    /// Perform a security operation using a DTO-based approach
    /// - Parameters:
    ///   - operation: The operation to perform
    ///   - data: The input data for the operation
    ///   - parameters: Additional parameters for the operation
    /// - Returns: Result containing the outcome of the operation or an error
    func performSecurityOperationDTO(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, SecurityErrorDTO>

    /// Perform a security operation with a string operation name
    /// - Parameters:
    ///   - operationName: The name of the operation to perform
    ///   - data: The input data for the operation
    ///   - parameters: Additional parameters for the operation
    /// - Returns: Result containing the outcome of the operation or an error
    func performSecurityOperationDTO(
        operationName: String,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, SecurityErrorDTO>
}

/// Extension to provide default implementations for backward compatibility
public extension SecurityProviderDTO {
    func getSecurityConfiguration() async -> Result<SecurityConfiguration, SecurityInterfacesError> {
        let result = await getSecurityConfigDTO()
        switch result {
        case let .success(dto):
            return .success(SecurityDTOAdapter.fromDTO(dto))
        case let .failure(errorDTO):
            return .failure(SecurityDTOAdapter.fromDTO(errorDTO))
        }
    }

    func updateSecurityConfiguration(_ configuration: SecurityConfiguration) async throws {
        let dto = SecurityDTOAdapter.toDTO(configuration)
        let result = await updateSecurityConfigDTO(dto)
        if case let .failure(errorDTO) = result {
            throw SecurityDTOAdapter.fromDTO(errorDTO)
        }
    }

    func performSecurityOperation(
        operation: SecurityProtocolsCore.SecurityOperation,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, SecurityErrorDTO> {
        await performSecurityOperationDTO(
            operation: operation,
            data: data,
            parameters: parameters
        )
    }

    func performSecurityOperation(
        operationName: String,
        data: SecureBytes?,
        parameters: [String: String]
    ) async -> Result<SecureBytes, SecurityErrorDTO> {
        await performSecurityOperationDTO(
            operationName: operationName,
            data: data,
            parameters: parameters
        )
    }
}

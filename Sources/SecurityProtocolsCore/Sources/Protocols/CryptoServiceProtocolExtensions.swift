import UmbraCoreTypes
import ErrorHandling
import ErrorHandlingDomains

// MARK: - DTO Extensions for CryptoServiceProtocol
/// These extensions provide DTO-based versions of the CryptoServiceProtocol methods
/// to provide a consistent interface with SecurityProvider
public extension CryptoServiceProtocol {
    /// Encrypt data using symmetric encryption (SecurityResultDTO version)
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Key to use for encryption
    ///   - config: Configuration options
    /// - Returns: Result as SecurityResultDTO
    func encryptSymmetricDTO(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        let result = await encryptSymmetric(
            data: data,
            key: key,
            config: config
        )
        
        switch result {
        case .success(let encryptedData):
            return SecurityResultDTO(data: encryptedData)
        case .failure(let error):
            return SecurityResultDTO(success: false, error: error)
        }
    }
    
    /// Decrypt data using symmetric encryption (SecurityResultDTO version)
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Key to use for decryption
    ///   - config: Configuration options
    /// - Returns: Result as SecurityResultDTO
    func decryptSymmetricDTO(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        let result = await decryptSymmetric(
            data: data,
            key: key,
            config: config
        )
        
        switch result {
        case .success(let decryptedData):
            return SecurityResultDTO(data: decryptedData)
        case .failure(let error):
            return SecurityResultDTO(success: false, error: error)
        }
    }
    
    /// Hash data with configuration parameters (SecurityResultDTO version)
    /// - Parameters:
    ///   - data: Data to hash
    ///   - config: Configuration options
    /// - Returns: Result as SecurityResultDTO
    func hashDTO(
        data: SecureBytes,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        let result = await hash(
            data: data,
            config: config
        )
        
        switch result {
        case .success(let hashValue):
            return SecurityResultDTO(data: hashValue)
        case .failure(let error):
            return SecurityResultDTO(success: false, error: error)
        }
    }
}

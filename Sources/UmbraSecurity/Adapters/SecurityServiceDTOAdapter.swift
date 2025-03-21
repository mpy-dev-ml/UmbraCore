import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityBridgeTypes
import UmbraCoreTypes

/// Protocol for Foundation-independent security service operations
public protocol SecurityServiceDTOProtocol {
    /// Generate random bytes
    /// - Parameter count: Number of bytes to generate
    /// - Returns: A result containing the random bytes or an error
    func generateRandomBytes(count: Int) -> OperationResultDTO<[UInt8]>
    
    /// Generate a secure token
    /// - Parameter byteCount: Number of bytes in the token
    /// - Returns: A result containing the token as a hex string or an error
    func generateSecureToken(byteCount: Int) -> OperationResultDTO<String>
    
    /// Hash data using the specified algorithm
    /// - Parameters:
    ///   - data: Data to hash
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the hash or an error
    func hashData(_ data: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]>
    
    /// Encrypt data using the specified key and algorithm
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the encrypted data or an error
    func encrypt(_ data: [UInt8], key: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]>
    
    /// Decrypt data using the specified key and algorithm
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the decrypted data or an error
    func decrypt(_ data: [UInt8], key: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]>
}

/// Adapter for SecurityService that provides a Foundation-independent interface
public final class SecurityServiceDTOAdapter: SecurityServiceDTOProtocol {
    // MARK: - Properties
    
    /// The underlying security service
    private let securityService: SecurityService
    
    // MARK: - Initialization
    
    /// Initialize with a security service
    /// - Parameter securityService: The security service to adapt
    public init(securityService: SecurityService = SecurityService.shared) {
        self.securityService = securityService
    }
    
    // MARK: - SecurityServiceDTOProtocol Implementation
    
    /// Generate random bytes
    /// - Parameter count: Number of bytes to generate
    /// - Returns: A result containing the random bytes or an error
    public func generateRandomBytes(count: Int) -> OperationResultDTO<[UInt8]> {
        do {
            let bytes = try securityService.generateRandomBytes(count: count)
            return .success(bytes)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    /// Generate a secure token
    /// - Parameter byteCount: Number of bytes in the token
    /// - Returns: A result containing the token as a hex string or an error
    public func generateSecureToken(byteCount: Int) -> OperationResultDTO<String> {
        do {
            let token = try securityService.generateSecureToken(byteCount: byteCount)
            return .success(token)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    /// Hash data using the specified algorithm
    /// - Parameters:
    ///   - data: Data to hash
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the hash or an error
    public func hashData(_ data: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]> {
        do {
            let algorithm = mapHashAlgorithm(from: config)
            let hash = try securityService.hashData(Data(data), algorithm: algorithm)
            return .success([UInt8](hash))
        } catch {
            return .failure(mapError(error))
        }
    }
    
    /// Encrypt data using the specified key and algorithm
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the encrypted data or an error
    public func encrypt(_ data: [UInt8], key: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]> {
        do {
            let encryptedData = try securityService.encrypt(data, key: key)
            return .success(encryptedData)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    /// Decrypt data using the specified key and algorithm
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    ///   - config: Configuration with algorithm and options
    /// - Returns: A result containing the decrypted data or an error
    public func decrypt(_ data: [UInt8], key: [UInt8], config: SecurityConfigDTO) -> OperationResultDTO<[UInt8]> {
        do {
            let decryptedData = try securityService.decrypt(data, key: key)
            return .success(decryptedData)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Map a hash algorithm from configuration
    /// - Parameter config: The security configuration
    /// - Returns: The hash algorithm
    private func mapHashAlgorithm(from config: SecurityConfigDTO) -> SecurityService.HashAlgorithm {
        // Default to SHA256 if not specified
        guard let algorithmName = config.options["algorithm"] else {
            return .sha256
        }
        
        switch algorithmName.lowercased() {
        case "sha1": return .sha1
        case "sha224": return .sha224
        case "sha384": return .sha384
        case "sha512": return .sha512
        case "md5": return .md5
        default: return .sha256
        }
    }
    
    /// Map errors to operation failure
    /// - Parameter error: The error to map
    /// - Returns: An operation failure
    private func mapError(_ error: Error) -> OperationResultDTO<[UInt8]>.Failure {
        if let securityError = error as? UmbraErrors.Security.Core {
            return .init(error: mapSecurityError(securityError))
        } else {
            return .init(error: SecurityErrorDTO(
                code: -1,
                domain: "security.service",
                message: "Security operation failed: \(error.localizedDescription)",
                details: [:]
            ))
        }
    }
    
    /// Map security errors to DTOs
    /// - Parameter error: The security error to map
    /// - Returns: A security error DTO
    private func mapSecurityError(_ error: UmbraErrors.Security.Core) -> SecurityErrorDTO {
        switch error {
        case .cryptoOperationFailed(let operation, let reason):
            return SecurityErrorDTO(
                code: 1001,
                domain: "security.crypto",
                message: "Crypto operation failed: \(operation)",
                details: ["reason": reason]
            )
        case .internalError(let reason):
            return SecurityErrorDTO(
                code: 1002,
                domain: "security.service",
                message: "Internal error",
                details: ["reason": reason]
            )
        case .invalidInputData(let context):
            return SecurityErrorDTO(
                code: 1003,
                domain: "security.service",
                message: "Invalid input data",
                details: ["context": context]
            )
        case .invalidOperation(let operation, let reason):
            return SecurityErrorDTO(
                code: 1004,
                domain: "security.service",
                message: "Invalid operation: \(operation)",
                details: ["reason": reason]
            )
        case .secureStorageFailed(let operation, let reason):
            return SecurityErrorDTO(
                code: 1005,
                domain: "security.storage",
                message: "Secure storage failed: \(operation)",
                details: ["reason": reason]
            )
        default:
            return SecurityErrorDTO(
                code: 1000,
                domain: "security.service",
                message: "Unknown security error",
                details: ["description": error.localizedDescription]
            )
        }
    }
}

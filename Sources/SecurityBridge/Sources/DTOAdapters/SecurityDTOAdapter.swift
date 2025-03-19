import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains

/// SecurityDTOAdapter supports conversions between various error domains and configurations in the
/// security subsystem and their Foundation-independent DTO representations.
public enum SecurityDTOAdapter {
    // Type aliases for clarity and to avoid ambiguity
    public typealias ConfigDTO = CoreDTOs.SecurityConfigDTO
    public typealias ErrorDTO = CoreDTOs.SecurityErrorDTO
    public typealias SecurityError = UmbraErrors.Security.Core

    // MARK: - Error Conversions
    
    /// Convert UmbraErrors.Security to SecurityErrorDTO
    ///
    /// - Parameter error: The UmbraErrors.Security to convert
    /// - Returns: A SecurityErrorDTO with equivalent information
    public static func toDTO(error: SecurityError) -> ErrorDTO {
        let details: [String: String] = error.userInfo.compactMapValues { value in
            if let stringValue = value as? String {
                return stringValue
            } else if let intValue = value as? Int {
                return String(intValue)
            } else if let boolValue = value as? Bool {
                return String(boolValue)
            } else if let doubleValue = value as? Double {
                return String(doubleValue)
            } else {
                return String(describing: value)
            }
        }
        
        switch error {
        case .encryptionFailed(let reason):
            return ErrorDTO.encryptionError(message: reason, details: details)
            
        case .decryptionFailed(let reason):
            return ErrorDTO.decryptionError(message: reason, details: details)
            
        case .hashingFailed(let reason):
            return ErrorDTO.keyError(message: reason, details: details)
            
        case .signatureInvalid(let reason):
            return ErrorDTO.keyError(message: reason, details: details)
            
        case .secureStorageFailed(let operation, let reason):
            var storageDetails = details
            storageDetails["operation"] = operation
            return ErrorDTO.storageError(message: reason, details: storageDetails)
            
        case .policyViolation(let policy, let reason):
            var policyDetails = details
            policyDetails["policy"] = policy
            return ErrorDTO(
                code: 1006,
                domain: "security",
                message: reason,
                details: policyDetails
            )
            
        case .internalError(let reason):
            return ErrorDTO(
                code: 1000,
                domain: "security",
                message: reason,
                details: details
            )
            
        default:
            return ErrorDTO(
                code: 9999,
                domain: "security.general",
                message: String(describing: error),
                details: details
            )
        }
    }
    
    /// Convert SecurityErrorDTO to UmbraErrors.Security
    ///
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A UmbraErrors.Security with equivalent information
    public static func fromDTO(error dto: ErrorDTO) -> SecurityError {
        // Map based on the error code and domain
        switch (dto.code, dto.domain) {
        case (1001, _):
            return .encryptionFailed(reason: dto.message)
            
        case (1002, _):
            return .decryptionFailed(reason: dto.message)
            
        case (1003, _):
            return .hashingFailed(reason: dto.message)
            
        case (1004, _):
            let operation = dto.details["operation"] ?? "unknown"
            return .secureStorageFailed(operation: operation, reason: dto.message)
            
        case (1005, _):
            return .signatureInvalid(reason: dto.message)
            
        case (1006, _):
            let policy = dto.details["policy"] ?? "unknown"
            return .policyViolation(policy: policy, reason: dto.message)
            
        default:
            return .internalError(reason: dto.message)
        }
    }
    
    // MARK: - Configuration Conversions
    
    /// Converts from a SecurityConfigDTO to a SecurityConfigDTO (pass-through for API consistency)
    ///
    /// - Parameter config: The SecurityConfigDTO to process
    /// - Returns: The unchanged SecurityConfigDTO
    public static func keyConfigFromDTO(config dto: ConfigDTO) -> ConfigDTO {
        dto
    }
    
    /// Converts from a SecurityConfigDTO to a SecurityConfigDTO (pass-through for API consistency)
    ///
    /// - Parameter config: The SecurityConfigDTO to process
    /// - Returns: The unchanged SecurityConfigDTO
    public static func encryptionConfigFromDTO(config dto: ConfigDTO) -> ConfigDTO {
        dto
    }
}

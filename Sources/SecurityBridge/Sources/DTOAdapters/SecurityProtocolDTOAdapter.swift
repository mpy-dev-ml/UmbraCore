import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains

/// SecurityProtocolDTOAdapter enables conversion between protocol-specific types
/// and CoreDTOs types for security operations.
public enum SecurityProtocolDTOAdapter {
    // Type aliases for clarity and to avoid ambiguity
    public typealias ConfigDTO = CoreDTOs.SecurityConfigDTO
    public typealias ErrorDTO = CoreDTOs.SecurityErrorDTO
    public typealias ProtocolConfigDTO = SecurityProtocolsCore.SecurityConfigDTO
    public typealias SecurityCoreError = UmbraErrors.Security.Core
    public typealias SecurityProtocolError = UmbraErrors.Security.Protocols
    
    // MARK: - Protocol Config Conversions
    
    /// Convert from CoreDTOs.SecurityConfigDTO to SecurityProtocolsCore.SecurityConfigDTO
    ///
    /// - Parameter config: The ConfigDTO to convert
    /// - Returns: A SecurityProtocolsCore.SecurityConfigDTO instance
    public static func toProtocolConfig(config: ConfigDTO) -> ProtocolConfigDTO {
        // Extract algorithm details
        let algorithm = config.algorithm
        let keySizeInBits = config.keySizeInBits
        
        // Extract all options as a dictionary
        let options = config.options
        
        // Extract input data if available
        let inputDataBytes = config.inputData
        let inputSecureBytes: SecureBytes? = inputDataBytes != nil ? SecureBytes(bytes: inputDataBytes!) : nil
        
        // Create and return the protocol config
        return ProtocolConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySizeInBits,
            options: options,
            inputData: inputSecureBytes
        )
    }
    
    /// Convert from SecurityProtocolsCore.SecurityConfigDTO to CoreDTOs.SecurityConfigDTO
    ///
    /// - Parameter protocolConfig: The SecurityProtocolsCore.SecurityConfigDTO to convert
    /// - Returns: A ConfigDTO instance
    public static func fromProtocolConfig(protocolConfig: ProtocolConfigDTO) -> ConfigDTO {
        // Extract input data bytes if available
        var inputDataBytes: [UInt8]?
        if let secureBytes = protocolConfig.inputData {
            inputDataBytes = Array(secureBytes)
        }
        
        // Create and return the CoreDTOs config
        return ConfigDTO(
            algorithm: protocolConfig.algorithm,
            keySizeInBits: protocolConfig.keySizeInBits,
            options: protocolConfig.options,
            inputData: inputDataBytes
        )
    }
    
    // MARK: - Error Conversions
    
    /// Convert a SecurityProtocolsCore error to a SecurityErrorDTO
    ///
    /// - Parameter error: The error from SecurityProtocolsCore
    /// - Returns: A SecurityErrorDTO representation
    public static func toDTO(error: Error) -> ErrorDTO {
        // Handle UmbraErrors.Security.Core errors
        if let coreError = error as? SecurityCoreError {
            return SecurityDTOAdapter.toDTO(error: coreError)
        }
        
        // Handle UmbraErrors.Security.Protocols errors
        if let protocolError = error as? SecurityProtocolError {
            switch protocolError {
            case .encryptionFailed(let reason):
                return ErrorDTO.encryptionError(message: reason)
                
            case .decryptionFailed(let reason):
                return ErrorDTO.decryptionError(message: reason)
                
            case .invalidFormat(let reason):
                return ErrorDTO(
                    code: 1001,
                    domain: "security.protocol",
                    message: reason,
                    details: [:]
                )
                
            case .unsupportedOperation(let name):
                return ErrorDTO(
                    code: 1002,
                    domain: "security.protocol",
                    message: "Operation not supported: \(name)",
                    details: ["operation": name]
                )
                
            case .invalidInput(let reason):
                return ErrorDTO(
                    code: 1007,
                    domain: "security.protocol",
                    message: "Invalid input: \(reason)",
                    details: ["details": reason]
                )
                
            case .internalError(let reason):
                return ErrorDTO(
                    code: 1006,
                    domain: "security.protocol",
                    message: reason,
                    details: [:]
                )
                
            default:
                return ErrorDTO(
                    code: 1000,
                    domain: "security.protocol",
                    message: String(describing: protocolError),
                    details: [:]
                )
            }
        }
        
        // Generic error handling
        return ErrorDTO(
            code: -1,
            domain: "security.unknown",
            message: error.localizedDescription,
            details: [:]
        )
    }
    
    /// Convert a SecurityErrorDTO to a SecurityProtocolError
    ///
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A UmbraErrors.Security.Protocols error
    public static func fromDTO(error dto: ErrorDTO) -> SecurityProtocolError {
        // Map based on domain and code
        switch (dto.domain, dto.code) {
        case (_, 1001):
            return .invalidFormat(reason: dto.message)
            
        case (_, 1002):
            return .unsupportedOperation(name: dto.details["operation"] ?? "unknown")
            
        case (_, 1007):
            return .invalidInput(dto.message)
            
        case (_, 1008):
            return .encryptionFailed(dto.message)
            
        case (_, 1009):
            return .decryptionFailed(dto.message)
            
        case (_, 1006):
            return .internalError(dto.message)
            
        default:
            return .serviceError(dto.message)
        }
    }
}

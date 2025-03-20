import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

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
    // DEPRECATED: public static func toDTO(error: Error) -> ErrorDTO {
        // Handle UmbraErrors.Security.Core errors
        // DEPRECATED: if let coreError = error as? SecurityCoreError {
            // DEPRECATED: return SecurityDTOAdapter.toDTO(error: coreError)
        }

        // Handle UmbraErrors.Security.Protocols errors
        // DEPRECATED: if let protocolError = error as? SecurityProtocolError {
            switch protocolError {
            case let .encryptionFailed(reason):
                return ErrorDTO.encryptionError(message: reason)

            case let .decryptionFailed(reason):
                return ErrorDTO.decryptionError(message: reason)

            case let .invalidFormat(reason):
                return ErrorDTO(
                    code: 1001,
                    domain: "security.protocol",
                    message: reason,
                    details: [:]
                )

            case let .unsupportedOperation(name):
                return ErrorDTO(
                    code: 1002,
                    domain: "security.protocol",
                    message: "Operation not supported: \(name)",
                    details: ["operation": name]
                )

            case let .invalidInput(reason):
                return ErrorDTO(
                    code: 1007,
                    domain: "security.protocol",
                    message: "Invalid input: \(reason)",
                    details: ["details": reason]
                )

            case let .internalError(reason):
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
            // DEPRECATED: message: error.localizedDescription,
            details: [:]
        )
    }

    /// Convert a SecurityErrorDTO to a SecurityProtocolError
    ///
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A UmbraErrors.Security.Protocols error
    // DEPRECATED: public static func fromDTO(error dto: ErrorDTO) -> SecurityProtocolError {
        // Map based on domain and code
        switch (dto.domain, dto.code) {
        case (_, 1001):
            .invalidFormat(reason: dto.message)

        case (_, 1002):
            .unsupportedOperation(name: dto.details["operation"] ?? "unknown")

        case (_, 1007):
            .invalidInput(dto.message)

        case (_, 1008):
            .encryptionFailed(dto.message)

        case (_, 1009):
            .decryptionFailed(dto.message)

        case (_, 1006):
            .internalError(dto.message)

        default:
            .serviceError(dto.message)
        }
    }
}

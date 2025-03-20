// DEPRECATED: SecurityDTOAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

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
                stringValue
            } else if let intValue = value as? Int {
                String(intValue)
            } else if let boolValue = value as? Bool {
                String(boolValue)
            } else if let doubleValue = value as? Double {
                String(doubleValue)
            } else {
                String(describing: value)
            }
        }

        switch error {
        case let .encryptionFailed(reason):
            return ErrorDTO.encryptionError(message: reason, details: details)

        case let .decryptionFailed(reason):
            return ErrorDTO.decryptionError(message: reason, details: details)

        case let .hashingFailed(reason):
            return ErrorDTO.keyError(message: reason, details: details)

        case let .signatureInvalid(reason):
            return ErrorDTO.keyError(message: reason, details: details)

        case let .secureStorageFailed(operation, reason):
            var storageDetails = details
            storageDetails["operation"] = operation
            return ErrorDTO.storageError(message: reason, details: storageDetails)

        case let .policyViolation(policy, reason):
            var policyDetails = details
            policyDetails["policy"] = policy
            return ErrorDTO(
                code: 1_006,
                domain: "security",
                message: reason,
                details: policyDetails
            )

        case let .internalError(reason):
            return ErrorDTO(
                code: 1_000,
                domain: "security",
                message: reason,
                details: details
            )

        default:
            return ErrorDTO(
                code: 9_999,
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
        case (1_001, _):
            return .encryptionFailed(reason: dto.message)

        case (1_002, _):
            return .decryptionFailed(reason: dto.message)

        case (1_003, _):
            return .hashingFailed(reason: dto.message)

        case (1_004, _):
            let operation = dto.details["operation"] ?? "unknown"
            return .secureStorageFailed(operation: operation, reason: dto.message)

        case (1_005, _):
            return .signatureInvalid(reason: dto.message)

        case (1_006, _):
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

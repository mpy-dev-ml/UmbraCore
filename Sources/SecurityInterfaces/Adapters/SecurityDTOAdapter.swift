import CoreDTOs
import CoreErrors
import Foundation
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Adapters for converting between Security module's types and Foundation-independent CoreDTOs
public enum SecurityDTOAdapter {
    // MARK: - SecurityConfiguration <-> SecurityConfigDTO

    /// Convert a SecurityConfiguration to a SecurityConfigDTO
    /// - Parameter config: The SecurityConfiguration to convert
    /// - Returns: A Foundation-independent SecurityConfigDTO
    public static func toDTO(_ config: SecurityConfiguration) -> CoreDTOs.SecurityConfigDTO {
        // Determine key size based on security level
        let keySizeInBits: Int
        switch config.securityLevel {
        case .basic:
            keySizeInBits = 128
        case .standard:
            keySizeInBits = 256
        case .advanced:
            keySizeInBits = 384
        case .maximum:
            keySizeInBits = 512
        }

        // Create options dictionary
        var options = config.options ?? [:]

        // Add algorithm-specific data
        options["hashAlgorithm"] = config.hashAlgorithm

        return CoreDTOs.SecurityConfigDTO(
            algorithm: config.encryptionAlgorithm,
            keySizeInBits: keySizeInBits,
            options: options
        )
    }

    /// Convert a SecurityConfigDTO to a SecurityConfiguration
    /// - Parameter dto: The SecurityConfigDTO to convert
    /// - Returns: A SecurityConfiguration compatible with the existing API
    public static func fromDTO(_ dto: CoreDTOs.SecurityConfigDTO) -> SecurityConfiguration {
        // Determine security level based on key size
        let securityLevel: SecurityLevel
        switch dto.keySizeInBits {
        case ..<192:
            securityLevel = .basic
        case 192 ..< 384:
            securityLevel = .standard
        case 384 ..< 512:
            securityLevel = .advanced
        default:
            securityLevel = .maximum
        }

        // Extract hash algorithm from options or use default
        let hashAlgorithm = dto.options["hashAlgorithm"] ?? "SHA-256"

        // Create filtered options without the hash algorithm
        var filteredOptions = dto.options
        filteredOptions.removeValue(forKey: "hashAlgorithm")

        return SecurityConfiguration(
            securityLevel: securityLevel,
            encryptionAlgorithm: dto.algorithm,
            hashAlgorithm: hashAlgorithm,
            options: filteredOptions
        )
    }

    // MARK: - SecurityInterfacesError <-> SecurityErrorDTO

    /// Convert a SecurityInterfacesError to a SecurityErrorDTO
    /// - Parameter error: The SecurityInterfacesError to convert
    /// - Returns: A Foundation-independent SecurityErrorDTO
    public static func toDTO(_ error: SecurityInterfacesError) -> CoreDTOs.SecurityErrorDTO {
        switch error {
        case let .bookmarkCreationFailed(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1_001,
                domain: "security.bookmark",
                message: "Failed to create bookmark for \(path)",
                details: ["path": path]
            )
        case .bookmarkResolutionFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1_002,
                domain: "security.bookmark",
                message: "Failed to resolve bookmark",
                details: [:]
            )
        case let .bookmarkStale(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1_003,
                domain: "security.bookmark",
                message: "Bookmark is stale for \(path)",
                details: ["path": path]
            )
        case let .bookmarkNotFound(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1_004,
                domain: "security.bookmark",
                message: "Bookmark not found for \(path)",
                details: ["path": path]
            )
        case let .resourceAccessFailed(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1_005,
                domain: "security.resource",
                message: "Failed to access resource at \(path)",
                details: ["path": path]
            )
        case .randomGenerationFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1_006,
                domain: "security.crypto",
                message: "Random generation failed",
                details: [:]
            )
        case let .authorizationFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1_007,
                domain: "security.auth",
                message: "Authorization failed: \(reason)",
                details: ["reason": reason]
            )
        case .timeout:
            CoreDTOs.SecurityErrorDTO(
                code: 1_008,
                domain: "security.service",
                message: "Operation timed out",
                details: [:]
            )
        case let .securityViolation(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1_009,
                domain: "security.violation",
                message: "Security violation detected",
                details: ["details": details]
            )
        case .serviceNotAvailable:
            CoreDTOs.SecurityErrorDTO(
                code: 1_010,
                domain: "security.service",
                message: "Security service not available",
                details: [:]
            )
        case let .keyError(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1_011,
                domain: "security.key",
                message: "Key operation failed",
                details: ["details": details]
            )
        case let .internalError(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1_012,
                domain: "security.internal",
                message: "Internal error: \(reason)",
                details: ["reason": reason]
            )
        case let .wrapped(error):
            CoreDTOs.SecurityErrorDTO(
                code: 1_013,
                domain: "security.wrapped",
                message: "Wrapped error: \(error.localizedDescription)",
                details: [:]
            )
        case let .operationFailed(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1_100,
                domain: "security.operation",
                message: message,
                details: [:]
            )
        case .encryptionFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1_200,
                domain: "security.crypto",
                message: "Encryption operation failed",
                details: [:]
            )
        case .decryptionFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1_201,
                domain: "security.crypto",
                message: "Decryption operation failed",
                details: [:]
            )
        case .keyManagementFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1_202,
                domain: "security.key",
                message: "Key management operation failed",
                details: [:]
            )
        case let .invalidParameters(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1_203,
                domain: "security.params",
                message: message,
                details: [:]
            )
        case .unknownError:
            CoreDTOs.SecurityErrorDTO(
                code: 9_999,
                domain: "security.unknown",
                message: "Unknown security error",
                details: [:]
            )
        }
    }

    /// Convert a SecurityErrorDTO to a SecurityInterfacesError
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A SecurityInterfacesError compatible with the existing API
    public static func fromDTO(_ dto: CoreDTOs.SecurityErrorDTO) -> SecurityInterfacesError {
        // Determine the domain category
        let domainParts = dto.domain.split(separator: ".")
        let category = domainParts.count > 1 ? String(domainParts[1]) : dto.domain

        switch category {
        case "bookmark":
            if let path = dto.details["path"] {
                switch dto.code {
                case 1_001:
                    return .bookmarkCreationFailed(path: path)
                case 1_003:
                    return .bookmarkStale(path: path)
                case 1_004:
                    return .bookmarkNotFound(path: path)
                default:
                    return .bookmarkError(dto.message)
                }
            } else {
                return dto.code == 1_002 ? .bookmarkResolutionFailed : .bookmarkError(dto.message)
            }

        case "resource":
            if let path = dto.details["path"] {
                return .resourceAccessFailed(path: path)
            } else {
                return .accessError(dto.message)
            }

        case "crypto":
            let reason = dto.details["reason"] ?? dto.message
            switch dto.code {
            case 1_006:
                return .randomGenerationFailed
            case 1_007:
                return .hashingFailed
            case 1_013:
                return .encryptionFailed(reason: reason)
            case 1_014:
                return .decryptionFailed(reason: reason)
            case 1_015:
                return .signatureFailed(reason: reason)
            case 1_016:
                return .verificationFailed(reason: reason)
            case 1_017:
                return .keyGenerationFailed(reason: reason)
            default:
                return .operationFailed(dto.message)
            }

        case "credential":
            return .itemNotFound

        case "serialization":
            return .serializationFailed(reason: dto.details["reason"] ?? dto.message)

        case "auth":
            return .authenticationFailed

        case "parameters":
            return .invalidParameters(dto.details["details"] ?? dto.message)

        default:
            if dto.domain.hasPrefix("security.core") {
                // Try to convert back to a CoreError
                if let rawCode = dto.details["raw_code"], let _ = Int(rawCode),
                   let _ = dto.details["raw_domain"] {
                    let coreError = UmbraErrors.Security.Core.internalError(reason: dto.message)
                    return .wrapped(coreError)
                }
            }
            return .unknown(reason: dto.message)
        }
    }

    // MARK: - SecurityError <-> SecurityErrorDTO

    /// Convert a CoreErrors.SecurityError to a SecurityErrorDTO
    /// - Parameter error: The SecurityError to convert
    /// - Returns: A Foundation-independent SecurityErrorDTO
    public static func toDTO(_ error: CoreErrors.SecurityError) -> CoreDTOs.SecurityErrorDTO {
        // Convert the SecurityError to a SecurityErrorDTO
        let interfacesError = SecurityProviderUtils.convertError(error)
        return toDTO(interfacesError)
    }

    // MARK: - XPC SecurityError <-> SecurityErrorDTO

    /// Convert a SecurityErrorDTO to a XPC SecurityError
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A XPC SecurityError compatible with the existing API
    public static func toXPCError(_ dto: CoreDTOs.SecurityErrorDTO) -> SecurityInterfacesError {
        if dto.domain.hasPrefix("xpc.") {
            switch dto.code {
            // Operation failures
            case 2_001:
                return .operationFailed("Service unavailable")
            case 2_002:
                return .operationFailed(dto.message)
            // Parameter issues
            case 2_003:
                return .invalidParameters("Operation not supported: \(dto.details["operation"] ?? dto.message)")
            case 2_004:
                return .invalidParameters("Invalid input data")
            case 2_005:
                return .invalidParameters(dto.details["details"] as? String ?? dto.message)
            // Authentication issues
            case 2_010:
                return .authenticationFailed
            // Bookmark issues
            case 2_020:
                let path = dto.details["path"] as? String ?? "unknown"
                return .bookmarkCreationFailed(path: path)
            case 2_021:
                return .bookmarkResolutionFailed
            case 2_022:
                let path = dto.details["path"] as? String ?? "unknown"
                return .bookmarkStale(path: path)
            case 2_023:
                let path = dto.details["path"] as? String ?? "unknown"
                return .bookmarkNotFound(path: path)
            case 2_060:
                let errorMsg = dto.details["error"] ?? dto.message
                return .bookmarkError(errorMsg)
            // Resource issues
            case 2_030:
                let path = dto.details["path"] as? String ?? "unknown"
                return .resourceAccessFailed(path: path)
            case 2_061:
                let errorMsg = dto.details["error"] ?? dto.message
                return .accessError(errorMsg)
            // Item issues
            case 2_050:
                return .itemNotFound
            // Cryptographic issues
            case 2_040:
                return .randomGenerationFailed
            case 2_041:
                return .hashingFailed
            case 2_070:
                let reason = dto.details["reason"] ?? dto.message
                return .serializationFailed(reason: reason)
            case 2_071:
                let reason = dto.details["reason"] ?? dto.message
                return .encryptionFailed(reason: reason)
            case 2_072:
                let reason = dto.details["reason"] ?? dto.message
                return .decryptionFailed(reason: reason)
            case 2_073:
                let reason = dto.details["reason"] ?? dto.message
                return .signatureFailed(reason: reason)
            case 2_074:
                let reason = dto.details["reason"] ?? dto.message
                return .verificationFailed(reason: reason)
            case 2_075:
                let reason = dto.details["reason"] ?? dto.message
                return .keyGenerationFailed(reason: reason)
            // Other issues
            case 2_099:
                let reason = dto.details["reason"] ?? dto.message
                return .unknown(reason: reason)
            case 2_100:
                // For wrapped errors, we create a generic error since we can't reconstruct the original
                return .operationFailed("Wrapped error: \(dto.message)")
            default:
                return .operationFailed("Unknown XPC error: \(dto.message)")
            }
        }

        // Convert non-XPC errors to appropriate XPC errors based on domain
        if dto.domain.contains("crypto") {
            return .operationFailed("Crypto operation failed: \(dto.message)")
        } else if dto.domain.contains("auth") {
            return .authenticationFailed
        } else if dto.domain.contains("parameters") || dto.domain.contains("configuration") {
            return .invalidParameters(dto.message)
        } else if dto.domain.contains("bookmark") {
            return .bookmarkError(dto.message)
        } else if dto.domain.contains("resource") || dto.domain.contains("access") {
            return .accessError(dto.message)
        } else {
            return .operationFailed(dto.message)
        }
    }
}

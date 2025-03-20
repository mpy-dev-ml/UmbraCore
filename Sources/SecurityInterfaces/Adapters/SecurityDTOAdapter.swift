// DEPRECATED: SecurityDTOAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

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
        let keySizeInBits = switch config.securityLevel {
        case .basic:
            128
        case .standard:
            256
        case .advanced:
            384
        case .maximum:
            512
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
        let securityLevel: SecurityLevel = switch dto.keySizeInBits {
        case ..<192:
            .basic
        case 192 ..< 384:
            .standard
        case 384 ..< 512:
            .advanced
        default:
            .maximum
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
                code: 1001,
                domain: "security.bookmark",
                message: "Failed to create bookmark for \(path)",
                details: ["path": path]
            )
        case .bookmarkResolutionFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1002,
                domain: "security.bookmark",
                message: "Failed to resolve bookmark",
                details: [:]
            )
        case let .bookmarkStale(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1003,
                domain: "security.bookmark",
                message: "Bookmark is stale for \(path)",
                details: ["path": path]
            )
        case let .bookmarkNotFound(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1004,
                domain: "security.bookmark",
                message: "Bookmark not found for \(path)",
                details: ["path": path]
            )
        case let .resourceAccessFailed(path):
            CoreDTOs.SecurityErrorDTO(
                code: 1005,
                domain: "security.access",
                message: "Security-scoped resource access failed for \(path)",
                details: ["path": path]
            )
        case .randomGenerationFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1006,
                domain: "security.crypto",
                message: "Random data generation failed",
                details: [:]
            )
        case .hashingFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1007,
                domain: "security.crypto",
                message: "Hashing operation failed",
                details: [:]
            )
        case .itemNotFound:
            CoreDTOs.SecurityErrorDTO(
                code: 1008,
                domain: "security.credential",
                message: "Credential or secure item not found",
                details: [:]
            )
        case let .operationFailed(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1009,
                domain: "security.operation",
                message: message,
                details: [:]
            )
        case let .bookmarkError(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1010,
                domain: "security.bookmark",
                message: message,
                details: [:]
            )
        case let .accessError(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1011,
                domain: "security.access",
                message: message,
                details: [:]
            )
        case let .serializationFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1012,
                domain: "security.serialization",
                message: "Serialization failed: \(reason)",
                details: ["reason": reason]
            )
        case let .encryptionFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1013,
                domain: "security.crypto",
                message: "Encryption failed: \(reason)",
                details: ["reason": reason]
            )
        case let .decryptionFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1014,
                domain: "security.crypto",
                message: "Decryption failed: \(reason)",
                details: ["reason": reason]
            )
        case let .signatureFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1015,
                domain: "security.crypto",
                message: "Signature failed: \(reason)",
                details: ["reason": reason]
            )
        case let .verificationFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1016,
                domain: "security.crypto",
                message: "Verification failed: \(reason)",
                details: ["reason": reason]
            )
        case let .keyGenerationFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1017,
                domain: "security.crypto",
                message: "Key generation failed: \(reason)",
                details: ["reason": reason]
            )
        case .authenticationFailed:
            CoreDTOs.SecurityErrorDTO(
                code: 1018,
                domain: "security.auth",
                message: "Authentication failed",
                details: [:]
            )
        case let .authorizationFailed(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1019,
                domain: "security.auth",
                message: "Authorization failed: \(reason)",
                details: ["reason": reason]
            )
        case let .authorizationDenied(operation):
            CoreDTOs.SecurityErrorDTO(
                code: 1020,
                domain: "security.auth",
                message: "Authorization denied for operation: \(operation)",
                details: ["operation": operation]
            )
        case let .timeout(after):
            CoreDTOs.SecurityErrorDTO(
                code: 1021,
                domain: "security.timeout",
                message: "Operation timed out after \(after) seconds",
                details: ["timeoutSeconds": String(format: "%.1f", after)]
            )
        case let .invalidInput(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1022,
                domain: "security.validation",
                message: "Invalid input: \(details)",
                details: ["details": details]
            )
        case .serviceUnavailable:
            CoreDTOs.SecurityErrorDTO(
                code: 1023,
                domain: "security.service",
                message: "Service unavailable",
                details: [:]
            )
        case let .keyNotFound(identifier):
            CoreDTOs.SecurityErrorDTO(
                code: 1024,
                domain: "security.key",
                message: "Key not found: \(identifier)",
                details: ["identifier": identifier]
            )
        case let .invalidKeyType(expected, received):
            CoreDTOs.SecurityErrorDTO(
                code: 1025,
                domain: "security.key",
                message: "Invalid key type: expected \(expected), received \(received)",
                details: ["expected": expected, "received": received]
            )
        case let .operationNotSupported(name):
            CoreDTOs.SecurityErrorDTO(
                code: 1026,
                domain: "security.operation",
                message: "Operation not supported: \(name)",
                details: ["operation": name]
            )
        case let .invalidState(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1027,
                domain: "security.state",
                message: "Invalid state: \(details)",
                details: ["details": details]
            )
        case let .unknown(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1999,
                domain: "security.unknown",
                message: "Unknown error: \(reason)",
                details: ["reason": reason]
            )
        case let .invalidParameters(message):
            CoreDTOs.SecurityErrorDTO(
                code: 1028,
                domain: "security.params",
                message: message,
                details: [:]
            )
        case let .wrapped(error):
            CoreDTOs.SecurityErrorDTO(
                code: 1013,
                domain: "security.wrapped",
                message: "Wrapped error: \(error.localizedDescription)",
                details: [:]
            )
        case let .internalError(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 1012,
                domain: "security.internal",
                message: "Internal error: \(reason)",
                details: ["reason": reason]
            )
        case let .securityViolation(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1009,
                domain: "security.violation",
                message: "Security violation detected",
                details: ["details": details]
            )
        case .serviceNotAvailable:
            CoreDTOs.SecurityErrorDTO(
                code: 1010,
                domain: "security.service",
                message: "Security service not available",
                details: [:]
            )
        case let .keyError(details):
            CoreDTOs.SecurityErrorDTO(
                code: 1011,
                domain: "security.key",
                message: "Key operation failed",
                details: ["details": details]
            )
        @unknown default:
            CoreDTOs.SecurityErrorDTO(
                code: 9999,
                domain: "security.unknown",
                message: "Unknown error",
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
                case 1001:
                    return .bookmarkCreationFailed(path: path)
                case 1003:
                    return .bookmarkStale(path: path)
                case 1004:
                    return .bookmarkNotFound(path: path)
                default:
                    return .bookmarkError(dto.message)
                }
            } else {
                return dto.code == 1002 ? .bookmarkResolutionFailed : .bookmarkError(dto.message)
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
            case 1006:
                return .randomGenerationFailed
            case 1007:
                return .hashingFailed
            case 1013:
                return .encryptionFailed(reason: reason)
            case 1014:
                return .decryptionFailed(reason: reason)
            case 1015:
                return .signatureFailed(reason: reason)
            case 1016:
                return .verificationFailed(reason: reason)
            case 1017:
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
                   let _ = dto.details["raw_domain"]
                {
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
            case 2001:
                return .operationFailed("Service unavailable")
            case 2002:
                return .operationFailed(dto.message)
            // Parameter issues
            case 2003:
                return .invalidParameters("Operation not supported: \(String(describing: dto.details["operation"]))")
            case 2004:
                return .invalidParameters("Invalid input data")
            case 2005:
                return .invalidParameters(String(describing: dto.details["details"]))
            // Authentication issues
            case 2010:
                return .authenticationFailed
            // Bookmark issues
            case 2020:
                let path = String(describing: dto.details["path"])
                return .bookmarkCreationFailed(path: path)
            case 2021:
                return .bookmarkResolutionFailed
            case 2022:
                let path = String(describing: dto.details["path"])
                return .bookmarkStale(path: path)
            case 2023:
                let path = String(describing: dto.details["path"])
                return .bookmarkNotFound(path: path)
            case 2060:
                let errorMsg = String(describing: dto.details["error"])
                return .bookmarkError(errorMsg)
            // Resource issues
            case 2030:
                let path = String(describing: dto.details["path"])
                return .resourceAccessFailed(path: path)
            case 2061:
                let errorMsg = String(describing: dto.details["error"])
                return .accessError(errorMsg)
            // Item issues
            case 2050:
                return .itemNotFound
            // Cryptographic issues
            case 2040:
                return .randomGenerationFailed
            case 2041:
                return .hashingFailed
            case 2070:
                let reason = String(describing: dto.details["reason"])
                return .serializationFailed(reason: reason)
            case 2071:
                let reason = String(describing: dto.details["reason"])
                return .encryptionFailed(reason: reason)
            case 2072:
                let reason = String(describing: dto.details["reason"])
                return .decryptionFailed(reason: reason)
            case 2073:
                let reason = String(describing: dto.details["reason"])
                return .signatureFailed(reason: reason)
            case 2074:
                let reason = String(describing: dto.details["reason"])
                return .verificationFailed(reason: reason)
            case 2075:
                let reason = String(describing: dto.details["reason"])
                return .keyGenerationFailed(reason: reason)
            // Other issues
            case 2099:
                let reason = String(describing: dto.details["reason"])
                return .unknown(reason: reason)
            case 2100:
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

    /// Convert an XPCSecurityError to a SecurityErrorDTO
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: A Foundation-independent SecurityErrorDTO
    public static func toDTO(_ error: XPCSecurityError) -> CoreDTOs.SecurityErrorDTO {
        switch error {
        case .serviceUnavailable:
            return CoreDTOs.SecurityErrorDTO(
                code: 3000,
                domain: "security.xpc.service",
                message: "Service unavailable",
                details: [:]
            )
        case let .serviceNotReady(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3001,
                domain: "security.xpc.service",
                message: "Service not ready",
                details: ["reason": reason]
            )
        case let .timeout(after):
            return CoreDTOs.SecurityErrorDTO(
                code: 3002,
                domain: "security.xpc.operation",
                message: "Operation timed out",
                details: ["timeout": String(after)]
            )
        case let .authenticationFailed(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3003,
                domain: "security.xpc.auth",
                message: "Authentication failed",
                details: ["reason": reason]
            )
        case let .authorizationDenied(operation):
            return CoreDTOs.SecurityErrorDTO(
                code: 3004,
                domain: "security.xpc.auth",
                message: "Authorization denied for operation: \(operation)",
                details: ["operation": operation]
            )
        case let .operationNotSupported(name):
            return CoreDTOs.SecurityErrorDTO(
                code: 3005,
                domain: "security.xpc.operation",
                message: "Operation not supported: \(name)",
                details: ["operation": name]
            )
        case let .notImplemented(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3006,
                domain: "security.xpc.operation",
                message: "Not implemented",
                details: ["reason": reason]
            )
        case let .invalidInput(details):
            return CoreDTOs.SecurityErrorDTO(
                code: 3007,
                domain: "security.xpc.input",
                message: "Invalid input",
                details: ["details": details]
            )
        case let .invalidState(details):
            return CoreDTOs.SecurityErrorDTO(
                code: 3008,
                domain: "security.xpc.state",
                message: "Invalid state",
                details: ["details": details]
            )
        case let .keyNotFound(identifier):
            return CoreDTOs.SecurityErrorDTO(
                code: 3009,
                domain: "security.xpc.key",
                message: "Key not found",
                details: ["identifier": identifier]
            )
        case let .invalidKeyType(expected, received):
            return CoreDTOs.SecurityErrorDTO(
                code: 3010,
                domain: "security.xpc.key",
                message: "Invalid key type, expected \(expected), received \(received)",
                details: ["expected": expected, "received": received]
            )
        case let .cryptographicError(operation, details):
            return CoreDTOs.SecurityErrorDTO(
                code: 3011,
                domain: "security.xpc.crypto",
                message: "Cryptographic error in operation: \(operation)",
                details: ["operation": operation, "details": details]
            )
        case let .internalError(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3012,
                domain: "security.xpc.internal",
                message: "Internal error",
                details: ["reason": reason]
            )
        case .connectionInterrupted:
            return CoreDTOs.SecurityErrorDTO(
                code: 3013,
                domain: "security.xpc.connection",
                message: "Connection interrupted",
                details: [:]
            )
        case let .connectionInvalidated(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3014,
                domain: "security.xpc.connection",
                message: "Connection invalidated",
                details: ["reason": reason]
            )
        case let .invalidData(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3015,
                domain: "security.xpc.data",
                message: "Invalid data",
                details: ["reason": reason]
            )
        case let .encryptionFailed(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3016,
                domain: "security.xpc.crypto",
                message: "Encryption failed",
                details: ["reason": reason]
            )
        case let .decryptionFailed(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3017,
                domain: "security.xpc.crypto",
                message: "Decryption failed",
                details: ["reason": reason]
            )
        case let .keyGenerationFailed(reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 3018,
                domain: "security.xpc.key",
                message: "Key generation failed",
                details: ["reason": reason]
            )
        @unknown default:
            return CoreDTOs.SecurityErrorDTO(
                code: 3999,
                domain: "security.xpc.unknown",
                message: "Unknown security error",
                details: [:]
            )
        }
    }

    /// Convert a XPCProtocolsCore.SecurityError to a SecurityErrorDTO
    /// - Parameter error: The SecurityError to convert
    /// - Returns: A Foundation-independent SecurityErrorDTO
    public static func toDTO(_ error: XPCProtocolsCore.SecurityError) -> CoreDTOs.SecurityErrorDTO {
        // Since XPCProtocolsCore.SecurityError is the same as XPCSecurityError, we implement
        // the conversion directly to avoid any potential infinite recursion

        // This should ideally be the same logic as used in the toDTO for XPCSecurityError,
        // but implemented directly to avoid recursion issues.
        switch error {
        case .serviceUnavailable:
            CoreDTOs.SecurityErrorDTO(
                code: 2000,
                domain: "security.xpc.service",
                message: "Service unavailable",
                details: [:]
            )
        case let .serviceNotReady(reason):
            CoreDTOs.SecurityErrorDTO(
                code: 2001,
                domain: "security.xpc.service",
                message: "Service not ready",
                details: ["reason": reason]
            )
        case let .timeout(after):
            CoreDTOs.SecurityErrorDTO(
                code: 2002,
                domain: "security.xpc.operation",
                message: "Operation timed out",
                details: ["timeout": String(after)]
            )
        // Add more cases as needed for other error types...
        default:
            // For other cases, return a generic error
            CoreDTOs.SecurityErrorDTO(
                code: 2999,
                domain: "security.xpc.generic",
                message: "XPC Protocol Error",
                details: [:]
            )
        }
    }
}

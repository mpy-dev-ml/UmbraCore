import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreDTOs

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
        let securityLevel = switch dto.keySizeInBits {
        case ..<192:
            SecurityLevel.basic
        case 192..<384:
            SecurityLevel.standard
        case 384..<512:
            SecurityLevel.advanced
        default:
            SecurityLevel.maximum
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
        case .bookmarkCreationFailed(let path):
            return CoreDTOs.SecurityErrorDTO(
                code: 1001,
                domain: "security.bookmark",
                message: "Failed to create bookmark for \(path)",
                details: ["path": path]
            )
        case .bookmarkResolutionFailed:
            return CoreDTOs.SecurityErrorDTO(
                code: 1002,
                domain: "security.bookmark",
                message: "Failed to resolve bookmark",
                details: [:]
            )
        case .bookmarkStale(let path):
            return CoreDTOs.SecurityErrorDTO(
                code: 1003,
                domain: "security.bookmark",
                message: "Bookmark is stale for \(path)",
                details: ["path": path]
            )
        case .bookmarkNotFound(let path):
            return CoreDTOs.SecurityErrorDTO(
                code: 1004,
                domain: "security.bookmark",
                message: "Bookmark not found for \(path)",
                details: ["path": path]
            )
        case .resourceAccessFailed(let path):
            return CoreDTOs.SecurityErrorDTO(
                code: 1005,
                domain: "security.resource",
                message: "Failed to access resource at \(path)",
                details: ["path": path]
            )
        case .randomGenerationFailed:
            return CoreDTOs.SecurityErrorDTO(
                code: 1006,
                domain: "security.crypto",
                message: "Random generation failed",
                details: [:]
            )
        case .hashingFailed:
            return CoreDTOs.SecurityErrorDTO(
                code: 1007,
                domain: "security.crypto",
                message: "Hashing operation failed",
                details: [:]
            )
        case .itemNotFound:
            return CoreDTOs.SecurityErrorDTO(
                code: 1008,
                domain: "security.credential",
                message: "Credential or secure item not found",
                details: [:]
            )
        case .operationFailed(let message):
            return CoreDTOs.SecurityErrorDTO(
                code: 1009,
                domain: "security.operation",
                message: message,
                details: [:]
            )
        case .bookmarkError(let message):
            return CoreDTOs.SecurityErrorDTO(
                code: 1010,
                domain: "security.bookmark",
                message: message,
                details: [:]
            )
        case .accessError(let message):
            return CoreDTOs.SecurityErrorDTO(
                code: 1011,
                domain: "security.access",
                message: message,
                details: [:]
            )
        case .serializationFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1012,
                domain: "security.serialization",
                message: "Serialization failed: \(reason)",
                details: ["reason": reason]
            )
        case .encryptionFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1013,
                domain: "security.crypto",
                message: "Encryption failed: \(reason)",
                details: ["reason": reason]
            )
        case .decryptionFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1014,
                domain: "security.crypto",
                message: "Decryption failed: \(reason)",
                details: ["reason": reason]
            )
        case .signatureFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1015,
                domain: "security.crypto",
                message: "Signature failed: \(reason)",
                details: ["reason": reason]
            )
        case .verificationFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1016,
                domain: "security.crypto",
                message: "Verification failed: \(reason)",
                details: ["reason": reason]
            )
        case .keyGenerationFailed(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1017,
                domain: "security.crypto",
                message: "Key generation failed: \(reason)",
                details: ["reason": reason]
            )
        case .authenticationFailed:
            return CoreDTOs.SecurityErrorDTO(
                code: 1018,
                domain: "security.auth",
                message: "Authentication failed",
                details: [:]
            )
        case .invalidParameters(let details):
            return CoreDTOs.SecurityErrorDTO(
                code: 1019,
                domain: "security.parameters",
                message: "Invalid parameters: \(details)",
                details: ["details": details]
            )
        case .unknown(let reason):
            return CoreDTOs.SecurityErrorDTO(
                code: 1020,
                domain: "security.unknown",
                message: "Unknown error: \(reason)",
                details: ["reason": reason]
            )
        case .wrapped(let error):
            return CoreDTOs.SecurityErrorDTO(
                code: Int32(error.code),
                domain: "security.core.\(error.domain)",
                message: error.localizedDescription,
                details: ["raw_code": String(error.code), "raw_domain": error.domain]
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
                if let rawCode = dto.details["raw_code"], let code = Int(rawCode),
                   let rawDomain = dto.details["raw_domain"] {
                    let coreError = UmbraErrors.Security.Core(code: code, domain: rawDomain)
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
    
    /// Convert a XPC SecurityError to a SecurityErrorDTO
    /// - Parameter error: The XPC SecurityError to convert
    /// - Returns: A Foundation-independent SecurityErrorDTO
    public static func toXPCErrorDTO(_ error: SecurityError) -> CoreDTOs.SecurityErrorDTO {
        switch error {
        case .serviceUnavailable:
            return CoreDTOs.SecurityErrorDTO(
                code: 2001,
                domain: "xpc.service",
                message: "XPC service unavailable",
                details: [:]
            )
        case .operationFailed(let message):
            return CoreDTOs.SecurityErrorDTO(
                code: 2002,
                domain: "xpc.operation",
                message: message,
                details: [:]
            )
        case .operationNotSupported(let name):
            return CoreDTOs.SecurityErrorDTO(
                code: 2003,
                domain: "xpc.operation",
                message: "Operation not supported: \(name)",
                details: ["operation": name]
            )
        case .invalidInput:
            return CoreDTOs.SecurityErrorDTO(
                code: 2004,
                domain: "xpc.input",
                message: "Invalid input data",
                details: [:]
            )
        case .invalidConfiguration:
            return CoreDTOs.SecurityErrorDTO(
                code: 2005,
                domain: "xpc.configuration",
                message: "Invalid configuration",
                details: [:]
            )
        case .securityViolation:
            return CoreDTOs.SecurityErrorDTO(
                code: 2006,
                domain: "xpc.security",
                message: "Security violation",
                details: [:]
            )
        case .authenticationFailed:
            return CoreDTOs.SecurityErrorDTO(
                code: 2007,
                domain: "xpc.auth",
                message: "Authentication failed",
                details: [:]
            )
        case .internalError(let message):
            return CoreDTOs.SecurityErrorDTO(
                code: 2008,
                domain: "xpc.internal",
                message: message,
                details: [:]
            )
        }
    }
    
    /// Convert a SecurityErrorDTO to a XPC SecurityError
    /// - Parameter dto: The SecurityErrorDTO to convert
    /// - Returns: A XPC SecurityError compatible with the existing API
    public static func toXPCError(_ dto: CoreDTOs.SecurityErrorDTO) -> SecurityError {
        if dto.domain.hasPrefix("xpc.") {
            switch dto.code {
            case 2001:
                return .serviceUnavailable
            case 2002:
                return .operationFailed(dto.message)
            case 2003:
                return .operationNotSupported(name: dto.details["operation"] ?? dto.message)
            case 2004:
                return .invalidInput
            case 2005:
                return .invalidConfiguration
            case 2006:
                return .securityViolation
            case 2007:
                return .authenticationFailed
            case 2008:
                return .internalError(dto.message)
            default:
                return .internalError("Unknown XPC error: \(dto.message)")
            }
        }
        
        // Convert non-XPC errors to appropriate XPC errors
        if dto.domain.contains("crypto") {
            return .operationFailed("Crypto operation failed: \(dto.message)")
        } else if dto.domain.contains("auth") {
            return .authenticationFailed
        } else if dto.domain.contains("parameters") || dto.domain.contains("configuration") {
            return .invalidConfiguration
        } else {
            return .internalError(dto.message)
        }
    }
}

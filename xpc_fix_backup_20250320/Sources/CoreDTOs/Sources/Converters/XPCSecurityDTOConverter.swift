import CoreErrors
import ErrorHandlingDomains
import SecurityBridgeTypes
import UmbraCoreTypes

/// Converts between ErrorHandlingDomains.UmbraErrors.Security.Protocols and ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO
public enum XPCSecurityDTOConverter {
    // MARK: - Convert to DTO

    /// Convert an ErrorHandlingDomains.UmbraErrors.Security.Protocols to ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO
    /// - Parameter error: The error to convert
    /// - Returns: A Foundation-independent ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO
    public static func toDTO(_ error: CoreErrors.SecurityError) -> ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO {
        switch error {
        case let .invalidKey(reason):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.invalidInput(details: "Invalid key: \(reason)")

        case let .invalidContext(reason):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.invalidInput(details: "Invalid context: \(reason)")

        case let .invalidParameter(name, reason):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.invalidInput(details: "Invalid parameter \(name): \(reason)")

        case let .operationFailed(operation, reason):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.cryptographicError(
                operation: operation,
                details: reason
            )

        case let .unsupportedAlgorithm(name):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.unsupportedOperation(operation: "Algorithm: \(name)")

        case let .missingImplementation(component):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.unsupportedOperation(operation: component)

        case let .internalError(description):
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.unknown(details: description)

        @unknown default:
            return ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO.unknown(details: "Unknown security error")
        }
    }

    // MARK: - Convert from DTO

    /// Convert an ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO to ErrorHandlingDomains.UmbraErrors.Security.Protocols
    /// - Parameter dto: The DTO to convert
    /// - Returns: A Foundation-dependent ErrorHandlingDomains.UmbraErrors.Security.Protocols
    public static func fromDTO(_ dto: ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO) -> CoreErrors.SecurityError {
        switch dto.code {
        case .invalidInput:
            return .invalidParameter(
                name: dto.details["parameter"] ?? "unknown",
                reason: dto.details["message"] ?? "Invalid input"
            )

        case .cryptographicError:
            let operation = dto.details["operation"] ?? "unknown"
            let details = dto.details["message"] ?? "Cryptographic error"
            return .operationFailed(operation: operation, reason: details)

        case .keyNotFound:
            return .invalidKey(reason: "Key not found: \(dto.details["keyIdentifier"] ?? "unknown")")

        case .serviceUnavailable:
            return .operationFailed(
                operation: "service connection",
                reason: "Service unavailable: \(dto.details["service"] ?? "XPC Service")"
            )

        case .unsupportedOperation:
            let operation = dto.details["operation"] ?? "unknown"
            return .missingImplementation(component: operation)

        case .permissionDenied:
            return .operationFailed(
                operation: "permission check",
                reason: dto.details["message"] ?? "Permission denied"
            )

        default:
            return .internalError(description: dto.details["message"] ?? "Unknown error")
        }
    }

    // MARK: - Convert to UmbraErrors

    /// Convert ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO to canonical UmbraErrors format
    /// - Parameter dto: The DTO to convert
    /// - Returns: A canonical UmbraErrors.GeneralSecurity.Core error
    public static func toCanonicalError(_ dto: ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO) -> UmbraErrors.GeneralSecurity.Core {
        switch dto.code {
        case .invalidInput:
            return .invalidInput(reason: dto.details["message"] ?? "Invalid input")

        case .cryptographicError:
            let operation = dto.details["operation"] ?? "unknown"
            if operation.contains("encrypt") {
                return .encryptionFailed(reason: dto.details["message"] ?? "Encryption failed")
            } else if operation.contains("decrypt") {
                return .decryptionFailed(reason: dto.details["message"] ?? "Decryption failed")
            } else {
                return .internalError("Operation failed: \(operation)")
            }

        case .keyNotFound:
            return .invalidKey(reason: "Key not found: \(dto.details["keyIdentifier"] ?? "unknown")")

        case .serviceUnavailable:
            return .serviceError(
                code: 503,
                reason: "Service unavailable: \(dto.details["service"] ?? "XPC Service")"
            )

        case .unsupportedOperation:
            return .notImplemented(feature: dto.details["operation"] ?? "unknown operation")

        case .permissionDenied:
            return .internalError("Permission denied: \(dto.details["message"] ?? "unknown")")

        default:
            return .internalError(dto.details["message"] ?? "Unknown error")
        }
    }
}

import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Utility functions for SecurityProvider implementations
public enum SecurityProviderUtils {
    /// Convert an XPCSecurityError to a SecurityInterfacesError
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: A SecurityInterfacesError
    public static func convertXPCError(_ error: XPCSecurityError) -> SecurityInterfacesError {
        let securityInterfacesError: SecurityInterfacesError = switch error {
        case .serviceUnavailable:
            .operationFailed("XPC service unavailable")
        case let .serviceNotReady(reason):
            .operationFailed("Service not ready: \(reason)")
        case let .authenticationFailed(reason):
            .operationFailed("Authentication failed: \(reason)")
        case let .invalidInput(details):
            .invalidParameters(details)
        case let .encryptionFailed(reason):
            .encryptionFailed(reason: reason)
        case let .decryptionFailed(reason):
            .decryptionFailed(reason: reason)
        case let .keyGenerationFailed(reason):
            .keyGenerationFailed(reason: reason)
        case let .cryptographicError(operation, details):
            .operationFailed("Cryptographic error in \(operation): \(details)")
        case .timeout:
            .operationFailed("Operation timed out")
        case let .operationNotSupported(name):
            .operationFailed("Operation not supported: \(name)")
        case let .invalidState(details):
            .operationFailed("Invalid state: \(details)")
        case let .keyNotFound(identifier):
            .operationFailed("Key not found: \(identifier)")
        case let .invalidKeyType(expected, received):
            .operationFailed("Invalid key type. Expected: \(expected), Received: \(received)")
        case let .invalidData(reason):
            .operationFailed("Invalid data: \(reason)")
        case let .authorizationDenied(operation):
            .operationFailed("Authorization denied for operation: \(operation)")
        case let .notImplemented(reason):
            .operationFailed("Not implemented: \(reason)")
        case let .internalError(reason):
            .operationFailed("Internal error: \(reason)")
        case .connectionInterrupted:
            .operationFailed("Connection interrupted")
        case let .connectionInvalidated(reason):
            .operationFailed("Connection invalidated: \(reason)")
        @unknown default:
            .operationFailed("Unknown XPC error: \(error.localizedDescription)")
        }

        return securityInterfacesError
    }

    /// Alias for convertXPCError - maps an XPCSecurityError to a SecurityInterfacesError
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: A SecurityInterfacesError
    public static func mapXPCError(_ error: XPCSecurityError) -> SecurityInterfacesError {
        return convertXPCError(error)
    }

    /// Map a CoreErrors SecurityError to a SecurityInterfacesError
    /// - Parameter error: The error to map
    /// - Returns: A SecurityInterfacesError equivalent
    public static func convertError(_ error: CoreErrors.SecurityError) -> SecurityInterfacesError {
        // Convert the error to a SecurityInterfacesError instance
        let securityInterfacesError: SecurityInterfacesError = switch error {
        case let .invalidKey(reason):
            .keyError("Invalid key: \(reason)")
        case let .invalidContext(reason):
            .operationFailed("Invalid context: \(reason)")
        case let .invalidParameter(name, reason):
            .operationFailed("Invalid parameter '\(name)': \(reason)")
        case let .operationFailed(operation, reason):
            .operationFailed("\(operation) failed: \(reason)")
        case let .unsupportedAlgorithm(name):
            .operationFailed("Unsupported algorithm: \(name)")
        case let .missingImplementation(component):
            .operationFailed("Missing implementation: \(component)")
        case let .internalError(description):
            .operationFailed("Internal error: \(description)")
        }
        
        return securityInterfacesError
    }

    /// Maps a general Error to a SecurityInterfacesError
    /// - Parameter error: The error to convert
    /// - Returns: A SecurityInterfacesError representation of the input error
    public static func mapToSecurityInterfacesError(_ error: Error) -> SecurityInterfacesError {
        if let securityError = error as? SecurityInterfacesError {
            return securityError
        } else if let coreError = error as? CoreErrors.SecurityError {
            return convertError(coreError)
        } else if let xpcError = error as? XPCSecurityError {
            switch xpcError {
            case .operationFailed(let message):
                return .operationFailed(message)
            case .keyError(let message):
                return .keyError(message)
            case .authenticationFailed:
                return .authenticationFailed
            }
        } else {
            return .operationFailed("Unknown error: \(error.localizedDescription)")
        }
    }

    /// Creates a SecurityConfiguration from a service status response
    /// - Parameter status: The status dictionary from the service
    /// - Returns: A SecurityConfiguration object
    public static func createSecurityConfiguration(from status: [String: String]) -> SecurityConfiguration {
        let securityLevel = Int(status["securityLevel"] ?? "1") ?? 1
        let encryptionAlgorithm = status["encryptionAlgorithm"] ?? "AES-256"
        let hashAlgorithm = status["hashAlgorithm"] ?? "SHA-256"

        var options: [String: String] = [:]

        // Copy additional options from the status dictionary
        for (key, value) in status where
            !["securityLevel", "encryptionAlgorithm", "hashAlgorithm"].contains(key)
        {
            options[key] = value
        }

        return SecurityConfiguration(
            securityLevel: SecurityLevel(rawValue: securityLevel) ?? .standard,
            encryptionAlgorithm: encryptionAlgorithm,
            hashAlgorithm: hashAlgorithm,
            options: options.isEmpty ? nil : options
        )
    }

    /// Converts Data to SecureBytes
    /// - Parameter data: The data to convert
    /// - Returns: SecureBytes representation
    public static func dataToSecureBytes(_ data: Data) -> SecureBytes {
        SecureBytes(bytes: [UInt8](data))
    }

    /// Converts SecureBytes to Data
    /// - Parameter secureBytes: The secure bytes to convert
    /// - Returns: Data representation
    public static func secureBytesToData(_ secureBytes: SecureBytes) -> Data {
        secureBytes.withUnsafeBytes { pointer in
            Data(bytes: pointer.baseAddress!, count: pointer.count)
        }
    }

    /// Generate a standard security config for operations
    /// - Parameters:
    ///   - provider: The security provider
    ///   - options: Additional options
    /// - Returns: A configured SecurityConfigDTO
    public static func createStandardConfig(
        provider: any SecurityProtocolsCore.SecurityProviderProtocol,
        options: [String: Any]? = nil
    ) -> SecurityProtocolsCore.SecurityConfigDTO {
        provider.createSecureConfig(options: options)
    }
}

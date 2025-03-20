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
        switch error {
        case .serviceUnavailable:
            return .operationFailed("XPC service unavailable")
        case let .serviceNotReady(reason):
            return .operationFailed("Service not ready: \(reason)")
        case let .timeout(after):
            return .timeout(after: after)
        case .authenticationFailed:
            return .authenticationFailed
        case let .authorizationDenied(operation):
            return .authorizationDenied(operation: operation)
        case let .operationNotSupported(name):
            return .operationNotSupported(name: name)
        case let .notImplemented(reason):
            return .operationFailed("Not implemented: \(reason)")
        case let .invalidInput(details):
            return .invalidInput(details: details)
        case let .invalidData(reason):
            return .operationFailed("Invalid data: \(reason)")
        case let .encryptionFailed(reason):
            return .encryptionFailed(reason: reason)
        case let .invalidState(details):
            return .operationFailed("Invalid state: \(details)")
        case let .keyNotFound(identifier):
            return .keyNotFound(identifier: identifier)
        case let .invalidKeyType(expected, received):
            return .invalidKeyType(expected: expected, received: received)
        case let .cryptographicError(operation, details):
            return .operationFailed("Cryptographic error in \(operation): \(details)")
        case let .decryptionFailed(reason):
            return .decryptionFailed(reason: reason)
        case let .keyGenerationFailed(reason):
            return .keyGenerationFailed(reason: reason)
        case let .internalError(reason):
            return .operationFailed("Internal error: \(reason)")
        case .connectionInterrupted:
            return .operationFailed("Connection interrupted")
        case let .connectionInvalidated(reason):
            return .operationFailed("Connection invalidated: \(reason)")
        @unknown default:
            return .operationFailed("Unknown XPC error: \(error.localizedDescription)")
        }
    }

    /// Alias for convertXPCError - maps an XPCSecurityError to a SecurityInterfacesError
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: A SecurityInterfacesError
    public static func mapXPCError(_ error: XPCSecurityError) -> SecurityInterfacesError {
        convertXPCError(error)
    }

    /// Map an XPCProtocolsCore.SecurityError to a SecurityInterfacesError
    /// - Parameter error: The SecurityError to convert
    /// - Returns: A SecurityInterfacesError
    public static func mapSPCError(_ error: XPCProtocolsCore.SecurityError) -> SecurityInterfacesError {
        // Convert from XPCProtocolsCore.SecurityError to SecurityInterfacesError
        switch error {
        case .serviceUnavailable:
            return .serviceUnavailable
        case let .serviceNotReady(reason):
            return .operationFailed("Service not ready: \(reason)")
        case let .timeout(after):
            return .timeout(after: after)
        case .authenticationFailed:
            return .authenticationFailed
        case let .authorizationDenied(operation):
            return .authorizationDenied(operation: operation)
        case let .operationNotSupported(name):
            return .operationNotSupported(name: name)
        case let .notImplemented(reason):
            return .operationFailed("Not implemented: \(reason)")
        case let .invalidInput(details):
            return .invalidInput(details: details)
        case let .invalidState(details):
            return .operationFailed("Invalid state: \(details)")
        case let .keyNotFound(identifier):
            return .keyNotFound(identifier: identifier)
        case let .invalidKeyType(expected, received):
            return .invalidKeyType(expected: expected, received: received)
        case let .cryptographicError(operation, details):
            return .operationFailed("Cryptographic error in \(operation): \(details)")
        case let .internalError(reason):
            return .operationFailed("Internal error: \(reason)")
        case .connectionInterrupted:
            return .operationFailed("Connection interrupted")
        case let .connectionInvalidated(reason):
            return .operationFailed("Connection invalidated: \(reason)")
        case let .operationFailed(operation, reason):
            return .operationFailed("\(operation) failed: \(reason)")
        @unknown default:
            return .operationFailed("Unknown security error: \(error.localizedDescription)")
        }
    }

    /// Map UmbraErrors.Security.Protocols to a SecurityInterfacesError
    /// - Parameter error: The UmbraErrors.Security.Protocols to convert
    /// - Returns: A SecurityInterfacesError
    public static func mapSPCError(_ error: UmbraErrors.Security.Protocols) -> SecurityInterfacesError {
        // Convert from UmbraErrors.Security.Protocols to SecurityInterfacesError
        switch error {
        case .serviceError:
            return .serviceUnavailable
        case let .notImplemented(reason):
            return .operationFailed("Not implemented: \(reason)")
        case let .invalidInput(details):
            return .invalidInput(details: details)
        case let .invalidState(state, expectedState):
            return .operationFailed("Invalid state: \(state), expected: \(expectedState)")
        case let .invalidFormat(reason):
            return .invalidInput(details: "Invalid format: \(reason)")
        case let .missingProtocolImplementation(protocolName):
            return .operationFailed("Missing protocol implementation: \(protocolName)")
        case let .unsupportedOperation(name):
            return .operationNotSupported(name: name)
        case let .incompatibleVersion(version):
            return .operationFailed("Incompatible version: \(version)")
        case let .internalError(reason):
            return .operationFailed("Internal error: \(reason)")
        case let .encryptionFailed(reason):
            return .operationFailed("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
            return .operationFailed("Decryption failed: \(reason)")
        case let .randomGenerationFailed(reason):
            return .operationFailed("Random generation failed: \(reason)")
        case let .storageOperationFailed(reason):
            return .operationFailed("Storage operation failed: \(reason)")
        @unknown default:
            return .operationFailed("Unknown security protocol error")
        }
    }

    /// Map a CoreErrors SecurityError to a SecurityInterfacesError
    /// - Parameter error: The error to map
    /// - Returns: A SecurityInterfacesError equivalent
    public static func convertError(_ error: CoreErrors.SecurityError) -> SecurityInterfacesError {
        // Convert the error to a SecurityInterfacesError instance
        switch error {
        case let .invalidKey(reason):
            return .keyError("Invalid key: \(reason)")
        case let .invalidContext(reason):
            return .operationFailed("Invalid context: \(reason)")
        case let .invalidParameter(name, reason):
            return .operationFailed("Invalid parameter '\(name)': \(reason)")
        case let .operationFailed(operation, reason):
            return .operationFailed("\(operation) failed: \(reason)")
        case let .unsupportedAlgorithm(name):
            return .operationFailed("Unsupported algorithm: \(name)")
        case let .missingImplementation(component):
            return .operationFailed("Missing implementation: \(component)")
        case let .internalError(description):
            return .operationFailed("Internal error: \(description)")
        @unknown default:
            return .operationFailed("Unknown security error: \(error.localizedDescription)")
        }
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
            case let .internalError(reason):
                return .operationFailed(reason)
            case let .invalidData(reason):
                return .keyError(reason)
            case let .keyNotFound(identifier):
                return .keyError("Key not found: \(identifier)")
            case let .encryptionFailed(reason), let .decryptionFailed(reason):
                return .operationFailed("Crypto operation failed: \(reason)")
            case .authenticationFailed:
                return .authenticationFailed
            case let .invalidInput(details):
                return .operationFailed("Invalid input: \(details)")
            case .connectionInterrupted:
                return .operationFailed("Connection interrupted")
            case let .connectionInvalidated(reason):
                return .operationFailed("Connection invalidated: \(reason)")
            default:
                return .operationFailed("XPC error: \(xpcError)")
            }
        } else if let spcError = error as? XPCProtocolsCore.SecurityError {
            return mapSPCError(spcError)
        } else if let umbraError = error as? UmbraErrors.Security.Protocols {
            return mapSPCError(umbraError)
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
            !["securityLevel", "encryptionAlgorithm", "hashAlgorithm"].contains(key) {
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

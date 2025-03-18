import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Utility functions for SecurityProvider implementations
public enum SecurityProviderUtils {
    /// Map a SecurityProtocolsCore error to a SecurityInterfacesError
    /// - Parameter error: The error to map
    /// - Returns: A SecurityInterfacesError equivalent
    public static func mapSPCError(_ error: SecurityProtocolsCore.SecurityError) -> SecurityInterfacesError {
        // Convert the error to a SecurityInterfacesError instance
        let securityInterfacesError: SecurityInterfacesError = switch error {
        case .serviceUnavailable:
            .operationFailed("XPC service unavailable")
        case .operationFailed(let operation, let reason):
            .operationFailed("\(operation) failed: \(reason)")
        case .authenticationFailed:
            .authenticationFailed
        case let .invalidParameters(details):
            .invalidParameters(details)
        case let .encryptionFailed(reason):
            .operationFailed("Encryption failed: \(reason)")
        case let .decryptionFailed(reason):
            .operationFailed("Decryption failed: \(reason)")
        case let .keyGenerationFailed(reason):
            .operationFailed("Key generation failed: \(reason)")
        case let .keyStoreFailed(reason):
            .operationFailed("Key store operation failed: \(reason)")
        case .noServiceAvailable:
            .serviceNotAvailable
        case .timeout:
            .timeout
        case let .invalidStateTransition(fromState, toState):
            .invalidState(fromState: fromState, toState: toState)
        case let .securityViolation(details):
            .securityViolation(details)
        case let .internal(message):
            .operationFailed("Internal error: \(message)")
        }

        return securityInterfacesError
    }

    /// Convert an XPCSecurityError to a SecurityInterfacesError
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: A SecurityInterfacesError
    public static func convertXPCError(_ error: XPCSecurityError) -> SecurityInterfacesError {
        let securityInterfacesError: SecurityInterfacesError = switch error {
        case .serviceUnavailable:
            .operationFailed("XPC service unavailable")
        case .serviceNotReady(let reason):
            .operationFailed("Service not ready: \(reason)")
        case .authenticationFailed(let reason):
            .operationFailed("Authentication failed: \(reason)")
        case .invalidInput(let details):
            .invalidParameters(details)
        case .encryptionFailed(let reason):
            .encryptionFailed(reason: reason)
        case .decryptionFailed(let reason):
            .decryptionFailed(reason: reason)
        case .keyGenerationFailed(let reason):
            .keyGenerationFailed(reason: reason)
        case .cryptographicError(let operation, let details):
            .operationFailed("Cryptographic error in \(operation): \(details)")
        case .timeout:
            .operationFailed("Operation timed out")
        case .operationNotSupported(let name):
            .operationFailed("Operation not supported: \(name)")
        case .invalidState(let details):
            .operationFailed("Invalid state: \(details)")
        case .keyNotFound(let identifier):
            .operationFailed("Key not found: \(identifier)")
        case .invalidKeyType(let expected, let received):
            .operationFailed("Invalid key type. Expected: \(expected), Received: \(received)")
        case .invalidData(let reason):
            .operationFailed("Invalid data: \(reason)")
        case .authorizationDenied(let operation):
            .operationFailed("Authorization denied for operation: \(operation)")
        case .notImplemented(let reason):
            .operationFailed("Not implemented: \(reason)")
        case .internalError(let reason):
            .operationFailed("Internal error: \(reason)")
        case .connectionInterrupted:
            .operationFailed("Connection interrupted")
        case .connectionInvalidated(let reason):
            .operationFailed("Connection invalidated: \(reason)")
        @unknown default:
            .operationFailed("Unknown XPC error: \(error.localizedDescription)")
        }
        
        return securityInterfacesError
    }

    /// Convert a CoreErrors.SecurityError to a SecurityInterfacesError
    /// - Parameter error: The error to convert
    /// - Returns: A SecurityInterfacesError
    public static func convertError(_ error: CoreErrors.SecurityError) -> SecurityInterfacesError {
        // Map CoreErrors.SecurityError to SecurityInterfacesError
        let securityInterfacesError: SecurityInterfacesError = switch error {
        case .general(let message):
            .operationFailed(message)
        case .authentication(let message):
            .authenticationFailed
        case .authorization(let message):
            .authorizationFailed(message)
        case .encryption(let message):
            .encryptionFailed(reason: message)
        case .decryption(let message):
            .decryptionFailed(reason: message)
        case .keyGeneration(let message):
            .keyGenerationFailed(reason: message)
        case .keyStorage(let message):
            .operationFailed("Key storage error: \(message)")
        case .invalidInput(let message):
            .invalidParameters(message)
        case .invalidState(let message):
            .operationFailed("Invalid state: \(message)")
        case .timeout(let message):
            .timeout
        case .serialization(let message):
            .operationFailed("Serialization error: \(message)")
        case .unsupportedOperation(let message):
            .operationFailed("Unsupported operation: \(message)")
        case .serviceUnavailable(let message):
            .serviceNotAvailable
        case .protocolViolation(let message):
            .securityViolation(message)
        case .internalError(let message):
            .operationFailed("Internal error: \(message)")
        }
        
        return securityInterfacesError
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
        return secureBytes.withUnsafeBytes { pointer in
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

import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityInterfacesBase
import UmbraCoreTypes /// Errors that can occur during security operations
import XPCProtocolsCore

public enum SecurityInterfacesError: Error, Sendable {
    /// Bookmark creation failed
    case bookmarkCreationFailed(path: String)
    /// Bookmark resolution failed
    case bookmarkResolutionFailed
    /// Bookmark is stale and needs to be recreated
    case bookmarkStale(path: String)
    /// Bookmark not found
    case bookmarkNotFound(path: String)
    /// Security-scoped resource access failed
    case resourceAccessFailed(path: String)
    /// Random data generation failed
    case randomGenerationFailed
    /// Hashing operation failed
    case hashingFailed
    /// Credential or secure item not found
    case itemNotFound
    /// General security operation failed
    case operationFailed(String)
    /// Custom bookmark error with message
    case bookmarkError(String)
    /// Custom access error with message
    case accessError(String)
    /// Serialization or deserialization failed
    case serializationFailed(reason: String)
    /// Encryption failed with reason
    case encryptionFailed(reason: String)
    /// Decryption failed with reason
    case decryptionFailed(reason: String)
    /// Signature failed with reason
    case signatureFailed(reason: String)
    /// Verification failed with reason
    case verificationFailed(reason: String)
    /// Key generation failed with reason
    case keyGenerationFailed(reason: String)
    /// Authentication failed
    case authenticationFailed
    /// Authorization failed with reason
    case authorizationFailed(String)
    /// Authorization denied with operation
    case authorizationDenied(operation: String)
    /// Operation timed out
    case timeout(after: TimeInterval)
    /// Invalid parameters with details
    case invalidParameters(String)
    /// Security protocol violation
    case securityViolation(String)
    /// Service is not available
    case serviceNotAvailable
    /// Service unavailable
    case serviceUnavailable
    /// Key-related error with reason
    case keyError(String)
    /// Internal error that should not occur in normal operation
    case internalError(reason: String)
    /// Unknown error with reason
    case unknown(reason: String)
    /// Wrapped UmbraErrors.Security.Core
    case wrapped(UmbraErrors.Security.Core)
    /// Invalid input with details
    case invalidInput(details: String)
    /// Invalid key type
    case invalidKeyType(expected: String, received: String)
    /// Key not found
    case keyNotFound(identifier: String)
    /// Operation not supported
    case operationNotSupported(name: String)
    /// Invalid state
    case invalidState(details: String)

    public var errorDescription: String? {
        switch self {
        case let .bookmarkCreationFailed(path):
            // DEPRECATED: "Failed to create security bookmark for path: \(path)"
        case .bookmarkResolutionFailed:
            "Failed to resolve security bookmark"
        case let .bookmarkStale(path):
            // DEPRECATED: "Security bookmark is stale for path: \(path)"
        case let .bookmarkNotFound(path):
            // DEPRECATED: "Security bookmark not found for path: \(path)"
        case let .resourceAccessFailed(path):
            "Failed to access security-scoped resource: \(path)"
        case .randomGenerationFailed:
            "Failed to generate random data"
        case .hashingFailed:
            "Failed to perform hashing operation"
        case .itemNotFound:
            "Security item not found"
        case let .operationFailed(message):
            "Security operation failed: \(message)"
        case let .bookmarkError(message):
            "Security bookmark error: \(message)"
        case let .accessError(message):
            "Security access error: \(message)"
        case let .serializationFailed(reason):
            "Serialization or deserialization failed: \(reason)"
        case let .encryptionFailed(reason):
            "Encryption operation failed: \(reason)"
        case let .decryptionFailed(reason):
            "Decryption operation failed: \(reason)"
        case let .signatureFailed(reason):
            "Signature operation failed: \(reason)"
        case let .verificationFailed(reason):
            "Verification operation failed: \(reason)"
        case let .keyGenerationFailed(reason):
            "Key generation failed: \(reason)"
        case .authenticationFailed:
            "Authentication failed"
        case let .authorizationFailed(message):
            "Authorization failed: \(message)"
        case let .authorizationDenied(operation):
            // DEPRECATED: "Authorization denied for operation: \(operation)"
        case let .timeout(after):
            "Operation timed out after \(after) seconds"
        case let .invalidParameters(details):
            "Invalid parameters: \(details)"
        case let .securityViolation(message):
            "Security protocol violation: \(message)"
        case .serviceNotAvailable:
            "Security service is not available"
        case .serviceUnavailable:
            "Security service is unavailable"
        case let .keyError(message):
            "Key operation error: \(message)"
        case let .internalError(reason):
            "Internal security error: \(reason)"
        case let .unknown(reason):
            "Unknown error: \(reason)"
        case let .wrapped(error):
            "Wrapped security error: \(error.localizedDescription)"
        case let .invalidInput(details):
            "Invalid input: \(details)"
        case let .invalidKeyType(expected, received):
            "Invalid key type: expected \(expected), received \(received)"
        case let .keyNotFound(identifier):
            "Key not found: \(identifier)"
        case let .operationNotSupported(name):
            "Operation not supported: \(name)"
        case let .invalidState(details):
            "Invalid state: \(details)"
        }
    }

    public init(from coreError: UmbraErrors.Security.Core) {
        self = .wrapped(coreError)
    }

    public func toCoreError() -> UmbraErrors.Security.Core? {
        switch self {
        case let .wrapped(coreError):
            coreError
        case .bookmarkCreationFailed, .bookmarkResolutionFailed, .bookmarkStale,
             .bookmarkNotFound, .resourceAccessFailed, .randomGenerationFailed,
             .hashingFailed, .itemNotFound, .operationFailed, .bookmarkError, .accessError,
             .serializationFailed, .encryptionFailed, .decryptionFailed, .signatureFailed,
             .verificationFailed, .keyGenerationFailed, .authenticationFailed, .invalidParameters,
             .unknown, .authorizationFailed, .timeout, .securityViolation, .serviceNotAvailable,
             .internalError, .keyError, .invalidInput, .invalidKeyType, .keyNotFound,
             .operationNotSupported, .invalidState, .authorizationDenied, .serviceUnavailable:
            nil
        }
    }
}

// Add LocalizedError conformance in a separate extension
// This allows us to maintain compatibility without importing Foundation directly
public extension SecurityInterfacesError {
    var localizedDescription: String {
        errorDescription ?? "Unknown security error"
    }
}

/// Map a SecurityProtocolsCore.SecurityError to a SecurityInterfacesError
/// This function is used by tests to verify error mapping functionality
/// - Parameter error: The original error from SecurityProtocolsCore
/// - Returns: A mapped SecurityInterfacesError
@available(*, deprecated, message: "Use SecurityProviderAdapter.mapError instead")
public func mapSPCError(_ error: XPCProtocolsCore.SecurityError) -> SecurityInterfacesError {
    switch error {
    case let .cryptographicError(operation, details):
        switch operation {
        case "encryption":
            .encryptionFailed(reason: details)
        case "decryption":
            .decryptionFailed(reason: details)
        case "signing":
            .signatureFailed(reason: details)
        case "verification":
            .verificationFailed(reason: details)
        case "key generation":
            .keyGenerationFailed(reason: details)
        default:
            .operationFailed("\(operation) failed: \(details)")
        }
    case let .keyManagementError(operation, details):
        .keyError("\(operation) failed: \(details)")
    case .authenticationFailed:
        .authenticationFailed
    case let .authorizationDenied(details):
        .authorizationDenied(operation: details)
    case let .invalidInput(details):
        .invalidInput(details: details)
    case let .invalidKeyType(expected, received):
        .invalidKeyType(expected: expected, received: received)
    case let .keyNotFound(identifier):
        .keyNotFound(identifier: identifier)
    case let .operationNotSupported(name):
        .operationNotSupported(name: name)
    case .serviceUnavailable:
        .serviceUnavailable
    case .timeout:
        .timeout(after: 30.0) // Use default timeout value
    case let .invalidState(details):
        .invalidState(details: details)
    case let .internalError(details):
        .internalError(reason: details)
    case .connectionInterrupted:
        .operationFailed("XPC connection interrupted")
    case let .connectionInvalidated(reason):
        .operationFailed("XPC connection invalidated: \(reason)")
    case let .serviceNotReady(reason):
        .operationFailed("Service not ready: \(reason)")
    case let .notImplemented(reason):
        .operationFailed("Not implemented: \(reason)")
    case let .operationFailed(operation, reason):
        .operationFailed("\(operation): \(reason)")
    @unknown default:
        .unknown(reason: "Unknown security error")
    }
}

/// Map a UmbraErrors.Security.Protocols error to a SecurityInterfacesError
/// - Parameter error: The protocol error to map
/// - Returns: A mapped SecurityInterfacesError
private func mapFromProtocolError(
    _ error: UmbraErrors.Security
        .Protocols
) -> SecurityInterfacesError {
    switch error {
    case let .invalidFormat(reason):
        return .operationFailed("Invalid format: \(reason)")
    case let .missingProtocolImplementation(name):
        return .operationFailed("Missing protocol implementation: \(name)")
    case let .unsupportedOperation(name):
        return .operationFailed("Unsupported operation: \(name)")
    case let .incompatibleVersion(version):
        return .operationFailed("Incompatible version: \(version)")
    case let .invalidState(current, expected):
        return .operationFailed("Invalid state: current=\(current), expected=\(expected)")
    case let .internalError(message):
        return .operationFailed("Internal error: \(message)")
    case let .invalidInput(reason):
        return .operationFailed("Invalid input: \(reason)")
    case let .encryptionFailed(reason):
        return .encryptionFailed(reason: reason)
    case let .decryptionFailed(reason):
        return .decryptionFailed(reason: reason)
    case let .randomGenerationFailed(reason):
        return .operationFailed("Random generation failed: \(reason)")
    case let .storageOperationFailed(reason):
        return .operationFailed("Storage operation failed: \(reason)")
    case let .serviceError(reason):
        return .operationFailed("Service error: \(reason)")
    case let .notImplemented(feature):
        return .operationFailed("Not implemented: \(feature)")
    @unknown default:
        return .operationFailed("Unknown security protocol error")
    }
}

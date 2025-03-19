import ErrorHandling
import ErrorHandlingDomains
import SecurityInterfacesBase
import UmbraCoreTypes
import XPCProtocolsCore

/// Errors that can occur during security operations.
///
/// This enum provides a comprehensive set of error cases for security-related operations
/// in the UmbraCore framework. It includes cases for common security errors such as
/// authentication failures, encryption/decryption errors, and access control issues.
///
/// ## Error Conversion
///
/// SecurityInterfacesError can be converted to UmbraErrors.Security.Core using the
/// `toCoreError()` method:
///
/// ```swift
/// let error = SecurityInterfacesError.authenticationFailed
/// let coreError = error.toCoreError() // Returns UmbraErrors.Security.Core.authenticationFailed
/// ```
///
/// ## Error Categories
///
/// - Access Control: Errors related to permissions and access to resources
/// - Cryptographic Operations: Errors during encryption, decryption, and hashing
/// - Authentication: Errors related to user authentication
/// - System Integration: Errors with system services and XPC communication
///
/// ## Topics
///
/// ### Bookmark Errors
///
/// - ``bookmarkCreationFailed(_:)``
/// - ``bookmarkResolutionFailed``
/// - ``bookmarkStale``
/// - ``bookmarkError(_:)``
///
/// ### Cryptographic Errors
///
/// - ``encryptionFailed(reason:)``
/// - ``decryptionFailed(reason:)``
/// - ``keyGenerationFailed(reason:)``
/// - ``hashingFailed``
/// - ``signatureFailed(reason:)``
/// - ``verificationFailed(reason:)``
///
/// ### Authentication Errors
///
/// - ``authenticationFailed``
/// - ``authorizationFailed(_:)``
///
/// ### Conversion
///
/// - ``toCoreError()``
/// - ``wrapped(_:)``
public enum SecurityInterfacesError: Error, Sendable {
    /// Bookmark creation failed
    ///
    /// This error occurs when the system fails to create a security-scoped bookmark
    /// for the specified path. Bookmarks are used to maintain access to files outside
    /// the application's sandbox.
    ///
    /// - Parameter path: The file system path for which bookmark creation failed
    case bookmarkCreationFailed(path: String)
    
    /// Bookmark resolution failed
    ///
    /// This error occurs when a previously created security-scoped bookmark
    /// cannot be resolved to a file URL.
    case bookmarkResolutionFailed
    
    /// Bookmark has become stale
    ///
    /// This error occurs when a security-scoped bookmark is no longer valid,
    /// typically because the target file has been moved or deleted.
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
    /// Operation timed out
    case timeout
    /// Invalid parameters with details
    case invalidParameters(String)
    /// Security protocol violation
    case securityViolation(String)
    /// Service is not available
    case serviceNotAvailable
    /// Key-related error with reason
    case keyError(String)
    /// Internal error that should not occur in normal operation
    case internalError(reason: String)
    /// Unknown error with reason
    case unknown(reason: String)
    /// Wrapped UmbraErrors.Security.Core
    case wrapped(UmbraErrors.Security.Core)

    public var errorDescription: String? {
        switch self {
        case let .bookmarkCreationFailed(path):
            "Failed to create security bookmark for path: \(path)"
        case .bookmarkResolutionFailed:
            "Failed to resolve security bookmark"
        case let .bookmarkStale(path):
            "Security bookmark is stale for path: \(path)"
        case let .bookmarkNotFound(path):
            "Security bookmark not found for path: \(path)"
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
        case .timeout:
            "Operation timed out"
        case let .invalidParameters(details):
            "Invalid parameters: \(details)"
        case let .securityViolation(message):
            "Security protocol violation: \(message)"
        case .serviceNotAvailable:
            "Security service is not available"
        case let .keyError(message):
            "Key operation error: \(message)"
        case let .internalError(reason):
            "Internal security error: \(reason)"
        case let .unknown(reason):
            "Unknown error: \(reason)"
        case let .wrapped(error):
            "Wrapped security error: \(error.localizedDescription)"
        }
    }

    /// Initializes a SecurityInterfacesError from a core error
    ///
    /// This initializer creates a SecurityInterfacesError by wrapping an UmbraErrors.Security.Core error.
    /// This is useful when you need to convert between error domains while preserving the original error.
    ///
    /// - Parameter coreError: The UmbraErrors.Security.Core error to wrap
    /// - Returns: A SecurityInterfacesError that wraps the core error
    public init(from coreError: UmbraErrors.Security.Core) {
        self = .wrapped(coreError)
    }

    /// Converts this error to a core error type if possible
    ///
    /// This method attempts to convert the SecurityInterfacesError to an UmbraErrors.Security.Core error.
    /// If the error was created by wrapping a core error, returns that error.
    /// For other error types, returns nil as they cannot be directly mapped to core errors.
    ///
    /// - Returns: The equivalent UmbraErrors.Security.Core error if available, nil otherwise
    public func toCoreError() -> UmbraErrors.Security.Core? {
        switch self {
        case let .wrapped(coreError):
            coreError
        case .bookmarkCreationFailed, .bookmarkResolutionFailed, .bookmarkStale,
             .bookmarkNotFound, .resourceAccessFailed, .randomGenerationFailed,
             .hashingFailed, .itemNotFound, .operationFailed, .bookmarkError, .accessError,
             .serializationFailed, .encryptionFailed, .decryptionFailed, .signatureFailed, .verificationFailed, .keyGenerationFailed, .authenticationFailed, .invalidParameters, .unknown, .authorizationFailed, .timeout, .securityViolation, .serviceNotAvailable, .internalError, .keyError:
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
            return .encryptionFailed(reason: details)
        case "decryption":
            return .decryptionFailed(reason: details)
        case "signing":
            return .signatureFailed(reason: details)
        case "verification":
            return .verificationFailed(reason: details)
        case "key generation":
            return .keyGenerationFailed(reason: details)
        default:
            return .operationFailed("\(operation) failed: \(details)")
        }
    case let .authenticationFailed(details):
        return .authenticationFailed
    case let .authorizationFailed(details):
        return .authorizationFailed(details)
    case let .invalidFormat(details):
        return .invalidParameters("Invalid format: \(details)")
    case let .invalidKey(details):
        return .invalidParameters("Invalid key: \(details)")
    case let .invalidParameters(details):
        return .invalidParameters(details)
    case let .keyNotFound(identifier):
        return .invalidParameters("Key not found: \(identifier)")
    case let .operationNotSupported(name):
        return .operationFailed("Operation not supported: \(name)")
    case .serviceUnavailable:
        return .serviceNotAvailable
    case let .timeout(details):
        return .timeout
    case let .invalidState(details):
        return .operationFailed("Invalid state: \(details)")
    case let .protocolViolation(details):
        return .securityViolation(details)
    case let .internalError(details):
        return .internalError(reason: details)
    case let .unknownError(details):
        return .unknown(reason: details)
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

import ErrorHandling
import ErrorHandlingDomains
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
    /// Invalid parameters with details
    case invalidParameters(String)
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
        case let .invalidParameters(details):
            "Invalid parameters: \(details)"
        case let .unknown(reason):
            "Unknown error: \(reason)"
        case let .wrapped(error):
            "Wrapped security error: \(error.localizedDescription)"
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
             .serializationFailed, .encryptionFailed, .decryptionFailed, .signatureFailed, .verificationFailed, .keyGenerationFailed, .authenticationFailed, .invalidParameters, .unknown:
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

// For backward compatibility
public typealias SecurityError = SecurityInterfacesError

/// Map a SecurityProtocolsCore.SecurityError to a SecurityInterfacesError
/// This function is used by tests to verify error mapping functionality
/// - Parameter error: The original error from SecurityProtocolsCore
/// - Returns: A mapped SecurityInterfacesError
@available(*, deprecated, message: "Use SecurityProviderAdapter.mapError instead")
public func mapSPCError(_ error: Error) -> Error {
    if let protocolError = error as? UmbraErrors.Security.Protocols {
        return mapFromProtocolError(protocolError)
    }

    // Return a generic error if type doesn't match
    return SecurityInterfacesError.operationFailed("Unknown error: \(error)")
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
    case let .invalidParameters(details):
        return .invalidParameters(details)
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

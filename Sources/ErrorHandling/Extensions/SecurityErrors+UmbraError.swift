import Foundation
import ErrorHandlingCommon
import ErrorHandlingInterfaces
import ErrorHandlingDomains

// Create an extension to provide an empty context constructor
extension ErrorHandlingCommon.ErrorContext {
    /// An empty context with minimal information
    public static var empty: ErrorHandlingCommon.ErrorContext {
        return ErrorHandlingCommon.ErrorContext(
            source: "Unknown",
            operation: "Unknown"
        )
    }
}

/// Extension to make UmbraErrors.Security.Core conform to UmbraError protocol
extension UmbraErrors.Security.Core: UmbraError {
    /// The domain that this error belongs to
    public var domain: String {
        "Security.Core"
    }
    
    /// A unique code that identifies this error within its domain
    public var code: String {
        switch self {
        case .encryptionFailed:
            return "ENCRYPTION_FAILED"
        case .decryptionFailed:
            return "DECRYPTION_FAILED"
        case .keyGenerationFailed:
            return "KEY_GENERATION_FAILED"
        case .invalidKey:
            return "INVALID_KEY"
        case .hashVerificationFailed:
            return "HASH_VERIFICATION_FAILED"
        case .randomGenerationFailed:
            return "RANDOM_GENERATION_FAILED"
        case .invalidInput:
            return "INVALID_INPUT"
        case .storageOperationFailed:
            return "STORAGE_OPERATION_FAILED"
        case .timeout:
            return "TIMEOUT"
        case .serviceError:
            return "SERVICE_ERROR"
        case .internalError:
            return "INTERNAL_ERROR"
        case .notImplemented:
            return "NOT_IMPLEMENTED"
        @unknown default:
            return "UNKNOWN_ERROR"
        }
    }
    
    /// A human-readable description of the error
    public var errorDescription: String {
        switch self {
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        case .keyGenerationFailed(let reason):
            return "Key generation failed: \(reason)"
        case .invalidKey(let reason):
            return "Invalid key: \(reason)"
        case .hashVerificationFailed(let reason):
            return "Hash verification failed: \(reason)"
        case .randomGenerationFailed(let reason):
            return "Random generation failed: \(reason)"
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        case .storageOperationFailed(let reason):
            return "Storage operation failed: \(reason)"
        case .timeout(let operation):
            return "Operation timed out: \(operation)"
        case .serviceError(let code, let reason):
            return "Security service error (\(code)): \(reason)"
        case .internalError(let message):
            return "Internal security error: \(message)"
        case .notImplemented(let feature):
            return "Not implemented: \(feature)"
        @unknown default:
            return "Unknown security core error"
        }
    }
    
    /// Optional source information about where the error occurred
    public var source: ErrorHandlingCommon.ErrorSource? {
        nil // Default implementation returns nil - can be set with with(source:)
    }
    
    /// Optional underlying error that caused this error
    public var underlyingError: Error? {
        nil // Default implementation returns nil - can be set with with(underlyingError:)
    }
    
    /// Additional context information about the error
    public var context: ErrorHandlingCommon.ErrorContext {
        .empty // Default implementation - can be set with with(context:)
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> Self {
        // This is where we'd create a new instance with the context
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
        // This is where we'd create a new instance with the underlying error
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
        // This is where we'd create a new instance with the source
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// CustomStringConvertible conformance
    public var description: String {
        errorDescription
    }
}

/// Extension to make UmbraErrors.Security.XPC conform to UmbraError protocol
extension UmbraErrors.Security.XPC: UmbraError {
    /// The domain that this error belongs to
    public var domain: String {
        "Security.XPC"
    }
    
    /// A unique code that identifies this error within its domain
    public var code: String {
        switch self {
        case .connectionFailed:
            return "CONNECTION_FAILED"
        case .serviceUnavailable:
            return "SERVICE_UNAVAILABLE"
        case .invalidResponse:
            return "INVALID_RESPONSE"
        case .unexpectedSelector:
            return "UNEXPECTED_SELECTOR"
        case .versionMismatch:
            return "VERSION_MISMATCH"
        case .invalidServiceIdentifier:
            return "INVALID_SERVICE_IDENTIFIER"
        case .internalError:
            return "INTERNAL_ERROR"
        @unknown default:
            return "UNKNOWN_ERROR"
        }
    }
    
    /// A human-readable description of the error
    public var errorDescription: String {
        switch self {
        case .connectionFailed(let reason):
            return "Connection to XPC service failed: \(reason)"
        case .serviceUnavailable:
            return "XPC service is not available"
        case .invalidResponse(let reason):
            return "Received an invalid response from XPC service: \(reason)"
        case .unexpectedSelector(let name):
            return "Attempted to use an unexpected selector: \(name)"
        case .versionMismatch(let expected, let found):
            return "Service version does not match expected version (expected: \(expected), found: \(found))"
        case .invalidServiceIdentifier:
            return "Service identifier is invalid"
        case .internalError(let message):
            return "Internal error within XPC handling: \(message)"
        @unknown default:
            return "Unknown XPC security error"
        }
    }
    
    /// Optional source information about where the error occurred
    public var source: ErrorHandlingCommon.ErrorSource? {
        nil // Default implementation returns nil - can be set with with(source:)
    }
    
    /// Optional underlying error that caused this error
    public var underlyingError: Error? {
        nil // Default implementation returns nil - can be set with with(underlyingError:)
    }
    
    /// Additional context information about the error
    public var context: ErrorHandlingCommon.ErrorContext {
        .empty // Default implementation - can be set with with(context:)
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> Self {
        // This is where we'd create a new instance with the context
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
        // This is where we'd create a new instance with the underlying error
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
        // This is where we'd create a new instance with the source
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// CustomStringConvertible conformance
    public var description: String {
        errorDescription
    }
}

/// Extension to make UmbraErrors.Security.Protocols conform to UmbraError protocol
extension UmbraErrors.Security.Protocols: UmbraError {
    /// The domain that this error belongs to
    public var domain: String {
        "Security.Protocols"
    }
    
    /// A unique code that identifies this error within its domain
    public var code: String {
        switch self {
        case .invalidFormat:
            return "INVALID_FORMAT"
        case .unsupportedOperation:
            return "UNSUPPORTED_OPERATION"
        case .incompatibleVersion:
            return "INCOMPATIBLE_VERSION"
        case .missingProtocolImplementation:
            return "MISSING_PROTOCOL_IMPLEMENTATION"
        case .invalidState:
            return "INVALID_STATE"
        case .internalError:
            return "INTERNAL_ERROR"
        @unknown default:
            return "UNKNOWN_ERROR"
        }
    }
    
    /// A human-readable description of the error
    public var errorDescription: String {
        switch self {
        case .invalidFormat(let reason):
            return "Data format does not conform to protocol expectations: \(reason)"
        case .unsupportedOperation(let name):
            return "Operation is not supported by the protocol: \(name)"
        case .incompatibleVersion(let version):
            return "Protocol version is incompatible: \(version)"
        case .missingProtocolImplementation(let protocolName):
            return "Required protocol implementation is missing: \(protocolName)"
        case .invalidState(let state, let expectedState):
            return "Protocol in invalid state: current '\(state)', expected '\(expectedState)'"
        case .internalError(let reason):
            return "Internal error within protocol handling: \(reason)"
        @unknown default:
            return "Unknown protocol security error"
        }
    }
    
    /// Optional source information about where the error occurred
    public var source: ErrorHandlingCommon.ErrorSource? {
        nil // Default implementation returns nil - can be set with with(source:)
    }
    
    /// Optional underlying error that caused this error
    public var underlyingError: Error? {
        nil // Default implementation returns nil - can be set with with(underlyingError:)
    }
    
    /// Additional context information about the error
    public var context: ErrorHandlingCommon.ErrorContext {
        .empty // Default implementation - can be set with with(context:)
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> Self {
        // This is where we'd create a new instance with the context
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
        // This is where we'd create a new instance with the underlying error
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
        // This is where we'd create a new instance with the source
        // But since we don't have that functionality built in yet, we'll just return self
        self
    }
    
    /// CustomStringConvertible conformance
    public var description: String {
        errorDescription
    }
}

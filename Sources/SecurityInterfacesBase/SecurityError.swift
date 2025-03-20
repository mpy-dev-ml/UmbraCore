import CoreErrors
import ErrorHandlingDomains
import SecurityInterfacesProtocols
import UmbraCoreTypes
import XPCProtocolsCore

/// This file was previously defining a duplicated SecurityError enum
/// It now uses the canonical UmbraErrors.Security.Core type directly
/// and provides mapping functions to/from XPCSecurityError for compatibility

/// Mapping functions for converting between UmbraErrors.Security.Core and XPCSecurityError
public extension UmbraErrors.Security.Core {
    /// Initialize from a protocol error
    init(from protocolError: XPCSecurityError) {
        // Map from XPC error to core error
        switch protocolError {
        case .serviceUnavailable:
            self = .secureConnectionFailed(reason: "XPC service unavailable")
        case let .serviceNotReady(reason):
            self = .internalError(reason: "XPC service not ready: \(reason)")
        case let .timeout(after: interval):
            self = .internalError(reason: "XPC operation timed out after \(interval) seconds")
        case let .authenticationFailed(reason):
            self = .authenticationFailed(reason: reason)
        case let .authorizationDenied(operation):
            self = .authorizationFailed(reason: "XPC authorization denied for operation: \(operation)")
        case let .operationNotSupported(name):
            self = .internalError(reason: "XPC operation not supported: \(name)")
        case let .invalidInput(details):
            self = .internalError(reason: "XPC invalid input: \(details)")
        case let .invalidState(details):
            self = .internalError(reason: "XPC invalid state: \(details)")
        case let .keyNotFound(identifier):
            self = .internalError(reason: "XPC key not found: \(identifier)")
        case let .invalidKeyType(expected, received):
            self =
                .internalError(reason: "XPC invalid key type: expected \(expected), received \(received)")
        case let .cryptographicError(operation, details):
            self = .internalError(reason: "XPC cryptographic error: \(operation) - \(details)")
        case let .internalError(reason):
            self = .internalError(reason: "XPC internal error: \(reason)")
        case let .invalidData(reason):
            self = .internalError(reason: "XPC invalid data: \(reason)")
        case let .encryptionFailed(reason):
            self = .internalError(reason: "XPC encryption failed: \(reason)")
        case let .decryptionFailed(reason):
            self = .internalError(reason: "XPC decryption failed: \(reason)")
        case let .keyGenerationFailed(reason):
            self = .internalError(reason: "XPC key generation failed: \(reason)")
        case let .notImplemented(reason):
            self = .internalError(reason: "XPC operation not implemented: \(reason)")
        case .connectionInterrupted:
            self = .secureConnectionFailed(reason: "XPC connection interrupted")
        case let .connectionInvalidated(reason):
            self = .secureConnectionFailed(reason: "XPC connection invalidated: \(reason)")
        @unknown default:
            self = .internalError(reason: "Unknown XPC security error: \(protocolError)")
        }
    }

    /// Convert to a protocol error
    /// - Returns: A protocol error representation of this error, or nil if no good match
    func toProtocolError() -> XPCSecurityError? {
        // Map from core error to XPC error
        switch self {
        case let .authenticationFailed(reason):
            .authenticationFailed(reason: reason)
        case let .authorizationFailed(reason):
            .authorizationDenied(operation: reason)
        case .secureConnectionFailed:
            .serviceUnavailable
        case let .internalError(reason) where reason.contains("timed out"):
            .timeout(after: 30.0) // Default timeout
        case let .internalError(reason):
            .internalError(reason: reason)
        default:
            .internalError(reason: localizedDescription)
        }
    }
}

/// Extension on XPCSecurityError to provide mapping back to UmbraErrors.Security.Core
public extension XPCSecurityError {
    /// Convert to a core error
    /// - Returns: A core error representation of this protocol error
    func toCoreError() -> UmbraErrors.Security.Core {
        UmbraErrors.Security.Core(from: self)
    }
}

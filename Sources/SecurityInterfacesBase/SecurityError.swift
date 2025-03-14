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
        case let .timeout(interval):
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
            switch operation.lowercased() {
            case "encryption", "encrypt":
                self = .encryptionFailed(reason: details)
            case "decryption", "decrypt":
                self = .decryptionFailed(reason: details)
            case "hash", "hashing":
                self = .hashingFailed(reason: details)
            case "signature", "signing", "verify":
                self = .signatureInvalid(reason: details)
            default:
                self = .internalError(reason: "XPC cryptographic error in \(operation): \(details)")
            }
        case let .internalError(reason):
            self = .internalError(reason: "XPC internal error: \(reason)")
        case .connectionInterrupted:
            self = .secureConnectionFailed(reason: "XPC connection interrupted")
        case let .connectionInvalidated(reason):
            self = .secureConnectionFailed(reason: "XPC connection invalidated: \(reason)")
        @unknown default:
            self = .internalError(reason: "Unknown XPC security error: \(protocolError)")
        }
    }

    /// Convert to a protocol error if possible
    func toProtocolError() -> XPCSecurityError? {
        // Map from core error to XPC error
        switch self {
        case let .authenticationFailed(reason):
            return .authenticationFailed(reason: reason)
        case let .authorizationFailed(reason) where reason.contains("XPC authorization denied"):
            if let operation = reason.split(separator: ":").last?.trimmingCharacters(in: .whitespaces) {
                return .authorizationDenied(operation: operation)
            }
            return .authorizationDenied(operation: "unknown")
        case let .secureConnectionFailed(reason):
            if reason == "XPC service unavailable" {
                return .serviceUnavailable
            } else if reason == "XPC connection interrupted" {
                return .connectionInterrupted
            } else if reason.starts(with: "XPC connection invalidated:") {
                let reasonDetail = reason.replacingOccurrences(of: "XPC connection invalidated: ", with: "")
                return .connectionInvalidated(reason: reasonDetail)
            }
            return .internalError(reason: reason)
        case let .encryptionFailed(reason):
            return .cryptographicError(operation: "encryption", details: reason)
        case let .decryptionFailed(reason):
            return .cryptographicError(operation: "decryption", details: reason)
        case let .hashingFailed(reason):
            return .cryptographicError(operation: "hashing", details: reason)
        case let .signatureInvalid(reason):
            return .cryptographicError(operation: "signature", details: reason)
        case let .internalError(reason):
            if reason.starts(with: "XPC service not ready:") {
                let reasonDetail = reason.replacingOccurrences(of: "XPC service not ready: ", with: "")
                return .serviceNotReady(reason: reasonDetail)
            } else if reason.starts(with: "XPC operation not supported:") {
                let name = reason.replacingOccurrences(of: "XPC operation not supported: ", with: "")
                return .operationNotSupported(name: name)
            } else if reason.starts(with: "XPC invalid input:") {
                let details = reason.replacingOccurrences(of: "XPC invalid input: ", with: "")
                return .invalidInput(details: details)
            } else if reason.starts(with: "XPC invalid state:") {
                let details = reason.replacingOccurrences(of: "XPC invalid state: ", with: "")
                return .invalidState(details: details)
            } else if reason.starts(with: "XPC key not found:") {
                let identifier = reason.replacingOccurrences(of: "XPC key not found: ", with: "")
                return .keyNotFound(identifier: identifier)
            } else if reason.starts(with: "XPC invalid key type:") {
                // This is a simplification as parsing would be more complex
                return .invalidKeyType(expected: "unknown", received: "unknown")
            } else if reason.starts(with: "XPC cryptographic error in") {
                // This is a simplification as parsing would be more complex
                return .cryptographicError(operation: "unknown", details: reason)
            } else if reason.starts(with: "XPC operation timed out after") {
                // Extract timeout value if possible
                return .timeout(after: 30.0) // Default fallback
            } else if reason.starts(with: "XPC internal error:") {
                let innerReason = reason.replacingOccurrences(of: "XPC internal error: ", with: "")
                return .internalError(reason: innerReason)
            }
            return .internalError(reason: reason)
        default:
            return .invalidInput(details: localizedDescription)
        }
    }
}

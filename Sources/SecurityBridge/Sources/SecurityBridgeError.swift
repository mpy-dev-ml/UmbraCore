// DEPRECATED: // DEPRECATED: SecurityBridgeError
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore

/// Error types that can be thrown by the SecurityBridge module
// DEPRECATED: public extension SecurityBridge {
    /// Error types specific to the bridge layer
    // DEPRECATED: enum SecurityBridgeError: Error, Sendable, Equatable {
        /// Bookmark resolution failed
        case bookmarkResolutionFailed
        /// Implementation is missing
        case implementationMissing(String)
        /// Unable to locate a valid service
        case serviceUnavailable(String)
        /// General error with message
        case general(String)
    }
}

/// Mapper to convert between SecurityError and SecurityBridgeError
public enum SecurityBridgeErrorMapper {
    /// Maps any error to a Bridge-specific error representation
    ///
    /// This method delegates the core error mapping to the centralised mapper,
    /// then converts the standardised error to a bridge-specific representation.
    ///
    /// - Parameter error: The error to map
    /// - Returns: A SecurityBridgeError representation
    // DEPRECATED: public static func mapToBridgeError(_ error: Error) -> Error {
        // First, ensure we have a consistent UmbraErrors.Security.Protocols
        // DEPRECATED: let securityError = CoreErrors.SecurityErrorMapper.mapToProtocolError(error)

        // Convert to a bridge-specific error with appropriate message
        switch securityError {
        case let .invalidFormat(reason):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError.general("Invalid format: \(reason)")
        case let .unsupportedOperation(name):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError.general("Unsupported operation: \(name)")
        case let .incompatibleVersion(version):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError.general("Incompatible version: \(version)")
        case let .missingProtocolImplementation(protocolName):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError
                .serviceUnavailable("Missing protocol: \(protocolName)")
        case let .invalidState(state, expectedState):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError
                .general("Invalid state: \(state) (expected: \(expectedState))")
        case let .internalError(message):
            // DEPRECATED: return SecurityBridge.SecurityBridgeError.general(message)
        default:
            // For any other error cases, create a generic message
            let message: String = if
                // DEPRECATED: let localizedError = error as? LocalizedError,
                let errorDescription = localizedError.errorDescription
            {
                errorDescription
            } else {
                // DEPRECATED: "\(error)"
            }
            // Create a basic SecurityError with the message
            return UmbraErrors.Security.Protocols.internalError(message)
        }
    }

    /// Maps a bridge error to a SecurityError
    ///
    /// This method converts bridge-specific errors to the standardised SecurityError type
    /// using the centralised mapper.
    ///
    /// - Parameter error: The bridge error to map
    /// - Returns: A SecurityError
    // DEPRECATED: public static func mapToSecurityError(_ error: Error) -> Error {
        // If it's already a SecurityBridgeError, create a basic error message
        // DEPRECATED: if let bridgeError = error as? SecurityBridge.SecurityBridgeError {
            let message: String = switch bridgeError {
            case .bookmarkResolutionFailed:
                "Bookmark resolution failed"
            case let .implementationMissing(details):
                details
            case let .serviceUnavailable(details):
                details
            case let .general(details):
                details
            }
            // Create a basic SecurityError with the message
            return UmbraErrors.Security.Protocols.internalError(message)
        }

        // For all other error types, use our canonical mapper
        // DEPRECATED: return CoreErrors.SecurityErrorMapper.mapToProtocolError(error)
    }
}

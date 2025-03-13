/// XPC-specific error types and namespace extensions
///
/// This file provides XPC-specific error type extensions to support
/// the XPC Protocol Consolidation efforts.

import ErrorHandling
import ErrorHandlingDomains
import Foundation

/// Namespace for XPC-specific error types
public enum XPCErrors {
    /// XPC Security Error type
    /// This provides a clear namespace for XPC security errors
    public enum SecurityError: Error, Codable {
        /// Communication-related errors
        case connectionFailed(reason: String)
        case messagingError(description: String)
        case serverUnavailable(serviceName: String)

        /// Authentication and permission issues
        case authenticationFailed(reason: String)
        case permissionDenied(operation: String)

        /// Protocol compatibility and validation
        case invalidRequest(reason: String)
        case incompatibleProtocolVersion(clientVersion: String, serverVersion: String)
        case internalError(description: String)

        /// Maps between XPC security errors and canonical errors
        enum Mapper {
            /// Maps an error to its canonical form
            /// - Parameter error: The XPC security error
            /// - Returns: The canonical error as an opaque Any type
            static func mapToCanonical(_ error: SecurityError) -> Any {
                let canonicalError: UmbraErrors.GeneralSecurity.XPC = switch error {
                case let .connectionFailed(reason):
                    .connectionFailed(reason: reason)
                case let .messagingError(description):
                    .invalidResponse(reason: description)
                case .serverUnavailable:
                    .serviceUnavailable
                case let .authenticationFailed(reason):
                    // Map to a general internal error since there's no direct equivalent
                    .internalError("Authentication failed: \(reason)")
                case let .permissionDenied(operation):
                    // Map to a general internal error since there's no direct equivalent
                    .internalError("Permission denied for operation: \(operation)")
                case let .invalidRequest(reason):
                    .invalidResponse(reason: reason)
                case let .incompatibleProtocolVersion(clientVersion, serverVersion):
                    .versionMismatch(expected: serverVersion, found: clientVersion)
                case let .internalError(description):
                    .internalError(description)
                @unknown default:
                    .internalError("Unknown XPC error")
                }

                return canonicalError
            }

            /// Maps a canonical error to an XPC security error
            /// - Parameter error: The canonical error as Any
            /// - Returns: An XPC security error if conversion is possible, nil otherwise
            static func mapFromCanonical(_ error: Any) -> SecurityError? {
                guard let canonicalError = error as? UmbraErrors.GeneralSecurity.XPC else {
                    return nil
                }

                switch canonicalError {
                case let .connectionFailed(reason):
                    return .connectionFailed(reason: reason)
                case .serviceUnavailable:
                    return .serverUnavailable(serviceName: "Unknown service")
                case let .invalidResponse(reason):
                    return .invalidRequest(reason: reason)
                case let .unexpectedSelector(name):
                    return .invalidRequest(reason: "Unexpected selector: \(name)")
                case let .versionMismatch(expected, found):
                    return .incompatibleProtocolVersion(clientVersion: found, serverVersion: expected)
                case .invalidServiceIdentifier:
                    return .serverUnavailable(serviceName: "Invalid service identifier")
                case let .internalError(description):
                    return .internalError(description: description)
                @unknown default:
                    return .internalError(description: "Unknown XPC error")
                }
            }
        }

        /// Converts this error to its canonical form
        /// - Returns: The canonical error as an opaque Any type
        public func toCanonical() -> Any {
            Mapper.mapToCanonical(self)
        }

        /// Creates a SecurityError from a canonical error
        /// - Parameter canonicalError: The canonical error as Any
        /// - Returns: A SecurityError if conversion is possible, nil otherwise
        public static func fromCanonical(_ canonicalError: Any) -> SecurityError? {
            Mapper.mapFromCanonical(canonicalError)
        }
    }

    /// XPC Service Error type alias
    /// @available(*, deprecated, message: "Use ServiceError directly")
    public typealias ServiceError = CoreErrors.ServiceError

    /// XPC Crypto Error type alias
    /// @available(*, deprecated, message: "Use CryptoError directly")
    public typealias CryptoError = CoreErrors.CryptoError
}

/// A collection of utility methods for converting between error types
public enum SecurityErrorConversion {
    /// Converts a Security Core error to an XPC-specific representation
    /// - Parameter error: The core error as Any
    /// - Returns: The XPC error as Any or nil if conversion is not possible
    public static func coreToXPC(_ error: Any) -> Any? {
        guard let coreError = error as? UmbraErrors.GeneralSecurity.Core else {
            return nil
        }

        return SecurityErrorMapper.mapToXPCError(coreError)
    }

    /// Converts an XPC-specific error to a Core representation
    /// - Parameter error: The XPC error as Any
    /// - Returns: The Core error as Any or nil if conversion is not possible
    public static func xpcToCore(_ error: Any) -> Any? {
        guard let xpcError = error as? UmbraErrors.GeneralSecurity.XPC else {
            return nil
        }

        return SecurityErrorMapper.mapToCoreError(xpcError)
    }

    /// Converts a Protocol error to an XPC-specific representation
    /// - Parameter error: The protocol error as Any
    /// - Returns: The XPC error as Any or nil if conversion is not possible
    public static func protocolToXPC(_ error: Any) -> Any? {
        guard let protocolError = error as? UmbraErrors.GeneralSecurity.Protocols else {
            return nil
        }

        return SecurityErrorMapper.mapToXPCError(protocolError)
    }

    /// Converts an XPC-specific error to a Protocol representation
    /// - Parameter error: The XPC error as Any
    /// - Returns: The Protocol error as Any or nil if conversion is not possible
    public static func xpcToProtocol(_ error: Any) -> Any? {
        guard let xpcError = error as? UmbraErrors.GeneralSecurity.XPC else {
            return nil
        }

        return SecurityErrorMapper.mapToProtocolError(xpcError)
    }
}

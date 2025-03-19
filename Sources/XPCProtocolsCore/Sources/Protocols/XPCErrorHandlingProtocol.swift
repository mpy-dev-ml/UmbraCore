/**
 # XPC Error Handling Protocol

 This file defines a standardised approach to error handling across XPC services
 in UmbraCore. It provides consistent error types, conversion methods, and error
 propagation patterns that can be used by any XPC service.

 ## Features

 * Unified error type definitions
 * Common error conversion patterns
 * Error mapping between different domains
 * Result-based error handling utilities

 This protocol ensures consistent error handling across all XPC services
 and provides a foundation for robust error management.
 */

import CoreErrors
import ErrorHandling
import Foundation
import UmbraCoreTypes

/// Protocol defining a standardised approach to error handling for XPC services.
/// This protocol can be adopted by any XPC service to ensure consistent error
/// handling patterns across the codebase.
public protocol XPCErrorHandlingProtocol {
    /// Convert a Foundation Error to an XPCSecurityError
    /// - Parameter error: The Error to convert
    /// - Returns: Equivalent XPCSecurityError
    func convertToXPCError(_ error: Error) -> XPCSecurityError

    /// Convert an XPCSecurityError to a general Error
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: Equivalent Error
    func convertToError(_ error: XPCSecurityError) -> Error

    /// Convert any Swift error to an XPCSecurityError
    /// - Parameter error: The error to convert
    /// - Returns: Equivalent XPCSecurityError
    func mapError(_ error: Error) -> XPCSecurityError
}

/// Default implementations for the XPC error handling protocol
public extension XPCErrorHandlingProtocol {
    /// Default implementation for converting Error to XPCSecurityError
    func convertToXPCError(_ error: Error) -> XPCSecurityError {
        // If it's already an XPCSecurityError, return it directly
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }

        // Handle common Foundation error domains
        let nsError = error as NSError
        if nsError.domain == URLError.errorDomain {
            let errorCode = nsError.code
            switch errorCode {
            case URLError.timedOut.rawValue, URLError.cannotConnectToHost.rawValue:
                return .serviceUnavailable
            case URLError.networkConnectionLost.rawValue:
                return .connectionInterrupted
            default:
                return .internalError(reason: "Network error \(errorCode): \(nsError.localizedDescription)")
            }
        }

        // Generic mapping from Error to XPCSecurityError
        return .internalError(reason: error.localizedDescription)
    }

    /// Default implementation for converting XPCSecurityError to Error
    func convertToError(_ error: XPCSecurityError) -> Error {
        // Simply return the XPCSecurityError as it already conforms to Error
        return error
    }

    /// Map any Swift error to an XPCSecurityError
    func mapError(_ error: Error) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        } else {
            // Convert generic errors to XPCSecurityError
            return .internalError(reason: "\(type(of: error)) error: \(error.localizedDescription)")
        }
    }
}

/// Extension to provide Result-based error handling utilities
public extension XPCErrorHandlingProtocol {
    /// Convert a throwing function call to a Result
    /// - Parameter operation: The operation to perform
    /// - Returns: Success with the operation result or failure with an XPCSecurityError
    func withErrorHandling<T>(_ operation: () throws -> T) -> Result<T, XPCSecurityError> {
        do {
            let result = try operation()
            return .success(result)
        } catch {
            return .failure(mapError(error))
        }
    }

    /// Convert an async throwing function call to a Result
    /// - Parameter operation: The async operation to perform
    /// - Returns: Success with the operation result or failure with an XPCSecurityError
    func withAsyncErrorHandling<T>(_ operation: () async throws -> T) async -> Result<T, XPCSecurityError> {
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            return .failure(mapError(error))
        }
    }
}

// Extension for common error transforms
public extension XPCErrorHandlingProtocol {
    /// Transform a Result<T, Error> to Result<T, XPCSecurityError>
    /// - Parameter result: Original result with generic Error
    /// - Returns: Result with XPCSecurityError
    func transformResult<T>(_ result: Result<T, Error>) -> Result<T, XPCSecurityError> {
        result.mapError { mapError($0) }
    }
}

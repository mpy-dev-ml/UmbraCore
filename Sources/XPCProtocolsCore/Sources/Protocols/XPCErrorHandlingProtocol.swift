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

import Foundation
import CoreErrors
import ErrorHandling
import UmbraCoreTypes

/// Protocol defining a standardised approach to error handling for XPC services.
/// This protocol can be adopted by any XPC service to ensure consistent error
/// handling patterns across the codebase.
public protocol XPCErrorHandlingProtocol {
    /// Convert an NSError to an XPCSecurityError
    /// - Parameter error: The NSError to convert
    /// - Returns: Equivalent XPCSecurityError
    func convertToXPCError(_ error: NSError) -> XPCSecurityError
    
    /// Convert an XPCSecurityError to an NSError
    /// - Parameter error: The XPCSecurityError to convert
    /// - Returns: Equivalent NSError
    func convertToNSError(_ error: XPCSecurityError) -> NSError
    
    /// Convert any Swift error to an XPCSecurityError
    /// - Parameter error: The error to convert
    /// - Returns: Equivalent XPCSecurityError
    func mapError(_ error: Error) -> XPCSecurityError
}

/// Default implementations for the XPC error handling protocol
public extension XPCErrorHandlingProtocol {
    /// Default implementation for converting NSError to XPCSecurityError
    func convertToXPCError(_ error: NSError) -> XPCSecurityError {
        // Handle common Foundation error domains
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorTimedOut, NSURLErrorCannotConnectToHost:
                return .serviceUnavailable
            case NSURLErrorNetworkConnectionLost:
                return .connectionFailed(reason: error.localizedDescription)
            default:
                return .networkError(code: error.code, message: error.localizedDescription)
            }
        }
        
        // Generic mapping for other NSError types
        return .unspecifiedError(description: error.localizedDescription, code: error.code)
    }
    
    /// Default implementation for converting XPCSecurityError to NSError
    func convertToNSError(_ error: XPCSecurityError) -> NSError {
        let domain = "com.umbra.xpc.security"
        var code = -1
        var userInfo: [String: Any] = [:]
        
        switch error {
        case .serviceUnavailable:
            code = 1001
            userInfo[NSLocalizedDescriptionKey] = "Service is not available"
        case .serviceNotReady(let reason):
            code = 1002
            userInfo[NSLocalizedDescriptionKey] = "Service not ready: \(reason)"
        case .timeout(let interval):
            code = 1003
            userInfo[NSLocalizedDescriptionKey] = "Operation timed out after \(interval) seconds"
        case .authenticationFailed(let reason):
            code = 2001
            userInfo[NSLocalizedDescriptionKey] = "Authentication failed: \(reason)"
        case .authorizationDenied(let operation):
            code = 2002
            userInfo[NSLocalizedDescriptionKey] = "Authorization denied for operation: \(operation)"
        case .operationNotSupported(let name):
            code = 3001
            userInfo[NSLocalizedDescriptionKey] = "Operation not supported: \(name)"
        case .invalidInput(let details):
            code = 3002
            userInfo[NSLocalizedDescriptionKey] = "Invalid input: \(details)"
        case .invalidState(let details):
            code = 3003
            userInfo[NSLocalizedDescriptionKey] = "Invalid state: \(details)"
        case .keyNotFound(let identifier):
            code = 4001
            userInfo[NSLocalizedDescriptionKey] = "Key not found: \(identifier)"
        case .invalidKeyType(let expected, let received):
            code = 4002
            userInfo[NSLocalizedDescriptionKey] = "Invalid key type. Expected: \(expected), received: \(received)"
        case .cryptographicError(let operation, let details):
            code = 5001
            userInfo[NSLocalizedDescriptionKey] = "Cryptographic error in \(operation): \(details)"
        case .internalError(let reason):
            code = 9001
            userInfo[NSLocalizedDescriptionKey] = "Internal error: \(reason)"
        case .connectionInterrupted:
            code = 9002
            userInfo[NSLocalizedDescriptionKey] = "Connection interrupted"
        case .connectionInvalidated(let reason):
            code = 9003
            userInfo[NSLocalizedDescriptionKey] = "Connection invalidated: \(reason)"
        case .operationFailed(let operation, let reason):
            code = 9004
            userInfo[NSLocalizedDescriptionKey] = "Operation \(operation) failed: \(reason)"
        }
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    /// Map any Swift error to an XPCSecurityError
    func mapError(_ error: Error) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        } else {
            // All Swift errors can be cast to NSError
            let nsError = error as NSError
            // Basic mapping from NSError to XPCSecurityError
            return .internalError(reason: "\(nsError.domain) error \(nsError.code): \(nsError.localizedDescription)")
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
    
    /// Convert a throwing async function call to a Result
    /// - Parameter operation: The async operation to perform
    /// - Returns: Success with the operation result or failure with an XPCSecurityError
    func withErrorHandling<T>(_ operation: () async throws -> T) async -> Result<T, XPCSecurityError> {
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            return .failure(mapError(error))
        }
    }
}

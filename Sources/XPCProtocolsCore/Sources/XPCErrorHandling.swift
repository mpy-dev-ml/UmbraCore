/**
 # XPC Error Handling

 This file defines error handling patterns for XPC communications, including
 structured error types and conversion utilities. Error handling in XPC requires special
 considerations due to the cross-process nature of these interactions.

 ## Features

 * Comprehensive error type hierarchy for XPC communications
 * Error conversion utilities between different domains
 * Structured error types with descriptive information
 * Support for error serialisation across process boundaries

 ## Usage

 Errors are handled using the Result type with specific error payloads:

 ```swift
 func performOperation() async -> Result<Data, XPCSecurityError> {
   guard isReady else {
     return .failure(.serviceNotReady(reason: "Service initialization incomplete"))
   }

   // Implementation...
   return .success(resultData)
 }
 ```

 ## Error Types

 The module provides a range of specific error types for different failure scenarios, allowing
 precise error handling and appropriate user feedback.
 */

import CoreErrors
import ErrorHandling
import Foundation

/// Standard error type used throughout the XPC protocol system
public enum XPCSecurityError: Error, Equatable, Sendable {
    /// The XPC service is not available
    case serviceUnavailable

    /// The XPC service is not ready to handle requests
    case serviceNotReady(reason: String)

    /// The XPC operation timed out
    case timeout(after: TimeInterval)

    /// Authentication with the XPC service failed
    case authenticationFailed(reason: String)

    /// Authorization to perform the requested operation was denied
    case authorizationDenied(operation: String)

    /// The requested operation is not supported by this implementation
    case operationNotSupported(name: String)

    /// The provided input was invalid for the requested operation
    case invalidInput(details: String)

    /// The provided data was invalid for the requested operation
    case invalidData(reason: String)

    /// Encryption operation failed
    case encryptionFailed(reason: String)

    /// The operation failed due to invalid state
    case invalidState(details: String)

    /// The key with the specified identifier could not be found
    case keyNotFound(identifier: String)

    /// The operation required a key of one type but received another
    case invalidKeyType(expected: String, received: String)

    /// A cryptographic operation failed
    case cryptographicError(operation: String, details: String)

    /// Decryption failed with a specific reason
    case decryptionFailed(reason: String)

    /// Key generation failed with a specific reason
    case keyGenerationFailed(reason: String)

    /// The operation is not implemented
    case notImplemented(reason: String)

    /// An internal error occurred that cannot be exposed for security reasons
    case internalError(reason: String)

    /// The XPC connection was interrupted
    case connectionInterrupted

    /// The XPC connection was invalidated
    case connectionInvalidated(reason: String)

    /// Equality implementation for XPCSecurityError
    public static func == (lhs: XPCSecurityError, rhs: XPCSecurityError) -> Bool {
        switch (lhs, rhs) {
        case (.serviceUnavailable, .serviceUnavailable):
            true
        case let (.serviceNotReady(lhsReason), .serviceNotReady(rhsReason)):
            lhsReason == rhsReason
        case let (.timeout(lhsTime), .timeout(rhsTime)):
            lhsTime == rhsTime
        case let (.authenticationFailed(lhsReason), .authenticationFailed(rhsReason)):
            lhsReason == rhsReason
        case let (.authorizationDenied(lhsOp), .authorizationDenied(rhsOp)):
            lhsOp == rhsOp
        case let (.operationNotSupported(lhsName), .operationNotSupported(rhsName)):
            lhsName == rhsName
        case let (.invalidInput(lhsDetails), .invalidInput(rhsDetails)):
            lhsDetails == rhsDetails
        case let (.invalidData(lhsReason), .invalidData(rhsReason)):
            lhsReason == rhsReason
        case let (.encryptionFailed(lhsReason), .encryptionFailed(rhsReason)):
            lhsReason == rhsReason
        case let (.invalidState(lhsDetails), .invalidState(rhsDetails)):
            lhsDetails == rhsDetails
        case let (.keyNotFound(lhsId), .keyNotFound(rhsId)):
            lhsId == rhsId
        case let (.invalidKeyType(lhsExp, lhsRec), .invalidKeyType(rhsExp, rhsRec)):
            lhsExp == rhsExp && lhsRec == rhsRec
        case let (.cryptographicError(lhsOp, lhsDetails), .cryptographicError(rhsOp, rhsDetails)):
            lhsOp == rhsOp && lhsDetails == rhsDetails
        case let (.decryptionFailed(lhsReason), .decryptionFailed(rhsReason)):
            lhsReason == rhsReason
        case let (.keyGenerationFailed(lhsReason), .keyGenerationFailed(rhsReason)):
            lhsReason == rhsReason
        case let (.notImplemented(lhsReason), .notImplemented(rhsReason)):
            lhsReason == rhsReason
        case let (.internalError(lhsReason), .internalError(rhsReason)):
            lhsReason == rhsReason
        case (.connectionInterrupted, .connectionInterrupted):
            true
        case let (.connectionInvalidated(lhsReason), .connectionInvalidated(rhsReason)):
            lhsReason == rhsReason
        default:
            false
        }
    }
}

/// Service status information returned by XPC services
public enum XPCServiceStatusType: String, Codable, Sendable {
    /// Service is fully operational
    case operational

    /// Service is starting up
    case initializing

    /// Service is in maintenance mode
    case maintenance

    /// Service is shutting down
    case shuttingDown

    /// Service has encountered an error but is still responsive
    case degraded

    /// Service has experienced a critical failure
    case failed
}

/// Extension for error locality information
extension XPCSecurityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            "XPC service is unavailable"
        case let .serviceNotReady(reason):
            "XPC service is not ready: \(reason)"
        case let .timeout(after):
            "XPC operation timed out after \(after) seconds"
        case let .authenticationFailed(reason):
            "Authentication with XPC service failed: \(reason)"
        case let .authorizationDenied(operation):
            "Authorization denied for operation: \(operation)"
        case let .operationNotSupported(name):
            "Operation not supported: \(name)"
        case let .invalidInput(details):
            "Invalid input: \(details)"
        case let .invalidData(reason):
            "Invalid data: \(reason)"
        case let .encryptionFailed(reason):
            "Encryption failed: \(reason)"
        case let .invalidState(details):
            "Invalid state: \(details)"
        case let .keyNotFound(identifier):
            "Key not found: \(identifier)"
        case let .invalidKeyType(expected, received):
            "Invalid key type: expected \(expected), received \(received)"
        case let .cryptographicError(operation, details):
            "Cryptographic error in \(operation): \(details)"
        case let .decryptionFailed(reason):
            "Decryption failed: \(reason)"
        case let .keyGenerationFailed(reason):
            "Key generation failed: \(reason)"
        case let .notImplemented(reason):
            "Operation not implemented: \(reason)"
        case let .internalError(reason):
            "Internal error: \(reason)"
        case .connectionInterrupted:
            "XPC connection interrupted"
        case let .connectionInvalidated(reason):
            "XPC connection invalidated: \(reason)"
        }
    }
}

/// Utilities for working with XPC errors
public enum XPCErrorUtilities {
    /// Convert a generic Error to an appropriate XPCSecurityError
    /// - Parameter error: Original error to convert
    /// - Returns: Equivalent XPCSecurityError
    public static func convertToXPCError(_ error: Error) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }
        
        // Handle CoreErrors.CryptoError specifically
        if let cryptoError = error as? CoreErrors.CryptoError {
            let operation: String
            let details: String
            
            switch cryptoError {
            case .encryptionFailed(let reason):
                operation = "encryption"
                details = reason
            case .decryptionFailed(let reason):
                operation = "decryption"
                details = reason
            case .keyGenerationFailed:
                operation = "key generation"
                details = "Key generation failed"
            case .keyDerivationFailed(let reason):
                operation = "key derivation"
                details = reason
            case .authenticationFailed(let reason):
                operation = "authentication"
                details = reason
            case let .invalidKeyLength(expected, got):
                operation = "key validation"
                details = "Invalid key length: expected \(expected), got \(got)"
            case .invalidKey(let reason):
                operation = "key validation"
                details = reason
            default:
                operation = "cryptographic operation"
                details = String(describing: cryptoError)
            }
            
            return .cryptographicError(operation: operation, details: details)
        }

        let nsError = error as NSError

        // Check for common error domains and convert appropriately
        switch nsError.domain {
        case NSURLErrorDomain:
            if nsError.code == NSURLErrorTimedOut {
                return .timeout(after: 30.0) // Default timeout
            } else {
                return .connectionInterrupted
            }

        case "XPCConnectionErrorDomain":
            return .connectionInvalidated(reason: nsError.localizedDescription)

        case "CryptoErrorDomain":
            return .cryptographicError(operation: "Unspecified", details: nsError.localizedDescription)

        default:
            return .internalError(reason: "Unknown error: \(nsError.localizedDescription)")
        }
    }
}

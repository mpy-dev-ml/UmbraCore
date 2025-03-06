// ErrorTypes.swift
// Defines protocols and types for error handling and conversion

import CoreErrors

/// Protocol for error types that can be converted to SecurityError
public protocol SecurityErrorConvertible: Error, Sendable {
    /// Convert this error to a SecurityError
    func toSecurityError() -> CoreErrors.SecurityError
    
    /// Create an instance of this error type from a SecurityError
    static func fromSecurityError(_ error: CoreErrors.SecurityError) -> Self
}

/// Protocol for error types that can be serialized for XPC transport
public protocol XPCTransportableError: Error, Sendable {
    /// Convert to a standard error representation for XPC transport
    func toTransportableError() -> CoreErrors.SecurityError
    
    /// Create from a standard error representation received via XPC
    static func fromTransportableError(_ error: CoreErrors.SecurityError) -> Self
}

/// Type alias for clarity when working with SecurityError from CoreErrors
public typealias CoreSecurityError = CoreErrors.SecurityError

/// Custom result type with standard error handling
public typealias SecurityResult<Success> = Result<Success, CoreSecurityError>

/// Error domain identifier for core security errors
public let coreSecurityErrorDomain = "com.umbra.core.security"

/// Base protocol for all security-related errors
public protocol SecurityError: Error, Sendable, CustomStringConvertible {
    /// A descriptive error code
    var errorCode: Int { get }
    
    /// The error domain
    var errorDomain: String { get }
    
    /// Human-readable error description
    var errorDescription: String { get }
}

/// Extension providing default implementation for SecurityError
public extension SecurityError {
    var errorDomain: String {
        coreSecurityErrorDomain
    }
    
    var description: String {
        errorDescription
    }
}

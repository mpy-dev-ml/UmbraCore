// SecurityErrorDomain.swift
// Security error domain implementation
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingProtocols
import ErrorHandlingCommon
import ErrorHandlingModels

/// Enum representing specific security error types
public enum SecurityErrorType: Error {
    /// Authentication failure (invalid credentials, expired token, etc.)
    case authenticationFailed(String)
    
    /// Authorization failure (insufficient permissions)
    case authorizationFailed(String)
    
    /// Cryptographic operation failure
    case cryptoOperationFailed(String)
    
    /// Invalid certificate or certificate chain
    case invalidCertificate(String)
    
    /// Security policy violation
    case policyViolation(String)
    
    /// Secure connection failure
    case connectionFailed(String)
    
    /// Secure storage failure
    case storageFailed(String)
    
    /// Tampered data detected
    case tamperedData(String)
    
    /// Generic security error
    case generalError(String)
    
    /// Get a code string for this error type
    var code: String {
        switch self {
        case .authenticationFailed: return "auth_failed"
        case .authorizationFailed: return "authorization_failed"
        case .cryptoOperationFailed: return "crypto_failed"
        case .invalidCertificate: return "invalid_certificate"
        case .policyViolation: return "policy_violation"
        case .connectionFailed: return "connection_failed"
        case .storageFailed: return "storage_failed"
        case .tamperedData: return "tampered_data"
        case .generalError: return "general_error"
        }
    }
    
    /// Get a descriptive message for this error type
    var message: String {
        switch self {
        case .authenticationFailed(let message): return "Authentication failed: \(message)"
        case .authorizationFailed(let message): return "Authorization failed: \(message)"
        case .cryptoOperationFailed(let message): return "Cryptographic operation failed: \(message)"
        case .invalidCertificate(let message): return "Invalid certificate: \(message)"
        case .policyViolation(let message): return "Security policy violation: \(message)"
        case .connectionFailed(let message): return "Secure connection failed: \(message)"
        case .storageFailed(let message): return "Secure storage failed: \(message)"
        case .tamperedData(let message): return "Tampered data detected: \(message)"
        case .generalError(let message): return "Security error: \(message)"
        }
    }
}

/// Protocol for domain-specific error types
public protocol DomainError: Error {
    /// The error domain
    static var domain: String { get }
}

/// Struct wrapper for security errors that conforms to UmbraError
public struct UmbraSecurityError: Error, UmbraError, Sendable {
    /// The specific security error type
    public let errorType: SecurityErrorType
    
    /// The domain for security errors
    public let domain: String = "Security"
    
    /// The error code
    public var code: String {
        errorType.code
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
        errorType.message
    }
    
    /// Source information about where the error occurred
    public let source: ErrorHandlingCommon.ErrorSource?
    
    /// The underlying error, if any
    public let underlyingError: Error?
    
    /// Additional context for the error
    public let context: ErrorHandlingCommon.ErrorContext
    
    /// Initialize a new security error
    public init(
        errorType: SecurityErrorType,
        source: ErrorHandlingCommon.ErrorSource? = nil,
        underlyingError: Error? = nil,
        context: ErrorHandlingCommon.ErrorContext? = nil
    ) {
        self.errorType = errorType
        self.source = source
        self.underlyingError = underlyingError
        self.context = context ?? ErrorHandlingCommon.ErrorContext(
            source: "Security",
            operation: "securityOperation",
            details: errorType.message
        )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> Self {
        UmbraSecurityError(
            errorType: self.errorType,
            source: self.source,
            underlyingError: self.underlyingError,
            context: context
        )
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
        UmbraSecurityError(
            errorType: self.errorType,
            source: self.source,
            underlyingError: underlyingError,
            context: self.context
        )
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
        UmbraSecurityError(
            errorType: self.errorType,
            source: source,
            underlyingError: self.underlyingError,
            context: self.context
        )
    }
    
    /// Create a security error with the specified type and message
    public static func create(
        _ type: SecurityErrorType,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> UmbraSecurityError {
        UmbraSecurityError(
            errorType: type,
            source: ErrorHandlingCommon.ErrorSource(
                file: file,
                function: function,
                line: line
            )
        )
    }
    
    // MARK: - Convenience Initializers
    
    /// Convenience function to create an authentication failed error
    /// - Parameters:
    ///   - message: Error message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    /// - Returns: A UmbraSecurityError with authenticationFailed type
    public static func authenticationFailed(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> UmbraSecurityError {
        create(.authenticationFailed(message), file: file, function: function, line: line)
    }
    
    /// Convenience function to create an authorization failed error
    /// - Parameters:
    ///   - message: Error message
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    /// - Returns: A UmbraSecurityError with authorizationFailed type
    public static func authorizationFailed(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> UmbraSecurityError {
        create(.authorizationFailed(message), file: file, function: function, line: line)
    }
    
    // Add more convenience methods as needed
}

// SecurityErrorDomain.swift
// Security error domain implementation
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// Security-related errors
public enum SecurityError: UmbraError, DomainError {
    /// The domain for security errors
    public static let domain = "Security"
    
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
    
    // MARK: - UmbraError Protocol
    
    /// The error code
    public var code: String {
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
    
    /// Human-readable error description
    public var errorDescription: String {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .authorizationFailed(let message):
            return "Authorization failed: \(message)"
        case .cryptoOperationFailed(let message):
            return "Cryptographic operation failed: \(message)"
        case .invalidCertificate(let message):
            return "Invalid certificate: \(message)"
        case .policyViolation(let message):
            return "Security policy violation: \(message)"
        case .connectionFailed(let message):
            return "Secure connection failed: \(message)"
        case .storageFailed(let message):
            return "Secure storage operation failed: \(message)"
        case .tamperedData(let message):
            return "Tampered data detected: \(message)"
        case .generalError(let message):
            return "Security error: \(message)"
        }
    }
    
    /// Source information (where the error occurred)
    public private(set) var source: ErrorSource?
    
    /// Optional underlying error
    public private(set) var underlyingError: Error?
    
    /// Additional context information
    public private(set) var context: ErrorContext = ErrorContext(
        source: SecurityError.domain,
        message: "Security error"
    )
    
    // MARK: - Modifiers
    
    /// Creates a new instance with additional context
    /// - Parameter context: The context to add
    /// - Returns: A new SecurityError with the added context
    public func with(context: ErrorContext) -> SecurityError {
        var result = self
        result.context = context
        return result
    }
    
    /// Creates a new instance with an underlying error
    /// - Parameter underlyingError: The underlying error to add
    /// - Returns: A new SecurityError with the underlying error
    public func with(underlyingError: Error) -> SecurityError {
        var result = self
        result.underlyingError = underlyingError
        return result
    }
    
    /// Creates a new instance with source information
    /// - Parameter source: The source information to add
    /// - Returns: A new SecurityError with the source information
    public func with(source: ErrorSource) -> SecurityError {
        var result = self
        result.source = source
        return result
    }
}

// MARK: - Convenience Functions

/// Convenience function to create an authentication failed error
/// - Parameters:
///   - message: Error message
///   - file: Source file (auto-filled by the compiler)
///   - line: Line number (auto-filled by the compiler)
///   - function: Function name (auto-filled by the compiler)
/// - Returns: A SecurityError.authenticationFailed with source information
public func authenticationFailedError(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) -> SecurityError {
    let error = SecurityError.authenticationFailed(message)
    return ErrorFactory.makeError(error, file: file, line: line, function: function)
}

/// Convenience function to create an authorization failed error
/// - Parameters:
///   - message: Error message
///   - file: Source file (auto-filled by the compiler)
///   - line: Line number (auto-filled by the compiler)
///   - function: Function name (auto-filled by the compiler)
/// - Returns: A SecurityError.authorizationFailed with source information
public func authorizationFailedError(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) -> SecurityError {
    let error = SecurityError.authorizationFailed(message)
    return ErrorFactory.makeError(error, file: file, line: line, function: function)
}

/// Convenience function to create a cryptographic operation failed error
/// - Parameters:
///   - message: Error message
///   - underlyingError: Optional underlying error
///   - file: Source file (auto-filled by the compiler)
///   - line: Line number (auto-filled by the compiler)
///   - function: Function name (auto-filled by the compiler)
/// - Returns: A SecurityError.cryptoOperationFailed with source information
public func cryptoFailedError(
    _ message: String,
    underlyingError: Error? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) -> SecurityError {
    let error = SecurityError.cryptoOperationFailed(message)
    var result = ErrorFactory.makeError(error, file: file, line: line, function: function)
    
    if let underlyingError = underlyingError {
        result = result.with(underlyingError: underlyingError)
    }
    
    return result
}

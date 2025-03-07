// ErrorHandlingProtocol.swift
// Core protocols for error handling
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingCommon

/// Error Handling Protocol
/// Defines the public interface for error handling operations.
public protocol ErrorHandlingProtocol {
  // Protocol will be implemented
}

/// A protocol that all UmbraCore errors must conform to.
/// This provides a consistent interface for error handling across the codebase.
public protocol UmbraError: Error, Sendable, CustomStringConvertible {
    /// The domain that this error belongs to, e.g., "Security", "Repository"
    var domain: String { get }
    
    /// A unique code that identifies this error within its domain
    var code: String { get }
    
    /// A human-readable description of the error
    var errorDescription: String { get }
    
    /// Optional source information about where the error occurred
    var source: ErrorHandlingCommon.ErrorSource? { get }
    
    /// Optional underlying error that caused this error
    var underlyingError: Error? { get }
    
    /// Additional context information about the error
    var context: ErrorHandlingCommon.ErrorContext { get }
    
    /// Creates a new instance of the error with additional context
    func with(context: ErrorHandlingCommon.ErrorContext) -> Self
    
    /// Creates a new instance of the error with a specified underlying error
    func with(underlyingError: Error) -> Self
    
    /// Creates a new instance of the error with source information
    func with(source: ErrorHandlingCommon.ErrorSource) -> Self
}

/// Default implementation for UmbraError
public extension UmbraError {
    var description: String {
        var desc = "[\(domain):\(code)] \(errorDescription)"
        
        if let source = source {
            desc += " (at \(source.function) in \(source.file):\(source.line))"
        }
        
        return desc
    }
    
    /// Default implementation returns an empty context
    var context: ErrorHandlingCommon.ErrorContext {
        return ErrorHandlingCommon.ErrorContext(
            source: domain,
            operation: "unknown",
            details: errorDescription
        )
    }
    
    /// Default implementation returns the underlying error as is
    func with(underlyingError: Error) -> Self {
        self
    }
    
    /// Default implementation returns nil
    var source: ErrorHandlingCommon.ErrorSource? {
        return nil
    }
}

/// Extension to add conveniences for UmbraError
public extension UmbraError {
    /// Create a new instance of the error with source location information
    ///
    /// - Parameters:
    ///   - file: The file where the error occurred (defaults to current file)
    ///   - line: The line where the error occurred (defaults to current line)
    ///   - function: The function where the error occurred (defaults to current function)
    /// - Returns: A new instance of the error with source information
    func withSource(file: String = #file, function: String = #function, line: Int = #line) -> Self {
        with(source: ErrorHandlingCommon.ErrorSource(file: file, function: function, line: line))
    }
}

/// A protocol for domain-specific error types
public protocol DomainError: UmbraError {
    /// The domain identifier for this error type
    static var domain: String { get }
}

/// Default implementation for DomainError
public extension DomainError {
    var domain: String {
        return Self.domain
    }
}

/// Error severity levels for classification and logging
public enum ErrorSeverity: String, Comparable, Sendable {
    /// Critical error that requires immediate attention
    case critical = "Critical"
    
    /// Error that significantly affects functionality
    case error = "Error"
    
    /// Warning about potential issues or degraded service
    case warning = "Warning"
    
    /// Informational message about non-critical events
    case info = "Information"
    
    /// Debug information for development purposes
    case debug = "Debug"
    
    /// Returns true if this severity level should trigger a user notification
    public var shouldNotify: Bool {
        switch self {
        case .critical, .error:
            return true
        case .warning, .info, .debug:
            return false
        }
    }
    
    public static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
        let order: [ErrorSeverity] = [.debug, .info, .warning, .error, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// Protocol for error recovery options
public protocol RecoveryOption: Sendable {
    /// The title of the recovery option
    var title: String { get }
    
    /// Additional description of the recovery option
    var description: String? { get }
    
    /// Action to perform when the recovery option is selected
    func perform() async
}

/// Protocol for providing recovery options for errors
public protocol RecoveryOptionsProvider {
    /// Get recovery options for a specific error
    /// - Parameter error: The error to get recovery options for
    /// - Returns: Array of recovery options
    func recoveryOptions<E: UmbraError>(for error: E) -> [RecoveryOption]
}

/// Protocol for error logging services
public protocol ErrorLoggingProtocol {
    /// Log an error with the specified severity
    /// - Parameters:
    ///   - error: The error to log
    ///   - severity: The severity of the error
    func log<E: UmbraError>(error: E, severity: ErrorSeverity)
    
    /// Log an error with debug severity
    /// - Parameter error: The error to log
    func logDebug<E: UmbraError>(_ error: E)
    
    /// Log an error with info severity
    /// - Parameter error: The error to log
    func logInfo<E: UmbraError>(_ error: E)
    
    /// Log an error with warning severity
    /// - Parameter error: The error to log
    func logWarning<E: UmbraError>(_ error: E)
    
    /// Log an error with error severity
    /// - Parameter error: The error to log
    func logError<E: UmbraError>(_ error: E)
    
    /// Log an error with critical severity
    /// - Parameter error: The error to log
    func logCritical<E: UmbraError>(_ error: E)
}

/// Default implementation for ErrorLoggingProtocol
public extension ErrorLoggingProtocol {
    func logDebug<E: UmbraError>(_ error: E) {
        log(error: error, severity: .debug)
    }
    
    func logInfo<E: UmbraError>(_ error: E) {
        log(error: error, severity: .info)
    }
    
    func logWarning<E: UmbraError>(_ error: E) {
        log(error: error, severity: .warning)
    }
    
    func logError<E: UmbraError>(_ error: E) {
        log(error: error, severity: .error)
    }
    
    func logCritical<E: UmbraError>(_ error: E) {
        log(error: error, severity: .critical)
    }
}

/// Protocol for error notification services
public protocol ErrorNotificationProtocol {
    /// Present an error to the user
    /// - Parameters:
    ///   - error: The error to present
    ///   - recoveryOptions: Optional recovery options to present to the user
    func presentError<E: UmbraError>(_ error: E, recoveryOptions: [RecoveryOption])
}

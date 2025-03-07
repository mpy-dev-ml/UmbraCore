// GenericUmbraError.swift
// Generic implementation of the UmbraError protocol
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// A generic implementation of UmbraError that can be used for any error domain
public struct GenericUmbraError: UmbraError {
    /// The error domain
    public let domain: String
    
    /// The error code
    public let code: String
    
    /// Human-readable description of the error
    public let errorDescription: String
    
    /// The underlying error, if any
    public let underlyingError: Error?
    
    /// Source location information
    public let source: ErrorSource?
    
    /// Additional context information
    public let context: ErrorContext
    
    /// Creates a new GenericUmbraError
    /// - Parameters:
    ///   - domain: The error domain
    ///   - code: The error code
    ///   - errorDescription: Human-readable description of the error
    ///   - underlyingError: The underlying error, if any
    ///   - source: Source location information
    ///   - context: Additional context information
    public init(
        domain: String,
        code: String,
        errorDescription: String,
        underlyingError: Error? = nil,
        source: ErrorSource? = nil,
        context: ErrorContext? = nil
    ) {
        self.domain = domain
        self.code = code
        self.errorDescription = errorDescription
        self.underlyingError = underlyingError
        self.source = source
        
        if let context = context {
            self.context = context
        } else {
            self.context = ErrorContext(
                source: domain,
                code: code,
                message: errorDescription
            )
        }
    }
    
    /// Creates a new GenericUmbraError with the specified context
    /// - Parameter context: The context to use
    /// - Returns: A new GenericUmbraError with the specified context
    public func with(context: ErrorContext) -> GenericUmbraError {
        return GenericUmbraError(
            domain: domain,
            code: code,
            errorDescription: errorDescription,
            underlyingError: underlyingError,
            source: source,
            context: context
        )
    }
    
    /// Creates a new GenericUmbraError with the specified underlying error
    /// - Parameter underlyingError: The underlying error to use
    /// - Returns: A new GenericUmbraError with the specified underlying error
    public func with(underlyingError: Error) -> GenericUmbraError {
        return GenericUmbraError(
            domain: domain,
            code: code,
            errorDescription: errorDescription,
            underlyingError: underlyingError,
            source: source,
            context: context
        )
    }
    
    /// Creates a new GenericUmbraError with the specified source
    /// - Parameter source: The source to use
    /// - Returns: A new GenericUmbraError with the specified source
    public func with(source: ErrorSource) -> GenericUmbraError {
        return GenericUmbraError(
            domain: domain,
            code: code,
            errorDescription: errorDescription,
            underlyingError: underlyingError,
            source: source,
            context: context
        )
    }
}

/// Extension to provide factory methods for common error types
public extension GenericUmbraError {
    /// Creates a generic error for validation failures
    /// - Parameters:
    ///   - message: The validation error message
    ///   - code: A specific validation error code
    /// - Returns: A new GenericUmbraError for validation failures
    static func validationError(
        message: String,
        code: String = "validation_failed"
    ) -> GenericUmbraError {
        return GenericUmbraError(
            domain: "Validation",
            code: code,
            errorDescription: message
        )
    }
    
    /// Creates a generic error for unexpected conditions
    /// - Parameters:
    ///   - message: Description of the unexpected condition
    ///   - code: A specific error code
    /// - Returns: A new GenericUmbraError for unexpected conditions
    static func unexpectedError(
        message: String,
        code: String = "unexpected_condition"
    ) -> GenericUmbraError {
        return GenericUmbraError(
            domain: "Internal",
            code: code,
            errorDescription: message
        )
    }
    
    /// Creates a generic error that wraps another error
    /// - Parameters:
    ///   - error: The error to wrap
    ///   - message: Optional message to include
    /// - Returns: A new GenericUmbraError that wraps the provided error
    static func wrap(
        _ error: Error,
        message: String? = nil
    ) -> GenericUmbraError {
        let errorDescription = message ?? "An error occurred: \(error.localizedDescription)"
        
        return GenericUmbraError(
            domain: "Wrapped",
            code: "wrapped_error",
            errorDescription: errorDescription,
            underlyingError: error
        )
    }
}

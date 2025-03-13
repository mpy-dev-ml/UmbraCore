import ErrorHandlingCommon
import ErrorHandlingInterfaces
import ErrorHandlingModels
import Foundation

/// Factory functions for creating errors with source attribution
public enum ErrorFactory {
    /// Creates a new UmbraError with source information
    /// - Parameters:
    ///   - error: The original error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    /// - Returns: A new error with source information
    public static func makeError<E: UmbraError>(
        _ error: E,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> E {
        let source = ErrorHandlingInterfaces.ErrorSource(file: file, line: line, function: function)
        return error.with(source: source)
    }

    /// Creates a new UmbraError with source and underlying error information
    /// - Parameters:
    ///   - error: The original error
    ///   - underlyingError: The cause of this error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    /// - Returns: A new error with source information
    public static func makeError<E: UmbraError>(
        _ error: E,
        underlyingError: Error,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> E {
        let source = ErrorHandlingInterfaces.ErrorSource(file: file, line: line, function: function)
        return error
            .with(source: source)
            .with(underlyingError: underlyingError)
    }

    /// Creates a new UmbraError with source and context information
    /// - Parameters:
    ///   - error: The original error
    ///   - context: Additional context information
    ///   - file: Source file (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    /// - Returns: A new error with source and context information
    public static func makeError<E: UmbraError>(
        _ error: E,
        context: ErrorHandlingCommon.ErrorContext,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> E {
        let source = ErrorHandlingInterfaces.ErrorSource(file: file, line: line, function: function)

        // Create a new context with the appropriate constructor parameters
        // Since we can't cast between the two types directly
        let interfaceContext = ErrorHandlingInterfaces.ErrorContext(
            source: file,
            operation: function,
            details: context.details,
            underlyingError: nil
        )

        return error
            .with(source: source)
            .with(context: interfaceContext)
    }

    /// Creates a new UmbraError with source, context and underlying error information
    /// - Parameters:
    ///   - error: The original error
    ///   - underlyingError: The cause of this error
    ///   - context: Additional context information
    ///   - file: Source file (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    /// - Returns: A new error with source, context and cause information
    public static func makeError<E: UmbraError>(
        _ error: E,
        underlyingError: Error,
        context: ErrorHandlingCommon.ErrorContext,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> E {
        let source = ErrorHandlingInterfaces.ErrorSource(file: file, line: line, function: function)

        // Create a new context with the appropriate constructor parameters
        // Since we can't cast between the two types directly
        let interfaceContext = ErrorHandlingInterfaces.ErrorContext(
            source: file,
            operation: function,
            details: context.details,
            underlyingError: nil
        )

        return error
            .with(source: source)
            .with(context: interfaceContext)
            .with(underlyingError: underlyingError)
    }

    /// Creates a generic UmbraError with the specified domain and message
    /// - Parameters:
    ///   - domain: The error domain
    ///   - code: The error code
    ///   - description: Human-readable description of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    /// - Returns: A new UmbraError with the specified details
    public static func makeGenericError(
        domain: String,
        code: String,
        description: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> ErrorHandlingModels.GenericUmbraError {
        let source = ErrorHandlingInterfaces.ErrorSource(file: file, line: line, function: function)
        return ErrorHandlingModels.GenericUmbraError(
            domain: domain,
            code: code,
            errorDescription: description,
            source: source
        )
    }
}

/// Convenience global function for creating UmbraErrors with source information
/// - Parameters:
///   - error: The original error
///   - file: Source file (auto-filled by the compiler)
///   - line: Line number (auto-filled by the compiler)
///   - function: Function name (auto-filled by the compiler)
/// - Returns: A new error with source information
public func makeError<E: UmbraError>(
    _ error: E,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) -> E {
    ErrorFactory.makeError(error, file: file, line: line, function: function)
}

import Foundation

/// A structure that provides detailed context about an error's occurrence.
///
/// `ErrorContext` enriches errors with information about where and how they
/// occurred, making debugging and error reporting more effective. It captures
/// both programmatic details (file, line, function) and semantic information
/// (source, operation, details).
///
/// Example:
/// ```swift
/// do {
///     try processPayment(amount: 100)
/// } catch let error {
///     throw ErrorContext(
///         source: "PaymentProcessor",
///         operation: "processPayment",
///         details: "Invalid card number",
///         underlyingError: error
///     )
/// }
/// ```
public struct ErrorContext: LocalizedError, Sendable {
    /// The component or module where the error occurred.
    ///
    /// This should be a descriptive name that identifies the part of the
    /// system where the error originated (e.g., "DatabaseService",
    /// "NetworkLayer").
    public let source: String

    /// The specific operation that failed.
    ///
    /// This should be a clear description of what was being attempted
    /// when the error occurred (e.g., "userLogin", "fileDownload").
    public let operation: String

    /// Additional context about the error.
    ///
    /// Use this field to provide any relevant information that might
    /// help in understanding or fixing the error.
    public let details: String?

    /// The original error that triggered this context.
    ///
    /// This is the actual error that occurred, wrapped with additional
    /// context information.
    public let underlyingError: Error

    /// The source file where the error occurred.
    ///
    /// This is automatically captured when the context is created
    /// and is useful for debugging.
    public let file: String

    /// The line number where the error occurred.
    ///
    /// This is automatically captured when the context is created
    /// and is useful for debugging.
    public let line: Int

    /// The function name where the error occurred.
    ///
    /// This is automatically captured when the context is created
    /// and is useful for debugging.
    public let function: String

    /// Creates a new error context with detailed information.
    ///
    /// - Parameters:
    ///   - source: The component or module where the error occurred
    ///             (e.g., "PaymentProcessor", "DatabaseService").
    ///   - operation: The specific operation that failed
    ///                (e.g., "processPayment", "queryUser").
    ///   - details: Optional additional information about what went wrong.
    ///   - underlyingError: The original error that occurred.
    ///   - file: The source file where the error occurred.
    ///           Defaults to the current file.
    ///   - line: The line number where the error occurred.
    ///           Defaults to the current line.
    ///   - function: The function name where the error occurred.
    ///               Defaults to the current function.
    public init(
        source: String,
        operation: String,
        details: String? = nil,
        underlyingError: Error,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        self.source = source
        self.operation = operation
        self.details = details
        self.underlyingError = underlyingError
        self.file = file
        self.line = line
        self.function = function
    }

    /// A localized description of the error context.
    ///
    /// This property combines all the context information into a
    /// human-readable error message.
    public var errorDescription: String? {
        var description = "[\(source)] Error in \(operation)"
        if let details = details {
            description += ": \(details)"
        }
        description += "\nUnderlying error: \(underlyingError.localizedDescription)"
        description += "\nLocation: \(file):\(line) - \(function)"
        return description
    }
}

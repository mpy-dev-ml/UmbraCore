import Foundation
import Models

/// Extension to Error type to provide context information.
public extension Error {
    /// Creates an error context for this error.
    /// - Parameters:
    ///   - source: The source of the error.
    ///   - operation: The operation being performed.
    ///   - details: Additional details about the error.
    ///   - file: The file where the error occurred.
    ///   - line: The line where the error occurred.
    ///   - function: The function where the error occurred.
    /// - Returns: An `ErrorContext` instance.
    func withContext(
        source: String,
        operation: String,
        details: String? = nil,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> ErrorContext {
        ErrorContext(
            source: source,
            operation: operation,
            details: details,
            underlyingError: self,
            file: file,
            line: line,
            function: function
        )
    }
}

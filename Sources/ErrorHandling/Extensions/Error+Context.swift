import Foundation
import Models

public extension Error {
    /// Create an error context for this error
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

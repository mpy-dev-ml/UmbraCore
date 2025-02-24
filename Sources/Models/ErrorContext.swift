import Foundation

/// Represents the context in which an error occurred.
public struct ErrorContext: LocalizedError, Sendable {
    /// The source of the error (e.g., component or service name).
    public let source: String
    
    /// The operation that was being performed.
    public let operation: String
    
    /// Additional details about the error.
    public let details: String?
    
    /// The underlying error that caused this error.
    public let underlyingError: Error
    
    /// The file where the error occurred.
    public let file: String
    
    /// The line number where the error occurred.
    public let line: Int
    
    /// The function where the error occurred.
    public let function: String
    
    /// Creates a new error context.
    /// - Parameters:
    ///   - source: The source of the error.
    ///   - operation: The operation being performed.
    ///   - details: Additional details about the error.
    ///   - underlyingError: The underlying error.
    ///   - file: The file where the error occurred.
    ///   - line: The line where the error occurred.
    ///   - function: The function where the error occurred.
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
    
    public var errorDescription: String? {
        var description = """
            Error in \(source) while \(operation)
            File: \(file)
            Line: \(line)
            Function: \(function)
            """
        
        if let details = details {
            description += "\nDetails: \(details)"
        }
        
        description += "\nUnderlying error: \(underlyingError.localizedDescription)"
        
        return description
    }
}

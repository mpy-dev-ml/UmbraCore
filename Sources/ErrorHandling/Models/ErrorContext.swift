import Foundation

/// Additional context that can be attached to errors
public struct ErrorContext {
    /// The source of the error (e.g., module name, class name)
    public let source: String
    
    /// Operation being performed when the error occurred
    public let operation: String
    
    /// Additional details about the error
    public let details: String?
    
    /// Underlying error if any
    public let underlyingError: Error?
    
    /// File where the error occurred
    public let file: String
    
    /// Line number where the error occurred
    public let line: Int
    
    /// Function where the error occurred
    public let function: String
    
    public init(
        source: String,
        operation: String,
        details: String? = nil,
        underlyingError: Error? = nil,
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
}

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
    var source: ErrorSource? { get }
    
    /// Optional underlying error that caused this error
    var underlyingError: Error? { get }
    
    /// Additional context information about the error
    var context: ErrorContext { get }
    
    /// Creates a new instance of the error with additional context
    func with(context: ErrorContext) -> Self
    
    /// Creates a new instance of the error with a specified underlying error
    func with(underlyingError: Error) -> Self
    
    /// Creates a new instance of the error with source information
    func with(source: ErrorSource) -> Self
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
    var context: ErrorContext {
        return ErrorContext(source: domain, message: errorDescription)
    }
    
    /// Default implementation returns nil
    var underlyingError: Error? {
        return nil
    }
    
    /// Default implementation returns nil
    var source: ErrorSource? {
        return nil
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

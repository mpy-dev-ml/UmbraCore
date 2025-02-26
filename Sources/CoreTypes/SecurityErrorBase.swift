// Base error types without Foundation dependencies

/// Base error type for security-related errors
public enum SecurityErrorBase: Error, Equatable {
    /// Access denied to a resource
    case accessDenied(reason: String)

    /// Item not found
    case itemNotFound

    /// Error creating or resolving a bookmark
    case bookmarkError(String)

    /// Random generation failed
    case randomGenerationFailed

    /// General security error
    case generalError(String)
}

/// Protocol for errors that can be converted to SecurityErrorBase
public protocol SecurityErrorConvertible {
    /// Convert to base error type
    func toBaseError() -> SecurityErrorBase
}

/// Make SecurityErrorBase conform to its own conversion protocol
extension SecurityErrorBase: SecurityErrorConvertible {
    public func toBaseError() -> SecurityErrorBase {
        return self
    }
}

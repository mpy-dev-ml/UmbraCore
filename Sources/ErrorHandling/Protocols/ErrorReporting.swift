import Foundation

/// Protocol for types that can provide detailed error information
public protocol ErrorReporting: LocalizedError {
    /// Context providing additional information about the error
    var context: ErrorContext { get }
    
    /// Whether the error is recoverable
    var isRecoverable: Bool { get }
    
    /// Suggested recovery steps if the error is recoverable
    var recoverySteps: [String]? { get }
}

public extension ErrorReporting {
    /// Default implementation assuming errors are not recoverable
    var isRecoverable: Bool { false }
    
    /// Default implementation providing no recovery steps
    var recoverySteps: [String]? { nil }
}

import ErrorHandlingModels
import Foundation

/// Protocol for service-specific errors that provide detailed context
public protocol ServiceErrorProtocol: LocalizedError {
    /// The source service that generated this error
    var serviceName: String { get }

    /// The operation that was being performed
    var operation: String { get }

    /// Additional details about what went wrong
    var details: String? { get }

    /// The underlying error that caused this error, if any
    var underlyingError: Error? { get }

    /// Whether this error can potentially be recovered from
    var isRecoverable: Bool { get }

    /// Steps that might help recover from this error
    var recoverySteps: [String]? { get }

    /// Creates an error context from this service error
    var context: ErrorContext { get }
}

public extension ServiceErrorProtocol {
    /// Default implementation assuming errors are not recoverable
    var isRecoverable: Bool { false }

    /// Default implementation providing no recovery steps
    var recoverySteps: [String]? { nil }

    /// Default implementation creating an error context
    var context: ErrorContext {
        var metadata: [String: String] = [:]
        if let details = details {
            metadata["details"] = details
        }
        metadata["operation"] = operation
        if let error = underlyingError {
            metadata["underlyingError"] = String(describing: error)
        }

        return ErrorContext(
            source: serviceName,
            message: localizedDescription,
            metadata: metadata
        )
    }
}

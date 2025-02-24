import Foundation

/// Severity level for service errors
@frozen
public enum ErrorSeverity: String, Codable, Sendable {
    /// Critical errors that require immediate attention
    case critical
    /// Serious errors that affect functionality
    case error
    /// Less severe issues that may affect performance
    case warning
    /// Informational issues that don't affect functionality
    case info
}

/// Types of service errors
@frozen
public enum ServiceErrorType: String, Sendable, CaseIterable {
    /// Configuration-related errors
    case configuration = "Configuration"
    /// Operation-related errors
    case operation = "Operation"
    /// State-related errors
    case state = "State"
    /// Resource-related errors
    case resource = "Resource"
    /// Dependency-related errors
    case dependency = "Dependency"
    /// Network-related errors
    case network = "Network"
    /// Authentication-related errors
    case authentication = "Authentication"
    /// Timeout-related errors
    case timeout = "Timeout"
    /// Initialization-related errors
    case initialization = "Initialization"
    /// Lifecycle-related errors
    case lifecycle = "Lifecycle"
    /// Permission-related errors
    case permission = "Permission"
    /// Unknown errors
    case unknown = "Unknown"

    /// User-friendly description of the error type
    public var description: String {
        switch self {
        case .configuration:
            return "Configuration Error"
        case .operation:
            return "Operation Error"
        case .state:
            return "State Error"
        case .resource:
            return "Resource Error"
        case .dependency:
            return "Dependency Error"
        case .network:
            return "Network Error"
        case .authentication:
            return "Authentication Error"
        case .timeout:
            return "Timeout Error"
        case .initialization:
            return "Initialization Error"
        case .lifecycle:
            return "Lifecycle Error"
        case .permission:
            return "Permission Error"
        case .unknown:
            return "Unknown Error"
        }
    }
}

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

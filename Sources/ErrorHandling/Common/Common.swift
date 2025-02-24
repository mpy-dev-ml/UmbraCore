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
    /// Security-related errors
    case security = "Security"
    /// Permission-related errors
    case permission = "Permission"
    /// Validation-related errors
    case validation = "Validation"
    /// Data-related errors
    case data = "Data"
    /// Service-related errors
    case service = "Service"
    /// Unknown errors
    case unknown = "Unknown"

    /// Returns a user-friendly description of the error type
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
        case .security:
            return "Security Error"
        case .permission:
            return "Permission Error"
        case .validation:
            return "Validation Error"
        case .data:
            return "Data Error"
        case .service:
            return "Service Error"
        case .unknown:
            return "Unknown Error"
        }
    }
}

import Foundation

/// Errors that can occur during repository operations
public enum RepositoryError: LocalizedError {
    /// Repository initialization failed
    case initializationFailed(reason: String)

    /// Repository validation failed
    case validationFailed(reason: String)

    /// Repository is locked
    case locked(reason: String)

    /// Repository is not accessible
    case notAccessible(reason: String)

    /// Repository operation failed
    case operationFailed(reason: String)

    /// Repository is corrupted
    case corrupted(reason: String)

    /// Repository configuration is invalid
    case invalidConfiguration(reason: String)

    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let reason):
            return "Repository initialization failed: \(reason)"
        case .validationFailed(let reason):
            return "Repository validation failed: \(reason)"
        case .locked(let reason):
            return "Repository is locked: \(reason)"
        case .notAccessible(let reason):
            return "Repository is not accessible: \(reason)"
        case .operationFailed(let reason):
            return "Repository operation failed: \(reason)"
        case .corrupted(let reason):
            return "Repository is corrupted: \(reason)"
        case .invalidConfiguration(let reason):
            return "Invalid repository configuration: \(reason)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .initializationFailed(let reason),
             .validationFailed(let reason),
             .locked(let reason),
             .notAccessible(let reason),
             .operationFailed(let reason),
             .corrupted(let reason),
             .invalidConfiguration(let reason):
            return reason
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .initializationFailed:
            return "Try reinitializing the repository or check the configuration"
        case .validationFailed:
            return "Run repository repair or check for corruption"
        case .locked:
            return "Wait for other operations to complete or force unlock if necessary"
        case .notAccessible:
            return "Check repository permissions and network connectivity"
        case .operationFailed:
            return "Retry the operation or check logs for more details"
        case .corrupted:
            return "Run repository repair or restore from backup"
        case .invalidConfiguration:
            return "Check repository configuration settings"
        }
    }
}

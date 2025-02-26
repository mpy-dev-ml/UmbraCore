import Foundation

/// Errors that can occur during Restic operations.
public enum ResticError: LocalizedError, Sendable {
    /// A required parameter was missing or invalid
    case missingParameter(String)

    /// A parameter has an invalid value
    case invalidParameter(String)

    /// The command failed to execute
    case executionFailed(String)

    /// The repository is invalid or inaccessible
    case repositoryNotFound(path: String)

    /// Authentication failed
    case invalidPassword

    /// Permission denied for a path
    case permissionDenied(path: String)

    /// Invalid configuration provided
    case invalidConfiguration(String)

    /// Invalid data format or content
    case invalidData(String)

    /// An error occurred during backup
    case backupFailed(String)

    /// An error occurred during restore
    case restoreFailed(String)

    /// An error occurred during repository check
    case checkFailed(String)

    /// An error occurred during repository maintenance
    case maintenanceFailed(String)

    /// A general error occurred
    case generalError(String)

    public var errorDescription: String? {
        switch self {
        case .missingParameter(let message):
            return "Missing parameter: \(message)"
        case .invalidParameter(let message):
            return "Invalid parameter: \(message)"
        case .executionFailed(let message):
            return "Command execution failed: \(message)"
        case .repositoryNotFound(let path):
            return "Repository not found at path: \(path)"
        case .invalidPassword:
            return "Invalid repository password"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .backupFailed(let message):
            return "Backup failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .checkFailed(let message):
            return "Repository check failed: \(message)"
        case .maintenanceFailed(let message):
            return "Maintenance failed: \(message)"
        case .generalError(let message):
            return "Error: \(message)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .missingParameter:
            return "Please provide all required parameters."
        case .invalidParameter:
            return "Please check the parameter value and try again."
        case .executionFailed:
            return "Check the error message and try again."
        case .repositoryNotFound:
            return "Verify the repository path and ensure it exists."
        case .invalidPassword:
            return "Check your password and try again."
        case .permissionDenied:
            return "Check file permissions and try again."
        case .invalidConfiguration:
            return "Review your configuration settings and try again."
        case .invalidData:
            return "Check the data format and content."
        case .backupFailed:
            return "Check source paths and repository access."
        case .restoreFailed:
            return "Verify snapshot ID and target path."
        case .checkFailed:
            return "Run repair command if needed."
        case .maintenanceFailed:
            return "Try running the command again."
        case .generalError:
            return "Check logs for more details."
        }
    }
}

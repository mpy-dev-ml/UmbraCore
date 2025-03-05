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
      case let .missingParameter(message):
        "Missing parameter: \(message)"
      case let .invalidParameter(message):
        "Invalid parameter: \(message)"
      case let .executionFailed(message):
        "Command execution failed: \(message)"
      case let .repositoryNotFound(path):
        "Repository not found at path: \(path)"
      case .invalidPassword:
        "Invalid repository password"
      case let .permissionDenied(path):
        "Permission denied: \(path)"
      case let .invalidConfiguration(message):
        "Invalid configuration: \(message)"
      case let .invalidData(message):
        "Invalid data: \(message)"
      case let .backupFailed(message):
        "Backup failed: \(message)"
      case let .restoreFailed(message):
        "Restore failed: \(message)"
      case let .checkFailed(message):
        "Repository check failed: \(message)"
      case let .maintenanceFailed(message):
        "Maintenance failed: \(message)"
      case let .generalError(message):
        "Error: \(message)"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
      case .missingParameter:
        "Please provide all required parameters."
      case .invalidParameter:
        "Please check the parameter value and try again."
      case .executionFailed:
        "Check the error message and try again."
      case .repositoryNotFound:
        "Verify the repository path and ensure it exists."
      case .invalidPassword:
        "Check your password and try again."
      case .permissionDenied:
        "Check file permissions and try again."
      case .invalidConfiguration:
        "Review your configuration settings and try again."
      case .invalidData:
        "Check the data format and content."
      case .backupFailed:
        "Check source paths and repository access."
      case .restoreFailed:
        "Verify snapshot ID and target path."
      case .checkFailed:
        "Run repair command if needed."
      case .maintenanceFailed:
        "Try running the command again."
      case .generalError:
        "Check logs for more details."
    }
  }
}

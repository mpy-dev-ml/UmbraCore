/// Errors that can occur during Restic operations
public enum ResticError: Error, Sendable {
  /// Required parameter is missing
  case missingParameter(String)
  /// Command execution failed
  case commandFailed(String)
  /// Repository error
  case repositoryError(String)
  /// Invalid configuration
  case invalidConfiguration(String)
}

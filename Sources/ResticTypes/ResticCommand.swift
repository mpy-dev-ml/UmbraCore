import Foundation

/// Protocol defining the requirements for a Restic command.
public protocol ResticCommand: Sendable {
    /// The command name (e.g., "backup", "restore").
    var command: String { get }
    
    /// Additional arguments for the command.
    var arguments: [String] { get }
    
    /// Environment variables required for the command.
    var environment: [String: String] { get }
    
    /// Environment variables that must be present, even if empty.
    var requiredEnvironmentVariables: Set<String> { get }
    
    /// Validates the command configuration.
    /// - Throws: `ResticError` if validation fails.
    func validate() throws
}

/// Errors that can occur during Restic operations.
public enum ResticError: LocalizedError, Sendable {
    /// Command execution failed with the given reason.
    case executionFailed(String)
    
    /// Command output parsing failed with the given reason.
    case outputParsingFailed(String)
    
    /// Invalid command configuration with the given reason.
    case invalidConfiguration(String)
    
    /// Repository error with the given reason.
    case repositoryError(String)
    
    /// Authentication error with the given reason.
    case authenticationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .executionFailed(let reason):
            return "Command execution failed: \(reason)"
        case .outputParsingFailed(let reason):
            return "Output parsing failed: \(reason)"
        case .invalidConfiguration(let reason):
            return "Invalid configuration: \(reason)"
        case .repositoryError(let reason):
            return "Repository error: \(reason)"
        case .authenticationError(let reason):
            return "Authentication error: \(reason)"
        }
    }
}

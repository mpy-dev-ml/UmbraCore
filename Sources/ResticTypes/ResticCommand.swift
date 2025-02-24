import Foundation

/// A protocol that defines the requirements for executing Restic commands.
///
/// This protocol provides a type-safe way to construct and validate Restic
/// commands before execution. It handles command-line arguments and environment
/// variables required for Restic operations.
///
/// Example:
/// ```swift
/// struct BackupCommand: ResticCommand {
///     let command = "backup"
///     let arguments = ["--tag", "daily", "/path/to/backup"]
///     let environment = ["RESTIC_PASSWORD": "secret"]
///     let requiredEnvironmentVariables = Set(["RESTIC_PASSWORD"])
///     
///     func validate() throws {
///         guard !arguments.isEmpty else {
///             throw ResticError.invalidConfiguration("No backup path specified")
///         }
///     }
/// }
/// ```
public protocol ResticCommand: Sendable {
    /// The name of the Restic command to execute.
    ///
    /// This should be one of the standard Restic commands such as
    /// "backup", "restore", "check", etc.
    var command: String { get }

    /// Command-line arguments to pass to the Restic command.
    ///
    /// These arguments should not include the command name itself.
    /// Each argument should be a separate string.
    var arguments: [String] { get }

    /// Environment variables required for command execution.
    ///
    /// Common variables include:
    /// - RESTIC_PASSWORD: Repository password
    /// - RESTIC_REPOSITORY: Repository location
    var environment: [String: String] { get }

    /// Environment variables that must exist, even if empty.
    ///
    /// Use this for variables that Restic requires to be set,
    /// even if their values are empty strings.
    var requiredEnvironmentVariables: Set<String> { get }

    /// Validates the command configuration before execution.
    ///
    /// This method should check that all required arguments and
    /// environment variables are properly set.
    ///
    /// - Throws: `ResticError.invalidConfiguration` if the command
    ///           is not properly configured.
    func validate() throws
}

/// Errors that can occur during Restic operations.
///
/// This enum provides specific error cases for different types of
/// failures that can occur when working with Restic commands.
public enum ResticError: LocalizedError, Sendable {
    /// The command failed during execution.
    ///
    /// - Parameter reason: A description of why the command failed.
    case executionFailed(String)

    /// Failed to parse the command output.
    ///
    /// - Parameter reason: A description of the parsing failure.
    case outputParsingFailed(String)

    /// The command configuration is invalid.
    ///
    /// - Parameter reason: A description of the configuration error.
    case invalidConfiguration(String)

    /// An error occurred with the Restic repository.
    ///
    /// - Parameter reason: A description of the repository error.
    case repositoryError(String)

    /// Authentication to the repository failed.
    ///
    /// - Parameter reason: A description of the authentication failure.
    case authenticationError(String)

    /// A localized description of the error.
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

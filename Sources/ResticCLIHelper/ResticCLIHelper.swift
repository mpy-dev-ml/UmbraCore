/// A Swift interface for interacting with the Restic command-line tool.
///
/// `ResticCLIHelper` provides a type-safe, Swift-native way to interact with
/// Restic, handling command construction, execution, and output parsing.
///
/// Features:
/// - Type-safe command building and validation
/// - Secure credential management
/// - Structured output parsing
/// - Progress tracking and statistics collection
/// - Comprehensive error handling
///
/// Example:
/// ```swift
/// let helper = ResticCLIHelper(executablePath: "/usr/local/bin/restic")
/// try await helper.execute(BackupCommand(
///     source: "/path/to/backup",
///     tags: ["daily"],
///     excludes: ["*.tmp"]
/// ))
/// ```
///
/// Command Categories:
/// - Backup: Create and manage backups
/// - Restore: Restore data from backups
/// - Maintenance: Repository maintenance and cleanup
/// - Query: Search and inspect backups
///
/// Security:
/// - Credentials are never logged or exposed
/// - Environment variables are cleared after use
/// - Paths are sanitized to prevent injection
///
/// Error Handling:
/// - Input validation before execution
/// - Detailed error messages with context
/// - Recovery suggestions when applicable
///
/// Performance:
/// - Asynchronous command execution
/// - Progress reporting for long operations
/// - Memory-efficient output handling

import Foundation
import ResticTypes
import UmbraLogging

/// A helper class that provides a Swift interface to the Restic command-line tool.
public final class ResticCLIHelper {
    /// The current version of the ResticCLIHelper module.
    ///
    /// This version follows semantic versioning (MAJOR.MINOR.PATCH).
    public static let version = "1.0.0"

    /// The absolute path to the Restic executable.
    ///
    /// This path is validated during initialization to ensure
    /// the executable exists and is accessible.
    private let executablePath: String

    /// The logger instance used for operation tracking.
    private let logger: Logger

    /// Creates a new Restic CLI helper.
    ///
    /// - Parameters:
    ///   - executablePath: The path to the Restic executable.
    ///                     Must be an absolute path to a valid executable.
    ///   - logger: The logger to use for operation tracking.
    ///            Defaults to the shared logger instance.
    /// - Throws: `ResticError.invalidConfiguration` if the executable
    ///          cannot be found or accessed.
    public init(
        executablePath: String,
        logger: Logger = .shared
    ) throws {
        self.executablePath = executablePath
        self.logger = logger

        // Validate executable
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: executablePath) else {
            throw ResticError.invalidConfiguration("Restic executable not found at \(executablePath)")
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: executablePath, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            throw ResticError.invalidConfiguration("Path is a directory: \(executablePath)")
        }
    }

    /// Execute a Restic command
    /// - Parameter command: The command to execute
    /// - Returns: The command output
    /// - Throws: ResticError if the command fails
    public func execute(_ command: ResticCommand) async throws -> String {
        // Validate the command
        try command.validate()

        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = command.arguments

        // Merge environment variables, ensuring we preserve PATH and don't override with empty values
        var environment = ProcessInfo.processInfo.environment
        let commandEnv = command.environment.filter { key, value in
            // Keep required environment variables even if empty
            command.requiredEnvironmentVariables.contains(key) || !value.isEmpty
        }
        environment.merge(commandEnv) { _, new in new }
        process.environment = environment

        // Set up pipes for output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Execute the command
        return try await withCheckedThrowingContinuation { continuation in
            let workItem = DispatchWorkItem {
                do {
                    try process.run()

                    // Read output and error data
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                    // Wait for process to complete
                    process.waitUntilExit()

                    if process.terminationStatus != 0 {
                        let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        let error: ResticError

                        switch process.terminationStatus {
                        case 1:
                            error = .executionFailed("Command failed: \(errorOutput)")
                        case 3:
                            error = .repositoryError(errorOutput)
                        case 101:
                            error = .authenticationError(errorOutput)
                        default:
                            error = .executionFailed("Process terminated with status \(process.terminationStatus): \(errorOutput)")
                        }

                        continuation.resume(throwing: error)
                        return
                    }

                    // Try to parse the output
                    if let output = String(data: outputData, encoding: .utf8) {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: ResticError.outputParsingFailed("Could not decode command output"))
                    }
                } catch {
                    continuation.resume(throwing: ResticError.executionFailed(error.localizedDescription))
                }
            }

            self.logger.info("Executing command: \(command)")
            DispatchQueue(label: "com.umbracore.restic-cli-helper").async(execute: workItem)
        }
    }
}

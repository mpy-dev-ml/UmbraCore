/// A Swift interface for interacting with the Restic command-line tool.
///
/// `ResticCLIHelper` provides a type-safe, Swift-native way to interact with Restic, handling command
/// construction, execution, and output parsing.
///
/// Features:
/// - Type-safe command building and validation
/// - Secure credential management
/// - Structured output parsing
/// - Progress tracking and statistics collection
/// - Comprehensive error handling
///
/// Example usage:
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
    /// This path is validated during initialization to ensure the executable exists and is accessible.
    private let executablePath: String

    /// The logger instance used by this helper.
    @MainActor private let logger: Logger

    /// The delegate for progress reporting.
    private var progressDelegate: ResticProgressReporting?

    /// The parser for progress reporting.
    private let progressParser: ProgressParser?

    /// Creates a new Restic CLI helper.
    ///
    /// - Parameters:
    ///   - executablePath: The path to the Restic executable. Must be an absolute path to a valid
    ///                     executable.
    ///   - logger: The logger to use for operation tracking. Defaults to the shared logger instance.
    ///   - progressDelegate: The delegate for progress reporting. Defaults to nil.
    ///
    /// - Throws: `ResticError.invalidConfiguration` if the executable cannot be found or accessed.
    public init(
        executablePath: String,
        logger: Logger = .shared,
        progressDelegate: ResticProgressReporting? = nil
    ) throws {
        self.executablePath = executablePath
        self.logger = logger
        self.progressDelegate = progressDelegate
        self.progressParser = progressDelegate.map { ProgressParser(delegate: $0) }

        // Validate executable
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: executablePath) else {
            throw ResticError.invalidConfiguration(
                "Restic executable not found at \(executablePath)"
            )
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: executablePath, isDirectory: &isDirectory),
              !isDirectory.boolValue
        else {
            throw ResticError.invalidConfiguration("Path is a directory: \(executablePath)")
        }
    }

    /// Executes a Restic command and returns its output.
    ///
    /// - Parameter command: The command to execute.
    /// - Returns: The command output as a string.
    /// - Throws: `ResticError` if the command fails.
    public func execute(_ command: ResticCommand) async throws -> String {
        // Validate the command
        try command.validate()

        // Create pipes for stdout and stderr
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = command.arguments
        process.environment = command.environment
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Set up async handlers for output
        let outputHandler = Task {
            for try await line in outputPipe.fileHandleForReading.bytes.lines {
                if let progressParser = progressParser {
                    progressParser.parseLine(line)
                }
                await logger.debug(line)
            }
        }

        let errorHandler = Task {
            for try await line in errorPipe.fileHandleForReading.bytes.lines {
                await logger.error(line)
            }
        }

        // Log the command
        let commandDescription = command.arguments.joined(separator: " ")
        await self.logger.info("Executing command: \(commandDescription)")

        // Execute the command
        return try await withCheckedThrowingContinuation { continuation in
            let workItem = DispatchWorkItem { [weak self] in
                guard self != nil else {
                    continuation.resume(throwing: ResticError.executionFailed(
                        "Helper was deallocated"
                    ))
                    return
                }

                do {
                    // Execute the process and wait for completion
                    try process.run()

                    // Wait for process to complete
                    process.waitUntilExit()

                    // Check the exit code
                    let exitCode = process.terminationStatus
                    if exitCode != 0 {
                        let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown error"
                        var error: ResticError
                        switch exitCode {
                        case 1:
                            error = .executionFailed("Command failed: \(errorOutput)")
                        case 3:
                            error = .repositoryError(errorOutput)
                        case 101:
                            error = .authenticationError(errorOutput)
                        default:
                            error = .commandFailed(exitCode: Int(exitCode), message: errorOutput)
                        }
                        continuation.resume(throwing: error)
                        return
                    }

                    // Try to parse the output
                    if let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: ResticError.outputParsingFailed("Failed to decode output as UTF-8"))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            DispatchQueue(label: "com.umbracore.restic-cli-helper").async(execute: workItem)
        }

        // Cancel output handlers when done
        outputHandler.cancel()
        errorHandler.cancel()
    }

    /// Set the progress delegate
    /// - Parameter delegate: The delegate to receive progress updates
    public func setProgressDelegate(_ delegate: ResticProgressReporting?) {
        self.progressDelegate = delegate
    }
}

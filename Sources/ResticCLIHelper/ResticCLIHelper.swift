/// ResticCLIHelper Module
///
/// Provides a type-safe Swift interface to the Restic command-line tool.
/// This module handles all aspects of Restic CLI interaction, from command
/// construction to output parsing.
///
/// # Key Features
/// - Type-safe command building
/// - Secure credential handling
/// - Output parsing
/// - Error management
///
/// # Module Organisation
///
/// ## Core Types
/// ```swift
/// ResticCommand
/// CommandBuilder
/// CommandResult
/// ```
///
/// ## Command Types
/// ```swift
/// BackupCommand
/// RestoreCommand
/// MaintenanceCommand
/// ```
///
/// ## Output Parsing
/// ```swift
/// OutputParser
/// ProgressTracker
/// StatisticsCollector
/// ```
///
/// # Command Building
///
/// ## Type Safety
/// Safe command construction:
/// - Parameter validation
/// - Path sanitisation
/// - Flag verification
///
/// ## Command Options
/// Supported command types:
/// - Backup operations
/// - Restore operations
/// - Repository management
/// - Maintenance tasks
///
/// # Credential Management
///
/// ## Security
/// Secure credential handling:
/// - Environment variables
/// - Configuration files
/// - Keychain integration
///
/// ## Validation
/// Credential validation:
/// - Format checking
/// - Permission verification
/// - Expiry management
///
/// # Output Handling
///
/// ## Parsing
/// Structured output parsing:
/// - JSON output
/// - Progress updates
/// - Error messages
///
/// ## Progress Tracking
/// Real-time progress monitoring:
/// - Transfer rates
/// - File counts
/// - Size statistics
///
/// # Usage Example
/// ```swift
/// let helper = ResticCLIHelper(resticPath: "/usr/local/bin/restic")
/// 
/// let result = try await helper.execute(
///     BackupCommand(
///         source: path,
///         tag: "daily"
///     )
/// )
/// ```
///
/// # Error Handling
///
/// ## CLI Errors
/// Comprehensive error handling:
/// - Command errors
/// - System errors
/// - Permission errors
///
/// ## Recovery
/// Error recovery strategies:
/// - Automatic retry
/// - Command adjustment
/// - Clean-up operations
///
/// # Thread Safety
/// CLI operations are thread-safe:
/// - Command queuing
/// - Output synchronisation
/// - Resource management
import Foundation
import ResticTypes

/// Main class for interacting with the Restic CLI
public final class ResticCLIHelper {
    /// Current version of the ResticCLIHelper module
    public static let version = "1.0.0"

    /// Path to the Restic executable
    private let resticPath: String

    /// Queue for serialising command execution
    private let executionQueue: DispatchQueue

    /// Initialise ResticCLIHelper
    /// - Parameter resticPath: Path to the Restic executable
    public init(resticPath: String = "/opt/homebrew/bin/restic") {
        self.resticPath = resticPath
        self.executionQueue = DispatchQueue(label: "com.umbracore.restic-cli-helper")
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
        process.executableURL = URL(fileURLWithPath: resticPath)
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
            
            self.executionQueue.async(execute: workItem)
        }
    }
}

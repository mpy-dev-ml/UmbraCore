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
    public init(resticPath: String = "/usr/local/bin/restic") {
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
        process.arguments = [command.commandName] + command.arguments
        process.environment = ProcessInfo.processInfo.environment.merging(
            command.environment,
            uniquingKeysWith: { _, new in new }
        )
        
        // Set up pipes for output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Execute the command
        return try await withCheckedThrowingContinuation { continuation in
            self.executionQueue.async {
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    if process.terminationStatus != 0 {
                        let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: ResticError.executionFailed(errorOutput))
                        return
                    }
                    
                    if let output = String(data: outputData, encoding: .utf8) {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: ResticError.outputParsingFailed("Could not decode command output"))
                    }
                } catch {
                    continuation.resume(throwing: ResticError.executionFailed(error.localizedDescription))
                }
            }
        }
    }
}

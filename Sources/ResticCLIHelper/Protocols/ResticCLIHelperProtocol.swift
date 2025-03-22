import Foundation
import ResticCLIHelperTypes
import ResticTypes

/// ResticCLIHelper Protocol
/// Defines the public interface for interacting with the Restic command-line interface.
public protocol ResticCLIHelperProtocol {
  /// Path to the Restic executable
  var resticPath: String { get }

  /// Default repository location
  var defaultRepository: String? { get set }

  /// Default repository password
  var defaultPassword: String? { get set }

  /// Execute a Restic command
  /// - Parameter command: The command to execute
  /// - Returns: The result of the command execution
  /// - Throws: ResticError if the command fails
  func execute<T: ResticCommand>(_ command: T) async throws -> CommandResult

  /// Initialize a new repository
  /// - Parameters:
  ///   - location: Repository location (path or URL)
  ///   - password: Repository password
  /// - Returns: CommandResult indicating success or failure
  /// - Throws: ResticError if initialization fails
  func initializeRepository(at location: String, password: String) async throws -> CommandResult

  /// Check repository health
  /// - Parameter location: Optional repository location (uses default if nil)
  /// - Returns: CommandResult with repository status
  /// - Throws: ResticError if check fails
  func checkRepository(at location: String?) async throws -> CommandResult

  /// List snapshots in repository
  /// - Parameters:
  ///   - location: Optional repository location (uses default if nil)
  ///   - tag: Optional tag to filter snapshots
  /// - Returns: CommandResult containing snapshot information
  /// - Throws: ResticError if listing fails
  func listSnapshots(at location: String?, tag: String?) async throws -> CommandResult

  /// Create a backup
  /// - Parameters:
  ///   - paths: Array of paths to backup
  ///   - tag: Optional tag for the backup
  ///   - excludes: Optional array of exclude patterns
  /// - Returns: CommandResult with backup information
  /// - Throws: ResticError if backup fails
  func backup(paths: [String], tag: String?, excludes: [String]?) async throws -> CommandResult

  /// Restore from backup
  /// - Parameters:
  ///   - snapshot: Snapshot ID to restore from
  ///   - target: Target path for restoration
  ///   - paths: Optional specific paths to restore
  /// - Returns: CommandResult with restore information
  /// - Throws: ResticError if restore fails
  func restore(snapshot: String, to target: String, paths: [String]?) async throws -> CommandResult

  /// Perform repository maintenance
  /// - Parameter type: Type of maintenance operation (prune, check, rebuild-index)
  /// - Returns: CommandResult with maintenance information
  /// - Throws: ResticError if maintenance fails
  func maintenance(type: MaintenanceType) async throws -> CommandResult
}

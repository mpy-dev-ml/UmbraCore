import Foundation

/// A protocol that defines the core requirements for a repository.
///
/// Repositories are actor-based entities that provide thread-safe access to their contents
/// and maintain their own state. Each repository must have a unique identifier and support
/// basic operations like initialization, locking, and statistics gathering.
///
/// Example:
/// ```swift
/// actor MyRepository: Repository {
///     let identifier: String
///     var state: RepositoryState = .uninitialized
///     let location: URL
///     
///     func initialize() async throws {
///         // Implementation
///     }
/// }
/// ```
public protocol Repository: Actor {
    /// The unique identifier for this repository.
    var identifier: String { get }

    /// The current operational state of the repository.
    var state: RepositoryState { get }

    /// The filesystem location where this repository is stored.
    var location: URL { get }

    /// Initializes the repository and prepares it for use.
    ///
    /// - Throws: `RepositoryError` if initialization fails due to filesystem
    ///           permissions, corruption, or other errors.
    func initialize() async throws

    /// Validates the repository structure and integrity.
    ///
    /// - Returns: `true` if the repository is valid, `false` otherwise.
    /// - Throws: `RepositoryError` if validation cannot be completed.
    func validate() async throws -> Bool

    /// Locks the repository for exclusive access.
    ///
    /// - Throws: `RepositoryError` if the lock cannot be acquired or if
    ///           the repository is in an invalid state.
    func lock() async throws

    /// Releases an exclusive lock on the repository.
    ///
    /// - Throws: `RepositoryError` if the lock cannot be released or if
    ///           the repository is in an invalid state.
    func unlock() async throws

    /// Checks if the repository is currently accessible.
    ///
    /// - Returns: `true` if the repository can be accessed, `false` otherwise.
    func isAccessible() async -> Bool

    /// Retrieves current statistics about the repository.
    ///
    /// - Returns: A `RepositoryStats` object containing current metrics.
    /// - Throws: `RepositoryError` if statistics cannot be gathered.
    func getStats() async throws -> RepositoryStats
}

/// The operational state of a repository.
///
/// This enum represents the various states a repository can be in during
/// its lifecycle, from initialization through active use.
public enum RepositoryState: Equatable, Sendable {
    /// The repository has not been initialized.
    case uninitialized

    /// The repository is initialized and ready for operations.
    case ready

    /// The repository is locked for exclusive access.
    case locked

    /// The repository is in an error state.
    case error(RepositoryError)

    public static func == (lhs: RepositoryState, rhs: RepositoryState) -> Bool {
        switch (lhs, rhs) {
        case (.uninitialized, .uninitialized),
             (.ready, .ready),
             (.locked, .locked):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

/// Statistics for a repository.
///
/// This struct contains various metrics about a repository, including its size,
/// snapshot count, and compression ratio.
public struct RepositoryStats: Codable, Equatable, Sendable {
    /// The total size of the repository in bytes.
    public let totalSize: UInt64

    /// The number of snapshots in the repository.
    public let snapshotCount: Int

    /// The space saved by deduplication.
    public let deduplicationSavings: UInt64

    /// The last modified timestamp.
    public let lastModified: Date

    /// The compression ratio (1.0 means no compression).
    public let compressionRatio: Double

    public init(
        totalSize: UInt64,
        snapshotCount: Int,
        deduplicationSavings: UInt64,
        lastModified: Date,
        compressionRatio: Double
    ) {
        self.totalSize = totalSize
        self.snapshotCount = snapshotCount
        self.deduplicationSavings = deduplicationSavings
        self.lastModified = lastModified
        self.compressionRatio = compressionRatio
    }
}

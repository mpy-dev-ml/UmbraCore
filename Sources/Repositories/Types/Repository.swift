// Standard modules
import Foundation

/// Deprecated: Use CompleteRepository typealias from RepositoryProtocols.swift instead.
///
/// A complete repository that implements all repository functionality.
public typealias Repository = RepositoryCore & RepositoryLocking & RepositoryMaintenance & RepositoryStats

/// Repository statistics data structure.
public struct RepositoryStatistics: Codable, Equatable, Sendable {
    /// The total size of the repository in bytes.
    public let totalSize: UInt64

    /// The number of snapshots in the repository.
    public let snapshotCount: UInt

    /// The time of the last check operation.
    public let lastCheck: Date

    /// Creates a new repository statistics instance.
    /// - Parameters:
    ///   - totalSize: Total size in bytes
    ///   - snapshotCount: Number of snapshots
    ///   - lastCheck: Time of last check
    public init(totalSize: UInt64, snapshotCount: UInt, lastCheck: Date) {
        self.totalSize = totalSize
        self.snapshotCount = snapshotCount
        self.lastCheck = lastCheck
    }
}

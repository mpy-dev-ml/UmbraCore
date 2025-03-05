import Foundation

/// Namespace for repository-related types and protocols
public enum Repositories {
  /// Protocol defining the interface for repository statistics
  public protocol RepositoryStats: Sendable {
    /// Repository size in bytes
    var totalSize: Int64 { get }

    /// Number of files backed up in the repository
    var totalFileCount: Int { get }

    /// Number of blobs in the repository
    var totalBlobCount: Int { get }

    /// Number of processed snapshots
    var snapshotsCount: Int { get }

    /// Repository size in bytes if blobs were uncompressed
    var totalUncompressedSize: Int64 { get }

    /// Factor by which the already compressed data has shrunk due to compression
    var compressionRatio: Double { get }
  }
}

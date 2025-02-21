import Foundation

/// Represents the progress of a backup operation
public struct BackupProgress: Codable {
    /// Type of message
    public let messageType: String

    /// Time since backup started
    public let secondsElapsed: Double?

    /// Estimated time remaining
    public let secondsRemaining: Double?

    /// Percentage of data backed up
    public let percentDone: Double?

    /// Total number of files detected
    public let totalFiles: Int?

    /// Files completed
    public let filesDone: Int?

    /// Total number of bytes in backup set
    public let totalBytes: Int64?

    /// Number of bytes completed
    public let bytesDone: Int64?

    /// Number of errors
    public let errorCount: Int?

    /// List of files currently being backed up
    public let currentFiles: [String]?

    /// Error message if present
    public let error: BackupError?

    /// Verbose status details
    public let action: String?
    public let item: String?
    public let duration: Double?
    public let dataSize: Int64?
    public let metadataSize: Int64?

    /// Summary details
    public let filesNew: Int?
    public let filesChanged: Int?
    public let filesUnmodified: Int?
    public let dirsNew: Int?
    public let dirsChanged: Int?
    public let dirsUnmodified: Int?
    public let dataBlobs: Int?
    public let treeBlobs: Int?
    public let dataAdded: Int64?
    public let dataAddedPacked: Int64?
    public let totalFilesProcessed: Int?
    public let totalBytesProcessed: Int64?
    public let totalDuration: Double?
    public let snapshotId: String?

    private enum CodingKeys: String, CodingKey {
        case messageType = "message_type"
        case secondsElapsed = "seconds_elapsed"
        case secondsRemaining = "seconds_remaining"
        case percentDone = "percent_done"
        case totalFiles = "total_files"
        case filesDone = "files_done"
        case totalBytes = "total_bytes"
        case bytesDone = "bytes_done"
        case errorCount = "error_count"
        case currentFiles = "current_files"
        case error
        case action
        case item
        case duration
        case dataSize = "data_size"
        case metadataSize = "metadata_size"
        case filesNew = "files_new"
        case filesChanged = "files_changed"
        case filesUnmodified = "files_unmodified"
        case dirsNew = "dirs_new"
        case dirsChanged = "dirs_changed"
        case dirsUnmodified = "dirs_unmodified"
        case dataBlobs = "data_blobs"
        case treeBlobs = "tree_blobs"
        case dataAdded = "data_added"
        case dataAddedPacked = "data_added_packed"
        case totalFilesProcessed = "total_files_processed"
        case totalBytesProcessed = "total_bytes_processed"
        case totalDuration = "total_duration"
        case snapshotId = "snapshot_id"
    }
}

/// Represents an error during backup
public struct BackupError: Codable {
    public let message: String
    public let during: String
    public let item: String?

    private enum CodingKeys: String, CodingKey {
        case message = "error.message"
        case during
        case item
    }
}

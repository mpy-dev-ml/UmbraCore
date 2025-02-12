import Foundation

/// Represents a snapshot in a Restic repository
///
/// A snapshot represents a point-in-time backup of one or more paths in a Restic
/// repository. It contains metadata about the backup including when it was created,
/// what paths were included, and its relationship to other snapshots.
///
/// - Important: Snapshots are immutable once created
///
/// Example usage:
/// ```swift
/// // Create a new snapshot
/// let snapshot = ResticSnapshot(
///     id: "abc123",
///     time: Date(),
///     hostname: "macbook-pro",
///     tags: ["documents", "weekly"],
///     paths: ["/Users/username/Documents"],
///     parent: "def456",
///     size: 1024 * 1024 * 1024,
///     repositoryId: "repo123"
/// )
///
/// // Access snapshot properties
/// print(
///     """
///     Snapshot \(snapshot.shortId) created at \
///     \(snapshot.time.formatted())
///     """
/// )
///
/// // Check backup details
/// print(
///     """
///     Backed up \(snapshot.paths.count) paths, \
///     total size: \(ByteCountFormatter().string(fromByteCount: Int64(snapshot.size)))
///     """
/// )
/// ```
@objc
public final class ResticSnapshot: NSObject,
    NSSecureCoding,
    Codable,
    Identifiable,
    Equatable,
    Hashable {
    // MARK: Lifecycle

    /// Creates a new snapshot instance
    /// - Parameters:
    ///   - id: Unique identifier of the snapshot
    ///   - time: Time when the snapshot was created
    ///   - hostname: Hostname where the snapshot was created
    ///   - tags: Optional tags associated with the snapshot
    ///   - paths: Paths included in the snapshot
    ///   - parent: Optional parent snapshot ID for incremental backups
    ///   - size: Total size of the snapshot in bytes
    ///   - repositoryId: ID of the repository this snapshot belongs to
    ///
    /// Example:
    /// ```swift
    /// let snapshot = ResticSnapshot(
    ///     id: "abc123def456",
    ///     time: Date(),
    ///     hostname: "macbook-pro",
    ///     tags: ["system", "monthly"],
    ///     paths: [
    ///         "/Users/username/Documents",
    ///         "/Users/username/Desktop"
    ///     ],
    ///     parent: "789xyz",
    ///     size: 2_147_483_648,
    ///     repositoryId: "main-repo"
    /// )
    /// ```
    public init(
        id: String,
        time: Date,
        hostname: String,
        tags: [String]? = nil,
        paths: [String],
        parent: String? = nil,
        size: UInt64,
        repositoryId: String
    ) {
        self.id = id
        self.time = time
        self.hostname = hostname
        self.tags = tags
        self.paths = paths
        self.parent = parent
        self.size = size
        self.repositoryId = repositoryId
        super.init()
    }

    /// Creates a snapshot from JSON data
    /// - Parameter json: Dictionary containing snapshot data
    /// - Throws: DecodingError if required fields are missing or invalid
    ///
    /// Required JSON fields:
    /// ```json
    /// {
    ///     "id": "string",
    ///     "time": "ISO8601 string",
    ///     "hostname": "string",
    ///     "paths": ["string"],
    ///     "size": number,
    ///     "repository_id": "string"
    /// }
    /// ```
    ///
    /// Optional JSON fields:
    /// ```json
    /// {
    ///     "tags": ["string"],
    ///     "parent": "string"
    /// }
    /// ```
    public convenience init(json: [String: Any]) throws {
        guard
            let id = json["id"] as? String,
            let timeString = json["time"] as? String,
            let hostname = json["hostname"] as? String,
            let paths = json["paths"] as? [String],
            let size = json["size"] as? UInt64,
            let repositoryId = json["repository_id"] as? String
        else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: """
                Missing required fields in snapshot JSON. Required: \
                id, time, hostname, paths, size, repository_id
                """
            )
            throw DecodingError.dataCorrupted(context)
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let time = dateFormatter.date(from: timeString) else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: """
                Invalid time format in snapshot JSON. Expected ISO8601, \
                got: \(timeString)
                """
            )
            throw DecodingError.dataCorrupted(context)
        }

        self.init(
            id: id,
            time: time,
            hostname: hostname,
            tags: json["tags"] as? [String],
            paths: paths,
            parent: json["parent"] as? String,
            size: size,
            repositoryId: repositoryId
        )
    }

    /// Decodes a snapshot from secure storage
    /// - Parameter coder: The coder to read from
    /// - Returns: A new ResticSnapshot instance, or nil if decoding fails
    ///
    /// Decoding process:
    /// 1. Validate required fields
    /// 2. Type-check all values
    /// 3. Handle optional fields
    /// 4. Initialize snapshot
    public required init?(coder: NSCoder) {
        guard
            let id = coder.decodeObject(
                of: NSString.self,
                forKey: "id"
            ) as String?,
            let time = coder.decodeObject(
                of: NSDate.self,
                forKey: "time"
            ) as Date?,
            let hostname = coder.decodeObject(
                of: NSString.self,
                forKey: "hostname"
            ) as String?,
            let paths = coder.decodeObject(
                of: NSArray.self,
                forKey: "paths"
            ) as? [String],
            let repositoryId = coder.decodeObject(
                of: NSString.self,
                forKey: "repositoryId"
            ) as String?
        else {
            return nil
        }

        self.id = id
        self.time = time
        self.hostname = hostname
        tags = coder.decodeObject(
            of: NSArray.self,
            forKey: "tags"
        ) as? [String]
        self.paths = paths
        parent = coder.decodeObject(
            of: NSString.self,
            forKey: "parent"
        ) as String?
        size = coder.decodeUInt64(forKey: "size")
        self.repositoryId = repositoryId
        super.init()
    }

    // MARK: Public

    public static var supportsSecureCoding: Bool { true }

    /// Provides a hash value for the snapshot
    override public var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(repositoryId)
        return hasher.finalize()
    }

    /// Unique identifier of the snapshot
    ///
    /// This ID is generated by Restic and is unique within the repository.
    /// Format: SHA256 hash (64 characters)
    public let id: String

    /// Time when the snapshot was created
    ///
    /// - Uses system timezone
    /// - Includes millisecond precision
    /// - Set by Restic during backup
    public let time: Date

    /// Hostname where the snapshot was created
    ///
    /// Used to:
    /// - Identify backup source
    /// - Filter snapshots by machine
    /// - Track backup origins
    public let hostname: String

    /// Tags associated with the snapshot
    ///
    /// Optional tags that can be used to:
    /// - Categorize backups
    /// - Filter snapshots
    /// - Group related backups
    /// - Implement retention policies
    public let tags: [String]?

    /// Paths included in the snapshot
    ///
    /// List of absolute paths that were:
    /// - Included in backup
    /// - Successfully processed
    /// - Stored in repository
    public let paths: [String]

    /// Parent snapshots IDs (for incremental backups)
    ///
    /// - Nil for full backups
    /// - Set for incremental backups
    /// - References previous snapshot
    public let parent: String?

    /// Total size of the snapshot in bytes
    ///
    /// Represents:
    /// - Combined size of all files
    /// - Before compression
    /// - Before deduplication
    public let size: UInt64

    /// Repository ID this snapshot belongs to
    ///
    /// Used to:
    /// - Track snapshot ownership
    /// - Prevent ID collisions
    /// - Support multiple repositories
    public let repositoryId: String

    /// Short ID (first 8 characters)
    ///
    /// Convenient shorter version of the snapshot ID for:
    /// - Display purposes
    /// - User interaction
    /// - Log messages
    public var shortId: String {
        String(id.prefix(8))
    }

    // MARK: - NSObject

    /// Compares:
    /// - Same snapshot ID
    /// - Same repository ID
    ///
    /// Note: Other properties don't affect equality
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ResticSnapshot else {
            return false
        }
        return id == other.id && repositoryId == other.repositoryId
    }

    // MARK: - NSSecureCoding

    /// Encodes the snapshot for secure storage
    /// - Parameter coder: The coder to write to
    ///
    /// Encodes all properties with appropriate types:
    /// - Strings as NSString
    /// - Arrays as NSArray
    /// - Date as NSDate
    /// - UInt64 as primitive
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(time, forKey: "time")
        coder.encode(hostname, forKey: "hostname")
        coder.encode(tags, forKey: "tags")
        coder.encode(paths, forKey: "paths")
        coder.encode(parent, forKey: "parent")
        coder.encode(size, forKey: "size")
        coder.encode(repositoryId, forKey: "repositoryId")
    }

    // MARK: - Hashable

    /// Hashes the essential components of the snapshot
    ///
    /// Combines:
    /// - Snapshot ID
    /// - Repository ID
    ///
    /// Note: Other properties are not included as they don't affect identity
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(repositoryId)
    }
}

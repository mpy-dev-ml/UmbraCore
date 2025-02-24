import Foundation

/// Types of objects stored in a repository
public enum RepositoryObjectType: String, Codable {
    case blob = "blob"
    case pack = "pack"
    case index = "index"
    case snapshot = "snapshot"
    case key = "key"
    case lock = "lock"
}

/// Represents an object in the repository
public struct RepositoryObject: Codable {
    /// Type of the object
    public let type: RepositoryObjectType

    /// Object ID
    public let id: String

    /// Size in bytes
    public let size: Int64

    /// Packed size in bytes (if compressed)
    public let packedSize: Int64?

    /// Time the object was created
    public let time: Date

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case size
        case packedSize = "packed_size"
        case time
    }
}

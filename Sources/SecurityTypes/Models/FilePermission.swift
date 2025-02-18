import Foundation

/// Represents the permission level for accessing a file
@frozen public enum FilePermission: Sendable {
    /// Read-only access to the file
    case readOnly
    /// Read and write access to the file
    case readWrite
    /// No access to the file
    case none

    /// Whether the permission allows reading
    public var canRead: Bool {
        switch self {
        case .readOnly, .readWrite:
            return true
        case .none:
            return false
        }
    }

    /// Whether the permission allows writing
    public var canWrite: Bool {
        switch self {
        case .readWrite:
            return true
        case .readOnly, .none:
            return false
        }
    }

    /// Creates a FilePermission from file attributes
    /// - Parameter attributes: File attributes dictionary from FileManager
    /// - Returns: Appropriate FilePermission based on writability
    public static func from(attributes: [FileAttributeKey: Any]) -> FilePermission {
        let readable = (attributes[.posixPermissions] as? NSNumber)?.intValue ?? 0 & 0o444 != 0
        let writable = (attributes[.posixPermissions] as? NSNumber)?.intValue ?? 0 & 0o222 != 0

        switch (readable, writable) {
        case (true, true):
            return .readWrite
        case (true, false):
            return .readOnly
        default:
            return .none
        }
    }
}

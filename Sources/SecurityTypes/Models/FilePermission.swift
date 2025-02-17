import Foundation

/// Represents the permission level for accessing a file
@frozen public enum FilePermission: Sendable {
    /// Read-only access to the file
    case readOnly
    /// Read and write access to the file
    case readWrite
    /// No access to the file
    case none
}

// ResourceLocator.swift
// UmbraCoreTypes
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// A Foundation-free representation of a resource location.
/// 
/// This type provides a replacement for Foundation's URL type without any
/// Foundation dependencies. It implements the core functionality needed
/// for identifying and locating resources within the UmbraCore ecosystem.
@frozen
public struct ResourceLocator: Sendable, Equatable, Hashable {
    // MARK: - Properties

    /// The scheme component of the locator (e.g., "file", "https")
    public let scheme: String

    /// The path component of the locator
    public let path: String

    /// Optional query parameters
    public let query: String?

    /// Optional fragment identifier
    public let fragment: String?

    /// Returns true if this locator points to a local file system resource
    public var isFileResource: Bool {
        return scheme == "file"
    }

    // MARK: - Initialization

    /// Create a new ResourceLocator
    /// - Parameters:
    ///   - scheme: The scheme component (e.g., "file", "https")
    ///   - path: The path component
    ///   - query: Optional query parameters
    ///   - fragment: Optional fragment identifier
    public init(scheme: String, path: String, query: String? = nil, fragment: String? = nil) {
        self.scheme = scheme
        self.path = path
        self.query = query
        self.fragment = fragment
    }

    /// Create a file system ResourceLocator
    /// - Parameter path: The file system path
    /// - Returns: A ResourceLocator with "file" scheme
    public static func fileLocator(path: String) -> ResourceLocator {
        return ResourceLocator(scheme: "file", path: path)
    }

    // MARK: - String Representation

    /// Convert the ResourceLocator to its string representation
    /// - Returns: A string representation of this ResourceLocator
    public func toString() -> String {
        var result = "\(scheme)://\(path)"

        if let query = query {
            result += "?\(query)"
        }

        if let fragment = fragment {
            result += "#\(fragment)"
        }

        return result
    }
}

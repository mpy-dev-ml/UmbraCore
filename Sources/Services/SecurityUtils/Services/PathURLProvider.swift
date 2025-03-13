import Foundation
import SecurityUtilsProtocols

/// Default implementation of URLProvider that uses FileManager
public struct PathURLProvider: URLProvider {
    // Use a static property instead of an instance property to avoid Sendable issues
    // FileManager.default is already thread-safe for read operations

    /// Initialize a new PathURLProvider
    public init() {
        // No initialization needed
    }

    /// Get the URL for a specified path
    /// - Parameter path: Path string
    /// - Returns: URL for the path
    public func url(forPath path: String) -> URL {
        URL(fileURLWithPath: path)
    }

    /// Get the URL for a specified directory
    /// - Parameters:
    ///   - directory: FileManager search path directory
    ///   - domain: FileManager search path domain mask
    /// - Returns: URL for the directory
    /// - Throws: Error if directory cannot be located
    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask
    ) throws -> URL {
        try FileManager.default.url(for: directory, in: domain, appropriateFor: nil, create: false)
    }

    /// Get the URL for a specified directory with additional path components
    /// - Parameters:
    ///   - directory: FileManager search path directory
    ///   - domain: FileManager search path domain mask
    ///   - pathComponents: Additional path components to append
    /// - Returns: URL for the directory with path components
    /// - Throws: Error if directory cannot be located
    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        pathComponents: [String]
    ) throws -> URL {
        var url = try url(for: directory, in: domain)
        for component in pathComponents {
            url.appendPathComponent(component)
        }
        return url
    }
}

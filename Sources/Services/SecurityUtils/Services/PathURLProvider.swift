import Foundation
import SecurityUtilsProtocols

/// Default implementation of URLProvider that uses FileManager
public struct PathURLProvider: URLProvider {

    /// FileManager instance
    private let fileManager: FileManager

    /// Initialize a new PathURLProvider
    /// - Parameter fileManager: FileManager instance to use
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
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
    public func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask) throws -> URL {
        try fileManager.url(for: directory, in: domain, appropriateFor: nil, create: false)
    }

    /// Get the URL for a specified directory with additional path components
    /// - Parameters:
    ///   - directory: FileManager search path directory
    ///   - domain: FileManager search path domain mask
    ///   - pathComponents: Additional path components to append
    /// - Returns: URL for the directory with path components
    /// - Throws: Error if directory cannot be located
    public func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, pathComponents: [String]) throws -> URL {
        var url = try url(for: directory, in: domain)
        for component in pathComponents {
            url.appendPathComponent(component)
        }
        return url
    }
}

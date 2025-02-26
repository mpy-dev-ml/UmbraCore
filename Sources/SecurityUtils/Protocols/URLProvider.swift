import Foundation

/// Protocol for providing URL-related operations
public protocol URLProvider: Sendable {
    /// Get the URL for a specified path
    /// - Parameter path: Path string
    /// - Returns: URL for the path
    func url(forPath path: String) -> URL

    /// Get the URL for a specified directory
    /// - Parameters:
    ///   - directory: FileManager search path directory
    ///   - domain: FileManager search path domain mask
    /// - Returns: URL for the directory
    /// - Throws: Error if directory cannot be located
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask) throws -> URL

    /// Get the URL for a specified directory with additional path components
    /// - Parameters:
    ///   - directory: FileManager search path directory
    ///   - domain: FileManager search path domain mask
    ///   - pathComponents: Additional path components to append
    /// - Returns: URL for the directory with path components
    /// - Throws: Error if directory cannot be located
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, pathComponents: [String]) throws -> URL
}

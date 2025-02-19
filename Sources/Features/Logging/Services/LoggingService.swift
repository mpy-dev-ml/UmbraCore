import Foundation
import SecurityTypes
import UmbraTestKit

/// Service for managing log files with security-scoped bookmarks
public actor LoggingService {
    /// Shared instance with default security service
    public static let shared = LoggingService(securityProvider: MockSecurityProvider())

    /// The security service to use for file operations
    private let securityProvider: SecurityProvider

    /// Initialize a new logging service
    /// - Parameter securityProvider: The security provider to use for file operations
    public init(securityProvider: SecurityProvider) {
        self.securityProvider = securityProvider
    }

    /// Create a bookmark for a log file
    /// - Parameter path: Path to the log file
    /// - Returns: Bookmark data for the file
    public func createLogBookmark(forPath path: String) async throws -> [UInt8] {
        try await securityProvider.createBookmark(forPath: path)
    }

    /// Save a bookmark for a log file
    /// - Parameters:
    ///   - bookmarkData: The bookmark data to save
    ///   - identifier: Unique identifier for the bookmark
    public func saveLogBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        try await securityProvider.saveBookmark(bookmarkData, withIdentifier: identifier)
    }

    /// Load a bookmark for a log file
    /// - Parameter identifier: Identifier of the bookmark to load
    /// - Returns: Bookmark data for the file
    public func loadLogBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        try await securityProvider.loadBookmark(withIdentifier: identifier)
    }

    /// Delete a bookmark for a log file
    /// - Parameter identifier: Identifier of the bookmark to delete
    public func deleteLogBookmark(withIdentifier identifier: String) async throws {
        try await securityProvider.deleteBookmark(withIdentifier: identifier)
    }

    /// Start accessing a log file
    /// - Parameter path: Path to the log file
    /// - Returns: True if access was granted
    public func startAccessingLog(path: String) async throws -> Bool {
        try await securityProvider.startAccessing(path: path)
    }

    /// Stop accessing a log file
    /// - Parameter path: Path to the log file
    public func stopAccessingLog(path: String) async {
        await securityProvider.stopAccessing(path: path)
    }

    /// Stop accessing all log files
    public func stopAccessingAllLogs() async {
        await securityProvider.stopAccessingAllResources()
    }

    /// Check if a log file is being accessed
    /// - Parameter path: Path to check
    /// - Returns: True if the file is being accessed
    public func isAccessingLog(path: String) async -> Bool {
        await securityProvider.isAccessing(path: path)
    }

    /// Get all currently accessed log file paths
    /// - Returns: Set of paths that are currently being accessed
    public func getAccessedLogPaths() async -> Set<String> {
        await securityProvider.getAccessedPaths()
    }

    /// Perform an operation with security-scoped access to a log file
    /// - Parameters:
    ///   - path: Path to the log file
    ///   - operation: Operation to perform while accessing the file
    /// - Returns: Result of the operation
    public func withSecurityScopedLogAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        try await securityProvider.withSecurityScopedAccess(to: path, perform: operation)
    }
}

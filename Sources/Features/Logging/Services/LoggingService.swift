import Foundation
import CoreTypes
@preconcurrency import SecurityInterfaces
import SecurityInterfacesFoundation
import SecurityTypesProtocols

/// Service for handling logging operations
@available(macOS 14.0, *)
public class LoggingService {
    private let securityProvider: SecurityInterfaces.SecurityProviderFoundation
    
    /// Initialize with a security provider
    /// - Parameter securityProvider: The security provider to use
    public init(securityProvider: SecurityInterfaces.SecurityProviderFoundation) {
        self.securityProvider = securityProvider
    }
    
    /// Create a bookmark for a log file
    /// - Parameter path: Path to the log file
    /// - Returns: Bookmark data
    /// - Throws: SecurityError if bookmark creation fails
    public nonisolated func createLogBookmark(path: String) async throws -> CoreTypes.BinaryData {
        return try await securityProvider.createBookmark(for: path)
    }
    
    /// Resolve a bookmark for a log file
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: Tuple containing path and whether the bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    public nonisolated func resolveLogBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (path: String, isStale: Bool) {
        let result = try await securityProvider.resolveBookmark(bookmarkData)
        return (path: result.identifier, isStale: result.isStale)
    }
    
    /// Validate a bookmark for a log file
    /// - Parameter bookmarkData: Bookmark data
    /// - Returns: True if the bookmark is valid
    /// - Throws: SecurityError if bookmark validation fails
    public nonisolated func validateLogBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool {
        return try await securityProvider.validateBookmark(bookmarkData)
    }
    
    /// Start accessing a log file
    /// - Parameter path: Path to the log file
    /// - Returns: True if access was granted
    /// - Throws: SecurityError if access fails
    public nonisolated func startAccessingLog(path: String) async throws -> Bool {
        return try await securityProvider.startAccessingResource(identifier: path)
    }
    
    /// Stop accessing a log file
    /// - Parameter path: Path to the log file
    public nonisolated func stopAccessingLog(path: String) async {
        await securityProvider.stopAccessingResource(identifier: path)
    }
    
    /// Stop accessing all log files
    public nonisolated func stopAccessingAllLogs() async {
        await securityProvider.stopAccessingAllResources()
    }
    
    /// Check if a log file is being accessed
    /// - Parameter path: Path to the log file
    /// - Returns: True if the log file is being accessed
    public nonisolated func isAccessingLog(path: String) async -> Bool {
        return await securityProvider.isAccessingResource(identifier: path)
    }
    
    /// Get all accessed log files
    /// - Returns: Set of paths to accessed log files
    public nonisolated func getAccessedLogs() async -> Set<String> {
        return await securityProvider.getAccessedResourceIdentifiers()
    }
    
    /// Perform an operation with security-scoped access to a log file
    /// - Parameters:
    ///   - path: Path to the log file
    ///   - operation: The operation to perform
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation
    public nonisolated func withSecurityScopedAccess<T: Sendable>(to path: String, operation: () async throws -> T) async throws -> T {
        let accessGranted = try await startAccessingLog(path: path)
        guard accessGranted else {
            throw SecurityInterfaces.SecurityInterfacesError.accessError("Failed to access log file at \(path)")
        }
        
        // Create a cleanup function that doesn't capture any variables
        // This avoids the task isolation warning
        func scheduleCleanup(provider: SecurityInterfaces.SecurityProviderFoundation, resourcePath: String) {
            // Using a separate function to avoid capturing context
            @Sendable func cleanupResource() async {
                await provider.stopAccessingResource(identifier: resourcePath)
            }
            
            Task.detached(operation: cleanupResource)
        }
        
        defer {
            // Schedule cleanup without capturing context in the closure
            scheduleCleanup(provider: securityProvider, resourcePath: path)
        }
        
        return try await operation()
    }
}

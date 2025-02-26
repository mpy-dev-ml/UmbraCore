import Foundation
import CoreServicesTypes

/// Protocol defining security-related operations for managing secure resource access
public protocol SecurityProvider: Sendable {
    // MARK: - Bookmark Management

    /// Create a security-scoped bookmark for a URL
    /// - Parameter path: File system path to create bookmark for
    /// - Returns: Bookmark data that can be persisted
    /// - Throws: SecurityError if bookmark creation fails
    func createBookmark(forPath path: String) async throws -> [UInt8]

    /// Resolve a previously created security-scoped bookmark
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: Tuple containing resolved path and whether bookmark is stale
    /// - Throws: SecurityError if bookmark resolution fails
    func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool)

    // MARK: - Resource Access Control

    /// Start accessing a security-scoped resource
    /// - Parameter path: Path to the resource to access
    /// - Returns: A boolean indicating if access was granted
    /// - Throws: SecurityError if access fails or is denied
    func startAccessing(path: String) async throws -> Bool

    /// Stop accessing a security-scoped resource
    /// - Parameter path: Path to the resource to stop accessing
    /// - Note: This method should be called in a defer block after startAccessing
    func stopAccessing(path: String) async

    /// Stop accessing all security-scoped resources
    /// - Note: This is typically called during cleanup or when the app is terminating
    func stopAccessingAllResources() async

    /// Perform an operation with security-scoped resource access
    /// - Parameters:
    ///   - path: Path to the resource to access
    ///   - operation: Operation to perform while resource is accessible
    /// - Returns: Result of the operation
    /// - Throws: SecurityError if access fails, or any error thrown by the operation
    /// - Note: This method handles starting and stopping access automatically
    func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T

    // MARK: - Bookmark Persistence

    /// Save a bookmark to persistent storage
    /// - Parameters:
    ///   - bookmarkData: Bookmark data to save
    ///   - identifier: Unique identifier for the bookmark
    /// - Throws: SecurityError if saving fails
    func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws

    /// Load a bookmark from persistent storage
    /// - Parameter identifier: Identifier of the bookmark to load
    /// - Returns: The stored bookmark data
    /// - Throws: SecurityError if loading fails or bookmark not found
    func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8]

    /// Delete a bookmark from persistent storage
    /// - Parameter identifier: Identifier of the bookmark to delete
    /// - Throws: SecurityError if deletion fails
    func deleteBookmark(withIdentifier identifier: String) async throws

    // MARK: - Status and Validation

    /// Check if a path is currently being accessed
    /// - Parameter path: Path to check
    /// - Returns: True if the path is currently being accessed
    func isAccessing(path: String) async -> Bool

    /// Validate a bookmark's data
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if the bookmark data is valid
    /// - Throws: SecurityError if validation fails
    func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool

    /// Get all currently accessed resource paths
    /// - Returns: Set of paths that are currently being accessed
    func getAccessedPaths() async -> Set<String>
}

/// Manages security operations and access control
public actor SecurityService: UmbraService, SecurityProvider {
    public static let serviceIdentifier = "com.umbracore.security"

    private var _state: ServiceState = .uninitialized
    public nonisolated(unsafe) private(set) var state: ServiceState = .uninitialized

    private let container: ServiceContainer
    private var cryptoService: CryptoService?
    private var accessedPaths: Set<String>
    private var bookmarks: [String: [UInt8]]

    /// Initialize security service
    /// - Parameter container: Service container for dependencies
    public init(container: ServiceContainer) {
        self.container = container
        self.accessedPaths = []
        self.bookmarks = [:]
    }

    /// Initialize the service
    public func initialize() async throws {
        guard _state == .uninitialized else {
            throw ServiceError.configurationError("Service already initialized")
        }

        state = .initializing
        _state = .initializing

        // Resolve dependencies
        cryptoService = try await container.resolve(CryptoService.self)

        _state = .ready
        state = .ready
    }

    /// Gracefully shut down the service
    public func shutdown() async {
        if _state == .ready {
            state = .shuttingDown
            _state = .shuttingDown

            // Stop accessing all paths
            await stopAccessingAllResources()

            // Shutdown crypto service
            if let crypto = cryptoService {
                await crypto.shutdown()
                cryptoService = nil
            }

            state = .uninitialized
            _state = .uninitialized
        }
    }

    // MARK: - SecurityProvider Implementation

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return Array(bookmarkData)
        } catch {
            throw SecurityError.bookmarkError("Failed to create bookmark for \(path): \(error.localizedDescription)")
        }
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        let data = Data(bookmarkData)
        var isStale = false

        do {
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return (url.path, isStale)
        } catch {
            throw SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
        }
    }

    public func startAccessing(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        if url.startAccessingSecurityScopedResource() {
            accessedPaths.insert(path)
            return true
        } else {
            throw SecurityError.accessError("Failed to access: \(path)")
        }
    }

    public func stopAccessing(path: String) async {
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
        accessedPaths.remove(path)
    }

    public func stopAccessingAllResources() async {
        for path in accessedPaths {
            await stopAccessing(path: path)
        }
    }

    public func withSecurityScopedAccess<T: Sendable>(
        to path: String,
        perform operation: @Sendable () async throws -> T
    ) async throws -> T {
        let accessGranted = try await startAccessing(path: path)
        guard accessGranted else {
            throw SecurityError.accessError("Access denied to: \(path)")
        }

        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }

    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        bookmarks[identifier] = bookmarkData
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        guard let data = bookmarks[identifier] else {
            throw SecurityError.bookmarkError("Bookmark not found: \(identifier)")
        }
        return data
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityError.bookmarkError("Bookmark not found: \(identifier)")
        }
    }

    public func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        do {
            let (_, isStale) = try await resolveBookmark(bookmarkData)
            return !isStale
        } catch {
            return false
        }
    }

    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }
}

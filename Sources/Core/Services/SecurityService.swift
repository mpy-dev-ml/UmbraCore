import CoreServicesTypes
import CoreTypes
import Foundation
import SecurityInterfaces

/// Manages security operations and access control
public actor SecurityService: UmbraService, SecurityProviderBase, SecurityProvider {
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

    // MARK: - SecurityProviderBase Implementation (Foundation-free)

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

    // Foundation-free credential methods
    public func storeCredential(
        data: [UInt8],
        account: String,
        service: String,
        metadata: [String: String]?
    ) async throws -> String {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        // Just store a basic implementation for now
        let key = "\(account).\(service)"
        bookmarks[key] = data
        return key
    }

    public func loadCredential(
        account: String,
        service: String
    ) async throws -> [UInt8] {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        let key = "\(account).\(service)"
        guard let data = bookmarks[key] else {
            throw SecurityError.itemNotFound
        }

        return data
    }

    public func loadCredentialWithMetadata(
        account: String,
        service: String
    ) async throws -> ([UInt8], [String: String]?) {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        let key = "\(account).\(service)"
        guard let data = bookmarks[key] else {
            throw SecurityError.itemNotFound
        }

        // For now, we don't have metadata in our simple implementation
        return (data, nil)
    }

    public func deleteCredential(
        account: String,
        service: String
    ) async throws {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        let key = "\(account).\(service)"
        guard bookmarks.removeValue(forKey: key) != nil else {
            throw SecurityError.itemNotFound
        }
    }

    public func generateRandomBytes(length: Int) async throws -> [UInt8] {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        if let crypto = cryptoService {
            // Use crypto service if available
            let data = try await crypto.generateSecureRandomBytes(length: length)
            return Array(data)
        } else {
            // Fallback implementation using SecRandomCopyBytes
            var bytes = [UInt8](repeating: 0, count: length)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

            guard status == errSecSuccess else {
                throw SecurityError.randomGenerationFailed
            }

            return bytes
        }
    }

    // MARK: - SecurityProvider Implementation (Foundation-dependent)

    public func createBookmark(for url: URL) async throws -> Data {
        do {
            return try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            throw SecurityError.bookmarkError("Failed to create bookmark for \(url.path): \(error.localizedDescription)")
        }
    }

    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        var isStale = false

        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return (url, isStale)
        } catch {
            throw SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
        }
    }

    public func startAccessing(url: URL) async throws -> Bool {
        if url.startAccessingSecurityScopedResource() {
            accessedPaths.insert(url.path)
            return true
        } else {
            throw SecurityError.accessError("Failed to access: \(url.path)")
        }
    }

    public func stopAccessing(url: URL) async {
        url.stopAccessingSecurityScopedResource()
        accessedPaths.remove(url.path)
    }

    public func isAccessing(url: URL) async -> Bool {
        return accessedPaths.contains(url.path)
    }

    public func getAccessedUrls() async -> Set<URL> {
        return Set(accessedPaths.map { URL(fileURLWithPath: $0) })
    }

    public func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
        do {
            var isStale = false
            _ = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return !isStale
        } catch {
            return false
        }
    }

    public func saveBookmark(_ bookmarkData: Data, withIdentifier identifier: String) async throws {
        bookmarks[identifier] = Array(bookmarkData)
    }

    public func loadBookmark(withIdentifier identifier: String) async throws -> Data {
        guard let bookmark = bookmarks[identifier] else {
            throw SecurityError.bookmarkError("Bookmark not found for identifier: \(identifier)")
        }
        return Data(bookmark)
    }

    public func deleteBookmark(withIdentifier identifier: String) async throws {
        guard bookmarks.removeValue(forKey: identifier) != nil else {
            throw SecurityError.bookmarkError("No bookmark found for identifier: \(identifier)")
        }
    }

    public func storeCredential(
        data: Data,
        account: String,
        service: String,
        metadata: [String: String]?
    ) async throws -> String {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        // Simple implementation for now
        let key = "\(account).\(service)"
        bookmarks[key] = Array(data)
        return key
    }

    public func loadCredential(
        account: String,
        service: String
    ) async throws -> Data {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        let key = "\(account).\(service)"
        guard let data = bookmarks[key] else {
            throw SecurityError.itemNotFound
        }

        return Data(data)
    }

    public func loadCredentialWithMetadata(
        account: String,
        service: String
    ) async throws -> (Data, [String: String]?) {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        let key = "\(account).\(service)"
        guard let data = bookmarks[key] else {
            throw SecurityError.itemNotFound
        }

        // We don't have metadata in our simple implementation
        return (Data(data), nil)
    }

    public func generateRandomBytes(length: Int) async throws -> Data {
        guard state == .ready else {
            throw ServiceError.invalidState("Security service not initialized")
        }

        if let crypto = cryptoService {
            // Use crypto service if available and it has the method
            return try await crypto.generateSecureRandomBytes(length: length)
        } else {
            // Fallback implementation
            var bytes = [UInt8](repeating: 0, count: length)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

            guard status == errSecSuccess else {
                throw SecurityError.randomGenerationFailed
            }

            return Data(bytes)
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

    public func stopAccessingAllResources() async {
        for path in accessedPaths {
            await stopAccessing(path: path)
        }
    }

    public func isAccessing(path: String) async -> Bool {
        accessedPaths.contains(path)
    }

    public func getAccessedPaths() async -> Set<String> {
        accessedPaths
    }
}

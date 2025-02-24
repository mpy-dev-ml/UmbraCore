import Foundation
import Repositories_Types
import SecurityTypes_Protocols
import SecurityTypes_Types
import UmbraSecurity

/// A mock repository implementation for testing that handles sandbox security
public actor MockRepository: Repository {
    public let identifier: String
    public let location: URL
    public private(set) var state: RepositoryState

    private let securityProvider: SecurityProvider
    private var isLocked: Bool = false
    private var mockStats: RepositoryStats
    private var shouldFailNextOperation: Bool = false
    private var error: RepositoryError?
    private var hasSecurityAccess: Bool = false

    public init(
        identifier: String = "mock-repo",
        location: URL = FileManager.default.temporaryDirectory.appendingPathComponent("mock-repo"),
        initialState: RepositoryState = .uninitialized,
        securityProvider: SecurityProvider = SecurityService.shared
    ) {
        self.identifier = identifier
        self.location = location
        self.state = initialState
        self.securityProvider = securityProvider
        self.mockStats = RepositoryStats(
            totalSize: 1_024 * 1_024, // 1MB
            snapshotCount: 5,
            deduplicationSavings: 512 * 1_024, // 512KB
            lastModified: Date(),
            compressionRatio: 0.7
        )
    }

    // MARK: - Security Access Management

    /// Ensure security-scoped access to the repository location
    /// - Throws: RepositoryError if access cannot be obtained
    private func ensureSecurityAccess() async throws {
        guard !hasSecurityAccess else { return }

        do {
            hasSecurityAccess = try await securityProvider.startAccessing(path: location.path)
            if !hasSecurityAccess {
                throw RepositoryError.notAccessible(reason: "Failed to obtain security-scoped access")
            }
        } catch {
            throw RepositoryError.notAccessible(reason: "Security access error: \(error.localizedDescription)")
        }
    }

    /// Release security-scoped access to the repository location
    private func releaseSecurityAccess() async {
        if hasSecurityAccess {
            await securityProvider.stopAccessing(path: location.path)
            hasSecurityAccess = false
        }
    }

    // MARK: - Test Control Methods

    /// Set the repository to fail the next operation
    /// - Parameter error: The error to throw, or nil to use a default error
    public func setFailNextOperation(_ error: RepositoryError? = nil) {
        shouldFailNextOperation = true
        self.error = error
    }

    /// Update the mock statistics
    /// - Parameter stats: New repository statistics
    public func updateStats(_ stats: RepositoryStats) {
        self.mockStats = stats
    }

    // MARK: - Repository Protocol Implementation

    public func initialize() async throws {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw error ?? RepositoryError.initializationFailed(reason: "Mock initialization failure")
        }

        try await ensureSecurityAccess()

        // Simulate repository initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        state = .ready
    }

    public func validate() async throws -> Bool {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw error ?? RepositoryError.validationFailed(reason: "Mock validation failure")
        }

        try await ensureSecurityAccess()
        return state == .ready
    }

    public func lock() async throws {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw error ?? RepositoryError.locked(reason: "Mock lock failure")
        }

        try await ensureSecurityAccess()

        if isLocked {
            throw RepositoryError.locked(reason: "Repository is already locked")
        }

        isLocked = true
        state = .locked
    }

    public func unlock() async throws {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw error ?? RepositoryError.operationFailed(reason: "Mock unlock failure")
        }

        try await ensureSecurityAccess()

        if !isLocked {
            throw RepositoryError.operationFailed(reason: "Repository is not locked")
        }

        isLocked = false
        state = .ready
    }

    public func isAccessible() async -> Bool {
        do {
            try await ensureSecurityAccess()
            return state == .ready || state == .locked
        } catch {
            return false
        }
    }

    public func getStats() async throws -> RepositoryStats {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw error ?? RepositoryError.operationFailed(reason: "Mock stats retrieval failure")
        }

        try await ensureSecurityAccess()
        return mockStats
    }

    // MARK: - Cleanup

    deinit {
        Task {
            await releaseSecurityAccess()
        }
    }
}

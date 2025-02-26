import Foundation
import RepositoriesTypes
import SecurityTypes
import SecurityTypesProtocols

/// A mock repository implementation for testing that handles sandbox security
public actor MockRepository: RepositoryCore & RepositoryLocking & RepositoryMaintenance {
    public let identifier: String
    public let location: URL
    public private(set) var state: RepositoryState

    private let securityProvider: SecurityProvider
    private var isLocked: Bool = false
    private var mockStats: RepositoryStatistics

    public init(
        identifier: String = UUID().uuidString,
        location: URL = FileManager.default.temporaryDirectory.appendingPathComponent("mock-repo"),
        initialState: RepositoryState = .uninitialized,
        securityProvider: SecurityProvider = MockSecurityProvider()
    ) {
        self.identifier = identifier
        self.location = location
        self.state = initialState
        self.securityProvider = securityProvider
        self.mockStats = RepositoryStatistics(
            totalSize: 0,
            snapshotCount: 0,
            deduplicationSavings: 0,
            lastModified: Date(),
            compressionRatio: 1.0
        )
    }

    public func initialize() async throws {
        guard try await securityProvider.startAccessing(path: location.path) else {
            throw SecurityTypes.SecurityError.accessError("Failed to access repository at \(location.path)")
        }
        state = .ready
    }

    public func validate() async throws -> Bool {
        return state == .ready && !isLocked
    }

    public func lock() async throws {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to lock")
        }
        guard !isLocked else {
            throw RepositoryError.locked(reason: "Repository is already locked")
        }
        isLocked = true
        state = .locked
    }

    public func unlock() async throws {
        guard state == .locked else {
            throw RepositoryError.operationFailed(reason: "Repository must be locked to unlock")
        }
        isLocked = false
        state = .ready
    }

    public func isAccessible() async -> Bool {
        state == .ready && !isLocked
    }

    public func getStats() async throws -> RepositoryStatistics {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to get stats")
        }
        return mockStats
    }

    public func check(readData: Bool, checkUnused: Bool) async throws -> RepositoryStatistics {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to check")
        }

        // Simulate a repository check
        // In a real implementation, this would scan the repository

        return mockStats
    }

    public func prune() async throws {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to prune")
        }
        // Mock implementation - just verify state
    }

    public func rebuildIndex() async throws {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to rebuild index")
        }
        // Mock implementation - just verify state
    }

    public func repair() async throws -> Bool {
        guard state == .ready else {
            throw RepositoryError.operationFailed(reason: "Repository must be ready to repair")
        }

        // Simulate a repository repair
        // In a real implementation, this would repair any issues found

        return true // Simulate successful repair
    }

    // Test helper methods
    public func setStats(_ stats: RepositoryStatistics) {
        self.mockStats = stats
    }
}

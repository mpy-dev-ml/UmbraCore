// Standard modules
import Foundation

// Internal modules
import RepositoriesTypes
import UmbraLogging

/// A concrete implementation of the Repository protocol that stores data on the local filesystem.
@preconcurrency public actor FileSystemRepository: Repository {
    /// The unique identifier for this repository.
    public nonisolated let identifier: String

    /// The current operational state of the repository.
    public nonisolated(unsafe) var state: RepositoryState

    /// The filesystem location where this repository is stored.
    public nonisolated let location: URL

    /// Logger instance for repository operations
    private let logger: Logger

    /// Current repository statistics
    private var stats: RepositoryStatistics
    
    /// Thread-safe copy of stats for nonisolated access
    /// This is updated whenever the internal stats are updated
    private nonisolated let statsAccessor = StatsAccessor()

    /// Initializes a new filesystem repository.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier for this repository
    ///   - location: The filesystem location where this repository is stored
    ///   - state: The initial state of the repository
    ///   - logger: Logger instance for repository operations
    public init(
        identifier: String,
        location: URL,
        state: RepositoryState,
        logger: Logger = .shared
    ) {
        self.identifier = identifier
        self.location = location
        self.state = state
        self.logger = logger
        let initialStats = RepositoryStatistics(
            totalSize: 0,
            snapshotCount: 0,
            lastCheck: Date(),
            totalFileCount: 0
        )
        self.stats = initialStats
        self.statsAccessor.updateStats(initialStats)
    }

    // MARK: - RepositoryStats

    public nonisolated var totalSize: Int64 {
        // Use the thread-safe accessor instead of direct access
        statsAccessor.totalSize
    }

    public nonisolated var totalFileCount: Int {
        statsAccessor.totalFileCount
    }

    public nonisolated var totalBlobCount: Int {
        statsAccessor.getStats().totalBlobCount
    }

    public nonisolated var snapshotsCount: Int {
        statsAccessor.getStats().snapshotsCount
    }

    public nonisolated var totalUncompressedSize: Int64 {
        statsAccessor.getStats().totalUncompressedSize
    }

    public nonisolated var compressionRatio: Double {
        statsAccessor.getStats().compressionRatio
    }

    public nonisolated var compressionProgress: Double {
        statsAccessor.getStats().compressionProgress
    }

    public nonisolated var compressionSpaceSaving: Double {
        statsAccessor.getStats().compressionSpaceSaving
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case identifier
        case state
        case location
        case stats
    }

    public nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(state, forKey: .state)
        try container.encode(location, forKey: .location)
        
        // Use the thread-safe accessor for stats
        try container.encode(statsAccessor.getStats(), forKey: .stats)
    }

    // Fix the Decoder parameter syntax and remove nonisolated modifier
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.state = try container.decode(RepositoryState.self, forKey: .state)
        self.location = try container.decode(URL.self, forKey: .location)
        let decodedStats = try container.decode(RepositoryStatistics.self, forKey: .stats)
        self.stats = decodedStats
        self.statsAccessor.updateStats(decodedStats)
        self.logger = .shared
    }

    // MARK: - RepositoryCore

    public func initialize() async throws {
        // Implementation
    }

    public func validate() async throws -> Bool {
        // Implementation
        return true
    }

    public func isAccessible() async -> Bool {
        // Implementation
        return true
    }

    // MARK: - RepositoryLocking

    public func lock() async throws {
        // Implementation
    }

    public func unlock() async throws {
        // Implementation
    }

    // MARK: - RepositoryMaintenance

    /// Checks the repository health and returns statistics.
    ///
    /// - Parameters:
    ///   - readData: If true, reads and validates repository data
    ///   - checkUnused: If true, checks for unused data
    /// - Returns: Repository statistics
    public func check(readData: Bool, checkUnused: Bool) async throws -> RepositoryStatistics {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )
        await logger.debug(
            "Checking repository",
            metadata: metadata
        )
        
        // If readData is true, verify all repository contents
        if readData {
            try await verifyContents()
        }
        
        // If checkUnused is true, check for unused data
        if checkUnused {
            try await validateIntegrity()
        }
        
        return try await getStats()
    }

    /// Repairs any issues found in the repository.
    ///
    /// - Returns: true if repairs were successful, false otherwise
    public func repair() async throws -> Bool {
        // Implementation
        return true
    }

    /// Removes unused data from the repository.
    public func prune() async throws {
        // Implementation
    }

    /// Rebuilds the repository index.
    public func rebuildIndex() async throws {
        // Implementation
    }
    
    // MARK: - Private Methods
    
    private func verifyContents() async throws {
        // Implementation for deep content verification
        // This would check all files, directories, and metadata
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )
        await logger.debug(
            "Verifying repository contents",
            metadata: metadata
        )
        // TODO: Implement deep content verification
    }
    
    private func validateIntegrity() async throws {
        // Implementation for data integrity validation
        // This would verify checksums, signatures, etc.
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )
        await logger.debug(
            "Validating repository integrity",
            metadata: metadata
        )
        // TODO: Implement integrity validation
    }
    
    /// Calculates the total size of the repository.
    private func calculateTotalSize() async throws -> UInt64 {
        var totalSize: UInt64 = 0
        let enumerator = FileManager.default.enumerator(
            at: location,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        )

        while let fileURL = enumerator?.nextObject() as? URL {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey]),
                  let fileSize = resourceValues.totalFileAllocatedSize else {
                continue
            }
            totalSize += UInt64(fileSize)
        }

        return totalSize
    }

    /// Counts the number of snapshots in the repository.
    private func countSnapshots() async throws -> UInt {
        let snapshotsDir = location.appendingPathComponent("snapshots")
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: snapshotsDir,
            includingPropertiesForKeys: nil
        ) else {
            return 0
        }
        return UInt(contents.count)
    }

    /// Retrieves current statistics about the repository.
    /// Changed from private to public to match protocol requirement
    public func getStats() async throws -> RepositoryStatistics {
        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        // Get repository size
        let totalSize = try await calculateTotalSize()

        // Get snapshot count
        let snapshotCount = try await countSnapshots()
        
        // Update stats
        let updatedStats = RepositoryStatistics(
            totalSize: totalSize,
            snapshotCount: snapshotCount, // Fix the type mismatch
            lastCheck: Date(),
            totalFileCount: try await calculateTotalFileCount()
        )
        
        // Store updated stats
        stats = updatedStats
        
        // Update the nonisolated accessor
        statsAccessor.updateStats(updatedStats)
        
        return updatedStats
    }

    private func calculateTotalFileCount() async throws -> Int {
        // Implementation for calculating total file count
        // This would count all files in the repository
        // TODO: Implement total file count calculation
        return 0
    }
}

/// Thread-safe accessor for repository statistics
/// This allows nonisolated access to stats while maintaining thread safety
private final class StatsAccessor: @unchecked Sendable {
    private let lock = NSLock()
    private var _stats: RepositoryStatistics
    
    init() {
        _stats = RepositoryStatistics(
            totalSize: 0,
            snapshotCount: 0,
            lastCheck: Date(),
            totalFileCount: 0
        )
    }
    
    var totalSize: Int64 {
        lock.lock()
        defer { lock.unlock() }
        return _stats.totalSize
    }
    
    var totalFileCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _stats.totalFileCount
    }
    
    func getStats() -> RepositoryStatistics {
        lock.lock()
        defer { lock.unlock() }
        return _stats
    }
    
    func updateStats(_ newStats: RepositoryStatistics) {
        lock.lock()
        defer { lock.unlock() }
        _stats = newStats
    }
}

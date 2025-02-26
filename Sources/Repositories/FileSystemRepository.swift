// Standard modules
import Foundation

// Internal modules
import RepositoriesTypes
import UmbraLogging

/// A concrete implementation of the Repository protocol that stores data on the local filesystem.
public actor FileSystemRepository: Repository, Codable {
    /// The unique identifier for this repository.
    public let identifier: String

    /// The current operational state of the repository.
    public private(set) var state: RepositoryState

    /// The filesystem location where this repository is stored.
    public let location: URL

    /// Logger instance for repository operations
    private let logger: Logger

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
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case identifier
        case state
        case location
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(state, forKey: .state)
        try container.encode(location.absoluteString, forKey: .location)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.state = try container.decode(RepositoryState.self, forKey: .state)
        let locationString = try container.decode(String.self, forKey: .location)
        guard let url = URL(string: locationString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .location,
                in: container,
                debugDescription: "Invalid URL string: \(locationString)"
            )
        }
        self.location = url
        self.logger = Logger.shared
    }

    // MARK: - RepositoryCore

    /// Initializes the repository and prepares it for use.
    public func initialize() async throws {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .uninitialized = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is already initialized"
            )
        }

        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(
            at: location,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Initialize repository structure
        try await initializeRepositoryStructure()

        state = .ready
        await logger.info(
            "Repository initialized successfully",
            metadata: metadata
        )
    }

    /// Validates the repository structure and integrity.
    public func validate() async throws -> Bool {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        // Check if directory exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: location.path,
            isDirectory: &isDirectory
        ) else {
            throw RepositoryError.notAccessible(
                reason: "Repository directory does not exist"
            )
        }

        guard isDirectory.boolValue else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository path exists but is not a directory"
            )
        }

        // Validate repository structure
        let isValid = try await validateRepositoryStructure()
        await logger.info(
            "Repository validation completed",
            metadata: metadata
        )
        return isValid
    }

    /// Checks if the repository is currently accessible.
    public func isAccessible() async -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(
            atPath: location.path,
            isDirectory: &isDirectory
        ) && isDirectory.boolValue
    }

    // MARK: - RepositoryLocking

    /// Locks the repository for exclusive access.
    public func lock() async throws {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        // Create lock file
        let lockFile = location.appendingPathComponent(".lock")
        guard FileManager.default.createFile(
            atPath: lockFile.path,
            contents: nil,
            attributes: nil
        ) else {
            throw RepositoryError.locked(
                reason: "Failed to create lock file"
            )
        }

        state = .locked
        await logger.info(
            "Repository locked successfully",
            metadata: metadata
        )
    }

    /// Releases an exclusive lock on the repository.
    public func unlock() async throws {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .locked = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not locked"
            )
        }

        // Remove lock file
        let lockFile = location.appendingPathComponent(".lock")
        try FileManager.default.removeItem(at: lockFile)

        state = .ready
        await logger.info(
            "Repository unlocked successfully",
            metadata: metadata
        )
    }

    // MARK: - RepositoryMaintenance

    /// Checks the repository health and returns statistics.
    public func check(
        readData: Bool,
        checkUnused: Bool
    ) async throws -> RepositoryStats {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        await logger.info(
            "Starting repository check",
            metadata: metadata
        )

        // Get repository size
        let totalSize = try await calculateTotalSize()

        // Get snapshot count
        let snapshotCount = try await countSnapshots()

        let stats = RepositoryStats(
            totalSize: totalSize,
            snapshotCount: snapshotCount,
            lastCheck: Date()
        )

        await logger.info(
            "Repository check completed successfully",
            metadata: metadata
        )

        return stats
    }

    /// Repairs any issues found in the repository.
    public func repair() async throws -> Bool {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        await logger.info(
            "Starting repository repair",
            metadata: metadata
        )

        // Attempt to repair repository structure
        try await initializeRepositoryStructure()

        await logger.info(
            "Repository repair completed successfully",
            metadata: metadata
        )

        return true
    }

    /// Removes unused data from the repository.
    public func prune() async throws {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        await logger.info(
            "Starting repository pruning",
            metadata: metadata
        )

        // TODO: Implement pruning logic
        throw RepositoryError.operationFailed(
            reason: "Pruning not yet implemented"
        )
    }

    /// Rebuilds the repository index.
    public func rebuildIndex() async throws {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        await logger.info(
            "Starting index rebuild",
            metadata: metadata
        )

        // TODO: Implement index rebuilding logic
        throw RepositoryError.operationFailed(
            reason: "Index rebuilding not yet implemented"
        )
    }

    // MARK: - RepositoryStats

    /// Retrieves current statistics about the repository.
    public func getStats() async throws -> RepositoryStats {
        let metadata = LogMetadataBuilder.forRepository(
            identifier: identifier,
            path: location.path
        )

        guard case .ready = state else {
            throw RepositoryError.invalidConfiguration(
                reason: "Repository is not in ready state"
            )
        }

        await logger.info(
            "Retrieving repository stats",
            metadata: metadata
        )

        return try await check(
            readData: false,
            checkUnused: false
        )
    }

    // MARK: - Private Methods

    /// Initializes the basic repository structure.
    private func initializeRepositoryStructure() async throws {
        // Create standard directories
        let standardDirs = ["data", "snapshots", "index", "config"]
        try standardDirs.forEach { dir in
            try FileManager.default.createDirectory(
                at: location.appendingPathComponent(dir),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        // Create initial config file
        let config = location.appendingPathComponent("config/config.json")
        let configData = try JSONSerialization.data(
            withJSONObject: ["version": "1.0"],
            options: .prettyPrinted
        )
        try configData.write(to: config)
    }

    /// Validates the repository structure.
    private func validateRepositoryStructure() async throws -> Bool {
        let standardDirs = ["data", "snapshots", "index", "config"]

        // Check all required directories exist
        for dir in standardDirs {
            var isDirectory: ObjCBool = false
            let dirPath = location.appendingPathComponent(dir)

            guard FileManager.default.fileExists(
                atPath: dirPath.path,
                isDirectory: &isDirectory
            ) else {
                return false
            }

            guard isDirectory.boolValue else {
                return false
            }
        }

        // Check config file exists and is valid
        let config = location.appendingPathComponent("config/config.json")
        guard let data = try? Data(contentsOf: config),
              let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }

        return true
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
}

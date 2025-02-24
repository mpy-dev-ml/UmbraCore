// Standard modules
import Foundation

// Internal modules
import Repositories_Types
import SecurityTypes_Protocols
import SecurityTypes_Types
import UmbraLogging

/// A service that manages repository registration, locking, and statistics.
///
/// The `RepositoryService` provides thread-safe access to repository operations through the actor model.
/// It maintains a registry of repositories and provides operations for managing their lifecycle.
///
/// Example:
/// ```swift
/// let service = RepositoryService.shared
/// try await service.register(myRepository)
/// let stats = try await service.getStats(for: myRepository.identifier)
/// ```
public actor RepositoryService {
    /// Shared instance of the repository service
    public static let shared = RepositoryService()

    /// Currently registered repositories
    private var repositories: [String: any Repository]

    /// Logger instance
    private let logger: Logger

    /// Initializes a new repository service instance.
    ///
    /// - Parameter logger: The logging service to use for operation tracking. Defaults to the shared logger.
    public init(
        logger: Logger = .shared
    ) {
        self.repositories = [:]
        self.logger = logger
    }

    // MARK: - Repository Management

    /// Registers a repository with the service.
    ///
    /// - Parameter repository: The repository to register. Must conform to the `Repository` protocol.
    /// - Throws: `RepositoryError.notAccessible` if the repository cannot be accessed,
    ///           `RepositoryError.alreadyRegistered` if a repository with the same identifier exists.
    public func register(_ repository: some Repository) async throws {
        let identifier = await repository.identifier
        let location = await repository.location
        let state = await repository.state

        let metadata = LogMetadata([
            "repository_id": identifier,
            "location": location.path,
            "state": String(describing: state)
        ])

        await logger.info("Registering repository", metadata: metadata)

        // Ensure repository is accessible
        guard await repository.isAccessible() else {
            await logger.error("Repository not accessible", metadata: metadata)
            throw RepositoryError.notAccessible(reason: "Repository is not accessible")
        }

        // Check for duplicate
        guard repositories[identifier] == nil else {
            await logger.error("Duplicate repository identifier", metadata: metadata)
            throw RepositoryError.invalidConfiguration(reason: "Repository with identifier '\(identifier)' already exists")
        }

        // Initialize repository if needed
        if case .uninitialized = state {
            await logger.info("Initializing uninitialized repository", metadata: metadata)
            try await repository.initialize()
        }

        // Validate repository
        do {
            guard try await repository.validate() else {
                await logger.error("Repository validation failed", metadata: metadata)
                throw RepositoryError.validationFailed(reason: "Repository validation failed")
            }
        } catch {
            await logger.error("Repository validation error: \(error.localizedDescription)", metadata: metadata)
            throw error
        }

        repositories[identifier] = repository
        await logger.info("Repository registered successfully", metadata: metadata)
    }

    /// Unregisters a repository from the service.
    ///
    /// - Parameter identifier: The identifier of the repository to unregister.
    /// - Returns: The unregistered repository.
    /// - Throws: `RepositoryError.notFound` if the repository is not found.
    @discardableResult
    public func unregister(_ identifier: String) async throws -> any Repository {
        let metadata = LogMetadata(["repository_id": identifier])
        await logger.info("Unregistering repository", metadata: metadata)

        guard let repository = repositories.removeValue(forKey: identifier) else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.notAccessible(reason: "Repository '\(identifier)' not found")
        }

        await logger.info("Repository unregistered successfully", metadata: metadata)
        return repository
    }

    /// Retrieves a repository by its identifier.
    ///
    /// - Parameter identifier: The identifier of the repository to retrieve.
    /// - Returns: The requested repository.
    /// - Throws: `RepositoryError.notFound` if the repository is not found.
    public func getRepository(_ identifier: String) async throws -> any Repository {
        let metadata = LogMetadata(["repository_id": identifier])

        guard let repository = repositories[identifier] else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.notAccessible(reason: "Repository '\(identifier)' not found")
        }

        await logger.debug("Repository retrieved", metadata: metadata)
        return repository
    }

    /// Lists all registered repositories.
    ///
    /// - Returns: An array of registered repositories.
    public func listRepositories() async -> [any Repository] {
        await logger.debug("Listing repositories", metadata: LogMetadata([
            "count": String(repositories.count)
        ]))
        return Array(repositories.values)
    }

    // MARK: - Bulk Operations

    /// Locks all repositories.
    ///
    /// - Parameter force: If true, ignore errors from individual repositories. Defaults to false.
    /// - Throws: `RepositoryError.operationFailed` if any repository fails to lock and force is false.
    public func lockAll(force: Bool = false) async throws {
        let metadata = LogMetadata([
            "force": String(force),
            "repository_count": String(repositories.count)
        ])

        await logger.info("Locking all repositories", metadata: metadata)
        var errors: [String: Error] = [:]

        for repository in repositories.values {
            let identifier = await repository.identifier
            let repoMetadata = LogMetadata([
                "repository_id": identifier,
                "force": String(force)
            ])

            do {
                try await repository.lock()
                await logger.debug("Repository locked successfully", metadata: repoMetadata)
            } catch {
                await logger.error("Failed to lock repository: \(error.localizedDescription)", metadata: repoMetadata)
                if !force {
                    throw RepositoryError.operationFailed(reason: "Failed to lock repository '\(identifier)': \(error.localizedDescription)")
                }
                errors[identifier] = error
            }
        }

        if !errors.isEmpty {
            await logger.warning("Some repositories failed to lock", metadata: LogMetadata([
                "error_count": String(errors.count),
                "force": String(force)
            ]))
        } else {
            await logger.info("All repositories locked successfully", metadata: metadata)
        }
    }

    /// Unlocks all repositories.
    ///
    /// - Parameter force: If true, ignore errors from individual repositories. Defaults to false.
    /// - Throws: `RepositoryError.operationFailed` if any repository fails to unlock and force is false.
    public func unlockAll(force: Bool = false) async throws {
        let metadata = LogMetadata([
            "force": String(force),
            "repository_count": String(repositories.count)
        ])

        await logger.info("Unlocking all repositories", metadata: metadata)
        var errors: [String: Error] = [:]

        for repository in repositories.values {
            let identifier = await repository.identifier
            let repoMetadata = LogMetadata([
                "repository_id": identifier,
                "force": String(force)
            ])

            do {
                try await repository.unlock()
                await logger.debug("Repository unlocked successfully", metadata: repoMetadata)
            } catch {
                await logger.error("Failed to unlock repository: \(error.localizedDescription)", metadata: repoMetadata)
                if !force {
                    throw RepositoryError.operationFailed(reason: "Failed to unlock repository '\(identifier)': \(error.localizedDescription)")
                }
                errors[identifier] = error
            }
        }

        if !errors.isEmpty {
            await logger.warning("Some repositories failed to unlock", metadata: LogMetadata([
                "error_count": String(errors.count),
                "force": String(force)
            ]))
        } else {
            await logger.info("All repositories unlocked successfully", metadata: metadata)
        }
    }

    /// Retrieves aggregated statistics for all repositories.
    ///
    /// - Returns: A dictionary mapping repository identifiers to their statistics.
    /// - Throws: `RepositoryError.operationFailed` if stats cannot be retrieved for any repository.
    public func getAllStats() async throws -> [String: RepositoryStats] {
        let metadata = LogMetadata(["repository_count": String(repositories.count)])
        await logger.info("Retrieving stats for all repositories", metadata: metadata)

        var stats: [String: RepositoryStats] = [:]
        var errors: [String: Error] = [:]

        for repository in repositories.values {
            let identifier = await repository.identifier
            let repoMetadata = LogMetadata(["repository_id": identifier])

            do {
                stats[identifier] = try await repository.getStats()
                await logger.debug("Retrieved stats successfully", metadata: repoMetadata)
            } catch {
                await logger.error("Failed to get repository stats: \(error.localizedDescription)", metadata: repoMetadata)
                errors[identifier] = error
            }
        }

        if !errors.isEmpty {
            await logger.error("Failed to get stats for some repositories", metadata: LogMetadata([
                "error_count": String(errors.count),
                "success_count": String(stats.count)
            ]))
            throw RepositoryError.operationFailed(reason: "Failed to get stats for some repositories: \(errors)")
        }

        await logger.info("Retrieved all repository stats successfully", metadata: LogMetadata([
            "repository_count": String(stats.count)
        ]))

        return stats
    }
}

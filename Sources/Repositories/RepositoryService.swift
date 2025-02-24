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
    internal private(set) var repositories: [String: any Repository]

    /// Logger instance
    internal let logger: Logger

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

        let metadata: LogMetadata = [
            "repository_id": .string(identifier),
            "location": .string(location.path),
            "state": .string(String(describing: state))
        ]

        await logger.info("Registering repository", metadata: metadata)

        // Ensure repository is accessible
        guard await repository.isAccessible() else {
            await logger.error("Repository not accessible", metadata: metadata)
            throw RepositoryError.notAccessible(
                reason: "Repository is not accessible"
            )
        }

        // Check for duplicate
        guard repositories[identifier] == nil else {
            await logger.error(
                "Duplicate repository identifier",
                metadata: metadata
            )
            throw RepositoryError.invalidConfiguration(
                reason: "Repository with identifier '\(identifier)' already exists"
            )
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
                throw RepositoryError.validationFailed(
                    reason: "Repository validation failed"
                )
            }
        } catch {
            await logger.error(
                "Repository validation error: \(error.localizedDescription)",
                metadata: metadata
            )
            throw error
        }

        repositories[identifier] = repository
        await logger.info("Repository registered successfully", metadata: metadata)
    }

    /// Deregisters a repository from the service.
    ///
    /// - Parameter identifier: The identifier of the repository to deregister.
    /// - Throws: `RepositoryError.repositoryNotFound` if no repository exists with the given identifier.
    public func deregister(identifier: String) async throws {
        let metadata: LogMetadata = ["repository_id": .string(identifier)]
        await logger.info("Deregistering repository", metadata: metadata)

        guard repositories.removeValue(forKey: identifier) != nil else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found with identifier '\(identifier)'"
            )
        }

        await logger.info("Repository deregistered successfully", metadata: metadata)
    }

    /// Lists all registered repositories.
    ///
    /// - Returns: An array of registered repositories.
    public func listRepositories() async -> [any Repository] {
        await logger.debug(
            "Listing repositories",
            metadata: LogMetadata([
                "count": .string(String(repositories.count))
            ])
        )
        return Array(repositories.values)
    }

    /// Gets a repository by its identifier.
    ///
    /// - Parameter identifier: The identifier of the repository.
    /// - Returns: The repository if found, nil otherwise.
    public func getRepository(identifier: String) async -> (any Repository)? {
        await logger.debug(
            "Getting repository",
            metadata: LogMetadata([
                "repository_id": .string(identifier)
            ])
        )
        return repositories[identifier]
    }

    /// Gets a repository at the specified URL.
    ///
    /// - Parameter url: The URL of the repository.
    /// - Returns: The repository if found, nil otherwise.
    public func getRepository(at url: URL) async -> (any Repository)? {
        let path = url.path
        await logger.debug(
            "Getting repository by URL",
            metadata: LogMetadata([
                "path": .string(path)
            ])
        )

        for (identifier, repository) where await repository.location.path == path {
            return repository
        }

        return nil
    }
}

// Standard modules
import Foundation

// Internal modules
import Repositories_Types
import UmbraLogging

/// Extension for repository validation functionality
extension RepositoryService {
    // MARK: - Validation Operations

    /// Validates a repository at a given URL.
    ///
    /// - Parameter url: The URL of the repository to validate
    /// - Returns: Whether the repository is valid
    /// - Throws: `RepositoryError.repositoryNotFound` if the repository is not found
    public func validateRepository(at url: URL) async throws -> Bool {
        let metadata: LogMetadata = ["path": .string(url.path)]
        await logger.info("Starting repository validation", metadata: metadata)

        guard let repository = await getRepository(at: url) else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found at \(url.path)"
            )
        }

        do {
            let result = try await repository.validate()
            if result {
                await logger.info(
                    "Repository validation completed successfully",
                    metadata: metadata
                )
            } else {
                await logger.warning(
                    "Repository validation failed",
                    metadata: metadata
                )
            }
            return result
        } catch {
            await logger.error(
                "Repository validation error: \(error.localizedDescription)",
                metadata: metadata
            )
            throw error
        }
    }

    /// Initialises a new repository at the specified URL.
    ///
    /// - Parameter url: Repository URL
    /// - Returns: Repository instance
    /// - Throws: `RepositoryError.repositoryExists` if a repository already exists at the URL
    public func initialiseRepository(at url: URL) async throws -> any Repository {
        let metadata: LogMetadata = ["path": .string(url.path)]
        await logger.info("Initialising new repository", metadata: metadata)

        guard !repositories.contains(where: { $0.key == url.path }) else {
            await logger.error(
                "Repository already exists at location",
                metadata: metadata
            )
            throw RepositoryError.repositoryExists(
                "Repository already exists at \(url.path)"
            )
        }

        do {
            let repository = try await Repository(url: url)
            repositories[url.path] = repository
            await logger.info(
                "Repository initialised successfully",
                metadata: metadata
            )
            return repository
        } catch {
            await logger.error(
                "Repository initialisation failed: \(error.localizedDescription)",
                metadata: metadata
            )
            throw error
        }
    }

    /// Checks a repository at a given URL.
    ///
    /// - Parameter url: The URL of the repository to check
    /// - Returns: The repository statistics
    /// - Throws: `RepositoryError.repositoryNotFound` if the repository is not found
    public func checkRepository(at url: URL) async throws -> RepositoryStats {
        let metadata: LogMetadata = ["path": .string(url.path)]
        await logger.info("Starting repository check", metadata: metadata)

        guard let repository = await getRepository(at: url) else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found at \(url.path)"
            )
        }

        do {
            let stats = try await repository.check()
            await logger.info(
                "Repository check completed successfully",
                metadata: metadata
            )
            return stats
        } catch {
            await logger.error(
                "Repository check failed: \(error.localizedDescription)",
                metadata: metadata
            )
            throw error
        }
    }
}

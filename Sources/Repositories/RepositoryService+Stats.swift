// Standard modules
import Foundation

// Internal modules
import Repositories_Types
import UmbraLogging

/// Extension for repository statistics-related functionality
extension RepositoryService {
    // MARK: - Repository Statistics
    
    /// Retrieves aggregated statistics for all repositories.
    ///
    /// - Returns: A dictionary mapping repository identifiers to their statistics.
    /// - Throws: `RepositoryError.operationFailed` if stats cannot be retrieved for any repository.
    public func getAllStats() async throws -> [String: RepositoryStats] {
        let metadata: LogMetadata = ["repository_count": .string(String(repositories.count))]
        await logger.info("Retrieving stats for all repositories", metadata: metadata)

        var stats: [String: RepositoryStats] = [:]
        var errors: [String: Error] = [:]

        for repository in repositories.values {
            let identifier = await repository.identifier
            let repoMetadata: LogMetadata = ["repository_id": .string(identifier)]

            do {
                stats[identifier] = try await repository.getStats()
                await logger.debug("Retrieved stats successfully", metadata: repoMetadata)
            } catch {
                await logger.error(
                    "Failed to get repository stats: \(error.localizedDescription)",
                    metadata: repoMetadata
                )
                errors[identifier] = error
            }
        }

        if !errors.isEmpty {
            await logger.error(
                "Failed to get stats for some repositories",
                metadata: LogMetadata([
                    "error_count": .string(String(errors.count)),
                    "success_count": .string(String(stats.count))
                ])
            )
            throw RepositoryError.operationFailed(
                reason: "Failed to get stats for some repositories: \(errors)"
            )
        }

        await logger.info(
            "Retrieved all repository stats successfully",
            metadata: LogMetadata([
                "repository_count": .string(String(stats.count))
            ])
        )

        return stats
    }

    /// Gets statistics for a specific repository.
    ///
    /// - Parameter identifier: The identifier of the repository.
    /// - Returns: Statistics for the specified repository.
    /// - Throws: `RepositoryError.repositoryNotFound` if no repository exists with the given identifier,
    ///           `RepositoryError.operationFailed` if stats cannot be retrieved.
    public func getStats(for identifier: String) async throws -> RepositoryStats {
        let metadata: LogMetadata = ["repository_id": .string(identifier)]
        await logger.info("Retrieving repository stats", metadata: metadata)

        guard let repository = repositories[identifier] else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found with identifier '\(identifier)'"
            )
        }

        do {
            let stats = try await repository.getStats()
            await logger.debug("Retrieved stats successfully", metadata: metadata)
            return stats
        } catch {
            await logger.error(
                "Failed to get repository stats: \(error.localizedDescription)",
                metadata: metadata
            )
            throw RepositoryError.operationFailed(
                reason: "Failed to get stats: \(error.localizedDescription)"
            )
        }
    }
}

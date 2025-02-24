// Standard modules
import Foundation

// Internal modules
import Repositories_Types
import UmbraLogging

/// Extension for repository locking functionality
extension RepositoryService {
    // MARK: - Locking Operations

    /// Unlocks all repositories.
    ///
    /// - Parameter force: If true, continue unlocking other repositories even if some fail
    /// - Throws: `RepositoryError.operationFailed` if any repository unlock fails and force is false
    public func unlockAll(force: Bool = false) async throws {
        let metadata: LogMetadata = [
            "repository_count": .string(String(repositories.count)),
            "force": .string(String(force))
        ]

        await logger.info(
            "Starting unlock for all repositories",
            metadata: metadata
        )

        var errors: [String: Error] = [:]

        for (identifier, repository) in repositories {
            let repoMetadata: LogMetadata = [
                "repository_id": .string(identifier)
            ]

            do {
                try await repository.unlock()
                await logger.debug(
                    "Repository unlocked successfully",
                    metadata: repoMetadata
                )
            } catch {
                await logger.error(
                    "Failed to unlock repository: \(error.localizedDescription)",
                    metadata: repoMetadata
                )
                if !force {
                    throw RepositoryError.operationFailed(
                        reason: "Failed to unlock '\(identifier)': \(error.localizedDescription)"
                    )
                }
                errors[identifier] = error
            }
        }

        if !errors.isEmpty {
            await logger.warning(
                "Some repositories failed to unlock",
                metadata: LogMetadata([
                    "error_count": .string(String(errors.count)),
                    "force": .string(String(force))
                ])
            )
        } else {
            await logger.info(
                "All repositories unlocked successfully",
                metadata: metadata
            )
        }
    }

    /// Unlocks a specific repository.
    ///
    /// - Parameter identifier: The identifier of the repository to unlock
    /// - Throws: `RepositoryError.repositoryNotFound` if the repository is not found,
    ///           `RepositoryError.operationFailed` if the unlock operation fails
    public func unlock(_ identifier: String) async throws {
        let metadata: LogMetadata = [
            "repository_id": .string(identifier)
        ]

        await logger.info("Starting repository unlock", metadata: metadata)

        guard let repository = repositories[identifier] else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found with identifier '\(identifier)'"
            )
        }

        do {
            try await repository.unlock()
            await logger.debug(
                "Repository unlocked successfully",
                metadata: metadata
            )
        } catch {
            await logger.error(
                "Failed to unlock repository: \(error.localizedDescription)",
                metadata: metadata
            )
            throw RepositoryError.operationFailed(
                reason: "Failed to unlock repository: \(error.localizedDescription)"
            )
        }
    }
}

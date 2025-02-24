// Standard modules
import Foundation

// Internal modules
import Repositories_Types
import UmbraLogging

/// Extension for repository locking-related functionality
extension RepositoryService {
    // MARK: - Repository Locking
    
    /// Unlocks all repositories.
    ///
    /// - Parameter force: If true, ignore errors from individual repositories. Defaults to false.
    /// - Throws: `RepositoryError.operationFailed` if any repository fails to unlock and force is false.
    public func unlockAll(force: Bool = false) async throws {
        let metadata: LogMetadata = [
            "force": .string(String(force)),
            "repository_count": .string(String(repositories.count))
        ]

        await logger.info("Unlocking all repositories", metadata: metadata)
        var errors: [String: Error] = [:]

        for repository in repositories.values {
            let identifier = await repository.identifier
            let repoMetadata: LogMetadata = [
                "repository_id": .string(identifier),
                "force": .string(String(force))
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
                        reason: "Failed to unlock repository '\(identifier)': \(error.localizedDescription)"
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
            await logger.info("All repositories unlocked successfully", metadata: metadata)
        }
    }

    /// Unlocks a specific repository.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the repository to unlock.
    /// - Throws: `RepositoryError.repositoryNotFound` if no repository exists with the given identifier,
    ///           `RepositoryError.operationFailed` if the unlock operation fails.
    public func unlock(identifier: String) async throws {
        let metadata: LogMetadata = ["repository_id": .string(identifier)]
        await logger.info("Unlocking repository", metadata: metadata)

        guard let repository = repositories[identifier] else {
            await logger.error("Repository not found", metadata: metadata)
            throw RepositoryError.repositoryNotFound(
                "No repository found with identifier '\(identifier)'"
            )
        }

        do {
            try await repository.unlock()
            await logger.debug("Repository unlocked successfully", metadata: metadata)
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

// Standard modules
import Foundation

// Internal modules
import RepositoriesTypes
import UmbraLogging

/// Extension for repository locking functionality
extension RepositoryService {
  /// Unlocks all repositories.
  ///
  /// - Parameter force: If true, attempts to unlock even if errors occur
  /// - Throws: `RepositoryError.operationFailed` if any repository fails to unlock
  public func unlockAll(force: Bool = false) async throws {
    let metadata = LogMetadata([
      "repository_count": String(repositories.count),
      "force": String(force)
    ])

    await logger.info("Unlocking all repositories", metadata: metadata)

    var errors: [String: Error] = [:]

    for (identifier, repository) in repositories {
      let repoMetadata = LogMetadata([
        "repository_id": identifier
      ])

      do {
        try await repository.unlock()
        await logger.debug("Repository unlocked successfully", metadata: repoMetadata)
      } catch {
        await logger.error(
          "Failed to unlock repository: \(error.localizedDescription)",
          metadata: repoMetadata
        )
        errors[identifier] = error

        if !force {
          throw RepositoryError.operationFailed(
            reason: "Failed to unlock repository \(identifier): \(error.localizedDescription)"
          )
        }
      }
    }

    if !errors.isEmpty {
      await logger.warning(
        "Some repositories failed to unlock",
        metadata: LogMetadata([
          "error_count": String(errors.count),
          "force": String(force)
        ])
      )
    }

    await logger.info("Repository unlock operation completed", metadata: metadata)
  }

  /// Unlocks a specific repository.
  ///
  /// - Parameter identifier: The repository identifier
  /// - Throws: `RepositoryError.notFound` if the repository does not exist,
  ///           `RepositoryError.operationFailed` if the unlock operation fails
  public func unlock(_ identifier: String) async throws {
    let metadata = LogMetadata([
      "repository_id": identifier
    ])

    await logger.info("Unlocking repository", metadata: metadata)

    guard let repository = repositories[identifier] else {
      throw RepositoryError.notFound(identifier: identifier)
    }

    do {
      try await repository.unlock()
      await logger.info("Repository unlocked successfully", metadata: metadata)
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

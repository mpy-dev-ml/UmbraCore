// Standard modules
import Foundation

// Internal modules
import RepositoriesTypes
import UmbraLogging

/// Extension for repository maintenance functionality
extension RepositoryService {
  // MARK: - Maintenance Operations

  /// Performs maintenance on a repository.
  ///
  /// - Parameters:
  ///   - identifier: The identifier of the repository to maintain
  ///   - rebuildIndex: Whether to rebuild the repository index
  /// - Throws: `RepositoriesTypes.RepositoryError.repositoryNotFound` if the repository is not
  /// found,
  ///           `RepositoriesTypes.RepositoryError.maintenanceFailed` if the operation fails
  public func maintain(
    _ identifier: String,
    rebuildIndex: Bool = false
  ) async throws {
    let metadata = LogMetadata([
      "repository_id": identifier,
      "rebuild_index": String(rebuildIndex)
    ])

    await logger.info("Starting repository maintenance", metadata: metadata)

    guard let repository = repositories[identifier] else {
      await logger.error("Repository not found", metadata: metadata)
      throw RepositoriesTypes.RepositoryError.repositoryNotFound(
        "No repository found with identifier '\(identifier)'"
      )
    }

    do {
      // Prune unused data
      try await repository.prune()

      if rebuildIndex {
        try await repository.rebuildIndex()
      }

      await logger.info(
        "Repository maintenance completed successfully",
        metadata: metadata
      )
    } catch {
      await logger.error(
        "Repository maintenance failed: \(error.localizedDescription)",
        metadata: metadata
      )
      throw RepositoriesTypes.RepositoryError.maintenanceFailed(
        reason: error.localizedDescription
      )
    }
  }

  /// Repairs a repository at a given URL.
  ///
  /// - Parameter url: The URL of the repository to repair
  /// - Returns: Whether the repository was successfully repaired
  /// - Throws: `RepositoriesTypes.RepositoryError.notFound` if the repository is not found
  public func repairRepository(at url: URL) async throws -> Bool {
    let metadata = LogMetadataBuilder.forRepository(
      path: url.path
    )
    await logger.info("Starting repository repair", metadata: metadata)

    guard let repository = await getRepository(at: url) else {
      await logger.error("Repository not found", metadata: metadata)
      throw RepositoriesTypes.RepositoryError.notFound(
        identifier: url.path
      )
    }

    do {
      let result = try await repository.repair()
      if result {
        await logger.info(
          "Repository repair completed successfully",
          metadata: metadata
        )
      } else {
        await logger.warning(
          "Repository repair completed but no issues were fixed",
          metadata: metadata
        )
      }
      return result
    } catch {
      await logger.error(
        "Repository repair failed: \(error.localizedDescription)",
        metadata: metadata
      )
      throw RepositoriesTypes.RepositoryError.maintenanceFailed(
        reason: error.localizedDescription
      )
    }
  }
}

// Standard modules
import Foundation

// Internal modules
import RepositoriesTypes
import UmbraLogging

/// Extension for repository validation functionality
extension RepositoryService {
  // MARK: - Validation Operations

  /// Validates a repository at a given URL.
  ///
  /// - Parameter url: The URL of the repository to validate
  /// - Returns: Whether the repository is valid
  /// - Throws: `RepositoriesTypes.RepositoryError.notFound` if the repository is not found
  public func validateRepository(at url: URL) async throws -> Bool {
    let metadata = LogMetadataBuilder.forRepository(
      path: url.path
    )
    await logger.info("Starting repository validation", metadata: metadata)

    guard let repository = await getRepository(at: url) else {
      await logger.error("Repository not found", metadata: metadata)
      throw RepositoriesTypes.RepositoryError.notFound(
        identifier: url.path
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
  /// - Throws: `RepositoriesTypes.RepositoryError.invalidConfiguration` if a repository already
  /// exists at the URL
  public func initialiseRepository(at url: URL) async throws -> any Repository {
    let metadata = LogMetadataBuilder.forRepository(
      path: url.path
    )
    await logger.info("Initialising new repository", metadata: metadata)

    guard !repositories.contains(where: { $0.key == url.path }) else {
      await logger.error(
        "Repository already exists at location",
        metadata: metadata
      )
      throw RepositoriesTypes.RepositoryError.invalidConfiguration(
        reason: "Repository already exists at \(url.path)"
      )
    }

    do {
      // Create a concrete repository instance based on the URL
      let repository = try await createRepository(at: url)
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
  /// - Throws: `RepositoriesTypes.RepositoryError.notFound` if the repository is not found
  public func checkRepository(at url: URL) async throws -> RepositoryStats {
    let metadata = LogMetadataBuilder.forRepository(
      path: url.path
    )
    await logger.info("Starting repository check", metadata: metadata)

    guard let repository = await getRepository(at: url) else {
      await logger.error("Repository not found", metadata: metadata)
      throw RepositoriesTypes.RepositoryError.notFound(
        identifier: url.path
      )
    }

    do {
      let stats = try await repository.check(
        readData: true,
        checkUnused: true
      )
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

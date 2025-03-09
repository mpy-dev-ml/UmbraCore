import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors {
  /// Repository error domain
  public enum Repository {
    // This namespace contains the various repository error types
    // Implementation in separate files:
    // - RepositoryCoreErrors.swift - Core repository errors
    // - RepositoryStorageErrors.swift - Storage-specific errors
    // - RepositoryQueryErrors.swift - Query-related errors
  }
}

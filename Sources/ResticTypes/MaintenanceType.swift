import Foundation

/// Type of maintenance operation to perform on a repository
public enum MaintenanceType: String, Sendable {
  /// Check repository for errors
  case check

  /// Remove unused data from repository
  case prune

  /// Rebuild repository index
  case rebuild

  /// Verify repository data integrity
  case verify
}

/// Type of maintenance operation to perform on a Restic repository
public enum MaintenanceType: String, Sendable {
  /// Check repository health
  case check
  /// Prune old snapshots
  case prune
  /// Remove unreferenced data
  case cleanup
}

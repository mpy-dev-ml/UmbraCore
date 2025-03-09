import Foundation
import ErrorHandlingDomains

/// Core storage error types used throughout the UmbraCore framework
///
/// This enum defines all storage-related errors in a single, flat structure
/// rather than nested within multiple levels. This approach simplifies
/// error handling and promotes a more maintainable codebase.
public enum StorageError: Error, Equatable, Sendable {
  // MARK: - Access Errors

  /// Requested resource does not exist
  case resourceNotFound(path: String)

  /// Resource already exists
  case resourceAlreadyExists(path: String)

  /// Access denied due to permissions
  case accessDenied(reason: String)

  /// Location is unavailable
  case locationUnavailable(path: String)

  // MARK: - Operation Errors

  /// Failed to read data
  case readFailed(reason: String)

  /// Failed to write data
  case writeFailed(reason: String)

  /// Failed to delete data
  case deleteFailed(reason: String)

  /// Failed to update data
  case updateFailed(reason: String)

  /// Failed to move data
  case moveFailed(source: String, destination: String, reason: String)

  /// Failed to copy data
  case copyFailed(source: String, destination: String, reason: String)

  // MARK: - Data Errors

  /// Data is in invalid format
  case invalidFormat(reason: String)

  /// Data is corrupted
  case dataCorruption(reason: String)

  /// Checksum verification failed
  case checksumMismatch(expected: String, actual: String)

  // MARK: - Capacity Errors

  /// Insufficient storage space
  case insufficientSpace(required: Int, available: Int)

  /// Storage quota exceeded
  case quotaExceeded(quota: Int, attempted: Int)

  // MARK: - Database Errors

  /// Database query failed
  case queryFailed(reason: String)

  /// Database transaction failed
  case transactionFailed(reason: String)

  /// Database is locked
  case databaseLocked(reason: String)

  // MARK: - General Errors

  /// Internal error occurred
  case internalError(reason: String)

  /// Unknown storage error
  case unknown(reason: String)
}

// MARK: - CustomStringConvertible

extension StorageError: CustomStringConvertible {
  public var description: String {
    switch self {
      case let .resourceNotFound(path):
        "Resource not found: \(path)"
      case let .resourceAlreadyExists(path):
        "Resource already exists: \(path)"
      case let .accessDenied(reason):
        "Access denied: \(reason)"
      case let .locationUnavailable(path):
        "Location unavailable: \(path)"
      case let .readFailed(reason):
        "Read failed: \(reason)"
      case let .writeFailed(reason):
        "Write failed: \(reason)"
      case let .deleteFailed(reason):
        "Delete failed: \(reason)"
      case let .updateFailed(reason):
        "Update failed: \(reason)"
      case let .moveFailed(source, destination, reason):
        "Move failed from \(source) to \(destination): \(reason)"
      case let .copyFailed(source, destination, reason):
        "Copy failed from \(source) to \(destination): \(reason)"
      case let .invalidFormat(reason):
        "Invalid format: \(reason)"
      case let .dataCorruption(reason):
        "Data corruption: \(reason)"
      case let .checksumMismatch(expected, actual):
        "Checksum mismatch: expected \(expected), got \(actual)"
      case let .insufficientSpace(required, available):
        "Insufficient space: required \(required) bytes, available \(available) bytes"
      case let .quotaExceeded(quota, attempted):
        "Quota exceeded: quota \(quota) bytes, attempted \(attempted) bytes"
      case let .queryFailed(reason):
        "Query failed: \(reason)"
      case let .transactionFailed(reason):
        "Transaction failed: \(reason)"
      case let .databaseLocked(reason):
        "Database locked: \(reason)"
      case let .internalError(reason):
        "Internal error: \(reason)"
      case let .unknown(reason):
        "Unknown storage error: \(reason)"
    }
  }
}

// MARK: - LocalizedError

extension StorageError: LocalizedError {
  public var errorDescription: String? {
    description
  }
}

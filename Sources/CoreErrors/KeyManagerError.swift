import Foundation

/// KeyManagerError error type
public enum KeyManagerError: Error {
  case keyNotFound(String)
  case unsupportedStorageLocation
  case synchronisationError(String)
  case operationFailed
  case keyExpired
  case notInitialized
  case securityBoundaryViolation(String)
  case storageError(String)
  case metadataError(String)
}

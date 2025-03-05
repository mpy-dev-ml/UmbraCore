import CoreErrors
import Foundation

/// Type alias for backward compatibility
/// Renamed to avoid conflict with native SecurityProtocolsCore.SecurityError
public typealias CoreSecurityError=CoreErrors.SecurityError

/// Create a mapping function to convert between CoreErrors.SecurityError and local SecurityError
/// types
/// This helps when working with external modules that expect the core error type
public func mapCoreSecurityError(_ error: CoreSecurityError) -> SecurityError {
  switch error {
    case .bookmarkError:
      SecurityError.internalError("Bookmark error")
    case .accessError:
      SecurityError.internalError("Access error")
    case .cryptoError:
      SecurityError.internalError("Crypto error")
    case .bookmarkCreationFailed:
      SecurityError.storageOperationFailed(reason: "Bookmark creation failed")
    case .bookmarkResolutionFailed:
      SecurityError.storageOperationFailed(reason: "Bookmark resolution failed")
  }
}

/// Map from local SecurityError to CoreErrors.SecurityError
/// This is needed when other modules expect the core error type
public func mapToCoreSecurity(_: SecurityError) -> CoreSecurityError {
  // Default mapping - in practice you would want more precise mappings
  .cryptoError
}

import CoreErrors
import Foundation

/// Type alias for backward compatibility
/// Renamed to avoid conflict with native SecurityProtocolsCore.SecurityError
public typealias CoreSecurityError=CoreErrors.SecurityError

/// Create a mapping function to convert between CoreErrors.SecurityError and local SecurityError
/// types. Uses the centralised CoreErrors.SecurityErrorMapper.
/// This helps when working with external modules that expect the core error type
public func mapCoreSecurityError(_ error: CoreSecurityError) -> SecurityError {
  // Delegate to the canonical implementation in CoreErrors.SecurityErrorMapper
  // Cast the result to SecurityError as required by the return type
  CoreErrors.SecurityErrorMapper.mapToSPCError(error) as! SecurityError
}

/// Map from local SecurityError to CoreErrors.SecurityError
/// Uses the centralised CoreErrors.SecurityErrorMapper.
/// This is needed when other modules expect the core error type
public func mapToCoreSecurity(_ error: SecurityError) -> CoreSecurityError {
  // Delegate to the canonical implementation in CoreErrors.SecurityErrorMapper
  CoreErrors.SecurityErrorMapper.mapToCoreError(error)
}

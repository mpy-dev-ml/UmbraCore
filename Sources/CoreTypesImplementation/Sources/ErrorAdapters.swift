import CoreErrors
import CoreTypesInterfaces
import UmbraCoreTypes

// Since SecurityProtocolsCore and XPCProtocolsCore are namespaces rather than direct modules,
// we need to use the correct type paths

/// Type alias for CoreErrors.SecurityError - our target error type
public typealias CESecurityError=CoreErrors.SecurityError

/// Create a local SecureBytesError enum that mirrors the one in UmbraCoreTypes.CoreErrors
public enum SecureBytesError: Error, Equatable {
  case invalidHexString
  case outOfBounds
  case allocationFailed
}

/// Map from SecurityProtocolsCore error to CoreErrors.SecurityError
/// This provides a clean conversion between error domains
public func mapExternalToCoreError(_ error: Error) -> CoreErrors.SecurityError {
  // If already a CoreErrors.SecurityError, return as is
  if let securityError=error as? CoreErrors.SecurityError {
    return securityError
  }

  // Default mapping for unknown errors
  return CoreErrors.SecurityError.general(String(describing: error))
}

/// Map from CoreErrors.SecurityError to another external error type
public func mapCoreToExternalError(_ error: CoreErrors.SecurityError) -> Error {
  // Just return the core error, implementations can cast as needed
  error
}

/// Map from SecureBytesError to CoreErrors.SecurityError
public func mapSecureBytesToCoreError(_ error: SecureBytesError) -> CoreErrors.SecurityError {
  switch error {
    case .invalidHexString:
      .general("Invalid hex string")
    case .outOfBounds:
      .general("Index out of bounds")
    case .allocationFailed:
      .general("Memory allocation failed")
  }
}

/// Maps any error to a Result with SecurityError
public func mapToSecurityResult<T>(_ result: Result<T, Error>)
-> Result<T, CoreErrors.SecurityError> {
  switch result {
    case let .success(value):
      return .success(value)
    case let .failure(error):
      if let securityError=error as? CoreErrors.SecurityError {
        return .failure(securityError)
      } else if let secureBytesError=error as? SecureBytesError {
        return .failure(mapSecureBytesToCoreError(secureBytesError))
      } else {
        return .failure(.general(String(describing: error)))
      }
  }
}

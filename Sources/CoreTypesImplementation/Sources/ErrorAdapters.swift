import CoreErrors
import CoreTypesInterfaces
import UmbraCoreTypes

// Since SecurityProtocolsCore and XPCProtocolsCore are namespaces rather than direct modules,
// we need to use the correct type paths to avoid ambiguity issues

/// Type alias for CoreErrors.SecurityError - our target error type
public typealias CESecurityError=CoreErrors.SecurityError

/// Create a local SecureBytesError enum that mirrors the one in UmbraCoreTypes.CoreErrors
public enum SecureBytesError: Error, Equatable {
  case invalidHexString
  case outOfBounds
  case allocationFailed
}

/// Maps errors from external domains to the CoreErrors.SecurityError domain
///
/// This adapter function provides a standardised way to convert any error type
/// into the centralised CoreErrors.SecurityError type. It delegates to the
/// centralised error mapper to ensure consistent error handling across the codebase.
///
/// - Parameter error: Any error from an external domain
/// - Returns: The equivalent CoreErrors.SecurityError
public func mapExternalToCoreError(_ error: Error) -> CoreErrors.SecurityError {
  CoreErrors.SecurityErrorMapper.mapToCoreError(error)
}

/// Maps from CoreErrors.SecurityError to an appropriate external error type
///
/// This adapter function provides bidirectional conversion capability,
/// complementing the mapExternalToCoreError function. It delegates to the
/// centralised error mapper to ensure consistent error handling.
///
/// - Parameter error: A CoreErrors.SecurityError to convert
/// - Returns: An appropriate error in the external domain
public func mapCoreToExternalError(_ error: CoreErrors.SecurityError) -> Error {
  CoreErrors.SecurityErrorMapper.mapFromCoreError(error)
}

/// Maps from SecureBytesError to CoreErrors.SecurityError
///
/// This specialised mapping function handles SecureBytesError conversion,
/// delegating to the centralised error mapper to ensure consistent handling.
///
/// - Parameter error: The SecureBytesError to convert
/// - Returns: An equivalent CoreErrors.SecurityError
public func mapSecureBytesToCoreError(_ error: SecureBytesError) -> CoreErrors.SecurityError {
  CoreErrors.SecurityErrorMapper.mapToCoreError(error)
}

/// Maps any Result with Error to a Result with CoreErrors.SecurityError
///
/// This helper function simplifies error handling when working with Result types
/// by automatically mapping the error component to a standardised SecurityError.
///
/// - Parameter result: A Result with any Error type
/// - Returns: A Result with CoreErrors.SecurityError
public func mapToSecurityResult<T>(_ result: Result<T, Error>)
-> Result<T, CoreErrors.SecurityError> {
  switch result {
    case let .success(value):
      .success(value)
    case let .failure(error):
      .failure(CoreErrors.SecurityErrorMapper.mapToCoreError(error))
  }
}

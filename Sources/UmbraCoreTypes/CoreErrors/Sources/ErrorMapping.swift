import CoreErrors
import ErrorHandlingDomains

// MARK: - Error Mapping Functions

/// Maps from a UmbraCoreTypes error to a CoreErrors error
///
/// This function centralises the mapping from domain-specific errors to core errors.
/// Where possible, it delegates to the SecurityErrorMapper to ensure consistent behaviour.
///
/// - Parameter error: The UmbraCoreTypes error to map
/// - Returns: Equivalent CoreErrors error
@Sendable
public func mapToCoreErrors(_ error: Error) -> Error {
  // Let the centralised mapper handle common cases
  CoreErrors.SecurityErrorMapper.mapToCoreError(error)
}

/// Maps from a CoreErrors error to a UmbraCoreTypes error
///
/// This function provides bidirectional mapping from core errors back to domain-specific errors.
/// It complements the mapToCoreErrors function by providing the reverse mapping operation,
/// which is essential for error propagation across module boundaries.
///
/// - Parameter error: The CoreErrors error to map
/// - Returns: Equivalent UmbraCoreTypes error
@Sendable
public func mapFromCoreErrors(_ error: Error) -> Error {
  // For specific error types, we need to handle the translation explicitly
  // as the default mapper doesn't handle these specialised cases

  if let resourceError=error as? CoreErrors.ResourceError {
    return mapFromCoreResourceError(resourceError)
  }

  if let securityError=error as? CoreErrors.SecurityError {
    return mapFromCoreSecurityError(securityError)
  }

  // Let the centralised mapper handle other cases
  // For now, preserve the original behaviour of returning the error as-is
  return error
}

/// Maps a CoreErrors.ResourceError to an appropriate UmbraCoreTypes error
///
/// This specialised mapping function handles the translation of core resource errors
/// to domain-specific error types, ensuring proper error semantics are preserved.
///
/// - Parameter error: The ResourceError to map
/// - Returns: Equivalent UmbraCoreTypes error
private func mapFromCoreResourceError(_ error: CoreErrors.ResourceError) -> Error {
  switch error {
    case .invalidState:
      return ResourceLocatorError.invalidPath
    case .resourceNotFound:
      return ResourceLocatorError.resourceNotFound
    case .operationFailed:
      return ResourceLocatorError.generalError("Operation failed")
    case .acquisitionFailed:
      return SecureBytesError.allocationFailed
    case .poolExhausted:
      return ResourceLocatorError.generalError("Resource pool exhausted")
    @unknown default:
      return ResourceLocatorError.generalError("Unknown resource error")
  }
}

/// Maps a CoreErrors.SecurityError to an appropriate UmbraCoreTypes error
///
/// This specialised mapping function handles the translation of core security errors
/// to domain-specific error types, ensuring proper error semantics are preserved
/// across module boundaries.
///
/// - Parameter error: The SecurityError to map
/// - Returns: Equivalent UmbraCoreTypes error
private func mapFromCoreSecurityError(_ error: CoreErrors.SecurityError) -> Error {
  switch error {
    case let .invalidKey(reason):
      return ResourceLocatorError.generalError("Invalid key: \(reason)")
    case let .invalidContext(reason):
      return ResourceLocatorError.generalError("Invalid context: \(reason)")
    case let .invalidParameter(name, reason):
      return ResourceLocatorError.generalError("Invalid parameter \(name): \(reason)")
    case let .operationFailed(operation, reason):
      return ResourceLocatorError.generalError("Operation failed [\(operation)]: \(reason)")
    case let .unsupportedAlgorithm(name):
      return ResourceLocatorError.generalError("Unsupported algorithm: \(name)")
    case let .missingImplementation(component):
      return ResourceLocatorError.generalError("Missing implementation: \(component)")
    case let .internalError(description):
      return ResourceLocatorError.generalError("Internal security error: \(description)")
    @unknown default:
      return ResourceLocatorError.generalError("Unknown security error")
  }
}

// MARK: - Error Container

/// A minimal error container for foundation-free error representation
public struct ErrorContainer: Error {
  public let domain: String
  public let code: Int
  public let userInfo: [String: Any]

  public init(domain: String, code: Int, userInfo: [String: Any]) {
    self.domain=domain
    self.code=code
    self.userInfo=userInfo
  }
}

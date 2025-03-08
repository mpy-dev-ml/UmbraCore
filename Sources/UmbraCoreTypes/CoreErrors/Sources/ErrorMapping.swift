import CoreErrors

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

  if let resourceError = error as? CoreErrors.ResourceError {
    return mapFromCoreResourceError(resourceError)
  }

  if let securityError = error as? CoreErrors.SecurityError {
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
    case .accessError:
      return ResourceLocatorError.accessDenied
    case .bookmarkError:
      return ResourceLocatorError.generalError("Bookmark error")
    case .cryptoError:
      return ResourceLocatorError.generalError("Cryptographic operation failed")
    case .bookmarkCreationFailed:
      return ResourceLocatorError.generalError("Bookmark creation failed")
    case .bookmarkResolutionFailed:
      return ResourceLocatorError.generalError("Bookmark resolution failed")
    case .encryptionFailed:
      return ResourceLocatorError.generalError("Encryption failed")
    case .decryptionFailed:
      return ResourceLocatorError.generalError("Decryption failed")
    case .keyGenerationFailed:
      return ResourceLocatorError.generalError("Key generation failed")
    case .invalidData:
      return ResourceLocatorError.generalError("Invalid data format")
    case .hashingFailed:
      return ResourceLocatorError.generalError("Hashing operation failed")
    case .serviceFailed:
      return ResourceLocatorError.generalError("Service operation failed")
    case .notImplemented:
      return ResourceLocatorError.generalError("Not implemented")
    case let .general(message):
      return ResourceLocatorError.generalError(message)
    @unknown default:
      return ResourceLocatorError.generalError("Security operation failed with unknown error")
  }
}

// MARK: - Error Container

/// A minimal error container for foundation-free error representation
public struct ErrorContainer: Error {
  public let domain: String
  public let code: Int
  public let userInfo: [String: Any]

  public init(domain: String, code: Int, userInfo: [String: Any]) {
    self.domain = domain
    self.code = code
    self.userInfo = userInfo
  }
}

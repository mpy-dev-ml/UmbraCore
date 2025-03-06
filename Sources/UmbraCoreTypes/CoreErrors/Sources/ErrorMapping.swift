import CoreErrors

// MARK: - Error Mapping Functions

/// Maps from a UmbraCoreTypes error to a CoreErrors error
/// - Parameter error: The UmbraCoreTypes error to map
/// - Returns: Equivalent CoreErrors error
@Sendable
public func mapToCoreErrors(_ error: Error) -> Error {
  // SecureBytes errors mapping
  if let secureError=error as? SecureBytesError {
    switch secureError {
      case .invalidHexString:
        return CoreErrors.ResourceError.operationFailed
      case .outOfBounds:
        return CoreErrors.ResourceError.invalidState
      case .allocationFailed:
        return CoreErrors.ResourceError.acquisitionFailed
      @unknown default:
        return CoreErrors.ResourceError.operationFailed
    }
  }

  // ResourceLocator errors mapping
  if let resourceError=error as? ResourceLocatorError {
    switch resourceError {
      case .invalidPath:
        return CoreErrors.ResourceError.invalidState
      case .resourceNotFound:
        return CoreErrors.ResourceError.resourceNotFound
      case .accessDenied:
        return CoreErrors.SecurityError.accessError
      case .unsupportedScheme:
        return CoreErrors.ResourceError.operationFailed
      case .generalError:
        return CoreErrors.ResourceError.operationFailed
      @unknown default:
        return CoreErrors.ResourceError.operationFailed
    }
  }

  // TimePoint errors mapping
  if let timeError=error as? TimePointError {
    switch timeError {
      case .invalidFormat:
        return CoreErrors.ResourceError.invalidState
      case .outOfRange:
        return CoreErrors.ResourceError.invalidState
      @unknown default:
        return CoreErrors.ResourceError.operationFailed
    }
  }

  // Default mapping for unknown errors
  return CoreErrors.ResourceError.operationFailed
}

/// Maps from a CoreErrors error to a UmbraCoreTypes error
/// - Parameter error: The CoreErrors error to map
/// - Returns: Equivalent UmbraCoreTypes error
@Sendable
public func mapFromCoreErrors(_ error: Error) -> Error {
  // Map from ResourceError
  if let resourceError=error as? CoreErrors.ResourceError {
    switch resourceError {
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

  // Map from SecurityError
  if let securityError=error as? CoreErrors.SecurityError {
    switch securityError {
      case .accessError:
        return ResourceLocatorError.accessDenied
      case .bookmarkError:
        return ResourceLocatorError.generalError("Bookmark error")
      case .cryptoError:
        return ResourceLocatorError.generalError("Crypto error")
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
        return ResourceLocatorError.generalError("Operation not implemented")
      case let .general(message):
        return ResourceLocatorError.generalError(message)
      @unknown default:
        return ResourceLocatorError.generalError("Unknown security error")
    }
  }

  // Default mapping
  return ResourceLocatorError.generalError("Unknown error")
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

import Foundation
import ErrorHandlingDomains

/// SecurityError error type
public enum SecurityError: Error {
  case bookmarkError
  case accessError
  case cryptoError
  case bookmarkCreationFailed
  case bookmarkResolutionFailed
}

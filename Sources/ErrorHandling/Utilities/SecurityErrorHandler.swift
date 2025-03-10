import ErrorHandling
import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import Foundation

/// A generic error implementation that conforms to UmbraError
private struct GenericError: ErrorHandlingInterfaces.UmbraError {
  let domain: String
  let code: String
  let message: String
  let details: [String: Any]
  let source: ErrorHandlingCommon.ErrorSource?
  let underlyingError: Error?
  let context: ErrorHandlingCommon.ErrorContext?

  /// Conform to CustomStringConvertible
  var description: String {
    message
  }

  /// A user-friendly error message (required by UmbraError)
  var errorDescription: String {
    message
  }

  /// Create a new instance with additional context
  func with(context: ErrorHandlingCommon.ErrorContext) -> GenericError {
    var newError=self
    newError.context=context
    return newError
  }

  /// Create a new instance with an underlying error
  func with(underlyingError: Error) -> GenericError {
    var newError=self
    newError.underlyingError=underlyingError
    return newError
  }

  /// Create a new instance with source information
  func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
    GenericError(
      domain: domain,
      code: code,
      message: message,
      details: details,
      source: source,
      underlyingError: underlyingError,
      context: context
    )
  }

  /// Create a new instance with additional user info
  func with(userInfo: [String: Any]) -> Self {
    var updatedDetails=details
    for (key, value) in userInfo {
      updatedDetails[key]=value
    }

    return GenericError(
      domain: domain,
      code: code,
      message: message,
      details: updatedDetails,
      source: source,
      underlyingError: underlyingError,
      context: context
    )
  }
}

/// A handler for security-related errors in the UmbraCore security stack.
/// This implementation provides consistent error handling across all security modules.
@MainActor
public final class SecurityErrorHandler: @unchecked Sendable {
  /// The shared instance for the handler
  public static let shared=SecurityErrorHandler()

  /// The error mapper used to transform errors
  private let errorMapper=SecurityErrorMapper()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Handle a security error with appropriate level and logging
  ///
  /// - Parameters:
  ///   - error: The error to handle
  ///   - severity: The severity level of the error
  ///   - file: The file where the error occurred
  ///   - function: The function where the error occurred
  ///   - line: The line number where the error occurred
  ///   - userInfo: Additional information about the error
  public func handle(
    _ error: Error,
    severity: ErrorHandlingInterfaces.ErrorSeverity,
    file: String=#file,
    function: String=#function,
    line: Int=#line,
    userInfo _: [String: Any]?=nil
  ) {
    // Create error context
    let source=ErrorHandlingCommon.ErrorSource(file: file, function: function, line: line)
    let context=ErrorHandlingCommon.ErrorContext(
      source: "SecurityErrorHandler",
      operation: "handle",
      details: "Handling security error",
      underlyingError: error
    )

    // Map our severity to the core severity type
    let mappedSeverity: ErrorHandlingCommon.ErrorSeverity=switch severity {
      case .critical:
        .critical
      case .error:
        .error
      case .warning:
        .warning
      case .info:
        .info
      case .debug:
        .debug
      case .trace:
        .debug // Map trace to debug as ErrorHandlingCommon might not have trace
      @unknown default:
        .error
    }

    // Create a generic error with our context
    let genericError=GenericError(
      domain: "Security",
      code: "SECURITY_ERROR",
      message: "An error occurred in the security module",
      details: [:],
      source: source,
      underlyingError: error,
      context: context
    )

    // Delegate to the core error handler
    ErrorHandlingCore.ErrorHandler.shared.handle(
      genericError,
      severity: mappedSeverity,
      file: file,
      function: function,
      line: line
    )

    // Log the full error details if needed
    log(error: error, severity: severity)
  }

  /// Log an error with appropriate severity
  private func log(error: Error, severity: ErrorHandlingInterfaces.ErrorSeverity) {
    var code="UNKNOWN"
    var message="Unknown error"

    // Try to map the error using our error mapper
    if let securityError=error as? SecurityCoreErrorWrapper {
      // Extract code and message from the error
      let (errorCode, errorMessage)=getErrorCodeAndMessage(securityError.wrappedError)
      code=errorCode
      message=errorMessage
    } else if let securityCoreError=error as? UmbraErrors.Security.Core {
      // Direct mapping from core error
      let (errorCode, errorMessage)=getErrorCodeAndMessage(securityCoreError)
      code=errorCode
      message=errorMessage
    } else {
      // Generic fallback for unknown errors
      code="UNKNOWN_SECURITY_ERROR"
      message=String(describing: error)
    }

    // Log the error with the appropriate severity
    switch severity {
      case .critical:
        print("[CRITICAL] Security error \(code): \(message)")
      case .error:
        print("[ERROR] Security error \(code): \(message)")
      case .warning:
        print("[WARNING] Security issue \(code): \(message)")
      case .info:
        print("[INFO] Security notice \(code): \(message)")
      case .debug:
        print("[DEBUG] Security debug \(code): \(message)")
      case .trace:
        print("[TRACE] Security trace \(code): \(message)")
      @unknown default:
        print("[ERROR] Security error \(code): \(message)")
    }
  }

  /// Maps a security error to a tuple containing a code and message
  private func getErrorCodeAndMessage(
    _ error: UmbraErrors.Security.Core
  ) -> (code: String, message: String) {
    switch error {
      case let .authenticationFailed(reason):
        return ("AUTHENTICATION_FAILED", "Authentication failed: \(reason)")
      case let .authorizationFailed(reason):
        return ("AUTHORIZATION_FAILED", "Authorization failed: \(reason)")
      case let .insufficientPermissions(resource, requiredPermission):
        return (
          "INSUFFICIENT_PERMISSIONS",
          "Insufficient permissions to access \(resource). Required: \(requiredPermission)"
        )
      case let .encryptionFailed(reason):
        return ("ENCRYPTION_FAILED", "Encryption failed: \(reason)")
      case let .decryptionFailed(reason):
        return ("DECRYPTION_FAILED", "Decryption failed: \(reason)")
      case let .hashingFailed(reason):
        return ("HASHING_FAILED", "Hashing operation failed: \(reason)")
      case let .signatureInvalid(reason):
        return ("SIGNATURE_INVALID", "Signature verification failed: \(reason)")
      case let .certificateInvalid(reason):
        return ("CERTIFICATE_INVALID", "Certificate is invalid: \(reason)")
      case let .certificateExpired(reason):
        return ("CERTIFICATE_EXPIRED", "Certificate has expired: \(reason)")
      case let .policyViolation(policy, reason):
        return ("POLICY_VIOLATION", "Security policy violation (\(policy)): \(reason)")
      case let .secureConnectionFailed(reason):
        return ("SECURE_CONNECTION_FAILED", "Secure connection failed: \(reason)")
      case let .secureStorageFailed(operation, reason):
        return ("SECURE_STORAGE_FAILED", "Secure storage operation \(operation) failed: \(reason)")
      case let .dataIntegrityViolation(reason):
        return ("DATA_INTEGRITY_VIOLATION", "Data integrity violation detected: \(reason)")
      case let .internalError(detail):
        return ("INTERNAL_ERROR", "Internal security error: \(detail)")
      @unknown default:
        return ("UNKNOWN", "Unknown security error")
    }
  }
}

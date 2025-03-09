import ErrorHandling
import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification
import ErrorHandlingRecovery
import Foundation

/// A generic error implementation that conforms to UmbraError
private struct GenericError: ErrorHandlingInterfaces.UmbraError {
  let domain: String
  let code: String
  let message: String
  let details: [String: String]

  // Additional properties required by UmbraError
  var source: ErrorHandlingCommon.ErrorSource?
  var underlyingError: Error?
  var context: ErrorHandlingCommon.ErrorContext = .init(
    source: "SecurityErrorHandler",
    operation: "GenericError",
    details: nil,
    underlyingError: nil
  )

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
  func with(source: ErrorHandlingCommon.ErrorSource) -> GenericError {
    var newError=self
    newError.source=source
    return newError
  }
}

/// A utility class for handling security errors across different modules
/// This class is responsible for mapping security errors to a common format and logging them
public final class SecurityErrorHandler: @unchecked Sendable {
  /// The shared instance for the handler
  public static let shared=SecurityErrorHandler()

  /// The error mapper used to transform errors
  private let errorMapper=SecurityErrorMapper()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Handle security errors with the shared error handler
  /// - Parameters:
  ///   - error: The error to handle
  ///   - severity: Error severity level
  ///   - file: File name (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  @MainActor
  public func handleSecurityError(
    _ error: Error,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    // Map the error to our common format
    let genericError=mapToGenericError(
      error,
      sourceFile: file,
      sourceFunction: function,
      sourceLine: line
    )

    // Use the generic error with the error handler
    ErrorHandlingCore.ErrorHandler.shared.handle(
      genericError,
      severity: severity,
      file: file,
      function: function,
      line: line
    )
  }

  /// Maps an error to our generic error format
  /// - Parameters:
  ///   - error: The error to map
  ///   - sourceFile: The source file where the error occurred
  ///   - sourceFunction: The function where the error occurred
  ///   - sourceLine: The line number where the error occurred
  /// - Returns: A generic error that conforms to UmbraError
  private func mapToGenericError(
    _ error: Error,
    sourceFile: String,
    sourceFunction: String,
    sourceLine: Int
  ) -> GenericError {
    // Extract error details from the security error
    let domain="security.umbracore.dev"
    let code: String
    let message: String

    // Try to map the error using our error mapper
    if let securityError=error as? SecurityCoreErrorWrapper {
      // Extract code and message from the error
      let errorInfo=extractErrorInfo(from: securityError.wrappedError)
      code=errorInfo.code
      message=errorInfo.message
    } else if let mappedError=errorMapper.mapFromAny(error) {
      // Use the mapped error information
      code=String(describing: mappedError).uppercased().replacingOccurrences(of: " ", with: "_")
      message=extractMessage(from: mappedError)
    } else {
      // Generic fallback for unknown errors
      code="UNKNOWN_SECURITY_ERROR"
      message="Unhandled security error: \(String(describing: error))"
    }

    // Create source information
    let source=ErrorHandlingCommon.ErrorSource(
      file: sourceFile,
      function: sourceFunction,
      line: sourceLine
    )

    // Create a generic error that conforms to UmbraError
    return GenericError(
      domain: domain,
      code: code,
      message: message,
      details: [:],
      source: source,
      underlyingError: error,
      context: ErrorHandlingCommon.ErrorContext(
        source: "SecurityErrorHandler",
        operation: "handleSecurityError",
        details: "Handling \(code)",
        underlyingError: error
      )
    )
  }

  /// Extracts the error code and message from a security error
  /// - Parameter error: The security error to extract information from
  /// - Returns: A tuple containing the error code and message
  private func extractErrorInfo(
    from error: UmbraErrors.Security
      .Core
  ) -> (code: String, message: String) {
    switch error {
      case let .encryptionFailed(reason):
        return ("ENCRYPTION_FAILED", "Encryption failed: \(reason)")
      case let .decryptionFailed(reason):
        return ("DECRYPTION_FAILED", "Decryption failed: \(reason)")
      case let .keyGenerationFailed(reason):
        return ("KEY_GENERATION_FAILED", "Key generation failed: \(reason)")
      case let .invalidKey(reason):
        return ("INVALID_KEY", "Invalid key: \(reason)")
      case let .hashVerificationFailed(reason):
        return ("HASH_VERIFICATION_FAILED", "Hash verification failed: \(reason)")
      case let .randomGenerationFailed(reason):
        return ("RANDOM_GENERATION_FAILED", "Random generation failed: \(reason)")
      case let .invalidInput(reason):
        return ("INVALID_INPUT", "Invalid input: \(reason)")
      case let .storageOperationFailed(reason):
        return ("STORAGE_OPERATION_FAILED", "Storage operation failed: \(reason)")
      case let .timeout(operation):
        return ("TIMEOUT", "Operation timed out: \(operation)")
      case let .serviceError(errorCode, reason):
        return ("SERVICE_ERROR_\(errorCode)", "Service error: \(reason)")
      case let .internalError(detail):
        return ("INTERNAL_ERROR", "Internal error: \(detail)")
      case let .notImplemented(feature):
        return ("NOT_IMPLEMENTED", "Not implemented: \(feature)")
      @unknown default:
        return ("UNKNOWN", "Unknown security error")
    }
  }

  /// Extracts a human-readable message from a mapped security error
  /// - Parameter error: The mapped security error
  /// - Returns: A human-readable error message
  private func extractMessage(from error: UmbraSecurityError) -> String {
    switch error {
      case let .authenticationFailed(reason):
        "Authentication failed: \(reason)"
      case let .unauthorizedAccess(reason):
        "Unauthorized access: \(reason)"
      case let .invalidCredentials(reason):
        "Invalid credentials: \(reason)"
      case let .sessionExpired(reason):
        "Session expired: \(reason)"
      case let .tokenExpired(reason):
        "Token expired: \(reason)"
      case let .encryptionFailed(reason):
        "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        "Decryption failed: \(reason)"
      case let .keyGenerationFailed(reason):
        "Key generation failed: \(reason)"
      case let .hashingFailed(reason):
        "Hashing failed: \(reason)"
      case let .signatureInvalid(reason):
        "Signature invalid: \(reason)"
      case let .permissionDenied(reason):
        "Permission denied: \(reason)"
      case let .certificateInvalid(reason):
        "Certificate invalid: \(reason)"
      case let .secureChannelFailed(reason):
        "Secure channel failed: \(reason)"
      case let .securityConfigurationError(reason):
        "Security configuration error: \(reason)"
      case let .unknown(reason):
        "Unknown security error: \(reason)"
    }
  }
}

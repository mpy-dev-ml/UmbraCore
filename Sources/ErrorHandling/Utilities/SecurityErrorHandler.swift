import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces

// Using ErrorHandlingInterfaces for UmbraError
import ErrorHandling // Import the main module with wrapper types
import ErrorHandlingCommon
import ErrorHandlingNotification // Add explicit import for notification types

// Removed ErrorHandlingLogging import to fix library evolution issues
import ErrorHandlingMapping
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
public final class SecurityErrorHandler: @unchecked Sendable {
  /// The shared instance for the handler
  public static let shared=SecurityErrorHandler()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Handle security errors with the shared error handler
  /// - Parameters:
  ///   - error: The error to handle
  ///   - severity: Error severity level
  ///   - file: File name (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  @MainActor // Add MainActor to make this function compatible with ErrorHandler
  public func handleSecurityError(
    _ error: Error,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    // Use a type check pattern to avoid ambiguity
    guard let securityError=error as? SecurityCoreErrorWrapper else {
      // Just log the error if it's not a security error we can handle
      print("Unhandled security error: \(String(describing: error))")
      return
    }

    // Map the security error to the required properties
    let domain="Security.Core"
    let code: String
    let message: String
    let details: [String: String]=[:]

    switch securityError.wrappedError {
      case let .encryptionFailed(reason):
        code="ENCRYPTION_FAILED"
        message="Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        code="DECRYPTION_FAILED"
        message="Decryption failed: \(reason)"
      case let .keyGenerationFailed(reason):
        code="KEY_GENERATION_FAILED"
        message="Key generation failed: \(reason)"
      case let .invalidKey(reason):
        code="INVALID_KEY"
        message="Invalid key: \(reason)"
      case let .hashVerificationFailed(reason):
        code="HASH_VERIFICATION_FAILED"
        message="Hash verification failed: \(reason)"
      case let .randomGenerationFailed(reason):
        code="RANDOM_GENERATION_FAILED"
        message="Random generation failed: \(reason)"
      case let .invalidInput(reason):
        code="INVALID_INPUT"
        message="Invalid input: \(reason)"
      case let .storageOperationFailed(reason):
        code="STORAGE_OPERATION_FAILED"
        message="Storage operation failed: \(reason)"
      case let .timeout(operation):
        code="TIMEOUT"
        message="Operation timed out: \(operation)"
      case let .serviceError(errorCode, reason):
        code="SERVICE_ERROR_\(errorCode)"
        message="Service error: \(reason)"
      case let .internalError(detail):
        code="INTERNAL_ERROR"
        message="Internal error: \(detail)"
      case let .notImplemented(feature):
        code="NOT_IMPLEMENTED"
        message="Not implemented: \(feature)"
      @unknown default:
        code="UNKNOWN"
        message="Unknown security error"
    }

    // Create source information
    let source=ErrorHandlingCommon.ErrorSource(
      file: file,
      function: function,
      line: line
    )

    // Create a generic error that we know conforms to UmbraError
    let genericError=GenericError(
      domain: domain,
      code: code,
      message: message,
      details: details,
      source: source,
      underlyingError: nil,
      context: ErrorHandlingCommon.ErrorContext(
        source: "SecurityErrorHandler",
        operation: "handleSecurityError",
        details: "Handling \(code)",
        underlyingError: error
      )
    )

    // Use the generic error with the error handler
    ErrorHandler.shared.handle(
      genericError,
      severity: severity,
      file: file,
      function: function,
      line: line
    )
  }

  /// Add recovery options for security errors
  /// - Parameters:
  ///   - error: The error to handle
  ///   - retryAction: The action to take when retry is selected
  ///   - cancelAction: The action to take when cancel is selected
  /// - Returns: Recovery options for the error
  public func addSecurityRecoveryOptions(
    for error: Error,
    retryAction: @escaping @Sendable () -> Void,
    cancelAction: @escaping @Sendable () -> Void
  ) -> RecoveryOptions {
    // Try to map to our SecurityCoreErrorWrapper type
    if let securityError=error as? SecurityCoreErrorWrapper {
      // Return recovery options based on the security error type
      switch securityError.wrappedError {
        case .invalidKey:
          // Use the factory methods from RecoveryOptions for consistent type handling
          RecoveryOptions.retryCancel(
            title: "Access Denied",
            message: String(describing: securityError),
            retryHandler: retryAction,
            cancelHandler: cancelAction
          )
        default:
          RecoveryOptions.retryCancel(
            title: "Security Error",
            message: String(describing: securityError),
            retryHandler: retryAction,
            cancelHandler: cancelAction
          )
      }
    } else {
      // Not a security error, or couldn't be mapped
      RecoveryOptions.retryCancel(
        title: "Security Error",
        message: String(describing: error),
        retryHandler: retryAction,
        cancelHandler: cancelAction
      )
    }
  }

  /// Creates a notification for security errors
  /// - Parameter error: Error to create a notification for
  /// - Returns: ErrorNotification for displaying to the user
  func createNotificationForUI(for error: Error) -> ErrorHandlingNotification.ErrorNotification {
    // Create recovery options based on the error type
    let recoveryOptions=createRecoveryOptions(for: error)

    // Use a conditional cast with explicit type to avoid ambiguity
    if let securityError=error as? SecurityExternalError {
      return ErrorHandlingNotification.ErrorNotification(
        error: securityError,
        title: "Security Alert",
        message: securityError.errorDescription,
        recoveryOptions: recoveryOptions?.actions ?? []
      )
    } else if let securityError=error as? SecurityCoreErrorWrapper {
      return ErrorHandlingNotification.ErrorNotification(
        error: securityError,
        title: "Security Alert",
        message: securityError.errorDescription,
        recoveryOptions: recoveryOptions?.actions ?? []
      )
    } else {
      return ErrorHandlingNotification.ErrorNotification(
        error: error,
        title: "Security Alert",
        message: String(describing: error),
        recoveryOptions: recoveryOptions?.actions ?? []
      )
    }
  }

  /// Map a security error to recovery options
  /// - Parameter securityError: The security error
  /// - Returns: Recovery options for the security error
  private func mappedSecurityErrorToRecoveryOptions(
    _ securityError: SecurityCoreErrorWrapper
  ) -> RecoveryOptions {
    // Determine appropriate recovery options based on the error type
    switch securityError.wrappedError {
      case let .invalidInput(reason) where reason.contains("authentication"):
        RecoveryOptions.retryCancel(
          title: "Authentication Required",
          message: String(describing: securityError),
          retryHandler: {
            print("Retrying after security error")
            // Implement retry logic here
          },
          cancelHandler: {
            print("Cancelled after security error")
            // Implement cancel logic here
          }
        )

      case let .invalidInput(reason) where reason.contains("session"):
        RecoveryOptions.retryCancel(
          title: "Session Expired",
          message: String(describing: securityError),
          retryHandler: {
            print("Retrying after security error")
            // Implement retry logic here
          },
          cancelHandler: {
            print("Cancelled after security error")
            // Implement cancel logic here
          }
        )

      case .invalidKey:
        RecoveryOptions.retryCancel(
          title: "Access Denied",
          message: String(describing: securityError),
          retryHandler: {
            print("Retrying after security error")
            // Implement retry logic here
          },
          cancelHandler: {
            print("Cancelled after security error")
            // Implement cancel logic here
          }
        )

      case let .invalidInput(reason) where reason.contains("permission"):
        RecoveryOptions.retryCancel(
          title: "Access Denied",
          message: String(describing: securityError),
          retryHandler: {
            print("Retrying after security error")
            // Implement retry logic here
          },
          cancelHandler: {
            print("Cancelled after security error")
            // Implement cancel logic here
          }
        )

      default:
        // Default recovery options for other security errors
        RecoveryOptions.retryCancel(
          title: "Security Error",
          message: String(describing: securityError),
          retryHandler: {
            print("Retrying after security error")
            // Implement retry logic here
          },
          cancelHandler: {
            print("Cancelled after security error")
            // Implement cancel logic here
          }
        )
    }
  }

  /// Example usage to explain how errors are handled
  @MainActor
  public func exampleHandling() {
    // Create a security error
    let securityError=SecurityCoreErrorWrapper(
      UmbraErrors.Security.Core
        .invalidInput(reason: "Incorrect password format")
    )

    // Handle the security error with the handler
    handleSecurityError(securityError)

    // Create a notification for the error
    let notification=createNotificationForUI(for: securityError)

    // Display the notification (simplified example)
    print("A security notification would be displayed: \(notification.title)")
  }

  @MainActor // Add MainActor to match handleSecurityError
  func createErrorNotification(
    from error: Error,
    severity _: ErrorHandlingInterfaces.ErrorSeverity
  ) -> ErrorHandlingNotification.ErrorNotification {
    // Create recovery options based on the severity
    let recoveryOptions: [ErrorHandlingNotification.ClosureRecoveryOption]=[]

    // Use a conditional cast with explicit type to avoid ambiguity
    if let securityError=error as? SecurityCoreErrorWrapper {
      // Get error message using the custom description
      let errorMessage=securityError.errorDescription
      let errorTitle="Security Error"

      return ErrorHandlingNotification.ErrorNotification(
        error: securityError,
        title: errorTitle,
        message: errorMessage,
        recoveryOptions: recoveryOptions
      )
    } else {
      // Handle non-security errors
      return ErrorHandlingNotification.ErrorNotification(
        error: error,
        title: "Error",
        message: String(describing: error),
        recoveryOptions: recoveryOptions
      )
    }
  }
}

/// Extension to provide usage examples
extension SecurityErrorHandler {
  /// Example usage of the security error handler
  /// - Parameter error: Any error to handle as a security error
  @MainActor
  public static func handleExampleError(_ error: Error) {
    // Create recovery options
    let recoveryOptions=shared.addSecurityRecoveryOptions(
      for: error,
      retryAction: {
        print("Retrying after security error")
        // Implement retry logic here
      },
      cancelAction: {
        print("Cancelled after security error")
        // Implement cancel logic here
      }
    )

    // Create a notification
    let notification=shared.createNotificationForUI(
      for: error
    )

    // Log and handle the error
    shared.handleSecurityError(error)

    // The notification can be shown in the UI
    print("A security notification would be displayed: \(notification.title)")
  }
}

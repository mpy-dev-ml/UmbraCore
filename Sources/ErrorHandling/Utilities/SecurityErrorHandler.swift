import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces

// Removed ErrorHandlingLogging import to fix library evolution issues
import ErrorHandlingMapping
import ErrorHandlingNotification
import ErrorHandlingProtocols
import ErrorHandlingRecovery
import Foundation

/// A utility class for handling security errors across different modules
public final class SecurityErrorHandler: @unchecked Sendable {
  /// The shared instance for the handler
  public static let shared=SecurityErrorHandler()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Handle any security-related error from any module
  /// - Parameters:
  ///   - error: The security error to handle
  ///   - severity: The severity level of the error
  ///   - file: Source file (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  public func handleSecurityError(
    _ error: Error,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .critical,
    file: String=#file,
    function: String=#function,
    line: Int=#line
  ) {
    // Try to map to our UmbraErrors.Security.Core type
    if let securityError=error as? UmbraErrors.Security.Core {
      // Successfully mapped, handle with our error handler
      ErrorHandler.shared.handle(
        securityError,
        severity: severity,
        file: file,
        function: function,
        line: line
      )
    } else {
      // Just log the error if it's not a security error we can handle
      print("Unhandled security error: \(error.localizedDescription)")
    }
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
    // Try to map to our UmbraErrors.Security.Core type
    if let securityError=error as? UmbraErrors.Security.Core {
      // Return recovery options based on the security error type
      switch securityError {
        case .invalidKey:
          // Use the factory methods from RecoveryOptions for consistent type handling
          RecoveryOptions.retryCancel(
            title: "Access Denied",
            message: "You don't have permission to access this resource.",
            retryHandler: retryAction,
            cancelHandler: cancelAction
          )
        default:
          RecoveryOptions.retryCancel(
            title: "Security Error",
            message: securityError.localizedDescription,
            retryHandler: retryAction,
            cancelHandler: cancelAction
          )
      }
    } else {
      // Not a security error, or couldn't be mapped
      RecoveryOptions.retryCancel(
        title: "Security Error",
        message: error.localizedDescription,
        retryHandler: retryAction,
        cancelHandler: cancelAction
      )
    }
  }

  /// Create a notification for a security error
  /// - Parameters:
  ///   - error: The security error
  ///   - recoveryOptions: Optional recovery options
  /// - Returns: An ErrorNotification for the security error
  public func createSecurityNotification(
    for error: Error,
    recoveryOptions: RecoveryOptions?=nil
  ) -> ErrorHandlingNotification.ErrorNotification {
    // Try to map to our UmbraErrors.Security.Core type
    if let securityError=error as? UmbraErrors.Security.Core {
      ErrorHandlingNotification.ErrorNotification(
        error: securityError,
        title: "Security Alert",
        message: securityError.localizedDescription,
        severity: .critical,
        recoveryOptions: recoveryOptions?.actions
      )
    } else {
      // Not a security error, or couldn't be mapped
      ErrorHandlingNotification.ErrorNotification(
        error: error,
        title: "Security Alert",
        message: error.localizedDescription,
        severity: .critical,
        recoveryOptions: recoveryOptions?.actions
      )
    }
  }

  /// Map a security error to recovery options
  /// - Parameter securityError: The security error
  /// - Returns: Recovery options for the security error
  private func mappedSecurityErrorToRecoveryOptions(
    _ securityError: UmbraErrors.Security
      .Core
  ) -> RecoveryOptions {
    // Determine appropriate recovery options based on the error type
    switch securityError {
      case let .invalidInput(reason) where reason.contains("authentication"):
        RecoveryOptions.retryCancel(
          title: "Authentication Required",
          message: "Your authentication has failed. Please re-authenticate to continue.",
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
          message: "Your session has expired. Please renew your session to continue.",
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
          message: "You do not have permission to perform this action.",
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
          message: "You do not have permission to perform this action.",
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
          message: securityError.localizedDescription,
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
    let notification=shared.createSecurityNotification(
      for: error,
      recoveryOptions: recoveryOptions
    )

    // Log and handle the error
    shared.handleSecurityError(error)

    // The notification can be shown in the UI
    print("A security notification would be displayed: \(notification.title)")
  }
}

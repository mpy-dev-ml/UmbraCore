import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingLogging
import ErrorHandlingMapping
import ErrorHandlingNotification
import ErrorHandlingProtocols
import ErrorHandlingRecovery
import Foundation

/// A utility class for handling security errors across different modules
public class SecurityErrorHandler {
  /// The shared instance for the handler
  public static let shared = SecurityErrorHandler()

  /// The error mapper to handle different security error types
  private let securityErrorMapper: SecurityErrorMapper

  /// Private initialiser to enforce singleton pattern
  private init() {
    self.securityErrorMapper = SecurityErrorMapper()
  }

  /// Handle any security-related error from any module
  /// - Parameters:
  ///   - error: The security error to handle
  ///   - severity: The severity level of the error
  ///   - file: Source file (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  public func handleSecurityError(
    _ error: Error,
    severity: ErrorHandlingNotification.NotificationSeverity = .critical,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    // Try to map to our consolidated UmbraSecurityError
    if let securityError = securityErrorMapper.mapFromAny(error) {
      // Successfully mapped, handle with our error handler
      ErrorHandler.shared.handle(
        securityError,
        severity: severity,
        file: file,
        function: function,
        line: line
      )
    } else {
      // Not a security error, or couldn't be mapped
      ErrorHandler.shared.handle(
        error,
        severity: severity,
        file: file,
        function: function,
        line: line
      )
    }
  }

  /// Map a security error to a recovery options object
  /// - Parameter error: The security error from any module
  /// - Returns: Recovery options for a security error
  public func securityErrorToRecoveryOptions(for error: Error) -> RecoveryOptions {
    // Map to our consolidated UmbraSecurityError if possible
    if let securityError = securityErrorMapper.mapFromAny(error) {
      return mappedSecurityErrorToRecoveryOptions(securityError)
    } else {
      // Not a security error, or couldn't be mapped
      return RecoveryOptions(
        actions: [
          RecoveryAction(id: "ok", title: "OK", isDefault: true)
        ],
        title: "Security Error",
        message: error.localizedDescription
      )
    }
  }

  /// Adds standard recovery options for security errors
  /// - Parameters:
  ///   - error: The security error
  ///   - retryAction: The action to perform when retrying
  ///   - cancelAction: The action to perform when cancelling
  /// - Returns: RecoveryOptions for the security error
  public func addSecurityRecoveryOptions(
    for error: Error,
    retryAction: @escaping @Sendable () -> Void,
    cancelAction: @escaping @Sendable () -> Void
  ) -> RecoveryOptions {
    // Map to our consolidated UmbraSecurityError if possible
    if let securityError = securityErrorMapper.mapFromAny(error) {
      // Return recovery options based on the security error type
      switch securityError {
      case .accessDenied:
        return RecoveryOptions(
          actions: [
            RecoveryAction(id: "request", title: "Request Access", isDefault: true, handler: retryAction),
            RecoveryAction(id: "cancel", title: "Cancel", handler: cancelAction)
          ],
          title: "Access Denied",
          message: "You don't have permission to access this resource."
        )
      default:
        return RecoveryOptions.retryCancel(
          title: "Security Error",
          message: securityError.errorDescription,
          retryHandler: retryAction,
          cancelHandler: cancelAction
        )
      }
    } else {
      // Not a security error, or couldn't be mapped
      return RecoveryOptions.retryCancel(
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
    recoveryOptions: RecoveryOptions? = nil
  ) -> ErrorHandlingNotification.ErrorNotification {
    // Map to our consolidated UmbraSecurityError if possible
    if let securityError = securityErrorMapper.mapFromAny(error) {
      return ErrorHandlingNotification.ErrorNotification(
        error: securityError,
        title: "Security Alert",
        message: securityError.errorDescription,
        severity: .critical,
        recoveryOptions: recoveryOptions?.actions
      )
    } else {
      // Not a security error, or couldn't be mapped
      return ErrorHandlingNotification.ErrorNotification(
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
  private func mappedSecurityErrorToRecoveryOptions(_ securityError: UmbraSecurityError) -> RecoveryOptions {
    // Determine appropriate recovery options based on the error type
    switch securityError {
    case .authenticationFailed, .invalidCredentials:
      return RecoveryOptions(
        actions: [
          RecoveryAction(
            id: "reauthenticate",
            title: "Re-authenticate",
            isDefault: true,
            handler: { [weak self] in
              print("Retrying after security error")
              // Implement retry logic here
            }
          ),
          RecoveryAction(id: "cancel", title: "Cancel", handler: { [weak self] in
            print("Cancelled after security error")
            // Implement cancel logic here
          })
        ],
        title: "Authentication Required",
        message: "Your authentication has failed. Please re-authenticate to continue."
      )

    case .tokenExpired, .sessionExpired:
      return RecoveryOptions(
        actions: [
          RecoveryAction(
            id: "renew",
            title: "Renew Session",
            isDefault: true,
            handler: { [weak self] in
              print("Retrying after security error")
              // Implement retry logic here
            }
          ),
          RecoveryAction(id: "cancel", title: "Cancel", handler: { [weak self] in
            print("Cancelled after security error")
            // Implement cancel logic here
          })
        ],
        title: "Session Expired",
        message: "Your session has expired. Please renew your session to continue."
      )

    case .permissionDenied, .insufficientPrivileges, .unauthorizedAccess:
      return RecoveryOptions(
        actions: [
          RecoveryAction(
            id: "request",
            title: "Request Access",
            isDefault: true,
            handler: { [weak self] in
              print("Retrying after security error")
              // Implement retry logic here
            }
          ),
          RecoveryAction(id: "cancel", title: "Cancel", handler: { [weak self] in
            print("Cancelled after security error")
            // Implement cancel logic here
          })
        ],
        title: "Access Denied",
        message: "You do not have permission to perform this action."
      )

    default:
      // Default recovery options for other security errors
      return RecoveryOptions.retryCancel(
        title: "Security Error",
        message: securityError.errorDescription,
        retryHandler: { [weak self] in
          print("Retrying after security error")
          // Implement retry logic here
        },
        cancelHandler: { [weak self] in
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
  public static func handleExampleError(_ error: Error) {
    // Create recovery options
    let recoveryOptions = shared.addSecurityRecoveryOptions(
      for: error,
      retryAction: { [weak self] in
        print("Retrying after security error")
        // Implement retry logic here
      },
      cancelAction: { [weak self] in
        print("Cancelled after security error")
        // Implement cancel logic here
      }
    )

    // Create a notification
    let notification = shared.createSecurityNotification(
      for: error,
      recoveryOptions: recoveryOptions
    )

    // Log and handle the error
    shared.handleSecurityError(error)

    // The notification can be shown in the UI
    print("A security notification would be displayed: \(notification.title)")
  }
}

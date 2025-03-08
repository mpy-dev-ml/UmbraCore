import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingLogging
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification
import ErrorHandlingProtocols
import ErrorHandlingRecovery
import Foundation

/// A sample class that demonstrates the error handling system
public class ErrorHandlingExample {
  /// Sample notification handler for demonstration purposes
  private class SampleNotificationHandler: ErrorNotificationHandler {
    /// Shows notifications in the console for demonstration
    public func present(notification: ErrorNotification) {
      print("🔔 NOTIFICATION: \(notification.title)")
      print("   Severity: \(notification.severity.rawValue)")
      print("   Message: \(notification.message)")

      if let recoveryOptions = notification.recoveryOptions {
        print("   Recovery options:")
        for action in recoveryOptions.actions {
          print("     - \(action.title)")
        }
      }

      print("")
    }

    /// Dismisses a notification by its ID
    public func dismiss(notificationWithId id: UUID) {
      print("Dismissed notification \(id)")
    }

    /// Dismisses all notifications
    public func dismissAll() {
      print("Dismissed all notifications")
    }
  }

  /// Sample recovery provider for demonstration purposes
  private class SampleRecoveryProvider: RecoveryOptionsProvider {
    /// Provides recovery options for security errors
    public func recoveryOptions(for error: Error) -> RecoveryOptions? {
      // Only provide recovery options for security errors
      guard let _ = error as? SecurityError else {
        return nil
      }

      // Create recovery options based on the error
      return RecoveryOptions(
        actions: [
          RecoveryAction(
            id: "retry",
            title: "Retry",
            description: "Try the operation again",
            isDefault: true,
            handler: { print("Retrying operation...") }
          ),
          RecoveryAction(
            id: "ignore",
            title: "Ignore",
            description: "Continue without resolving the error",
            handler: { print("Ignoring error and continuing...") }
          ),
          RecoveryAction(
            id: "cancel",
            title: "Cancel",
            description: "Cancel the operation",
            handler: { print("Cancelling operation...") }
          )
        ],
        title: "Security Error",
        message: "A security error occurred. Please choose how to proceed."
      )
    }
  }

  /// Run the example to demonstrate the error handling system
  public static func runExample() {
    // Set up the error handler
    let errorHandler = ErrorHandler.shared
    errorHandler.setNotificationHandler(SampleNotificationHandler())
    errorHandler.registerRecoveryProvider(SampleRecoveryProvider())

    print("=== ERROR HANDLING SYSTEM EXAMPLE ===\n")

    // Example 1: Handle a security error
    print("Example 1: Handle a security error")
    let securityError = SecurityError.authenticationFailed("Invalid username or password")
    errorHandler.handle(securityError, severity: .high)

    // Example 2: Simulated external security error
    print("\nExample 2: Handle an external security error")
    // This simulates an error from a different module with namespace conflicts
    let externalError = NSError(
      domain: "SecurityProtocolsCore.SecurityError",
      code: 401,
      userInfo: [NSLocalizedDescriptionKey: "Authentication failed: Token expired"]
    )

    // Use our mapper to handle it
    let securityErrorMapper = SecurityErrorMapper()
    if let mappedError = securityErrorMapper.mapFromAny(externalError) {
      errorHandler.handle(mappedError, severity: .high)
    } else {
      errorHandler.handle(
        GenericUmbraError(
          domain: "Security",
          code: "mapping_failed",
          description: "Failed to map external error"
        ),
        severity: .medium
      )
    }

    // Example 3: Error with recovery options
    print("\nExample 3: Error with recovery options")
    let recoveryOptions = RecoveryOptions.retryCancel(
      title: "Connection Error",
      message: "Could not establish a secure connection. Would you like to retry?",
      retryHandler: { print("Retrying connection...") },
      cancelHandler: { print("Connection attempt cancelled") }
    )

    let connectionError = SecurityError.secureChannelFailed("TLS handshake failed")
    let notification = ErrorNotification.from(
      umbraError: connectionError,
      severity: .high,
      recoveryOptions: recoveryOptions
    )

    let notificationHandler = SampleNotificationHandler()
    notificationHandler.present(notification: notification)

    print("\n=== END OF EXAMPLE ===")
  }
}

/// Extension to demonstrate how to add additional functionality
extension ErrorHandlingExample {
  /// Helper method to demonstrate handling of different security error types
  public static func handleMixedSecurityErrors() {
    print("=== MIXED SECURITY ERROR HANDLING ===\n")

    // Set up the security error handler
    let securityHandler = SecurityErrorHandler.shared

    // Example 1: Direct SecurityError from our module
    print("Example 1: Handle our SecurityError type")
    let ourError = SecurityError.permissionDenied("Insufficient privileges")
    securityHandler.handleSecurityError(ourError)

    // Example 2: External error type
    print("\nExample 2: Handle external security error")
    let externalError = NSError(
      domain: "SecurityTypes.SecurityError",
      code: 403,
      userInfo: [NSLocalizedDescriptionKey: "Authorization failed: Access denied to resource"]
    )
    securityHandler.handleSecurityError(externalError)

    // Example 3: Unknown error that appears security-related
    print("\nExample 3: Handle ambiguous security error")
    let unknownError = NSError(
      domain: "App.Error",
      code: 1_001,
      userInfo: [NSLocalizedDescriptionKey: "Authentication process failed with status code 401"]
    )
    securityHandler.handleSecurityError(unknownError)

    print("\n=== END OF MIXED ERROR HANDLING ===")
  }
}

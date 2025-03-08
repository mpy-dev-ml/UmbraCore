import ErrorHandlingCore
import ErrorHandlingDomains
// Removed ErrorHandlingLogging import to fix library evolution issues
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification
import ErrorHandlingProtocols
import ErrorHandlingRecovery
import Foundation

/// A sample class that demonstrates the error handling system
public class ErrorHandlingExample {
  /// Sample notification handler for demonstration purposes
  private class SampleNotificationHandler: ErrorHandlingInterfaces.ErrorNotificationProtocol {
    /// Shows notifications in the console for demonstration
    public func presentError<E: ErrorHandlingInterfaces.UmbraError>(_ error: E, recoveryOptions: [ErrorHandlingInterfaces.RecoveryOption]) {
      print("🔔 NOTIFICATION: Error from domain \(error.domain)")
      print("   Message: \(error.errorDescription)")

      if !recoveryOptions.isEmpty {
        print("   Recovery options:")
        for action in recoveryOptions {
          print("     - \(action.title)")
        }
      }

      print("")
    }

    /// Legacy method for backward compatibility
    public func present(notification: ErrorHandlingNotification.ErrorNotification) {
      print("🔔 NOTIFICATION: \(notification.title)")
      print("   Severity: \(notification.severity.rawValue)")
      print("   Message: \(notification.message)")

      if let recoveryOptions = notification.recoveryOptions {
        print("   Recovery options:")
        for action in recoveryOptions {
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
  private class SampleRecoveryProvider: ErrorHandlingInterfaces.RecoveryOptionsProvider {
    /// Provides recovery options for errors
    public func recoveryOptions<E: ErrorHandlingInterfaces.UmbraError>(for error: E) -> [ErrorHandlingInterfaces.RecoveryOption] {
      // Create recovery options based on the error
      return [
        ErrorHandlingRecovery.ErrorRecoveryOption(
          id: UUID(),
          title: "Retry",
          description: "Retry the operation",
          successLikelihood: .likely,
          isDisruptive: false
        ) {
          print("Retrying operation after error")
          // Implement retry logic here
        },
        ErrorHandlingRecovery.ErrorRecoveryOption(
          id: UUID(),
          title: "Cancel",
          description: "Cancel the operation",
          successLikelihood: .veryLikely,
          isDisruptive: false
        ) {
          print("Operation cancelled")
          // Implement cancel logic here
        }
      ]
    }
  }

  // MARK: - Example Methods

  /// Run a comprehensive example that demonstrates error handling
  @MainActor public func run() {
    // Set up the error handler
    let errorHandler = ErrorHandler.shared
    errorHandler.setNotificationHandler(SampleNotificationHandler())
    errorHandler.registerRecoveryProvider(SampleRecoveryProvider())

    print("=== ERROR HANDLING SYSTEM EXAMPLE ===\n")

    // Example 1: Handle a security error directly
    print("Example 1: Handle a security error")
    let securityError = UmbraErrors.Security.Core.invalidInput(reason: "Invalid username or password")
    // Use a locally mapped security error that conforms to UmbraError
    let mappedSecurityError = SecurityErrorMapper().mapFromTyped(securityError)
    errorHandler.handle(mappedSecurityError, severity: .critical)

    // Example 2: Simulated external security error
    print("\nExample 2: Handle an external security error")
    let externalError = NSError(
      domain: "ExternalSecurityAPI",
      code: 401,
      userInfo: [
        NSLocalizedDescriptionKey: "Authentication failed: Account is locked"
      ]
    )

    // Map the error and handle it
    let securityErrorMapper = SecurityErrorMapper()
    if let mappedError = securityErrorMapper.mapFromAny(externalError) {
      errorHandler.handle(mappedError, severity: .critical)
    } else {
      // Handle unmapped errors with an application error
      let appErrorMapper = ApplicationErrorMapper()
      let applicationError = appErrorMapper.mapFromTyped(
        UmbraErrors.Application.Core.internalError(
          reason: "Failed to map external security error"
        )
      )
      errorHandler.handle(applicationError, severity: .warning)
    }

    // Example 3: Different severity levels
    print("\nExample 3: Test different severity levels")
    let infoError = UmbraErrors.Security.Core.invalidInput(reason: "Token will expire soon")
    let mappedInfoError = SecurityErrorMapper().mapFromTyped(infoError)
    errorHandler.handle(mappedInfoError, severity: .info)

    let warningError = UmbraErrors.Security.Core.invalidInput(reason: "Suspicious login attempt detected")
    let mappedWarningError = SecurityErrorMapper().mapFromTyped(warningError)
    errorHandler.handle(mappedWarningError, severity: .warning)

    let criticalError = UmbraErrors.Security.Core.invalidKey(reason: "Master key compromised")
    let mappedCriticalError = SecurityErrorMapper().mapFromTyped(criticalError)
    errorHandler.handle(mappedCriticalError, severity: .critical)

    print("\nExample 4: Recovery options")
    let recoverableError = UmbraErrors.Security.Core.invalidInput(reason: "Session expired")
    let mappedRecoverableError = SecurityErrorMapper().mapFromTyped(recoverableError)
    errorHandler.handle(mappedRecoverableError, severity: .warning)
    
    // Example 5: Application errors
    print("\nExample 5: Application errors")
    let configError = UmbraErrors.Application.Core.configurationError(reason: "Invalid app configuration")
    let appMapper = ApplicationErrorMapper()
    let mappedConfigError = appMapper.mapFromTyped(configError)
    errorHandler.handle(mappedConfigError, severity: .warning)
    
    let initError = UmbraErrors.Application.Core.initializationError(
      component: "Database", 
      reason: "Failed to connect to database"
    )
    let mappedInitError = appMapper.mapFromTyped(initError)
    errorHandler.handle(mappedInitError, severity: .critical)
  }

  /// Demonstrates basic error handling
  @MainActor public static func demonstrateBasicErrorHandling() {
    print("=== BASIC ERROR HANDLING EXAMPLE ===\n")

    // Create a sample error
    let sampleError = UmbraErrors.Security.Core.invalidKey(reason: "Key has expired")

    // Create notification handler
    let notificationHandler = SampleNotificationHandler()

    // Create recovery provider
    let recoveryProvider = SampleRecoveryProvider()

    // Get recovery options directly without using an existential type
    let options = recoveryProvider.recoveryOptions(for: sampleError)
    
    // Create a notification with error details
    let notification = ErrorHandlingNotification.ErrorNotification(
      error: sampleError,
      title: "Security Error",
      message: sampleError.localizedDescription,
      severity: .critical,
      recoveryOptions: options
    )
    
    // Present error with recovery options
    notificationHandler.present(notification: notification)

    // Simulate selecting the retry option
    if let retryAction = options.first {
      print("User selected: \(retryAction.title)")
      Task {
        await retryAction.perform()
      }
    }

    print("\nBasic error handling demonstration complete.\n")
  }
}

// MARK: - Extensions for Demo

extension ErrorHandlingExample {
  /// Helper method to demonstrate handling of different security error types
  @MainActor public static func handleMixedSecurityErrors() {
    print("=== MIXED SECURITY ERROR HANDLING ===\n")

    // Create error handler with demo handlers
    let errorHandler = ErrorHandler.shared
    errorHandler.setNotificationHandler(SampleNotificationHandler())
    errorHandler.registerRecoveryProvider(SampleRecoveryProvider())

    // Example of handling different security error types
    let invalidKeyError = UmbraErrors.Security.Core.invalidKey(reason: "API key expired")
    let mappedInvalidKeyError = SecurityErrorMapper().mapFromTyped(invalidKeyError)
    errorHandler.handle(mappedInvalidKeyError, severity: .critical)

    let authError = UmbraErrors.Security.Core.invalidInput(reason: "Invalid credentials")
    let mappedAuthError = SecurityErrorMapper().mapFromTyped(authError)
    errorHandler.handle(mappedAuthError, severity: .warning)
    
    // Application errors
    let appMapper = ApplicationErrorMapper()
    let resourceError = UmbraErrors.Application.Core.resourceNotFound(
      resourceType: "ConfigFile", 
      identifier: "app-config.json"
    )
    let mappedResourceError = appMapper.mapFromTyped(resourceError)
    errorHandler.handle(mappedResourceError, severity: .warning)

    print("\nMixed error handling complete.\n")
  }
}

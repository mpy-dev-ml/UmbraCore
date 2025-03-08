import ErrorHandlingCore
import ErrorHandlingDomains

// Removed ErrorHandlingLogging import to fix library evolution issues
import ErrorHandling // Add this import to access the wrapper types
import ErrorHandlingCommon
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingNotification

/// Example class demonstrating the usage of the error handling system
///
/// This class provides sample implementations and usage patterns for:
/// - Setting up error notifications
/// - Registering recovery options
/// - Handling different error types
/// - Mapping errors between domains
public class ErrorHandlingExample {
  /// Sample notification handler for demonstration purposes
  private class SampleNotificationHandler: ErrorHandlingInterfaces.ErrorNotificationProtocol {
    /// Shows notifications in the console for demonstration
    public func presentError(
      _ error: some ErrorHandlingInterfaces.UmbraError,
      recoveryOptions: [ErrorHandlingInterfaces.RecoveryOption]
    ) {
      print("=== ERROR NOTIFICATION ===")
      print("Title: \(error.domain) Error")
      print("Message: \(error.errorDescription)")
      print("Severity: Critical")

      if !recoveryOptions.isEmpty {
        print("Recovery options:")
        for (index, option) in recoveryOptions.enumerated() {
          print("  \(index + 1). \(option.title)")
        }
      }

      print("=========================")
    }
  }

  /// Sample recovery provider for demonstration purposes
  private class SampleRecoveryProvider: RecoveryOptionsProvider {
    /// Provides recovery options for security errors
    public func recoveryOptions(for error: Error)
    -> [ErrorHandlingNotification.ClosureRecoveryOption]? {
      // Map to security error if possible
      if let securityError=error as? SecurityCoreErrorWrapper {
        // Provide different recovery options based on error type
        switch securityError.wrappedError {
          case .invalidKey:
            return [
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Regenerate Key",
                action: { print("Regenerating key...") }
              ),
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Try Backup Key",
                action: { print("Using backup key...") }
              )
            ]
          case .keyNotFound:
            return [
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Create New Key",
                action: { print("Creating new key...") }
              ),
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Import Key",
                action: { print("Importing key...") }
              )
            ]
          default:
            return [
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Retry",
                action: { print("Retrying operation...") }
              ),
              ErrorHandlingNotification.ClosureRecoveryOption(
                title: "Cancel",
                action: { print("Operation cancelled") }
              )
            ]
        }
      }

      // Default recovery options for other error types
      return [
        ErrorHandlingNotification.ClosureRecoveryOption(
          title: "OK",
          action: { print("Acknowledged") }
        )
      ]
    }
  }

  /// Run a demonstration of the error handling system
  @MainActor
  public func run() {
    // Set up the error handler
    let errorHandler=ErrorHandler.shared
    errorHandler.setNotificationHandler(SampleNotificationHandler())
    errorHandler.registerRecoveryProvider(SampleRecoveryProvider())

    print("Starting error handling demonstration...")

    // Create a security error for demonstration
    let securityError=UmbraErrors.Security.Core.invalidKey(reason: "Missing encryption key")

    // Manually create a wrapped error
    let wrappedError=SecurityCoreErrorWrapper(securityError)

    // Report the error
    Task {
      await errorHandler.reportError(wrappedError)
      print("Security error handled.")

      // Demonstrate error mapping
      demonstrateErrorMapping()
    }
  }

  private func demonstrateErrorMapping() {
    print("\nDemonstrating error mapping...")

    // Create a mock external error
    struct ExternalError: Error, CustomStringConvertible {
      let message: String
      var description: String { message }
    }

    let externalError=ExternalError(message: "External API connection failed")

    // Try to map to security error
    // Remove the try? since it doesn't throw
    if let securityMapper=SecurityErrorMapper() {
      // Check if the map method exists
      if let securityError=securityMapper.mapFromAny(externalError) {
        print("Successfully mapped to security error: \(securityError)")
      } else {
        // Handle unmapped errors with an application error
        let coreAppError=UmbraErrors.Application.Core.internalError(
          reason: "Failed to map external security error"
        )
        let wrappedAppError=ApplicationCoreErrorWrapper(coreAppError)
        print("Mapped to application error: \(wrappedAppError.errorDescription)")
      }
    } else {
      print("Failed to create security mapper")
    }
  }

  /// Demonstrate direct usage of error mapping and handling
  public func demonstrateDirectUsage() {
    // Create a sample security error
    let coreError=UmbraErrors.Security.Core.invalidKey(reason: "Key has expired")

    // Wrap the error in our conforming wrapper
    let securityError=SecurityCoreErrorWrapper(coreError)

    // Handle the wrapped error
    print("\nDemonstrating direct error handling...")
    print("Error domain: \(securityError.domain)")
    print("Error code: \(securityError.code)")
    print("Error description: \(securityError.errorDescription)")
    print("Recovery suggestion: \(securityError.recoverySuggestion)")

    // Add context to the error
    let contextualError=securityError.with(
      context: ErrorHandlingCommon.ErrorContext(
        source: "KeyManager",
        operation: "validateKey",
        details: "Failed to validate key during authentication"
      )
    )

    print("\nContextual error information:")
    print("Source: \(contextualError.context.source)")
    print("Operation: \(contextualError.context.operation)")
    print("Details: \(contextualError.context.details ?? "None")")
  }
}

// MARK: - Extensions for Demo

extension ErrorHandlingExample {
  /// Create an example notification for demonstration
  private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
    let securityError=SecurityCoreErrorWrapper(
      UmbraErrors.Security.Core.invalidKey(reason: "Expired key")
    )

    return ErrorHandlingNotification.ErrorNotification(
      error: securityError,
      title: "Security Alert",
      message: "Security key has expired",
      recoveryOptions: []
    )
  }
}

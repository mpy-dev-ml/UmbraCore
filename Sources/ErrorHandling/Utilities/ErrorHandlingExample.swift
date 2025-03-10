import ErrorHandling // Add this import to access the wrapper types
import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification

// Use the direct protocol name from ErrorHandling.Interfaces
// Define the full type name instead of using a typealias

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
  private final class SampleRecoveryProvider: RecoveryOptionsProvider {
    /// Provides recovery options for security errors
    public func recoveryOptions(for error: some Error) -> [RecoveryOption]? {
      // Map to security error if possible
      if let securityError = error as? SecurityCoreErrorWrapper {
        // Provide different recovery options based on error type
        switch securityError.wrappedError {
          case .encryptionFailed, .decryptionFailed:
            return [
              ErrorRecoveryOption(
                title: "Try Again",
                handler: {
                  print("Retrying cryptographic operation...")
                }
              ),
              ErrorRecoveryOption(
                title: "Use Alternative Method",
                handler: {
                  print("Using alternative cryptographic method...")
                }
              )
            ]
          case .invalidKey:
            return [
              ErrorRecoveryOption(
                title: "Regenerate Key",
                handler: {
                  print("Regenerating security key...")
                }
              ),
              ErrorRecoveryOption(
                title: "Import Existing Key",
                handler: {
                  print("Importing existing key...")
                }
              )
            ]
          case .hashVerificationFailed:
            return [
              ErrorRecoveryOption(
                title: "Download Again",
                handler: {
                  print("Downloading file again...")
                }
              ),
              ErrorRecoveryOption(
                title: "Ignore Warning",
                handler: {
                  print("Ignoring integrity warning...")
                }
              )
            ]
          default:
            return [
              ErrorRecoveryOption(
                title: "Retry Operation",
                handler: {
                  print("Retrying operation...")
                }
              )
            ]
        }
      }

      // Default recovery options for unknown errors
      return [
        ErrorRecoveryOption(
          title: "Retry",
          handler: {
            print("Retrying operation...")
          }
        ),
        ErrorRecoveryOption(
          title: "Cancel",
          handler: {
            print("Operation cancelled")
          }
        )
      ]
    }
  }

  /// Run a demonstration of the error handling system
  @MainActor
  public func run() {
    // Set up the error handler
    let errorHandler = ErrorHandler.shared
    errorHandler.setNotificationHandler(SampleNotificationHandler())
    errorHandler.registerRecoveryProvider(SampleRecoveryProvider())

    print("Starting error handling demonstration...")

    // Create a security error for demonstration
    let securityError = UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Missing encryption key")

    // Manually create a wrapped error
    let wrappedError = SecurityCoreErrorWrapper(securityError)

    // Report the error
    Task {
      await errorHandler.handle(wrappedError)
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

    let externalError = ExternalError(message: "External API connection failed")

    // Try to map to security error
    let securityMapper = SecurityErrorMapper()

    // Map external error to core error
    if let mappedError = securityMapper.mapToCoreError(externalError) {
      print("Successfully mapped to security error: \(mappedError)")
    } else {
      // Handle unmapped errors with an application error
      let coreAppError = UmbraErrors.Application.Core.operationFailed(
        operation: "External API",
        reason: "Authentication required"
      )
      let wrappedAppError = ApplicationCoreErrorWrapper(coreAppError)
      print("Mapped to application error: \(wrappedAppError.errorDescription)")
    }
  }

  /// Demonstrate direct usage of error mapping and handling
  public func demonstrateDirectUsage() {
    // Create a sample security error
    let coreError = UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Key has expired")

    // Wrap the error in our conforming wrapper
    let securityError = SecurityCoreErrorWrapper(coreError)

    // Handle the wrapped error
    print("\nDemonstrating direct error handling...")
    print("Error domain: \(securityError.domain)")
    print("Error code: \(securityError.code)")
    print("Error description: \(securityError.errorDescription)")
    print("Recovery suggestion: \(securityError.recoverySuggestion ?? "None available")")

    // Add context to the error
    let contextualError = securityError.with(
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
    let securityError = SecurityCoreErrorWrapper(
      UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Expired key")
    )

    return ErrorHandlingNotification.ErrorNotification(
      error: securityError,
      title: "Security Alert",
      message: "Security key has expired",
      recoveryOptions: []
    )
  }
}

import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification
import Foundation

/// Provides recovery options and handlers for security-related errors.
///
/// # Overview
/// This file contains recovery options and handlers for various security errors that may occur
/// within the UmbraCore framework. It provides a consistent approach to error recovery by:
///
/// - Defining recovery options for each error type
/// - Providing handler closures that implement the recovery actions
/// - Supporting localisation for user-facing error messages and recovery options
///
/// # Usage
/// ```swift
/// // Get recovery options for a security error
/// let error = UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Key has expired")
/// let recoveryProvider = SecurityErrorRecovery()
/// let options = recoveryProvider.recoveryOptions(for: error)
///
/// // Present options to the user and handle selection
/// if let selectedOption = presentOptionsToUser(options) {
///     let handler = options.actions[selectedOption].handler
///     handler()
/// }
/// ```
///
/// # Important Notes
/// - All handler closures must return `Void`, not `Bool`
/// - Always include `@unknown default` cases in switch statements for Swift 6 compatibility
/// - When adding new error cases, add corresponding recovery options
/// - Use British English for user-facing strings (e.g., "Authorisation" not "Authorization")
/// - Recovery options should be ordered from most to least recommended

/// A wrapper for Security Core errors to maintain type safety
public struct SecurityCoreErrorWrapper: Error, Sendable {
  /// The wrapped error
  public let wrappedError: UmbraErrors.GeneralSecurity.Core

  /// Initialise with a security error
  /// - Parameter error: The error to wrap
  public init(_ error: UmbraErrors.GeneralSecurity.Core) {
    wrappedError=error
  }
}

/// A utility class for generating recovery options for security errors
/// This class separates recovery functionality from error handling
public final class SecurityErrorRecovery: @unchecked Sendable, RecoveryOptionsProvider {
  /// The shared instance for the recovery service
  public static let shared=SecurityErrorRecovery()

  /// The error mapper used to transform errors
  private let errorMapper=SecurityErrorMapper()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Implement RecoveryOptionsProvider protocol
  public func recoveryOptions(for error: Error) -> RecoveryOptions? {
    // Try to map to our SecurityCoreErrorWrapper type
    if let securityError=error as? SecurityCoreErrorWrapper {
      // Return recovery options based on the security error type
      return createRecoveryOptions(for: securityError)
    } else if let securityCoreError=error as? UmbraErrors.GeneralSecurity.Core {
      // Wrap the core error and process it
      let wrapper=SecurityCoreErrorWrapper(securityCoreError)
      return createRecoveryOptions(for: wrapper)
    } else {
      // Not a security error, or couldn't be mapped
      return nil
    }
  }

  /// Creates recovery options for a security error
  /// - Parameter error: The security error to create options for
  private func createRecoveryOptions(for error: SecurityCoreErrorWrapper) -> RecoveryOptions {
    // Create appropriate actions based on the error type
    var actions: [RecoveryAction]=[]

    switch error.wrappedError {
      case .encryptionFailed, .decryptionFailed:
        // Cryptographic operation failures
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            handler: {
              print("User chose to retry cryptographic operation")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "alternative",
            title: "Use Alternative Method",
            handler: {
              print("User chose to use alternative cryptographic method")
            }
          )
        )

      case .invalidKey:
        // Key validation failures
        actions.append(
          RecoveryAction(
            id: "regenerate",
            title: "Regenerate Key",
            isDefault: true,
            handler: {
              print("User chose to regenerate key")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "import",
            title: "Import Existing Key",
            handler: {
              print("User chose to import existing key")
            }
          )
        )

      case .hashVerificationFailed:
        // Data integrity failures
        actions.append(
          RecoveryAction(
            id: "redownload",
            title: "Download Again",
            isDefault: true,
            handler: {
              print("User chose to download file again")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "ignore",
            title: "Ignore Warning",
            handler: {
              print("User chose to ignore integrity warning")
            }
          )
        )

      case .invalidInput:
        // Input validation failures
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            isDefault: true,
            handler: {
              print("User chose to retry with different input")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "help",
            title: "Get Help",
            handler: {
              print("User chose to get help with input format")
            }
          )
        )

      case .internalError:
        // Internal errors
        actions.append(
          RecoveryAction(
            id: "report",
            title: "Report Issue",
            isDefault: true,
            handler: {
              print("User chose to report the issue")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            handler: {
              print("User chose to retry operation")
            }
          )
        )

      case .keyGenerationFailed:
        // Key generation failures
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            isDefault: true,
            handler: {
              print("User chose to retry key generation")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "import",
            title: "Import Existing Key",
            handler: {
              print("User chose to import existing key")
            }
          )
        )

      case .randomGenerationFailed:
        // Random generation failures
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            isDefault: true,
            handler: {
              print("User chose to retry random generation")
            }
          )
        )

      case .storageOperationFailed:
        // Storage operation failures
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            isDefault: true,
            handler: {
              print("User chose to retry storage operation")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "alternative",
            title: "Use Alternative Storage",
            handler: {
              print("User chose to use alternative storage")
            }
          )
        )

      case let .timeout(operation):
        // Timeout errors
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try \(operation) Again",
            isDefault: true,
            handler: {
              print("User chose to retry operation: \(operation)")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "cancel",
            title: "Cancel",
            handler: {
              print("User chose to cancel operation: \(operation)")
            }
          )
        )

      case .serviceError:
        // Service errors
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Try Again",
            isDefault: true,
            handler: {
              print("User chose to retry service operation")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "report",
            title: "Report Issue",
            handler: {
              print("User chose to report service issue")
            }
          )
        )

      case .notImplemented:
        // Not implemented errors
        actions.append(
          RecoveryAction(
            id: "cancel",
            title: "Cancel",
            isDefault: true,
            handler: {
              print("User chose to cancel operation")
            }
          )
        )
        actions.append(
          RecoveryAction(
            id: "request",
            title: "Request Feature",
            handler: {
              print("User chose to request feature implementation")
            }
          )
        )

      @unknown default:
        // Handle any future cases we don't know about yet
        actions.append(
          RecoveryAction(
            id: "default",
            title: "Continue",
            handler: {
              print("User chose default action for unknown error")
            }
          )
        )
    }

    // Create the recovery options with the appropriate title and message
    let (title, message)=getTitleAndMessage(for: error.wrappedError)
    return RecoveryOptions(
      actions: actions,
      title: title,
      message: message
    )
  }

  /// Gets the title and message for a security error
  /// - Parameter error: The error to get the title and message for
  /// - Returns: A tuple containing the title and message
  private func getTitleAndMessage(for error: UmbraErrors.GeneralSecurity.Core) -> (String, String) {
    switch error {
      case .encryptionFailed:
        return ("Encryption Failed", "Could not encrypt data")
      case .decryptionFailed:
        return ("Decryption Failed", "Could not decrypt data")
      case .keyGenerationFailed:
        return ("Key Generation Failed", "Could not generate key")
      case .invalidKey:
        return ("Invalid Key", "The key is invalid")
      case .hashVerificationFailed:
        return ("Hash Verification Failed", "Could not verify hash")
      case .randomGenerationFailed:
        return ("Random Generation Failed", "Could not generate random data")
      case .invalidInput:
        return ("Invalid Input", "The input is invalid")
      case .storageOperationFailed:
        return ("Storage Operation Failed", "Could not complete storage operation")
      case .timeout:
        return ("Timeout", "The operation timed out")
      case .serviceError:
        return ("Service Error", "A service error occurred")
      case .internalError:
        return ("Internal Error", "An internal error occurred")
      case .notImplemented:
        return ("Not Implemented", "This feature is not implemented")
      @unknown default:
        return ("Security Error", "An unknown security error occurred")
    }
  }

  /// Example of how to use the recovery options
  /// - Parameter sampleError: A sample error to get recovery options for
  public func exampleUsage(sampleError: UmbraErrors.GeneralSecurity.Core) {
    if let options=recoveryOptions(for: sampleError) {
      print("Recovery options for \(sampleError):")
      print("Title: \(options.title ?? "No title")")
      print("Message: \(options.message ?? "No message")")
      print("Actions:")
      for action in options.actions {
        print("- \(action.title)\(action.isDefault ? " (Default)" : "")")
      }
    } else {
      print("No recovery options available for \(sampleError)")
    }
  }
}

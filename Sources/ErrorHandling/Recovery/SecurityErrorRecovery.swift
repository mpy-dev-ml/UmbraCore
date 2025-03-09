import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels
import ErrorHandlingNotification
import Foundation

/// A wrapper for Security Core errors to maintain type safety
public struct SecurityCoreErrorWrapper: Error, Sendable {
  /// The wrapped error
  public let wrappedError: UmbraErrors.Security.Core
  
  /// Initialise with a security error
  /// - Parameter error: The error to wrap
  public init(_ error: UmbraErrors.Security.Core) {
    self.wrappedError = error
  }
}

/// A utility class for generating recovery options for security errors
/// This class separates recovery functionality from error handling
public final class SecurityErrorRecovery: @unchecked Sendable, RecoveryOptionsProvider {
  /// The shared instance for the recovery service
  public static let shared = SecurityErrorRecovery()

  /// The error mapper used to transform errors
  private let errorMapper = SecurityErrorMapper()

  /// Private initialiser to enforce singleton pattern
  private init() {}

  /// Implement RecoveryOptionsProvider protocol
  public func recoveryOptions(for error: Error) -> RecoveryOptions? {
    // Try to map to our SecurityCoreErrorWrapper type
    if let securityError = error as? SecurityCoreErrorWrapper {
      // Return recovery options based on the security error type
      return createRecoveryOptions(for: securityError)
    } else if let securityCoreError = error as? UmbraErrors.Security.Core {
      // Wrap the core error and process it
      let wrapper = SecurityCoreErrorWrapper(securityCoreError)
      return createRecoveryOptions(for: wrapper)
    } else {
      // Not a security error, or couldn't be mapped
      return nil
    }
  }
  
  /// Creates recovery options for a security error
  /// - Parameter error: The security error to create options for
  /// - Returns: Recovery options suitable for the error
  private func createRecoveryOptions(for error: SecurityCoreErrorWrapper) -> RecoveryOptions {
    // Create appropriate actions based on the error type
    var actions: [RecoveryAction] = []
    
    switch error.wrappedError {
      case .authenticationFailed(let reason):
        actions.append(
          RecoveryAction(
            id: "retry_auth",
            title: "Try Again",
            description: "Retry with different credentials",
            isDisruptive: false,
            isDefault: true,
            handler: { /* Implementation to retry authentication */ }
          )
        )
        
        actions.append(
          RecoveryAction(
            id: "reset_credentials",
            title: "Reset Credentials",
            description: "Reset your security credentials",
            isDisruptive: true,
            isDefault: false,
            handler: { /* Implementation to reset credentials */ }
          )
        )
        
      case .encryptionFailed(let reason):
        actions.append(
          RecoveryAction(
            id: "alt_algorithm",
            title: "Try Alternate Algorithm",
            description: "Attempt the operation with a different cryptographic algorithm",
            isDisruptive: false,
            isDefault: true,
            handler: { /* Implementation to use alternate algorithm */ }
          )
        )
        
      case .decryptionFailed(let reason):
        actions.append(
          RecoveryAction(
            id: "verify_key",
            title: "Verify Encryption Key",
            description: "Check if you're using the correct encryption key",
            isDisruptive: false,
            isDefault: true,
            handler: { /* Implementation to verify key */ }
          )
        )
        
      case .tamperedData:
        actions.append(
          RecoveryAction(
            id: "restore_backup",
            title: "Restore from Backup",
            description: "Restore data from a secure backup",
            isDisruptive: true,
            isDefault: true,
            handler: { /* Implementation to restore from backup */ }
          )
        )
        
      default:
        // Add general retry option for other cases
        actions.append(
          RecoveryAction(
            id: "retry",
            title: "Retry",
            description: "Try the operation again",
            isDisruptive: false,
            isDefault: true,
            handler: { /* Generic retry implementation */ }
          )
        )
    }
    
    // Always add a cancel option
    actions.append(
      RecoveryAction(
        id: "cancel",
        title: "Cancel",
        description: "Cancel the operation",
        isDisruptive: false,
        isDefault: false,
        handler: { /* Cancel implementation */ }
      )
    )
    
    // Create appropriate title and message
    let title = "Security Error"
    let message = "A security error occurred: \(error.wrappedError)"
    
    return RecoveryOptions(
      actions: actions,
      title: title,
      message: message
    )
  }
  
  /// Helper to get user-friendly title and message for security errors
  private func getTitleAndMessage(for error: UmbraErrors.Security.Core) -> (String, String) {
    switch error {
      case let .encryptionFailed(reason):
        ("Encryption Failed", "Could not encrypt data: \(reason)")
      case let .decryptionFailed(reason):
        ("Decryption Failed", "Could not decrypt data: \(reason)")
      case let .keyGenerationFailed(reason):
        ("Key Generation Failed", "Could not generate cryptographic key: \(reason)")
      case let .invalidKey(reason):
        ("Invalid Key", "The cryptographic key is invalid: \(reason)")
      case let .hashVerificationFailed(reason):
        ("Verification Failed", "Data integrity check failed: \(reason)")
      case let .randomGenerationFailed(reason):
        ("Random Generation Failed", "Could not generate secure random data: \(reason)")
      case let .invalidInput(reason):
        ("Invalid Input", "The input data is invalid: \(reason)")
      case let .storageOperationFailed(reason):
        ("Storage Failed", "Could not complete secure storage operation: \(reason)")
      case let .timeout(operation):
        ("Operation Timeout", "The security operation '\(operation)' timed out")
      case let .serviceError(code, reason):
        ("Security Service Error", "Error \(code): \(reason)")
      case let .internalError(reason):
        ("Internal Error", "An internal security error occurred: \(reason)")
      case let .notImplemented(feature):
        ("Not Implemented", "The security feature '\(feature)' is not implemented")
    }
  }
  
  /// Additional recovery options implementations
  private func createKeyGenerationRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    // Implementation similar to other methods
    return createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }
  
  private func createIntegrityRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }
  
  private func createStorageRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }
  
  private func createTimeoutRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }
  
  private func createServiceRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }
  
  private func createNotImplementedRecoveryOptions(
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return [
      ErrorRecoveryOption(
        title: "OK",
        description: "Acknowledge this feature is not available",
        recoveryAction: { await Task { cancelAction() }.value }
      )
    ]
  }
  
  private func createGenericSecurityRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    return [
      ErrorRecoveryOption(
        title: "Try Again",
        description: "Retry the operation",
        recoveryAction: { await Task { retryAction() }.value }
      ),
      ErrorRecoveryOption(
        title: "Cancel",
        description: "Cancel the operation",
        recoveryAction: { await Task { cancelAction() }.value }
      )
    ]
  }
}

/// Extension to provide usage examples
extension SecurityErrorRecovery {
  /// Example usage of the security error recovery
  public func exampleUsage() {
    // Create a security error
    let securityError = UmbraErrors.Security.Core.invalidInput(reason: "Incorrect password format")
    
    // Get recovery options
    let options = recoveryOptions(for: securityError)
    
    // Process the options (just for example)
    if let options = options {
      print("Recovery options for \(securityError):")
      for action in options.actions {
        print("  \(action.title): \(action.description ?? "")")
      }
    }
  }
}

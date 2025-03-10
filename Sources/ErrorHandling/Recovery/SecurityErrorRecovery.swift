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
    var actions: [RecoveryAction]=[]

    switch error.wrappedError {
      case .authenticationFailed(_):
        actions.append(
          RecoveryAction(
            id: "retry-auth",
            title: "Try Authentication Again",
            description: "Retry with different credentials",
            isDefault: true,
            handler: { /* Implementation to retry authentication */ }
          )
        )

      case .encryptionFailed(_):
        actions.append(
          RecoveryAction(
            id: "retry-encryption",
            title: "Retry Encryption",
            description: "Try encryption operation again",
            isDefault: true,
            handler: { /* Implementation to retry encryption */ }
          )
        )

      case .decryptionFailed(_):
        actions.append(
          RecoveryAction(
            id: "retry-decryption",
            title: "Retry Decryption",
            description: "Try decryption operation again",
            isDefault: true,
            handler: { /* Implementation to retry decryption */ }
          )
        )

      case .hashingFailed(_):
        actions.append(
          RecoveryAction(
            id: "retry-hash",
            title: "Retry Hashing",
            description: "Try hashing operation again",
            isDefault: true,
            handler: { /* Implementation to retry hashing */ }
          )
        )

      case .signatureInvalid(_):
        actions.append(
          RecoveryAction(
            id: "retry-signature",
            title: "Retry Signature Verification",
            description: "Try again with a different signature",
            isDefault: true,
            handler: { /* Implementation to retry signature verification */ }
          )
        )

      case .certificateInvalid(_):
        actions.append(
          RecoveryAction(
            id: "trust-cert",
            title: "Trust Certificate",
            description: "Trust this certificate for the current session",
            isDefault: true,
            handler: { /* Implementation to trust certificate */ }
          )
        )

      case .certificateExpired(_):
        actions.append(
          RecoveryAction(
            id: "ignore-expiry",
            title: "Ignore Expiry",
            description: "Continue despite the expired certificate",
            isDefault: true,
            handler: { /* Implementation to ignore certificate expiry */ }
          )
        )

      case .policyViolation(let policy, _):
        actions.append(
          RecoveryAction(
            id: "override-policy",
            title: "Override Policy",
            description: "Override policy '\(policy)' for this operation",
            isDefault: true,
            handler: { /* Implementation to override policy */ }
          )
        )

      case .authorizationFailed(_):
        actions.append(
          RecoveryAction(
            id: "retry-auth",
            title: "Try Again",
            description: "Retry with different authorisation",
            isDefault: true,
            handler: { /* Implementation to retry authorisation */ }
          )
        )

      case .insufficientPermissions(let resource, let requiredPermission):
        actions.append(
          RecoveryAction(
            id: "request_permission",
            title: "Request Permission",
            description: "Request the required permission '\(requiredPermission)' for '\(resource)'",
            isDefault: true,
            handler: { /* Implementation to request permission */ }
          )
        )

      // Handle any additional cases that might be added in the future
      default:
        actions.append(
          RecoveryAction(
            id: "report_security_error",
            title: "Report Error",
            description: "Report this security issue to support",
            isDefault: true,
            handler: { /* Implementation to report error */ }
          )
        )
    }

    // Always add a cancel option
    actions.append(
      RecoveryAction(
        id: "cancel",
        title: "Cancel",
        description: "Cancel the operation",
        isDefault: false,
        handler: { /* Cancel implementation */ }
      )
    )

    // Create appropriate title and message
    let (title, message)=getTitleAndMessage(for: error.wrappedError)

    return RecoveryOptions(
      actions: actions,
      title: title,
      message: message
    )
  }

  /// Helper to get user-friendly title and message for security errors
  private func getTitleAndMessage(for error: UmbraErrors.Security.Core) -> (String, String) {
    switch error {
      case .encryptionFailed(_):
        ("Encryption Failed", "Could not encrypt data")
      case .decryptionFailed(_):
        ("Decryption Failed", "Could not decrypt data")
      case .hashingFailed(_):
        ("Hashing Failed", "Could not hash data")
      case .signatureInvalid(_):
        ("Invalid Signature", "The cryptographic signature is invalid")
      case .certificateInvalid(_):
        ("Invalid Certificate", "The certificate is invalid")
      case .certificateExpired(_):
        ("Certificate Expired", "The certificate has expired")
      case .policyViolation(let policy, _):
        ("Security Policy Violation", "Operation violates security policy '\(policy)'")
      case .authenticationFailed(_):
        ("Authentication Failed", "Authentication failed")
      case .authorizationFailed(_):
        ("Authorisation Failed", "Authorisation failed")
      case .insufficientPermissions(let resource, let requiredPermission):
        ("Insufficient Permissions", "You don't have permission to access '\(resource)': \(requiredPermission) required")
      default:
        ("Security Error", "A security error occurred")
    }
  }

  /// Additional recovery options implementations
  private func createKeyGenerationRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    // Implementation similar to other methods
    createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }

  private func createIntegrityRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }

  private func createStorageRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }

  private func createTimeoutRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }

  private func createServiceRecoveryOptions(
    _ retryAction: @escaping @Sendable () -> Void,
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    createGenericSecurityRecoveryOptions(retryAction, cancelAction)
  }

  private func createNotImplementedRecoveryOptions(
    _ cancelAction: @escaping @Sendable () -> Void
  ) -> [any RecoveryOption] {
    [
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
    [
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
    let securityError = UmbraErrors.Security.Core.authenticationFailed(reason: "Incorrect password")

    // Get recovery options
    let options=recoveryOptions(for: securityError)

    // Process the options (just for example)
    if let options {
      print("Recovery options for \(securityError):")
      for action in options.actions {
        print("  \(action.title): \(action.description ?? "")")
      }
    }
  }
}

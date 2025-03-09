import ErrorHandlingCommon
import ErrorHandlingInterfaces
import Foundation

/// Provides recovery options for security errors
@MainActor
public final class SecurityErrorRecoveryService: ErrorRecoveryService {
  /// Shared instance
  public static let shared = SecurityErrorRecoveryService()
  
  /// Recovery providers registered with this service
  private var providers: [RecoveryOptionsProvider] = []

  /// Private initialiser to enforce singleton pattern
  private init() {
    // Register with the recovery registry
    ErrorRecoveryRegistry.shared.register(self)
  }
  
  /// Register a provider of recovery options
  /// - Parameter provider: The provider to register
  public func registerProvider(_ provider: any RecoveryOptionsProvider) {
    providers.append(provider)
  }
  
  /// Get available recovery options for an error
  /// - Parameter error: The error to get recovery options for
  /// - Returns: Available recovery options
  public func getRecoveryOptions(for error: some Error) -> [any RecoveryOption] {
    // If it's not a security error, return no options
    guard isSecurity(error: error) else {
      return []
    }
    
    // Collect options from all providers
    var allOptions: [any RecoveryOption] = []
    
    // Add options from registered providers
    for provider in providers {
      if let options = provider.recoveryOptions(for: error) {
        allOptions.append(contentsOf: options.actions.map { action in
          return ErrorRecoveryOption(
            title: action.title,
            description: action.description,
            isDisruptive: action.isDisruptive,
            recoveryAction: { try await action.perform() }
          )
        })
      }
    }
    
    // If no providers handled it, use built-in recovery options
    if allOptions.isEmpty {
      allOptions = defaultRecoveryOptions(for: error)
    }
    
    return allOptions
  }
  
  /// Attempt to automatically recover from an error
  /// - Parameters:
  ///   - error: The error to recover from
  ///   - context: Additional context for recovery
  /// - Returns: Whether recovery was successful
  public func attemptRecovery(from error: some Error, context: [String: Any]?) async -> Bool {
    // Only attempt recovery for security errors
    guard isSecurity(error: error) else {
      return false
    }
    
    // Get recovery options
    let options = getRecoveryOptions(for: error)
    
    // Try each option in order
    for option in options {
      // Skip options marked as disruptive (they require user interaction)
      guard !option.isDisruptive else {
        continue
      }
      
      // Attempt recovery with this option
      await option.perform()
      
      // Since we don't have a way to know if the option succeeded,
      // we'll assume the first non-disruptive option worked
      return true
    }
    
    // No recovery option succeeded
    return false
  }

  /// Determines if an error is a security-related error
  /// - Parameter error: The error to check
  /// - Returns: Whether this is a security error
  private func isSecurity(error: some Error) -> Bool {
    if let umbraError = error as? UmbraError {
      return umbraError.domain.contains("Security")
    }
    return false
  }
  
  /// Provides default recovery options for security errors
  /// - Parameter error: The error to provide options for
  /// - Returns: Array of recovery options
  private func defaultRecoveryOptions(for error: some Error) -> [any RecoveryOption] {
    var options: [any RecoveryOption] = []
    
    // Try to extract error code for specific handling
    let errorCode = extractErrorCode(from: error)
    
    // Handle specific security error types based on error code
    switch errorCode {
      case "authentication_failed":
        options.append(createRetryAuthenticationOption())
        options.append(createResetCredentialsOption())
        
      case "authorization_failed":
        options.append(createRequestPermissionsOption())
        
      case "crypto_operation_failed":
        options.append(createRetryWithAlternateAlgorithmOption())
        
      case "tampered_data":
        options.append(createRestoreFromBackupOption())
        
      case "connection_failed":
        options.append(createRetryConnectionOption())
        
      default:
        // Add a generic option for unhandled security errors
        options.append(createReportSecurityIssueOption())
    }
    
    // Always add a generic retry option
    if !options.contains(where: { $0.title == "Retry" }) {
      options.append(
        ErrorRecoveryOption(
          title: "Retry",
          description: "Retry the operation that failed",
          recoveryAction: { /* Implementation would depend on the error */ }
        )
      )
    }
    
    return options
  }
  
  /// Extract error code from an error
  /// - Parameter error: The error to extract from
  /// - Returns: Error code string
  private func extractErrorCode(from error: some Error) -> String {
    if let umbraError = error as? UmbraError {
      return umbraError.code
    }
    return "unknown"
  }
  
  // MARK: - Recovery Option Factories
  
  /// Creates a recovery option for retrying authentication
  private func createRetryAuthenticationOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "E2A94E8F-8543-4F5B-B26E-346FB9442E72"),
      title: "Try Again",
      description: "Retry with different credentials",
      recoveryAction: { /* Implementation would authenticate again */ }
    )
  }
  
  /// Creates a recovery option for resetting credentials
  private func createResetCredentialsOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "7AB3CD12-0987-4321-ABCD-1234EFGH5678"),
      title: "Reset Credentials",
      description: "Reset your password or other credentials",
      isDisruptive: true,
      recoveryAction: { /* Implementation would reset credentials */ }
    )
  }
  
  /// Creates a recovery option for requesting permissions
  private func createRequestPermissionsOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "F12A3456-7890-ABCD-EF12-34567890ABCD"),
      title: "Request Access",
      description: "Request permission from an administrator",
      isDisruptive: true,
      recoveryAction: { /* Implementation would request permissions */ }
    )
  }
  
  /// Creates a recovery option for using alternate crypto algorithm
  private func createRetryWithAlternateAlgorithmOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "9876FEDC-BA09-8765-4321-0FEDCBA98765"),
      title: "Try Alternate Algorithm",
      description: "Attempt the operation with a different cryptographic algorithm",
      recoveryAction: { /* Implementation would use alternate algorithm */ }
    )
  }
  
  /// Creates a recovery option for restoring from backup
  private func createRestoreFromBackupOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "54321ABC-DEF9-8765-4321-ABCDEF123456"),
      title: "Restore from Backup",
      description: "Attempt to restore data from a recent backup",
      isDisruptive: true,
      recoveryAction: { /* Implementation would restore from backup */ }
    )
  }
  
  /// Creates a recovery option for retrying connection
  private func createRetryConnectionOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "ABCDEF12-3456-7890-ABCD-EF1234567890"),
      title: "Retry Connection",
      description: "Attempt to reestablish the secure connection",
      recoveryAction: { /* Implementation would retry connection */ }
    )
  }
  
  /// Creates a recovery option for reporting security issues
  private func createReportSecurityIssueOption() -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      id: UUID(uuidString: "1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D"),
      title: "Report Issue",
      description: "Report this security issue to the support team",
      isDisruptive: true,
      recoveryAction: { /* Implementation would report the issue */ }
    )
  }
}

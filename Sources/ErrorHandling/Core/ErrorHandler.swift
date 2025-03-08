import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingModels
import Foundation

/// Main error handler for the UmbraCore framework
@MainActor
public final class ErrorHandler {
  /// Shared instance of the error handler
  @MainActor
  public static let shared = ErrorHandler()

  /// The logger used for error logging
  private var logger: ErrorLoggingProtocol?

  /// The notification handler for presenting errors to the user
  private var notificationHandler: ErrorNotificationProtocol?

  /// Registered recovery options providers
  private var recoveryProviders: [RecoveryOptionsProvider]

  /// Private initialiser to enforce singleton pattern
  private init() {
    recoveryProviders = []
  }

  /// Set the logger to use for error logging
  /// - Parameter logger: The logger to use
  public func setLogger(_ logger: ErrorLoggingProtocol) {
    self.logger = logger
  }

  /// Set the notification handler to use for presenting errors
  /// - Parameter handler: The notification handler to use
  public func setNotificationHandler(_ handler: ErrorNotificationProtocol) {
    notificationHandler = handler
  }

  /// Register a recovery options provider
  /// - Parameter provider: The provider to register
  public func registerRecoveryProvider(_ provider: RecoveryOptionsProvider) {
    recoveryProviders.append(provider)
  }

  /// Handle an error by logging it and presenting it to the user if appropriate
  /// - Parameters:
  ///   - error: The error to handle
  ///   - severity: The severity of the error
  ///   - file: Source file (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  public func handle(
    _ error: some UmbraError,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    // Create a source object for the error
    let source = ErrorSource(file: file, function: function, line: line)

    // Enrich the error with source information
    let enrichedError = error.with(source: source)

    // Log the error
    logger?.log(error: enrichedError, severity: severity)

    // Present error to the user if appropriate and notification handler is set
    if severity.shouldNotify, let notificationHandler {
      // Collect recovery options from all providers
      let recoveryOptions = recoveryProviders.flatMap {
        $0.recoveryOptions(for: enrichedError)
      }

      // Present the error
      notificationHandler.presentError(enrichedError, recoveryOptions: recoveryOptions)
    }
  }

  /// Get recovery options for an error from all registered providers
  /// - Parameter error: The error to get recovery options for
  /// - Returns: Array of recovery options
  public func recoveryOptions(for error: some UmbraError) -> [RecoveryOption] {
    recoveryProviders.flatMap { $0.recoveryOptions(for: error) }
  }
}

/// Extension for convenience methods targeting specific error types
extension ErrorHandler {
  /// Handle a security error
  /// - Parameters:
  ///   - error: The security error to handle
  ///   - severity: The severity of the error
  ///   - file: Source file (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  public func handleSecurity(
    _ error: ErrorHandlingDomains.SecurityError,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    handle(error, severity: severity, file: file, function: function, line: line)
  }

  /// Handle a repository error
  /// - Parameters:
  ///   - error: The repository error to handle
  ///   - severity: The severity of the error
  ///   - file: Source file (auto-filled by the compiler)
  ///   - function: Function name (auto-filled by the compiler)
  ///   - line: Line number (auto-filled by the compiler)
  public func handleRepository(
    _ error: ErrorHandlingDomains.RepositoryError,
    severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    handle(error, severity: severity, file: file, function: function, line: line)
  }
}

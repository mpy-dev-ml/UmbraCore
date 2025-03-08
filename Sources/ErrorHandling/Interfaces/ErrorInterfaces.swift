import ErrorHandlingCommon
import Foundation

/// Protocol defining the fundamental error interface
public protocol UmbraError: Error, Sendable, CustomStringConvertible {
  /// The domain that this error belongs to, e.g., "Security", "Repository"
  var domain: String { get }

  /// A unique code that identifies this error within its domain
  var code: String { get }

  /// A human-readable description of the error
  var errorDescription: String { get }

  /// Optional source information about where the error occurred
  var source: ErrorHandlingCommon.ErrorSource? { get }

  /// Optional underlying error that caused this error
  var underlyingError: Error? { get }

  /// Additional context information about the error
  var context: ErrorHandlingCommon.ErrorContext { get }

  /// Creates a new instance of the error with additional context
  func with(context: ErrorHandlingCommon.ErrorContext) -> Self

  /// Creates a new instance of the error with a specified underlying error
  func with(underlyingError: Error) -> Self

  /// Creates a new instance of the error with source information
  func with(source: ErrorHandlingCommon.ErrorSource) -> Self
}

/// Error severity levels for classification and logging
public enum ErrorSeverity: String, Comparable, Sendable {
  /// Critical error that requires immediate attention
  case critical="Critical"

  /// Error that significantly affects functionality
  case error="Error"

  /// Warning about potential issues or degraded service
  case warning="Warning"

  /// Informational message about non-critical events
  case info="Information"

  /// Debug information for development purposes
  case debug="Debug"

  /// Returns true if this severity level should trigger a user notification
  public var shouldNotify: Bool {
    switch self {
      case .critical, .error:
        true
      case .warning, .info, .debug:
        false
    }
  }

  public static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
    let order: [ErrorSeverity]=[.debug, .info, .warning, .error, .critical]
    guard
      let lhsIndex=order.firstIndex(of: lhs),
      let rhsIndex=order.firstIndex(of: rhs)
    else {
      return false
    }
    return lhsIndex < rhsIndex
  }
}

/// Protocol for error recovery options
public protocol RecoveryOption: Sendable {
  /// The title of the recovery option
  var title: String { get }

  /// Additional description of the recovery option
  var description: String? { get }

  /// Action to perform when the recovery option is selected
  func perform() async
}

/// Protocol for providing recovery options for errors
public protocol RecoveryOptionsProvider {
  /// Get recovery options for a specific error
  /// - Parameter error: The error to get recovery options for
  /// - Returns: Array of recovery options
  func recoveryOptions<E: UmbraError>(for error: E) -> [RecoveryOption]
}

/// Protocol for error logging services
public protocol ErrorLoggingProtocol {
  /// Log an error with the specified severity
  /// - Parameters:
  ///   - error: The error to log
  ///   - severity: The severity of the error
  func log<E: UmbraError>(error: E, severity: ErrorSeverity)

  /// Log an error with debug severity
  /// - Parameter error: The error to log
  func logDebug<E: UmbraError>(_ error: E)

  /// Log an error with info severity
  /// - Parameter error: The error to log
  func logInfo<E: UmbraError>(_ error: E)

  /// Log an error with warning severity
  /// - Parameter error: The error to log
  func logWarning<E: UmbraError>(_ error: E)

  /// Log an error with error severity
  /// - Parameter error: The error to log
  func logError<E: UmbraError>(_ error: E)

  /// Log an error with critical severity
  /// - Parameter error: The error to log
  func logCritical<E: UmbraError>(_ error: E)
}

/// Default implementation for ErrorLoggingProtocol
extension ErrorLoggingProtocol {
  public func logDebug(_ error: some UmbraError) {
    log(error: error, severity: .debug)
  }

  public func logInfo(_ error: some UmbraError) {
    log(error: error, severity: .info)
  }

  public func logWarning(_ error: some UmbraError) {
    log(error: error, severity: .warning)
  }

  public func logError(_ error: some UmbraError) {
    log(error: error, severity: .error)
  }

  public func logCritical(_ error: some UmbraError) {
    log(error: error, severity: .critical)
  }
}

/// Protocol for error notification services
public protocol ErrorNotificationProtocol {
  /// Present an error to the user
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Optional recovery options to present to the user
  func presentError<E: UmbraError>(_ error: E, recoveryOptions: [RecoveryOption])
}

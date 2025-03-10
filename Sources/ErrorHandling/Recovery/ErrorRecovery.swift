import ErrorHandlingCommon
import ErrorHandlingInterfaces
import Foundation

/// Represents a potential recovery option for an error
public struct ErrorRecoveryOption: RecoveryOption, Sendable {
  /// A unique identifier for this recovery option
  public let id: UUID

  /// User-facing title for this recovery option
  public let title: String

  /// Additional description of what this recovery will do
  public let description: String?

  /// How likely this recovery option is to succeed
  public let successLikelihood: RecoveryLikelihood

  /// Whether this recovery option can disrupt the user's workflow
  public let isDisruptive: Bool

  /// The action to perform for recovery
  public let recoveryAction: @Sendable () async throws -> Void

  /// Creates a new recovery option
  /// - Parameters:
  ///   - id: A unique identifier (optional, auto-generated if nil)
  ///   - title: The user-facing button or option title
  ///   - description: Optional additional details about this recovery
  ///   - successLikelihood: How likely this recovery is to succeed
  ///   - isDisruptive: Whether this recovery interrupts workflow
  ///   - recoveryAction: The action to perform for this recovery
  public init(
    id: UUID?=nil,
    title: String,
    description: String?=nil,
    successLikelihood: RecoveryLikelihood = .likely,
    isDisruptive: Bool=false,
    recoveryAction: @escaping @Sendable () async throws -> Void
  ) {
    self.id=id ?? UUID()
    self.title=title
    self.description=description
    self.successLikelihood=successLikelihood
    self.isDisruptive=isDisruptive
    self.recoveryAction=recoveryAction
  }

  /// Perform the recovery action as required by RecoveryOption protocol
  public func perform() async {
    _=await execute()
  }

  /// Execute the recovery action
  /// - Returns: Whether recovery was successful
  public func execute() async -> Bool {
    do {
      try await recoveryAction()
      return true
    } catch {
      // Create a simple error description if logging is not available
      print("Recovery action failed: \(id) - \(error)")
      return false
    }
  }
}

/// How likely a recovery option is to succeed
public enum RecoveryLikelihood: String, CaseIterable, Sendable {
  case veryLikely="Very Likely"
  case likely="Likely"
  case possible="Possible"
  case unlikely="Unlikely"
  case veryUnlikely="Very Unlikely"

  /// Gets a numerical value representing the likelihood (0-1)
  public var probability: Double {
    switch self {
      case .veryLikely: 0.9
      case .likely: 0.7
      case .possible: 0.5
      case .unlikely: 0.3
      case .veryUnlikely: 0.1
    }
  }
}

/// Protocol for errors that provide recovery options
public protocol RecoverableError: ErrorHandlingInterfaces.UmbraError {
  /// Gets available recovery options for this error
  /// - Returns: Array of recovery options
  func recoveryOptions() -> [ErrorRecoveryOption]

  /// Attempts to recover from this error using all available options
  /// - Returns: Whether recovery was successful
  func attemptRecovery() async -> Bool
}

/// Default implementation of RecoverableError
extension RecoverableError {
  /// Default implementation attempts each recovery option in order
  public func attemptRecovery() async -> Bool {
    let options=recoveryOptions()
    for option in options {
      if await option.execute() {
        return true
      }
    }
    return false
  }
}

/// Concrete implementation of recovery options
/// This builds on the ErrorRecoveryOption interface defined in ErrorHandlingInterfaces
public final class RecoveryManager: RecoveryOptionsProvider, Sendable {
  /// The shared instance
  @MainActor
  public static let shared=RecoveryManager()

  /// Private initialiser to enforce singleton pattern
  private init() {
    // Register with the interface registry
    // ErrorRecoveryRegistry.shared.register(self)
  }

  /// Collection of registered domain-specific recovery handlers
  @MainActor
  private var handlers: [String: any RecoveryOptionsProvider]=[:]

  /// Register a domain-specific recovery handler
  /// - Parameters:
  ///   - handler: The handler to register
  ///   - domain: The error domain this handler can process
  @MainActor
  public func registerHandler(
    _ handler: any RecoveryOptionsProvider,
    for domain: String
  ) {
    handlers[domain]=handler
  }

  /// Get recovery options for a specific error
  /// - Parameter error: The error to get recovery options for
  /// - Returns: Recovery options, or nil if no recovery is available
  @MainActor
  public func recoveryOptions(for error: Error) async -> RecoveryOptions? {
    // Get the error domain
    let domain = String(describing: type(of: error))

    // Access handlers directly since we're in the MainActor context
    let domainHandler = handlers[domain]

    // Look for a domain-specific handler
    if let handler = domainHandler {
      return await handler.recoveryOptions(for: error)
    }

    // Default recovery options if no specific handler
    if let umbraError = error as? UmbraError {
      return createDefaultRecoveryOptions(for: umbraError)
    }

    // No recovery options available
    return nil
  }

  /// Provides default recovery options for common error types
  /// - Parameter error: The error to provide recovery options for
  /// - Returns: RecoveryOptions containing default recovery actions
  private func createDefaultRecoveryOptions(for error: UmbraError) -> RecoveryOptions {
    // Create standard retry and cancel actions
    let retryAction = RecoveryAction(
      id: "retry",
      title: "Try Again",
      description: "Retry the operation that failed",
      isDefault: true,
      handler: { /* Implementation would vary based on the error */ }
    )

    let cancelAction = RecoveryAction(
      id: "cancel",
      title: "Cancel",
      description: "Skip this operation",
      isDefault: false,
      handler: { /* Do nothing */ }
    )

    // Create a message based on the error
    let errorMessage = String(describing: error)
    let message: String = "An error occurred: \(errorMessage)"

    // Return standard recovery options
    return RecoveryOptions(
      actions: [retryAction, cancelAction],
      title: "Operation Failed",
      message: message
    )
  }
}

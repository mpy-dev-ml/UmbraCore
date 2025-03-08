import ErrorHandlingInterfaces
import Foundation

/// Container for recovery actions that can be presented to the user
public struct RecoveryOptions: Sendable, Equatable {
  /// Array of available recovery actions
  public let actions: [RecoveryAction]

  /// Optional title for the recovery options dialogue
  public let title: String?

  /// Optional message explaining the error and recovery options
  public let message: String?

  /// Creates a new RecoveryOptions instance
  /// - Parameters:
  ///   - actions: Array of available recovery actions
  ///   - title: Optional title for the recovery options dialogue
  ///   - message: Optional message explaining the error and recovery options
  public init(
    actions: [RecoveryAction],
    title: String? = nil,
    message: String? = nil
  ) {
    self.actions = actions
    self.title = title
    self.message = message
  }

  /// Find the default recovery action, if one exists
  /// - Returns: The default recovery action, or nil if none is marked as default
  public var defaultAction: RecoveryAction? {
    actions.first(where: { $0.isDefault })
  }

  /// Find a recovery action by its ID
  /// - Parameter id: The ID of the recovery action to find
  /// - Returns: The recovery action with the specified ID, or nil if not found
  public func action(withId id: String) -> RecoveryAction? {
    actions.first(where: { $0.id == id })
  }

  /// Equality comparison for RecoveryOptions
  public static func == (lhs: RecoveryOptions, rhs: RecoveryOptions) -> Bool {
    lhs.actions == rhs.actions &&
      lhs.title == rhs.title &&
      lhs.message == rhs.message
  }
}

/// A protocol for error handlers that provide recovery options
public protocol RecoveryOptionsProvider {
  /// Provides recovery options for the specified error
  /// - Parameter error: The error to provide recovery options for
  /// - Returns: Recovery options, or nil if no recovery is possible
  func recoveryOptions(for error: Error) -> RecoveryOptions?
}

/// Extension to provide factory methods for common recovery option sets
extension RecoveryOptions {
  /// Creates recovery options with retry and cancel actions
  /// - Parameters:
  ///   - title: Optional title for the recovery options dialogue
  ///   - message: Optional message explaining the error and recovery options
  ///   - retryHandler: The action to perform when retrying
  ///   - cancelHandler: The action to perform when cancelling
  /// - Returns: RecoveryOptions with retry and cancel actions
  public static func retryCancel(
    title: String? = nil,
    message: String? = nil,
    retryHandler: @escaping @Sendable () -> Void,
    cancelHandler: @escaping @Sendable () -> Void
  ) -> RecoveryOptions {
    RecoveryOptions(
      actions: [
        .retry(handler: retryHandler),
        .cancel(handler: cancelHandler)
      ],
      title: title,
      message: message
    )
  }

  /// Creates recovery options with retry, ignore, and cancel actions
  /// - Parameters:
  ///   - title: Optional title for the recovery options dialogue
  ///   - message: Optional message explaining the error and recovery options
  ///   - retryHandler: The action to perform when retrying
  ///   - ignoreHandler: The action to perform when ignoring
  ///   - cancelHandler: The action to perform when cancelling
  /// - Returns: RecoveryOptions with retry, ignore, and cancel actions
  public static func retryIgnoreCancel(
    title: String? = nil,
    message: String? = nil,
    retryHandler: @escaping @Sendable () -> Void,
    ignoreHandler: @escaping @Sendable () -> Void,
    cancelHandler: @escaping @Sendable () -> Void
  ) -> RecoveryOptions {
    RecoveryOptions(
      actions: [
        .retry(handler: retryHandler),
        .ignore(handler: ignoreHandler),
        .cancel(handler: cancelHandler)
      ],
      title: title,
      message: message
    )
  }
}

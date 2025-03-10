import ErrorHandlingInterfaces
import Foundation

/// A recovery option that wraps a closure
public struct ClosureRecoveryOption: RecoveryOption, Identifiable {
  /// Unique identifier
  public let id=UUID()

  /// The title of the recovery option
  public let title: String

  /// Additional description of the recovery option
  public let description: String?

  /// Whether this recovery option is potentially disruptive to the user's workflow
  public let isDisruptive: Bool

  /// The action to perform for recovery
  private let action: @Sendable () async throws -> Void

  /// Creates a new recovery option
  /// - Parameters:
  ///   - title: Title of the option
  ///   - description: Optional description
  ///   - isDisruptive: Whether this recovery option might disrupt the user's workflow
  ///   - action: Action to perform
  public init(
    title: String,
    description: String?=nil,
    isDisruptive: Bool=false,
    action: @escaping @Sendable () async throws -> Void
  ) {
    self.title=title
    self.description=description
    self.isDisruptive=isDisruptive
    self.action=action
  }

  /// Perform the recovery action
  public func perform() async {
    do {
      try await action()
    } catch {
      // If action throws, we catch and ignore the error since perform() doesn't throw
      // The error may be handled within the action closure itself
    }
  }
}

/// Represents a notification about an error with optional recovery actions
public struct ErrorNotification: Sendable, Identifiable {
  /// Unique identifier for the notification
  public let id: UUID

  /// The error that triggered this notification
  public let error: Error

  /// Title of the notification
  public let title: String

  /// Message body of the notification
  public let message: String

  /// Options for recovering from the error
  public let recoveryOptions: [any RecoveryOption]

  /// Creates a new error notification
  /// - Parameters:
  ///   - error: The error that triggered this notification
  ///   - title: Title of the notification
  ///   - message: Message body of the notification
  ///   - recoveryOptions: Options for recovering from the error
  public init(
    error: Error,
    title: String,
    message: String,
    recoveryOptions: [any RecoveryOption]=[]
  ) {
    id=UUID()
    self.error=error
    self.title=title
    self.message=message
    self.recoveryOptions=recoveryOptions
  }
}

/// Protocol for handling error notifications
public protocol ErrorNotificationManager: Sendable {
  /// Presents an error to the user
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Recovery options to present
  func presentError(_ error: Error, recoveryOptions: [any RecoveryOption])

  /// Recovers from an error with the selected recovery option
  /// - Parameters:
  ///   - notificationId: ID of the notification to recover from
  ///   - recoveryOptionId: ID of the recovery option to use
  func recoverFromError(
    notificationId: UUID,
    recoveryOptionId: UUID
  ) async throws

  /// Dismisses an error notification
  /// - Parameter notificationId: ID of the notification to dismiss
  func dismissError(notificationId: UUID)
}

/// Default implementation of the error notification manager
public final class DefaultErrorNotificationManager: ErrorNotificationManager {
  /// The shared instance
  public static let shared=DefaultErrorNotificationManager()

  /// Currently active notifications
  @MainActor
  private var activeNotifications: [UUID: ErrorNotification]=[:]

  /// Creates a new notification manager
  public init() {}

  /// Presents an error to the user (non-async version to satisfy protocol requirement)
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Recovery options to present
  public nonisolated func presentError(
    _ error: Error,
    recoveryOptions: [any RecoveryOption]
  ) {
    // Create a detached task to handle the async call
    // TODO: Swift 6 compatibility - refactor actor isolation
    Task { @MainActor in
      await self.presentErrorOnMainActor(error, recoveryOptions: recoveryOptions)
    }
  }

  /// Presents an error to the user (async version)
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Recovery options to present
  @MainActor
  public func presentErrorOnMainActor(
    _ error: Error,
    recoveryOptions: [any RecoveryOption]
  ) async {
    let domain: String=if let nsError=error as? NSError {
      nsError.domain
    } else if let customError=error as? any CustomStringConvertible {
      String(describing: type(of: customError))
    } else {
      "Unknown"
    }

    let notification=ErrorNotification(
      error: error,
      title: "Error: \(domain)",
      message: error.localizedDescription,
      recoveryOptions: recoveryOptions
    )

    activeNotifications[notification.id]=notification

    // TODO: Present UI for the notification
  }

  /// Get the recovery option with the given ID
  /// - Parameter id: The ID of the recovery option
  /// - Returns: The recovery option, or nil if not found
  @MainActor
  public func getRecoveryOption(withID id: UUID) -> (any RecoveryOption)? {
    for notification in activeNotifications.values {
      for option in notification.recoveryOptions where option.id == id {
        return option
      }
    }
    return nil
  }

  /// Recover from an error with the selected option
  /// - Parameter optionID: The ID of the selected recovery option
  /// - Returns: Whether recovery was successful
  @MainActor
  public func recoverWithOption(id optionID: UUID) async -> Bool {
    guard let option=getRecoveryOption(withID: optionID) else {
      return false
    }

    await option.perform()
    return true
  }

  /// Recovers from an error with the selected recovery option
  /// - Parameters:
  ///   - notificationId: ID of the notification to recover from
  ///   - recoveryOptionId: ID of the recovery option to use
  public func recoverFromError(
    notificationId _: UUID,
    recoveryOptionId: UUID
  ) async throws {
    let success=await recoverWithOption(id: recoveryOptionId)
    if !success {
      throw NSError(
        domain: "ErrorNotification",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Recovery option not found"]
      )
    }
  }

  /// Dismisses an error notification
  /// - Parameter notificationId: ID of the notification to dismiss
  public func dismissError(notificationId: UUID) {
    Task { @MainActor in
      activeNotifications[notificationId]=nil
    }
  }
}

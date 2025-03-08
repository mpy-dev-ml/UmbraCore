import ErrorHandlingInterfaces
import Foundation

/// Represents a notification about an error with optional recovery actions
public struct ErrorNotification: Sendable, Identifiable {
  /// Unique identifier for the notification
  public let id: UUID

  /// The error that triggered this notification
  public let error: Error

  /// Human-readable title for the notification
  public let title: String

  /// Detailed message explaining the error
  public let message: String

  /// Notification severity level
  public let severity: NotificationSeverity

  /// Optional recovery options for the error
  public let recoveryOptions: [RecoveryOption]?

  /// Optional timestamp for when the notification was created
  public let timestamp: Date

  /// Initializes a new notification
  /// - Parameters:
  ///   - error: The error that triggered this notification
  ///   - title: The title for the notification
  ///   - message: The detailed message explaining the error
  ///   - severity: The severity level (default: .error)
  ///   - recoveryOptions: Optional recovery options
  ///   - timestamp: Creation timestamp (default: current date)
  public init(
    error: Error,
    title: String,
    message: String,
    severity: NotificationSeverity = .error,
    recoveryOptions: [RecoveryOption]?=nil,
    timestamp: Date=Date()
  ) {
    id=UUID()
    self.error=error
    self.title=title
    self.message=message
    self.severity=severity
    self.recoveryOptions=recoveryOptions
    self.timestamp=timestamp
  }
}

/// Severity levels for error notifications
public enum NotificationSeverity: Int, Comparable, Sendable {
  case info=0
  case warning=1
  case error=2
  case critical=3

  public static func < (lhs: NotificationSeverity, rhs: NotificationSeverity) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

/// A notification manager for presenting errors to users
public protocol ErrorNotificationManager: ErrorNotificationProtocol {
  /// Presents a notification to the user
  /// - Parameter notification: The notification to present
  func presentNotification(_ notification: ErrorNotification) async

  /// Dismiss a notification
  /// - Parameter id: The ID of the notification to dismiss
  func dismissNotification(id: UUID) async

  /// Get all active notifications
  /// - Returns: Array of active notifications
  func activeNotifications() async -> [ErrorNotification]
}

/// Default implementation of ErrorNotificationProtocol
@MainActor
public final class DefaultErrorNotificationManager: ErrorNotificationManager {
  /// The shared instance
  public static let shared=DefaultErrorNotificationManager()

  /// Currently active notifications
  private var notifications: [UUID: ErrorNotification]=[:]

  /// Private initializer to enforce singleton
  private init() {}

  /// Presents an error to the user (non-async version to satisfy protocol requirement)
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Recovery options to present
  public nonisolated func presentError(
    _ error: some UmbraError,
    recoveryOptions: [RecoveryOption]
  ) {
    // Create a detached task to handle the async call
    Task { @MainActor in
      await presentError(error, recoveryOptions: recoveryOptions)
    }
  }

  /// Presents an error to the user (async version)
  /// - Parameters:
  ///   - error: The error to present
  ///   - recoveryOptions: Recovery options to present
  public func presentError(_ error: some UmbraError, recoveryOptions: [RecoveryOption]) async {
    let notification=ErrorNotification(
      error: error,
      title: "Error: \(error.domain)",
      message: error.localizedDescription,
      severity: .error,
      recoveryOptions: recoveryOptions
    )
    await presentNotification(notification)
  }

  /// Presents a notification to the user
  /// - Parameter notification: The notification to present
  public func presentNotification(_ notification: ErrorNotification) async {
    // Store the notification
    notifications[notification.id]=notification

    // In a real implementation, this would show UI
    #if DEBUG
      print("🔔 NOTIFICATION [\(notification.severity)]: \(notification.title)")
      print("  Message: \(notification.message)")
      if let options=notification.recoveryOptions, !options.isEmpty {
        print("  Recovery Options:")
        for (index, option) in options.enumerated() {
          print("    \(index + 1). \(option.title)")
        }
      }
    #endif
  }

  /// Dismiss a notification
  /// - Parameter id: The ID of the notification to dismiss
  public func dismissNotification(id: UUID) async {
    notifications.removeValue(forKey: id)
  }

  /// Get all active notifications
  /// - Returns: Array of active notifications
  public func activeNotifications() async -> [ErrorNotification] {
    Array(notifications.values)
  }
}

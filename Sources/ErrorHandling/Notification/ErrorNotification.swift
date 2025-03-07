// ErrorNotification.swift
// Notification management for errors with recovery options
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingProtocols
import ErrorHandlingRecovery

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
    public let recoveryOptions: RecoveryOptions?
    
    /// Optional timestamp for when the notification was created
    public let timestamp: Date
    
    /// Creates a new ErrorNotification instance
    /// - Parameters:
    ///   - error: The error that triggered this notification
    ///   - title: Human-readable title for the notification
    ///   - message: Detailed message explaining the error
    ///   - severity: Notification severity level
    ///   - recoveryOptions: Optional recovery options for the error
    ///   - timestamp: Optional timestamp for when the notification was created (defaults to now)
    public init(
        error: Error,
        title: String,
        message: String,
        severity: NotificationSeverity,
        recoveryOptions: RecoveryOptions? = nil,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.error = error
        self.title = title
        self.message = message
        self.severity = severity
        self.recoveryOptions = recoveryOptions
        self.timestamp = timestamp
    }
}

/// Severity levels for error notifications
public enum NotificationSeverity: String, Sendable, Comparable, CaseIterable {
    /// Informational notification, not an actual error
    case info
    
    /// Minor issue that doesn't affect functionality
    case low
    
    /// Issue that affects some functionality but the system can continue
    case medium
    
    /// Serious issue that affects core functionality
    case high
    
    /// Critical issue that requires immediate attention
    case critical
    
    /// Compare severity levels
    public static func < (lhs: NotificationSeverity, rhs: NotificationSeverity) -> Bool {
        let order: [NotificationSeverity] = [.info, .low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// Protocol for error notification handlers
public protocol ErrorNotificationHandler {
    /// Present a notification to the user
    /// - Parameter notification: The notification to present
    func present(notification: ErrorNotification)
    
    /// Dismiss a specific notification
    /// - Parameter id: The ID of the notification to dismiss
    func dismiss(notificationWithId id: UUID)
    
    /// Dismiss all current notifications
    func dismissAll()
}

/// Factory methods for creating error notifications
public extension ErrorNotification {
    /// Create a notification from an UmbraError
    /// - Parameters:
    ///   - error: The UmbraError to create a notification for
    ///   - severity: The severity level of the notification
    ///   - recoveryOptions: Optional recovery options
    /// - Returns: A new ErrorNotification instance
    static func from(
        umbraError: UmbraError,
        severity: NotificationSeverity,
        recoveryOptions: RecoveryOptions? = nil
    ) -> ErrorNotification {
        return ErrorNotification(
            error: umbraError,
            title: "[\(umbraError.domain)] \(umbraError.code)",
            message: umbraError.errorDescription,
            severity: severity,
            recoveryOptions: recoveryOptions
        )
    }
    
    /// Create a generic error notification
    /// - Parameters:
    ///   - error: Any error type
    ///   - title: Human-readable title for the notification
    ///   - message: Optional custom message (if nil, uses error.localizedDescription)
    ///   - severity: The severity level of the notification
    ///   - recoveryOptions: Optional recovery options
    /// - Returns: A new ErrorNotification instance
    static func generic(
        error: Error,
        title: String,
        message: String? = nil,
        severity: NotificationSeverity,
        recoveryOptions: RecoveryOptions? = nil
    ) -> ErrorNotification {
        return ErrorNotification(
            error: error,
            title: title,
            message: message ?? error.localizedDescription,
            severity: severity,
            recoveryOptions: recoveryOptions
        )
    }
}

// RecoveryAction.swift
// Defines actions that can be taken to recover from errors
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingProtocols

/// Represents an action that can be taken to recover from an error
public struct RecoveryAction: Sendable, Equatable {
    /// Unique identifier for the recovery action
    public let id: String
    
    /// Human-readable title for the recovery action
    public let title: String
    
    /// Optional detailed description of what the recovery action will do
    public let description: String?
    
    /// Indicates whether this action should be presented as the default option
    public let isDefault: Bool
    
    /// The action handler closure that will be called when the action is selected
    /// Note: This property is not Sendable-compliant and should be used with caution
    private let actionHandler: () -> Void
    
    /// Creates a new RecoveryAction instance
    /// - Parameters:
    ///   - id: Unique identifier for the recovery action
    ///   - title: Human-readable title for the recovery action
    ///   - description: Optional detailed description of what the recovery action will do
    ///   - isDefault: Indicates whether this action should be presented as the default option
    ///   - handler: The action handler closure that will be called when the action is selected
    public init(
        id: String,
        title: String,
        description: String? = nil,
        isDefault: Bool = false,
        handler: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isDefault = isDefault
        self.actionHandler = handler
    }
    
    /// Execute the recovery action
    public func perform() {
        actionHandler()
    }
    
    /// Equality comparison for RecoveryAction
    /// Note: Only compares the id, title, description, and isDefault properties
    /// The actionHandler is not compared as functions cannot be compared for equality
    public static func == (lhs: RecoveryAction, rhs: RecoveryAction) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.isDefault == rhs.isDefault
    }
}

/// Extension to provide factory methods for common recovery actions
public extension RecoveryAction {
    /// Creates a retry action
    /// - Parameters:
    ///   - title: Custom title for the retry action (defaults to "Retry")
    ///   - description: Optional description of what will be retried
    ///   - handler: The action to perform when retrying
    /// - Returns: A new RecoveryAction for retrying
    static func retry(
        title: String = "Retry",
        description: String? = nil,
        handler: @escaping () -> Void
    ) -> RecoveryAction {
        return RecoveryAction(
            id: "retry",
            title: title,
            description: description,
            isDefault: true,
            handler: handler
        )
    }
    
    /// Creates a cancel action
    /// - Parameters:
    ///   - title: Custom title for the cancel action (defaults to "Cancel")
    ///   - description: Optional description of what will be cancelled
    ///   - handler: The action to perform when cancelling
    /// - Returns: A new RecoveryAction for cancelling
    static func cancel(
        title: String = "Cancel",
        description: String? = nil,
        handler: @escaping () -> Void
    ) -> RecoveryAction {
        return RecoveryAction(
            id: "cancel",
            title: title,
            description: description,
            handler: handler
        )
    }
    
    /// Creates an ignore action
    /// - Parameters:
    ///   - title: Custom title for the ignore action (defaults to "Ignore")
    ///   - description: Optional description of what will be ignored
    ///   - handler: The action to perform when ignoring
    /// - Returns: A new RecoveryAction for ignoring
    static func ignore(
        title: String = "Ignore",
        description: String? = nil,
        handler: @escaping () -> Void
    ) -> RecoveryAction {
        return RecoveryAction(
            id: "ignore",
            title: title,
            description: description,
            handler: handler
        )
    }
}

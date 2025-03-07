// ErrorNotifier.swift
// Notification system for errors in the enhanced error handling system
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// Protocol for services that can notify users about errors
public protocol ErrorNotificationService {
    /// Notifies the user about an error
    /// - Parameters:
    ///   - error: The error to notify about
    ///   - level: The notification level
    ///   - recoveryOptions: Optional recovery options to present
    /// - Returns: The chosen recovery option ID, if any
    func notifyUser(
        about error: UmbraError,
        level: ErrorNotificationLevel,
        recoveryOptions: [ErrorRecoveryOption]?
    ) async -> String?
    
    /// The types of errors that this service can handle
    var supportedErrorDomains: [String] { get }
    
    /// The notification levels that this service supports
    var supportedLevels: [ErrorNotificationLevel] { get }
}

/// Represents the level of notification for an error
public enum ErrorNotificationLevel: Int, Comparable {
    case debug = 0    // Developer-focused, typically not shown to end users
    case info = 1     // Informational, non-critical
    case warning = 2  // Warning that might need attention
    case error = 3    // Error that needs attention
    case critical = 4 // Critical error that requires immediate attention
    
    public static func < (lhs: ErrorNotificationLevel, rhs: ErrorNotificationLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    /// Converts a UmbraLogLevel to ErrorNotificationLevel
    /// - Parameter logLevel: The log level to convert
    /// - Returns: The corresponding notification level
    public static func from(logLevel: UmbraLogLevel) -> ErrorNotificationLevel {
        switch logLevel {
        case .verbose, .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        case .critical, .fault:
            return .critical
        }
    }
}

/// Central coordinating service for error notifications
public final class ErrorNotifier {
    /// The shared instance
    public static let shared = ErrorNotifier()
    
    /// Registered notification services
    private var notificationServices: [ErrorNotificationService] = []
    
    /// The minimum level for notifications
    public var minimumNotificationLevel: ErrorNotificationLevel = .warning
    
    /// Whether automatic notification is enabled
    public var automaticNotificationEnabled: Bool = true
    
    /// Private initialiser to enforce singleton pattern
    private init() {}
    
    /// Registers a notification service
    /// - Parameter service: The service to register
    public func register(_ service: ErrorNotificationService) {
        notificationServices.append(service)
    }
    
    /// Notifies the user about an error
    /// - Parameters:
    ///   - error: The error to notify about
    ///   - level: The notification level
    ///   - recoveryOptions: Optional recovery options to present
    /// - Returns: The chosen recovery option ID, if any
    public func notifyUser(
        about error: UmbraError,
        level: ErrorNotificationLevel,
        recoveryOptions: [ErrorRecoveryOption]? = nil
    ) async -> String? {
        // Skip if level is below minimum
        guard level >= minimumNotificationLevel else {
            return nil
        }
        
        // Find appropriate notification services for this error's domain
        let applicableServices = notificationServices.filter { service in
            service.supportedErrorDomains.contains(error.domain) &&
            service.supportedLevels.contains(level)
        }
        
        // Get recovery options if not provided
        let options = recoveryOptions ?? ErrorRecoveryRegistry.shared.recoveryOptions(for: error)
        
        // Try each service until one handles the notification
        for service in applicableServices {
            if let chosenOptionID = await service.notifyUser(
                about: error,
                level: level,
                recoveryOptions: options
            ) {
                return chosenOptionID
            }
        }
        
        // No service could handle the notification or no option was chosen
        return nil
    }
    
    /// Notifies the user about an error and attempts recovery if an option is chosen
    /// - Parameters:
    ///   - error: The error to notify about and recover from
    ///   - level: The notification level
    /// - Returns: Whether recovery was successful
    public func notifyAndRecover(
        from error: UmbraError,
        level: ErrorNotificationLevel
    ) async -> Bool {
        // Get recovery options
        let options = ErrorRecoveryRegistry.shared.recoveryOptions(for: error)
        
        // Skip if no options available
        guard !options.isEmpty else {
            // Just notify without recovery options
            _ = await notifyUser(about: error, level: level)
            return false
        }
        
        // Notify user and get chosen option
        if let chosenOptionID = await notifyUser(
            about: error,
            level: level,
            recoveryOptions: options
        ) {
            // Find the chosen option
            if let chosenOption = options.first(where: { $0.id == chosenOptionID }) {
                // Attempt recovery with the chosen option
                return await chosenOption.attemptRecovery()
            }
        }
        
        return false
    }
}

/// Extension to UmbraError for notification capabilities
public extension UmbraError {
    /// Notifies the user about this error
    /// - Parameters:
    ///   - level: The notification level
    ///   - logError: Whether to also log the error
    /// - Returns: The chosen recovery option ID, if any
    func notify(
        level: ErrorNotificationLevel = .error,
        logError: Bool = true
    ) async -> String? {
        // Log the error if requested
        if logError {
            switch level {
            case .debug:
                self.logAsDebug()
            case .info:
                self.logAsInfo()
            case .warning:
                self.logAsWarning()
            case .error, .critical:
                self.logAsError()
            }
        }
        
        // Notify the user
        return await ErrorNotifier.shared.notifyUser(about: self, level: level)
    }
    
    /// Notifies the user about this error and attempts recovery if an option is chosen
    /// - Parameters:
    ///   - level: The notification level
    ///   - logError: Whether to also log the error
    /// - Returns: Whether recovery was successful
    func notifyAndRecover(
        level: ErrorNotificationLevel = .error,
        logError: Bool = true
    ) async -> Bool {
        // Log the error if requested
        if logError {
            switch level {
            case .debug:
                self.logAsDebug()
            case .info:
                self.logAsInfo()
            case .warning:
                self.logAsWarning()
            case .error, .critical:
                self.logAsError()
            }
        }
        
        // Notify and recover
        return await ErrorNotifier.shared.notifyAndRecover(from: self, level: level)
    }
}

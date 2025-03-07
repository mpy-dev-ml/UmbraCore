// ErrorHandler.swift
// Core error handling functionality for UmbraCore
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingProtocols
import ErrorHandlingLogging
import ErrorHandlingRecovery
import ErrorHandlingNotification
import ErrorHandlingModels

/// Main error handler for the UmbraCore framework
public final class ErrorHandler {
    /// Shared instance of the error handler
    public static let shared = ErrorHandler()
    
    /// The logger used for error logging
    private let logger: ErrorLogger
    
    /// The notification handler for presenting errors to the user
    private var notificationHandler: ErrorNotificationHandler?
    
    /// Registered recovery options providers
    private var recoveryProviders: [RecoveryOptionsProvider]
    
    /// Private initialiser to enforce singleton pattern
    private init() {
        self.logger = ErrorLogger.shared
        self.recoveryProviders = []
    }
    
    /// Set the notification handler to use for presenting errors
    /// - Parameter handler: The notification handler to use
    public func setNotificationHandler(_ handler: ErrorNotificationHandler) {
        self.notificationHandler = handler
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
        _ error: Error,
        severity: NotificationSeverity = .medium,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Wrap the error in a GenericUmbraError if it's not already an UmbraError
        let umbraError: UmbraError
        if let error = error as? UmbraError {
            umbraError = error
        } else {
            umbraError = GenericUmbraError.wrapped(error)
        }
        
        // Add source information
        let errorWithSource = umbraError.with(
            source: ErrorSource(file: file, line: line, function: function)
        )
        
        // Log the error
        switch severity {
        case .critical, .high:
            logger.logError(errorWithSource)
        case .medium:
            logger.logWarning(errorWithSource)
        case .low, .info:
            logger.logInfo(errorWithSource)
        }
        
        // Find recovery options for this error
        let recoveryOptions = findRecoveryOptions(for: error)
        
        // Present a notification to the user if appropriate
        if severity >= .medium {
            let notification = ErrorNotification.from(
                umbraError: errorWithSource,
                severity: severity,
                recoveryOptions: recoveryOptions
            )
            
            notificationHandler?.present(notification: notification)
        }
    }
    
    /// Handle an error asynchronously
    /// - Parameters:
    ///   - error: The error to handle
    ///   - severity: The severity of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func handleAsync(
        _ error: Error,
        severity: NotificationSeverity = .medium,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Task {
            handle(error, severity: severity, file: file, function: function, line: line)
        }
    }
    
    /// Find recovery options for an error
    /// - Parameter error: The error to find recovery options for
    /// - Returns: Recovery options if available, otherwise nil
    private func findRecoveryOptions(for error: Error) -> RecoveryOptions? {
        for provider in recoveryProviders {
            if let options = provider.recoveryOptions(for: error) {
                return options
            }
        }
        return nil
    }
}

/// Extension to provide convenience methods for specific error types
public extension ErrorHandler {
    /// Handle a security error
    /// - Parameters:
    ///   - error: The security error to handle
    ///   - severity: The severity of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func handleSecurityError(
        _ error: Error,
        severity: NotificationSeverity = .high,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        handle(error, severity: severity, file: file, function: function, line: line)
    }
    
    /// Handle a network error
    /// - Parameters:
    ///   - error: The network error to handle
    ///   - severity: The severity of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func handleNetworkError(
        _ error: Error,
        severity: NotificationSeverity = .medium,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        handle(error, severity: severity, file: file, function: function, line: line)
    }
    
    /// Handle a validation error
    /// - Parameters:
    ///   - error: The validation error to handle
    ///   - severity: The severity of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func handleValidationError(
        _ error: Error,
        severity: NotificationSeverity = .low,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        handle(error, severity: severity, file: file, function: function, line: line)
    }
}

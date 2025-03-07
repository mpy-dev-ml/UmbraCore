// SecurityErrorHandler.swift
// Utility for handling different security errors across the UmbraCore codebase
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingMapping
import ErrorHandlingProtocols
import ErrorHandlingLogging
import ErrorHandlingNotification
import ErrorHandlingRecovery

/// A utility class for handling security errors across different modules
public class SecurityErrorHandler {
    /// The shared instance for the handler
    public static let shared = SecurityErrorHandler()
    
    /// The error mapper to handle different security error types
    private let securityErrorMapper: SecurityErrorMapper
    
    /// Private initialiser to enforce singleton pattern
    private init() {
        self.securityErrorMapper = SecurityErrorMapper()
    }
    
    /// Handle any security-related error from any module
    /// - Parameters:
    ///   - error: The security error to handle
    ///   - severity: The severity level of the error
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    public func handleSecurityError(
        _ error: Error,
        severity: NotificationSeverity = .high,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Try to map to our consolidated UmbraSecurityError
        if let securityError = securityErrorMapper.mapFromAny(error) {
            // Successfully mapped, handle with our error handler
            ErrorHandler.shared.handle(securityError, severity: severity, file: file, function: function, line: line)
        } else {
            // Not a security error, or couldn't be mapped
            ErrorHandler.shared.handle(error, severity: severity, file: file, function: function, line: line)
        }
    }
    
    /// Adds standard recovery options for security errors
    /// - Parameters:
    ///   - error: The security error
    ///   - retryAction: The action to perform when retrying
    ///   - cancelAction: The action to perform when cancelling
    /// - Returns: RecoveryOptions for the security error
    public func addSecurityRecoveryOptions(
        for error: Error,
        retryAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> RecoveryOptions {
        // Map to our consolidated UmbraSecurityError if possible
        let securityError = securityErrorMapper.mapFromAny(error) ?? 
                            UmbraSecurityError.unknown("Unknown security error")
        
        // Determine appropriate recovery options based on the error type
        switch securityError {
        case .authenticationFailed, .invalidCredentials:
            return RecoveryOptions(
                actions: [
                    RecoveryAction(id: "reauthenticate", title: "Re-authenticate", isDefault: true, handler: retryAction),
                    RecoveryAction(id: "cancel", title: "Cancel", handler: cancelAction)
                ],
                title: "Authentication Required",
                message: "Your authentication has failed. Please re-authenticate to continue."
            )
            
        case .tokenExpired, .sessionExpired:
            return RecoveryOptions(
                actions: [
                    RecoveryAction(id: "renew", title: "Renew Session", isDefault: true, handler: retryAction),
                    RecoveryAction(id: "cancel", title: "Cancel", handler: cancelAction)
                ],
                title: "Session Expired",
                message: "Your session has expired. Please renew your session to continue."
            )
            
        case .permissionDenied, .insufficientPrivileges, .unauthorizedAccess:
            return RecoveryOptions(
                actions: [
                    RecoveryAction(id: "request", title: "Request Access", isDefault: true, handler: retryAction),
                    RecoveryAction(id: "cancel", title: "Cancel", handler: cancelAction)
                ],
                title: "Access Denied",
                message: "You do not have permission to perform this action."
            )
            
        default:
            // Default recovery options for other security errors
            return RecoveryOptions.retryCancel(
                title: "Security Error",
                message: securityError.errorDescription,
                retryHandler: retryAction,
                cancelHandler: cancelAction
            )
        }
    }
    
    /// Create a notification for a security error
    /// - Parameters:
    ///   - error: The security error
    ///   - recoveryOptions: Optional recovery options
    /// - Returns: An ErrorNotification for the security error
    public func createSecurityNotification(
        for error: Error,
        recoveryOptions: RecoveryOptions? = nil
    ) -> ErrorNotification {
        // Map to our consolidated UmbraSecurityError if possible
        if let securityError = securityErrorMapper.mapFromAny(error) {
            return ErrorNotification(
                error: securityError,
                title: "Security Alert",
                message: securityError.errorDescription,
                severity: .high,
                recoveryOptions: recoveryOptions
            )
        } else {
            // Not a security error, or couldn't be mapped
            return ErrorNotification(
                error: error,
                title: "Security Alert",
                message: error.localizedDescription,
                severity: .high,
                recoveryOptions: recoveryOptions
            )
        }
    }
}

/// Extension to provide usage examples
public extension SecurityErrorHandler {
    /// Example usage of the security error handler
    /// - Parameter error: Any error to handle as a security error
    static func handleExampleError(_ error: Error) {
        // Create recovery options
        let recoveryOptions = shared.addSecurityRecoveryOptions(
            for: error,
            retryAction: {
                print("Retrying after security error")
                // Implement retry logic here
            },
            cancelAction: {
                print("Cancelled after security error")
                // Implement cancel logic here
            }
        )
        
        // Create a notification
        let notification = shared.createSecurityNotification(
            for: error,
            recoveryOptions: recoveryOptions
        )
        
        // Log and handle the error
        shared.handleSecurityError(error)
        
        // The notification can be shown in the UI
        print("A security notification would be displayed: \(notification.title)")
    }
}

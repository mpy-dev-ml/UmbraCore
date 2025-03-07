// MacErrorNotificationService.swift
// macOS implementation of error notification service
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
#if os(macOS)
import AppKit
#endif

/// A macOS implementation of the ErrorNotificationService
public final class MacErrorNotificationService: ErrorNotificationService {
    
    /// Supported error domains for this service
    public let supportedErrorDomains: [String]
    
    /// Notification levels supported by this service
    public let supportedLevels: [ErrorNotificationLevel]
    
    /// Initialises with specific error domains and levels
    /// - Parameters:
    ///   - supportedDomains: Domains this service can handle (or nil for all)
    ///   - supportedLevels: Levels this service can handle
    public init(
        supportedDomains: [String]? = nil,
        supportedLevels: [ErrorNotificationLevel] = [.warning, .error, .critical]
    ) {
        self.supportedErrorDomains = supportedDomains ?? []
        self.supportedLevels = supportedLevels
    }
    
    /// Creates a notification service that handles all domains
    /// - Returns: A notification service for all error domains
    public static func forAllDomains() -> MacErrorNotificationService {
        return MacErrorNotificationService(supportedDomains: nil)
    }
    
    /// Notifies the user about an error using macOS alerts
    /// - Parameters:
    ///   - error: The error to notify about
    ///   - level: The notification level
    ///   - recoveryOptions: Optional recovery options to present
    /// - Returns: The chosen recovery option ID, if any
    public func notifyUser(
        about error: UmbraError,
        level: ErrorNotificationLevel,
        recoveryOptions: [ErrorRecoveryOption]?
    ) async -> String? {
        #if os(macOS)
        // Return to the main thread for UI operations
        return await MainActor.run {
            // Create the alert
            let alert = NSAlert()
            
            // Configure the alert based on the error level
            configureAlert(alert, for: error, level: level)
            
            // Add buttons for recovery options
            if let recoveryOptions = recoveryOptions, !recoveryOptions.isEmpty {
                // Add recovery option buttons
                addRecoveryButtons(to: alert, options: recoveryOptions)
            } else {
                // Add a default OK button if no recovery options
                alert.addButton(withTitle: "OK")
            }
            
            // Run the alert
            let response = alert.runModal()
            
            // Handle the response
            return handleAlertResponse(response, recoveryOptions: recoveryOptions)
        }
        #else
        // Not supported on non-macOS platforms
        return nil
        #endif
    }
    
    // MARK: - Private Methods
    
    #if os(macOS)
    /// Configures an NSAlert based on the error and level
    /// - Parameters:
    ///   - alert: The alert to configure
    ///   - error: The error to display
    ///   - level: The notification level
    private func configureAlert(
        _ alert: NSAlert,
        for error: UmbraError,
        level: ErrorNotificationLevel
    ) {
        // Set the message text to the error description
        alert.messageText = error.errorDescription
        
        // Set informative text from error context if available
        if let message = error.context.message {
            alert.informativeText = message
        }
        
        // Configure alert style based on level
        switch level {
        case .debug, .info:
            alert.alertStyle = .informational
        case .warning:
            alert.alertStyle = .warning
        case .error, .critical:
            alert.alertStyle = .critical
        }
        
        // Set appropriate icon for the error domain if available
        if let icon = iconForErrorDomain(error.domain) {
            alert.icon = icon
        }
    }
    
    /// Gets an appropriate icon for an error domain
    /// - Parameter domain: The error domain
    /// - Returns: An icon for the error, if available
    private func iconForErrorDomain(_ domain: String) -> NSImage? {
        switch domain {
        case "Security":
            return NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "Security Error")
        case "Network", "Connectivity":
            return NSImage(systemSymbolName: "network", accessibilityDescription: "Network Error")
        case "FileSystem":
            return NSImage(systemSymbolName: "folder.badge.questionmark", accessibilityDescription: "File System Error")
        case "Database":
            return NSImage(systemSymbolName: "externaldrive.badge.exclamationmark", accessibilityDescription: "Database Error")
        default:
            return NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Error")
        }
    }
    
    /// Adds recovery option buttons to an alert
    /// - Parameters:
    ///   - alert: The alert to add buttons to
    ///   - options: The recovery options to add
    private func addRecoveryButtons(
        to alert: NSAlert,
        options: [ErrorRecoveryOption]
    ) {
        // Add a button for each recovery option (limited to what macOS supports)
        let maxOptions = 3
        for (index, option) in options.prefix(maxOptions).enumerated() {
            let button = alert.addButton(withTitle: option.title)
            
            // Set button tooltip if description is available
            if let description = option.description {
                button.toolTip = description
            }
            
            // Make the first button the default and primary action
            if index == 0 {
                button.keyEquivalent = "\r" // Return key
                
                // If the option is disruptive, use a different key equivalent
                if option.isDisruptive {
                    button.keyEquivalent = ""
                }
            }
        }
        
        // Add a "Cancel" button as the last option
        let cancelButton = alert.addButton(withTitle: "Cancel")
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
    }
    
    /// Handles the response from an alert
    /// - Parameters:
    ///   - response: The button clicked
    ///   - recoveryOptions: The recovery options presented
    /// - Returns: The ID of the chosen recovery option, if any
    private func handleAlertResponse(
        _ response: NSApplication.ModalResponse,
        recoveryOptions: [ErrorRecoveryOption]?
    ) -> String? {
        guard let recoveryOptions = recoveryOptions, !recoveryOptions.isEmpty else {
            return nil
        }
        
        // Calculate which button was clicked
        let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
        
        // Check if a valid recovery option was selected
        if buttonIndex >= 0 && buttonIndex < recoveryOptions.count {
            return recoveryOptions[buttonIndex].id
        }
        
        // Cancel or no valid selection
        return nil
    }
    #endif
}

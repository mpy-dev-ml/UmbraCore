import Foundation
#if os(macOS)
  import AppKit
#endif
import ErrorHandlingInterfaces
import ErrorHandlingRecovery

/// A macOS implementation of the ErrorNotificationService
@MainActor
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
    supportedErrorDomains = supportedDomains ?? []
    self.supportedLevels = supportedLevels
  }

  /// Creates a notification service that handles all domains
  /// - Returns: A notification service for all error domains
  public static func forAllDomains() -> MacErrorNotificationService {
    MacErrorNotificationService(supportedDomains: nil)
  }

  /// Notifies the user about an error using macOS alerts
  /// - Parameters:
  ///   - error: The error to notify about
  ///   - level: The notification level
  ///   - recoveryOptions: Recovery options to present
  /// - Returns: The chosen recovery option ID, if any
  public func notifyUser(
    about error: some UmbraError,
    level: ErrorNotificationLevel,
    recoveryOptions: [ErrorRecoveryOption]
  ) async -> UUID? {
    // Skip if this service doesn't support the error domain or level
    if !canHandle(error) || !supportedLevels.contains(level) {
      return nil
    }

    #if os(macOS)
      // Create and configure the alert
      let alert = NSAlert()
      configureAlert(alert, for: error, level: level)

      // Add recovery options as buttons if available
      if !recoveryOptions.isEmpty {
        addRecoveryButtons(to: alert, options: recoveryOptions)
      } else {
        // Add default OK button if no recovery options
        alert.addButton(withTitle: "OK")
      }

      // Run the alert modally and get the user's choice
      let response = alert.runModal()

      // The button indexes are 1000, 1001, 1002, etc.
      // Subtract 1000 and check if it's valid for our options
      let buttonIndex = Int(response.rawValue) - 1_000
      if buttonIndex >= 0 && buttonIndex < recoveryOptions.count {
        return recoveryOptions[buttonIndex].id
      }
    #endif

    return nil
  }

  /// Checks if this service can handle a specific error
  /// - Parameter error: The error to check
  /// - Returns: Whether this service can handle the error
  public func canHandle(_ error: some UmbraError) -> Bool {
    // If no specific domains are defined, handle all
    if supportedErrorDomains.isEmpty {
      return true
    }

    // Otherwise, check if the error's domain is supported
    return supportedErrorDomains.contains(error.domain)
  }

  // MARK: - Private Methods

  #if os(macOS)
    /// Configures an alert for an error
    /// - Parameters:
    ///   - alert: The alert to configure
    ///   - error: The error to display
    ///   - level: The notification level
    @MainActor
    private func configureAlert(
      _ alert: NSAlert,
      for error: ErrorHandlingInterfaces.UmbraError,
      level: ErrorNotificationLevel
    ) {
      // Set the alert's title based on error domain
      alert.messageText = "Error in \(error.domain)"

      // Set the alert's message to the error description
      alert.informativeText = error.errorDescription

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
          NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "Security Error")
        case "Network", "Connectivity":
          NSImage(systemSymbolName: "network", accessibilityDescription: "Network Error")
        case "FileSystem":
          NSImage(
            systemSymbolName: "folder.badge.questionmark",
            accessibilityDescription: "File System Error"
          )
        case "Database":
          NSImage(
            systemSymbolName: "externaldrive.badge.exclamationmark",
            accessibilityDescription: "Database Error"
          )
        default:
          NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Error")
      }
    }

    /// Adds recovery option buttons to an alert
    /// - Parameters:
    ///   - alert: The alert to add buttons to
    ///   - options: The recovery options to add
    @MainActor
    private func addRecoveryButtons(
      to alert: NSAlert,
      options: [ErrorHandlingRecovery.ErrorRecoveryOption]
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
  #endif
}

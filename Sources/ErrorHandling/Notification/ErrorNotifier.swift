import ErrorHandlingInterfaces
import ErrorHandlingRecovery
import Foundation
import UmbraLogging

/// Protocol for services that can notify users about errors
@MainActor
public protocol ErrorNotificationService: Sendable {
  /// Present a notification to the user about an error
  /// - Parameters:
  ///   - error: The error to notify the user about
  ///   - level: The severity level of the notification
  ///   - recoveryOptions: Available recovery options to present
  /// - Returns: The ID of the chosen recovery option, if applicable
  func notifyUser(
    about error: some UmbraError,
    level: ErrorNotificationLevel,
    recoveryOptions: [ErrorRecoveryOption]
  ) async -> UUID?

  /// Whether this service can handle a particular error
  /// - Parameter error: The error to check
  /// - Returns: Whether this service can handle the error
  func canHandle(_ error: some UmbraError) -> Bool

  /// The types of errors that this service can handle
  var supportedErrorDomains: [String] { get }

  /// The notification levels that this service supports
  var supportedLevels: [ErrorNotificationLevel] { get }
}

/// Represents the level of notification for an error
public enum ErrorNotificationLevel: Int, Comparable, Sendable {
  case debug=0 // Developer-focused, typically not shown to end users
  case info=1 // Informational, non-critical
  case warning=2 // Warning that might need attention
  case error=3 // Error that needs attention
  case critical=4 // Critical error that requires immediate attention

  public static func < (lhs: ErrorNotificationLevel, rhs: ErrorNotificationLevel) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

  /// Converts a UmbraLogLevel to ErrorNotificationLevel
  /// - Parameter logLevel: The log level to convert
  /// - Returns: The corresponding notification level
  public static func from(logLevel: UmbraLogLevel) -> ErrorNotificationLevel {
    switch logLevel {
      case .verbose, .debug:
        .debug
      case .info:
        .info
      case .warning:
        .warning
      case .error:
        .error
      case .critical, .fault:
        .critical
    }
  }
}

/// Central coordinating service for error notifications
@MainActor
public final class ErrorNotifier {
  /// The shared instance
  public static let shared=ErrorNotifier()

  /// Registered notification services
  private var notificationServices: [ErrorNotificationService]=[]

  /// The minimum level for notifications
  public var minimumNotificationLevel: ErrorNotificationLevel = .warning

  /// Whether automatic notification is enabled
  public var automaticNotificationEnabled: Bool=true

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
    about error: ErrorHandlingInterfaces.UmbraError,
    level: ErrorNotificationLevel,
    recoveryOptions: [ErrorHandlingRecovery.ErrorRecoveryOption]?=nil
  ) async -> UUID? {
    // Skip if level is below minimum
    guard level >= minimumNotificationLevel else {
      return nil
    }

    // Find appropriate notification services for this error's domain
    let applicableServices=notificationServices.filter { service in
      service.supportedErrorDomains.contains(error.domain) &&
        service.supportedLevels.contains(level)
    }

    // Get recovery options if not provided
    let options=recoveryOptions ?? ErrorHandlingRecovery.ErrorRecoveryRegistry.shared
      .recoveryOptions(for: error)

    // Try each service until one handles the notification
    for service in applicableServices {
      if
        let chosenOptionID=await service.notifyUser(
          about: error,
          level: level,
          recoveryOptions: options
        )
      {
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
    from error: ErrorHandlingInterfaces.UmbraError,
    level: ErrorNotificationLevel
  ) async -> Bool {
    // Get recovery options
    let options=ErrorHandlingRecovery.ErrorRecoveryRegistry.shared.recoveryOptions(for: error)

    // Skip if no options available
    guard !options.isEmpty else {
      // Just notify without recovery options
      _=await notifyUser(about: error, level: level)
      return false
    }

    // Notify user and get chosen option
    if
      let chosenOptionID=await notifyUser(
        about: error,
        level: level,
        recoveryOptions: options
      )
    {
      // Find the chosen option
      if let chosenOption=options.first(where: { $0.id == chosenOptionID }) {
        // Attempt recovery with the chosen option
        await chosenOption.perform()
        return true
      }
    }

    return false
  }
}

/// Extension to UmbraError for notification capabilities
extension ErrorHandlingInterfaces.UmbraError {
  /// Notifies the user about this error
  /// - Parameters:
  ///   - level: The notification level
  ///   - logError: Whether to also log the error
  /// - Returns: The chosen recovery option ID, if any
  public func notify(
    level: ErrorNotificationLevel = .error,
    logError: Bool=true
  ) async -> UUID? {
    // Log the error if requested
    if logError {
      switch level {
        case .debug:
          print("DEBUG: [\(domain)] \(errorDescription)")
        case .info:
          print("INFO: [\(domain)] \(errorDescription)")
        case .warning:
          print("WARNING: [\(domain)] \(errorDescription)")
        case .error, .critical:
          print("ERROR: [\(domain)] \(errorDescription)")
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
  public func notifyAndRecover(
    level: ErrorNotificationLevel = .error,
    logError: Bool=true
  ) async -> Bool {
    // Log the error if requested
    if logError {
      switch level {
        case .debug:
          print("DEBUG: [\(domain)] \(errorDescription)")
        case .info:
          print("INFO: [\(domain)] \(errorDescription)")
        case .warning:
          print("WARNING: [\(domain)] \(errorDescription)")
        case .error, .critical:
          print("ERROR: [\(domain)] \(errorDescription)")
      }
    }

    // Notify and recover
    return await ErrorNotifier.shared.notifyAndRecover(from: self, level: level)
  }
}

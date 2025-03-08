import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

/// Maps application errors from different sources to a consolidated ApplicationError
public class ApplicationErrorMapper: ErrorMapper {
  /// The source error type
  public typealias SourceType=UmbraErrors.Application.Core

  /// The target error type
  public typealias TargetType=ApplicationError

  /// The domain this mapper handles
  public let domain="Application"

  /// Create a new application error mapper
  public init() {}

  /// Maps from the source error type to the target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  public func mapError(_ error: SourceType) -> TargetType {
    mapFromTyped(error)
  }

  /// Map from a generic error to an ApplicationError if possible
  /// - Parameter error: Any error
  /// - Returns: An ApplicationError or nil if the error is not mappable
  public func mapFromAny(_ error: Error) -> ApplicationError? {
    // Get the error type name as a string
    let errorType=String(describing: type(of: error))

    // Core application errors
    if errorType.contains("UmbraErrors.Application.Core") {
      if let typedError=error as? UmbraErrors.Application.Core {
        return mapFromTyped(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Core")
    }
    // UI errors
    else if errorType.contains("UmbraErrors.Application.UI") {
      if let typedError=error as? UmbraErrors.Application.UI {
        return mapFromUI(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.UI")
    }
    // Lifecycle errors
    else if errorType.contains("UmbraErrors.Application.Lifecycle") {
      if let typedError=error as? UmbraErrors.Application.Lifecycle {
        return mapFromLifecycle(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Lifecycle")
    }
    // Settings errors
    else if errorType.contains("UmbraErrors.Application.Settings") {
      if let typedError=error as? UmbraErrors.Application.Settings {
        return mapFromSettings(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Settings")
    } else {
      // Only map if it seems like an application error
      let errorDescription=String(describing: error).lowercased()
      if errorDescription.contains("init") || errorDescription.contains("application") {
        return .unknown("Unmapped application error: \(errorDescription)")
      }
    }

    return nil
  }

  /// Maps from UmbraErrors.Application.Core to our consolidated ApplicationError
  /// - Parameter error: The source UmbraErrors.Application.Core error
  /// - Returns: The mapped ApplicationError
  public func mapFromTyped(_ error: UmbraErrors.Application.Core) -> ApplicationError {
    switch error {
      case let .configurationError(reason):
        return .configurationError("Configuration error: \(reason)")
      case let .initializationError(component, reason):
        return .initializationError("Initialization error in \(component): \(reason)")
      case let .resourceNotFound(resourceType, identifier):
        return .resourceNotFound("\(resourceType) not found with ID: \(identifier)")
      case let .resourceAlreadyExists(resourceType, identifier):
        return .resourceAlreadyExists("\(resourceType) already exists with ID: \(identifier)")
      case let .operationTimeout(operation, durationMs):
        return .operationTimeout("Operation timed out after \(durationMs)ms: \(operation)")
      case let .operationCancelled(operation):
        return .operationCancelled("Operation cancelled: \(operation)")
      case let .invalidState(currentState, expectedState):
        return .invalidState("Invalid state: current=\(currentState), expected=\(expectedState)")
      case let .dependencyError(dependency, reason):
        return .dependencyError("Dependency error for \(dependency): \(reason)")
      case let .externalServiceError(service, reason):
        return .externalServiceError("External service error in \(service): \(reason)")
      case let .internalError(reason):
        return .unknown("Internal error: \(reason)")
      @unknown default:
        return .unknown("Unknown application core error: \(error)")
    }
  }

  /// Maps from UmbraErrors.Application.UI to our consolidated ApplicationError
  /// - Parameter error: The source UmbraErrors.Application.UI error
  /// - Returns: The mapped ApplicationError
  private func mapFromUI(_ error: UmbraErrors.Application.UI) -> ApplicationError {
    switch error {
      case let .viewNotFound(identifier):
        return .viewError("View not found: \(identifier)")
      case let .invalidViewState(view, state):
        return .viewError("Invalid view state for \(view): \(state)")
      case let .renderingError(view, reason):
        return .renderingError("Rendering error for \(view): \(reason)")
      case let .animationError(animation, reason):
        return .renderingError("Animation error for \(animation): \(reason)")
      case let .constraintError(constraint, reason):
        return .viewError("Constraint error for \(constraint): \(reason)")
      case let .resourceLoadingError(resource, reason):
        return .resourceLoadingError("Resource loading error for \(resource): \(reason)")
      case let .inputValidationError(field, reason):
        return .inputValidationError("Validation error for \(field): \(reason)")
      case let .componentInitializationError(component, reason):
        return .initializationError("Component initialization error for \(component): \(reason)")
      case let .internalError(reason):
        return .unknown("Internal UI error: \(reason)")
      @unknown default:
        return .unknown("Unknown UI error: \(error)")
    }
  }

  /// Maps from UmbraErrors.Application.Lifecycle to our consolidated ApplicationError
  /// - Parameter error: The source UmbraErrors.Application.Lifecycle error
  /// - Returns: The mapped ApplicationError
  private func mapFromLifecycle(_ error: UmbraErrors.Application.Lifecycle) -> ApplicationError {
    switch error {
      case let .launchError(reason):
        return .lifecycleError("Launch error: \(reason)")
      case let .backgroundTransitionError(reason):
        return .lifecycleError("Background transition error: \(reason)")
      case let .foregroundTransitionError(reason):
        return .lifecycleError("Foreground transition error: \(reason)")
      case let .terminationError(reason):
        return .lifecycleError("Termination error: \(reason)")
      case let .stateRestorationError(reason):
        return .stateError("State restoration error: \(reason)")
      case let .statePreservationError(reason):
        return .stateError("State preservation error: \(reason)")
      case let .memoryWarningError(reason):
        return .lifecycleError("Memory warning error: \(reason)")
      case let .notificationHandlingError(notification, reason):
        return .lifecycleError("Notification handling error for \(notification): \(reason)")
      case let .internalError(reason):
        return .unknown("Internal lifecycle error: \(reason)")
      @unknown default:
        return .unknown("Unknown lifecycle error: \(error)")
    }
  }

  /// Maps from UmbraErrors.Application.Settings to our consolidated ApplicationError
  /// - Parameter error: The source UmbraErrors.Application.Settings error
  /// - Returns: The mapped ApplicationError
  private func mapFromSettings(_ error: UmbraErrors.Application.Settings) -> ApplicationError {
    switch error {
      case let .settingsNotFound(key):
        return .settingsError("Settings not found for key: \(key)")
      case let .invalidValue(key, value, reason):
        return .settingsError("Invalid value '\(value)' for key '\(key)': \(reason)")
      case let .accessError(key, reason):
        return .settingsError("Settings access error for key '\(key)': \(reason)")
      case let .persistenceError(reason):
        return .settingsError("Settings persistence error: \(reason)")
      case let .migrationError(fromVersion, toVersion, reason):
        return .settingsError(
          "Settings migration error from \(fromVersion) to \(toVersion): \(reason)"
        )
      case let .synchronizationError(reason):
        return .settingsError("Settings synchronization error: \(reason)")
      case let .defaultSettingsError(reason):
        return .settingsError("Default settings error: \(reason)")
      case let .schemaValidationError(reason):
        return .settingsError("Settings schema validation error: \(reason)")
      case let .internalError(reason):
        return .unknown("Internal settings error: \(reason)")
      @unknown default:
        return .unknown("Unknown settings error: \(error)")
    }
  }
}

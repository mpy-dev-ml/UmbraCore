import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

/// Maps application errors from different sources to a consolidated ApplicationError
public class ApplicationErrorMapper: ErrorMapper {
  /// The source error type
  public typealias SourceType = UmbraErrors.Application.Core
  
  /// The target error type
  public typealias TargetType = ApplicationError
  
  /// The domain this mapper handles
  public let domain = "Application"

  /// Create a new application error mapper
  public init() {}
  
  /// Maps from the source error type to the target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  public func mapError(_ error: SourceType) -> TargetType {
    return mapFromTyped(error)
  }

  /// Map from a generic error to an ApplicationError if possible
  /// - Parameter error: Any error
  /// - Returns: An ApplicationError or nil if the error is not mappable
  public func mapFromAny(_ error: Error) -> ApplicationError? {
    // Get the error type name as a string
    let errorType = String(describing: type(of: error))

    // Core application errors
    if errorType.contains("UmbraErrors.Application.Core") {
      if let typedError = error as? UmbraErrors.Application.Core {
        return mapFromTyped(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Core")
    }
    // UI errors
    else if errorType.contains("UmbraErrors.Application.UI") {
      if let typedError = error as? UmbraErrors.Application.UI {
        return mapFromUI(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.UI")
    }
    // Lifecycle errors
    else if errorType.contains("UmbraErrors.Application.Lifecycle") {
      if let typedError = error as? UmbraErrors.Application.Lifecycle {
        return mapFromLifecycle(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Lifecycle")
    }
    // Settings errors
    else if errorType.contains("UmbraErrors.Application.Settings") {
      if let typedError = error as? UmbraErrors.Application.Settings {
        return mapFromSettings(typedError)
      }
      return .unknown("Unable to cast to UmbraErrors.Application.Settings")
    }
    else {
      // Only map if it seems like an application error
      let errorDescription = String(describing: error).lowercased()
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
    case .configurationError(let reason):
      return .configurationError("Configuration error: \(reason)")
    case .initializationError(let component, let reason):
      return .initializationError("Initialization error in \(component): \(reason)")
    case .resourceNotFound(let resourceType, let identifier):
      return .resourceNotFound("\(resourceType) not found with ID: \(identifier)")
    case .resourceAlreadyExists(let resourceType, let identifier):
      return .resourceAlreadyExists("\(resourceType) already exists with ID: \(identifier)")
    case .operationTimeout(let operation, let durationMs):
      return .operationTimeout("Operation timed out after \(durationMs)ms: \(operation)")
    case .operationCancelled(let operation):
      return .operationCancelled("Operation cancelled: \(operation)")
    case .invalidState(let currentState, let expectedState):
      return .invalidState("Invalid state: current=\(currentState), expected=\(expectedState)")
    case .dependencyError(let dependency, let reason):
      return .dependencyError("Dependency error for \(dependency): \(reason)")
    case .externalServiceError(let service, let reason):
      return .externalServiceError("External service error in \(service): \(reason)")
    case .internalError(let reason):
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
    case .viewNotFound(let identifier):
      return .viewError("View not found: \(identifier)")
    case .invalidViewState(let view, let state):
      return .viewError("Invalid view state for \(view): \(state)")
    case .renderingError(let view, let reason):
      return .renderingError("Rendering error for \(view): \(reason)")
    case .animationError(let animation, let reason):
      return .renderingError("Animation error for \(animation): \(reason)")
    case .constraintError(let constraint, let reason):
      return .viewError("Constraint error for \(constraint): \(reason)")
    case .resourceLoadingError(let resource, let reason):
      return .resourceLoadingError("Resource loading error for \(resource): \(reason)")
    case .inputValidationError(let field, let reason):
      return .inputValidationError("Validation error for \(field): \(reason)")
    case .componentInitializationError(let component, let reason):
      return .initializationError("Component initialization error for \(component): \(reason)")
    case .internalError(let reason):
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
    case .launchError(let reason):
      return .lifecycleError("Launch error: \(reason)")
    case .backgroundTransitionError(let reason):
      return .lifecycleError("Background transition error: \(reason)")
    case .foregroundTransitionError(let reason):
      return .lifecycleError("Foreground transition error: \(reason)")
    case .terminationError(let reason):
      return .lifecycleError("Termination error: \(reason)")
    case .stateRestorationError(let reason):
      return .stateError("State restoration error: \(reason)")
    case .statePreservationError(let reason):
      return .stateError("State preservation error: \(reason)")
    case .memoryWarningError(let reason):
      return .lifecycleError("Memory warning error: \(reason)")
    case .notificationHandlingError(let notification, let reason):
      return .lifecycleError("Notification handling error for \(notification): \(reason)")
    case .internalError(let reason):
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
    case .settingsNotFound(let key):
      return .settingsError("Settings not found for key: \(key)")
    case .invalidValue(let key, let value, let reason):
      return .settingsError("Invalid value '\(value)' for key '\(key)': \(reason)")
    case .accessError(let key, let reason):
      return .settingsError("Settings access error for key '\(key)': \(reason)")
    case .persistenceError(let reason):
      return .settingsError("Settings persistence error: \(reason)")
    case .migrationError(let fromVersion, let toVersion, let reason):
      return .settingsError("Settings migration error from \(fromVersion) to \(toVersion): \(reason)")
    case .synchronizationError(let reason):
      return .settingsError("Settings synchronization error: \(reason)")
    case .defaultSettingsError(let reason):
      return .settingsError("Default settings error: \(reason)")
    case .schemaValidationError(let reason):
      return .settingsError("Settings schema validation error: \(reason)")
    case .internalError(let reason):
      return .unknown("Internal settings error: \(reason)")
    @unknown default:
      return .unknown("Unknown settings error: \(error)")
    }
  }
}

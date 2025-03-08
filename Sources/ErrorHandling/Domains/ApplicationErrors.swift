import Foundation

extension UmbraErrors {
  /// Application error domain
  /// Contains error types specific to the application layer
  public enum Application {
    /// Core application errors
    /// These are general errors that can occur at the application level
    public enum Core: Error, Sendable, Equatable {
      /// Configuration error
      case configurationError(reason: String)

      /// Initialization error
      case initializationError(component: String, reason: String)

      /// Resource not found
      case resourceNotFound(resourceType: String, identifier: String)

      /// Resource already exists
      case resourceAlreadyExists(resourceType: String, identifier: String)

      /// Operation timeout
      case operationTimeout(operation: String, durationMs: Int)

      /// Operation cancelled
      case operationCancelled(operation: String)

      /// Invalid application state
      case invalidState(currentState: String, expectedState: String)

      /// Dependency injection error
      case dependencyError(dependency: String, reason: String)

      /// External service error
      case externalServiceError(service: String, reason: String)

      /// Internal error
      case internalError(reason: String)
    }

    /// UI-related errors
    /// These are errors specific to user interface operations
    public enum UI: Error, Sendable, Equatable {
      /// View not found
      case viewNotFound(identifier: String)

      /// Invalid view state
      case invalidViewState(view: String, state: String)

      /// Rendering error
      case renderingError(view: String, reason: String)

      /// Animation error
      case animationError(animation: String, reason: String)

      /// Layout constraint error
      case constraintError(constraint: String, reason: String)

      /// Resource loading error
      case resourceLoadingError(resource: String, reason: String)

      /// User input validation error
      case inputValidationError(field: String, reason: String)

      /// Component initialization error
      case componentInitializationError(component: String, reason: String)

      /// Internal error
      case internalError(reason: String)
    }

    /// Lifecycle-related errors
    /// These errors are related to application lifecycle events
    public enum Lifecycle: Error, Sendable, Equatable {
      /// Launch error
      case launchError(reason: String)

      /// Background transition error
      case backgroundTransitionError(reason: String)

      /// Foreground transition error
      case foregroundTransitionError(reason: String)

      /// Termination error
      case terminationError(reason: String)

      /// State restoration error
      case stateRestorationError(reason: String)

      /// State preservation error
      case statePreservationError(reason: String)

      /// Memory warning handling error
      case memoryWarningError(reason: String)

      /// System notification handling error
      case notificationHandlingError(notification: String, reason: String)

      /// Internal error
      case internalError(reason: String)
    }

    /// Settings-related errors
    /// These errors relate to application settings and preferences
    public enum Settings: Error, Sendable, Equatable {
      /// Settings not found
      case settingsNotFound(key: String)

      /// Invalid settings value
      case invalidValue(key: String, value: String, reason: String)

      /// Settings access error
      case accessError(key: String, reason: String)

      /// Settings persistence error
      case persistenceError(reason: String)

      /// Settings migration error
      case migrationError(fromVersion: String, toVersion: String, reason: String)

      /// Settings synchronization error
      case synchronizationError(reason: String)

      /// Default settings error
      case defaultSettingsError(reason: String)

      /// Settings schema validation error
      case schemaValidationError(reason: String)

      /// Internal error
      case internalError(reason: String)
    }
  }
}

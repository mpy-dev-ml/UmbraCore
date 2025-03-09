import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Application {
  /// Application lifecycle and state management errors
  public enum Lifecycle: Error, UmbraError, Sendable, CustomStringConvertible {
    /// Error during application startup or initialisation
    case startupError(String)
    
    /// Error during application shutdown
    case shutdownError(String)
    
    /// Error transitioning between application states
    case stateTransitionError(String, fromState: String, toState: String)
    
    /// Error with component lifecycle (init, pause, resume, destroy)
    case componentLifecycleError(String, component: String)
    
    /// Error loading or saving application settings
    case settingsError(String)
    
    /// Error during background task execution
    case backgroundTaskError(String)
    
    /// Error during foreground transition
    case foregroundTransitionError(String)
    
    // MARK: - UmbraError Protocol
    
    /// The domain identifier for application lifecycle errors
    public var domain: String {
      "Application.Lifecycle"
    }
    
    /// Error code that uniquely identifies the error type
    public var code: String {
      switch self {
      case .startupError:
        return "startup_error"
      case .shutdownError:
        return "shutdown_error"
      case .stateTransitionError:
        return "state_transition_error"
      case .componentLifecycleError:
        return "component_lifecycle_error"
      case .settingsError:
        return "settings_error"
      case .backgroundTaskError:
        return "background_task_error"
      case .foregroundTransitionError:
        return "foreground_transition_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .startupError(msg):
        return "Application startup error: \(msg)"
      case let .shutdownError(msg):
        return "Application shutdown error: \(msg)"
      case let .stateTransitionError(msg, from, to):
        return "State transition error from \(from) to \(to): \(msg)"
      case let .componentLifecycleError(msg, component):
        return "Component lifecycle error in \(component): \(msg)"
      case let .settingsError(msg):
        return "Settings error: \(msg)"
      case let .backgroundTaskError(msg):
        return "Background task error: \(msg)"
      case let .foregroundTransitionError(msg):
        return "Foreground transition error: \(msg)"
      }
    }
    
    /// A user-readable description of the error
    public var description: String {
      "[\(domain).\(code)] \(errorDescription)"
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "lifecycle_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .startupError(msg):
        return .startupError(msg)
      case let .shutdownError(msg):
        return .shutdownError(msg)
      case let .stateTransitionError(msg, from, to):
        return .stateTransitionError(msg, fromState: from, toState: to)
      case let .componentLifecycleError(msg, component):
        return .componentLifecycleError(msg, component: component)
      case let .settingsError(msg):
        return .settingsError(msg)
      case let .backgroundTaskError(msg):
        return .backgroundTaskError(msg)
      case let .foregroundTransitionError(msg):
        return .foregroundTransitionError(msg)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Application.Lifecycle {
  /// Create a startup error with the specified message
  public static func startup(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Lifecycle {
    .startupError(message)
  }
  
  /// Create a settings error with the specified message
  public static func settings(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Lifecycle {
    .settingsError(message)
  }
  
  /// Create a state transition error with the specified details
  public static func stateTransition(
    _ message: String,
    fromState: String,
    toState: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Lifecycle {
    .stateTransitionError(message, fromState: fromState, toState: toState)
  }
}

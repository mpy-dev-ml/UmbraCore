import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Application {
  /// Core application errors relating to configuration, resources, and operations
  public enum Core: Error, UmbraError, Sendable, CustomStringConvertible {
    // Configuration errors
    /// The application configuration is invalid or missing
    case configurationError(String)
    
    // Resource errors
    /// A required resource could not be found
    case resourceNotFound(String)
    
    /// A resource already exists when attempting to create it
    case resourceAlreadyExists(String)
    
    /// Error loading or accessing a resource
    case resourceLoadingError(String)
    
    // Operation errors
    /// An operation timed out
    case operationTimeout(String)
    
    /// An operation was cancelled
    case operationCancelled(String)
    
    // State errors
    /// The application is in an invalid state for the requested operation
    case invalidState(String)
    
    // Dependency errors
    /// A required dependency encountered an error or is unavailable
    case dependencyError(String)
    
    /// An external service encountered an error
    case externalServiceError(String)
    
    /// Initialisation of a component failed
    case initialisationError(String)
    
    /// Unknown application error
    case unknown(String)
    
    // MARK: - UmbraError Protocol
    
    /// The domain identifier for application core errors
    public var domain: String {
      "Application.Core"
    }
    
    /// Error code that uniquely identifies the error type
    public var code: String {
      switch self {
      case .configurationError:
        return "configuration_error"
      case .resourceNotFound:
        return "resource_not_found"
      case .resourceAlreadyExists:
        return "resource_already_exists"
      case .resourceLoadingError:
        return "resource_loading_error"
      case .operationTimeout:
        return "operation_timeout"
      case .operationCancelled:
        return "operation_cancelled"
      case .invalidState:
        return "invalid_state"
      case .dependencyError:
        return "dependency_error"
      case .externalServiceError:
        return "external_service_error"
      case .initialisationError:
        return "initialisation_error"
      case .unknown:
        return "unknown"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .configurationError(msg):
        return "Configuration error: \(msg)"
      case let .resourceNotFound(msg):
        return "Resource not found: \(msg)"
      case let .resourceAlreadyExists(msg):
        return "Resource already exists: \(msg)"
      case let .resourceLoadingError(msg):
        return "Resource loading error: \(msg)"
      case let .operationTimeout(msg):
        return "Operation timed out: \(msg)"
      case let .operationCancelled(msg):
        return "Operation cancelled: \(msg)"
      case let .invalidState(msg):
        return "Invalid application state: \(msg)"
      case let .dependencyError(msg):
        return "Dependency error: \(msg)"
      case let .externalServiceError(msg):
        return "External service error: \(msg)"
      case let .initialisationError(msg):
        return "Initialisation error: \(msg)"
      case let .unknown(msg):
        return "Unknown application error: \(msg)"
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
        operation: "application_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .configurationError(msg):
        return .configurationError(msg)
      case let .resourceNotFound(msg):
        return .resourceNotFound(msg)
      case let .resourceAlreadyExists(msg):
        return .resourceAlreadyExists(msg)
      case let .resourceLoadingError(msg):
        return .resourceLoadingError(msg)
      case let .operationTimeout(msg):
        return .operationTimeout(msg)
      case let .operationCancelled(msg):
        return .operationCancelled(msg)
      case let .invalidState(msg):
        return .invalidState(msg)
      case let .dependencyError(msg):
        return .dependencyError(msg)
      case let .externalServiceError(msg):
        return .externalServiceError(msg)
      case let .initialisationError(msg):
        return .initialisationError(msg)
      case let .unknown(msg):
        return .unknown(msg)
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

extension UmbraErrors.Application.Core {
  /// Create an application error with the specified type and message
  public static func create(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Core {
    .unknown(message)
  }
  
  /// Create a configuration error with the specified message
  public static func configuration(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Core {
    .configurationError(message)
  }
  
  /// Create a resource not found error with the specified message
  public static func resourceNotFound(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.Core {
    .resourceNotFound(message)
  }
}

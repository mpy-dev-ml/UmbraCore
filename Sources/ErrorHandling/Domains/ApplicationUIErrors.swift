import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Application {
  /// User interface related application errors
  public enum UI: Error, UmbraError, Sendable, CustomStringConvertible {
    /// Error rendering a view or component
    case renderingError(String)
    
    /// Error with user input validation
    case inputValidationError(String)
    
    /// Error loading UI resources (images, fonts, etc.)
    case resourceLoadingError(String)
    
    /// Error with view presentation or management
    case viewError(String)
    
    /// Error with UI state management
    case stateError(String)
    
    /// Error with animations or transitions
    case animationError(String)
    
    /// Error with layout calculations or constraints
    case layoutError(String)
    
    // MARK: - UmbraError Protocol
    
    /// The domain identifier for application UI errors
    public var domain: String {
      "Application.UI"
    }
    
    /// Error code that uniquely identifies the error type
    public var code: String {
      switch self {
      case .renderingError:
        return "rendering_error"
      case .inputValidationError:
        return "input_validation_error"
      case .resourceLoadingError:
        return "resource_loading_error"
      case .viewError:
        return "view_error"
      case .stateError:
        return "state_error"
      case .animationError:
        return "animation_error"
      case .layoutError:
        return "layout_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .renderingError(msg):
        return "UI rendering error: \(msg)"
      case let .inputValidationError(msg):
        return "Input validation error: \(msg)"
      case let .resourceLoadingError(msg):
        return "UI resource loading error: \(msg)"
      case let .viewError(msg):
        return "View error: \(msg)"
      case let .stateError(msg):
        return "UI state error: \(msg)"
      case let .animationError(msg):
        return "Animation error: \(msg)"
      case let .layoutError(msg):
        return "Layout error: \(msg)"
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
        operation: "ui_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .renderingError(msg):
        return .renderingError(msg)
      case let .inputValidationError(msg):
        return .inputValidationError(msg)
      case let .resourceLoadingError(msg):
        return .resourceLoadingError(msg)
      case let .viewError(msg):
        return .viewError(msg)
      case let .stateError(msg):
        return .stateError(msg)
      case let .animationError(msg):
        return .animationError(msg)
      case let .layoutError(msg):
        return .layoutError(msg)
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

extension UmbraErrors.Application.UI {
  /// Create a rendering error with the specified message
  public static func rendering(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.UI {
    .renderingError(message)
  }
  
  /// Create an input validation error with the specified message
  public static func inputValidation(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.UI {
    .inputValidationError(message)
  }
  
  /// Create a view error with the specified message
  public static func view(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> UmbraErrors.Application.UI {
    .viewError(message)
  }
}

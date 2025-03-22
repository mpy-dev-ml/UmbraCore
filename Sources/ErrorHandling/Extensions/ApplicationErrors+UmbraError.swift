import ErrorHandlingCommon
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import Foundation

// MARK: - Error Wrapper Types

// Create wrapper types in our own module that can safely conform to UmbraError

/// Wrapper for UmbraErrors.Application.Core that conforms to UmbraError
public struct ApplicationCoreErrorWrapper: UmbraError, CustomStringConvertible {
  private let wrappedError: UmbraErrors.Application.Core

  /// The source of the error
  public var source: ErrorHandlingInterfaces.ErrorSource?

  /// The underlying error that caused this error
  public var underlyingError: Error?

  /// Additional context for the error
  public var context: ErrorHandlingInterfaces.ErrorContext = .init(
    source: "ApplicationCoreErrorWrapper",
    operation: "wrapping",
    details: nil,
    underlyingError: nil
  )

  public init(_ error: UmbraErrors.Application.Core) {
    wrappedError=error
    source=nil
    underlyingError=nil
  }

  /// The domain that this error belongs to
  public var domain: String {
    "Application.Core"
  }

  /// A unique code that identifies this error within its domain
  public var code: String {
    switch wrappedError {
      case .configurationError:
        return "CONFIGURATION_ERROR"
      case .resourceNotFound:
        return "RESOURCE_NOT_FOUND"
      case .resourceAlreadyExists:
        return "RESOURCE_ALREADY_EXISTS"
      case .resourceLoadingError:
        return "RESOURCE_LOADING_ERROR"
      case .operationTimeout:
        return "OPERATION_TIMEOUT"
      case .operationCancelled:
        return "OPERATION_CANCELLED"
      case .invalidState:
        return "INVALID_STATE"
      case .dependencyError:
        return "DEPENDENCY_ERROR"
      case .externalServiceError:
        return "EXTERNAL_SERVICE_ERROR"
      case .initialisationError:
        return "INITIALISATION_ERROR"
      case .unknown:
        return "UNKNOWN_ERROR"
      @unknown default:
        return "UNKNOWN_ERROR"
    }
  }

  /// A standard user-facing message describing the error
  public var errorDescription: String {
    switch wrappedError {
      case let .configurationError(reason):
        return "Configuration error: \(reason)"
      case let .resourceNotFound(resourceInfo):
        return "Resource not found: \(resourceInfo)"
      case let .resourceAlreadyExists(resourceInfo):
        return "Resource already exists: \(resourceInfo)"
      case let .resourceLoadingError(reason):
        return "Error loading resource: \(reason)"
      case let .operationTimeout(operation):
        return "Operation timed out: \(operation)"
      case let .operationCancelled(operation):
        return "Operation was cancelled: \(operation)"
      case let .invalidState(state):
        return "Application is in an invalid state: \(state)"
      case let .dependencyError(dependency):
        return "Dependency error: \(dependency)"
      case let .externalServiceError(service):
        return "External service error: \(service)"
      case let .initialisationError(component):
        return "Failed to initialise component: \(component)"
      case let .unknown(reason):
        return "Unknown application error: \(reason)"
      @unknown default:
        return "Unknown application error"
    }
  }

  /// Additional technical details that may help developers diagnose the issue
  public var recoverySuggestion: String {
    switch wrappedError {
      case .configurationError:
        return "Check the application configuration and ensure all required settings are valid."
      case .resourceNotFound:
        return "Ensure the resource exists and has the correct identifier."
      case .resourceAlreadyExists:
        return "Use a different identifier or remove the existing resource before creating a new one."
      case .resourceLoadingError:
        return "Check network connectivity and server response times. Try again later."
      case .operationTimeout:
        return "Check network connectivity and server response times. Try again later."
      case .operationCancelled:
        return "The operation was cancelled. You may try again if needed."
      case .invalidState:
        return "The application is in an incorrect state for this operation. Try restarting the application."
      case .dependencyError:
        return "Check that all required dependencies are properly installed and configured."
      case .externalServiceError:
        return "Check the external service status and configuration. The service might be temporarily unavailable."
      case .initialisationError:
        return "Verify that all dependencies are available and properly configured."
      case .unknown:
        return "An unexpected error occurred. Please restart the application and try again."
      @unknown default:
        return "An unexpected error occurred. Please restart the application and try again."
    }
  }

  /// Get the underlying wrapped error object
  public var wrappedApplicationError: UmbraErrors.Application.Core {
    wrappedError
  }

  // MARK: - CustomStringConvertible Conformance

  /// A textual representation of the error
  public var description: String {
    errorDescription
  }

  // MARK: - Context and Source Methods

  /// Creates a new instance of the error with additional context
  public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
    var copy=self
    copy.context=context
    return copy
  }

  /// Creates a new instance of the error with a specified underlying error
  public func with(underlyingError: Error) -> Self {
    var copy=self
    copy.underlyingError=underlyingError
    return copy
  }

  /// Creates a new instance of the error with source information
  public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
    var copy=self
    copy.source=source
    return copy
  }
}

// MARK: - Extension for Error type to provide easy access to wrapped errors

extension Error {
  /// Try to wrap an Application.Core error in a type that conforms to UmbraError
  public var asApplicationCoreError: ApplicationCoreErrorWrapper? {
    self as? ApplicationCoreErrorWrapper ?? (self as? UmbraErrors.Application.Core)
      .map(ApplicationCoreErrorWrapper.init)
  }
}

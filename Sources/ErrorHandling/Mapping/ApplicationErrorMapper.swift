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
    // Simplify the mapping to avoid issues with mismatched enum cases
    let errorDescription = String(describing: error)
    
    // Basic mapping based on the error description
    if errorDescription.contains("configurationError") {
      return .configurationError("Configuration error: \(errorDescription)")
    } else if errorDescription.contains("resourceNotFound") {
      return .resourceNotFound("Resource not found: \(errorDescription)")
    } else if errorDescription.contains("resourceAlreadyExists") {
      return .resourceAlreadyExists("Resource already exists: \(errorDescription)")
    } else if errorDescription.contains("operationTimeout") {
      return .operationTimeout("Operation timed out: \(errorDescription)")
    } else if errorDescription.contains("operationCancelled") {
      return .operationCancelled("Operation cancelled: \(errorDescription)")
    } else {
      // Default fallback
      return .unknown("Application error: \(errorDescription)")
    }
  }

  /// Maps from UmbraErrors.Application.UI to ApplicationError for UI-specific issues
  /// - Parameter error: The source UmbraErrors.Application.UI error
  /// - Returns: The mapped ApplicationError
  private func mapFromUI(_ error: UmbraErrors.Application.UI) -> ApplicationError {
    // Use string descriptions to avoid pattern matching problems
    let errorDescription = String(describing: error)
    
    if errorDescription.contains("viewNotFound") {
      return .viewError("View not found error: \(errorDescription)")
    } else if errorDescription.contains("renderingError") {
      return .renderingError("Rendering error: \(errorDescription)")
    } else if errorDescription.contains("animationError") {
      return .renderingError("Animation error: \(errorDescription)")
    } else {
      // Default fallback for other UI errors
      return .viewError("UI error: \(errorDescription)")
    }
  }

  /// Maps from UmbraErrors.Application.Lifecycle to ApplicationError
  /// - Parameter error: The source UmbraErrors.Application.Lifecycle error
  /// - Returns: The mapped ApplicationError
  private func mapFromLifecycle(_ error: UmbraErrors.Application.Lifecycle) -> ApplicationError {
    // Use string description to avoid pattern matching problems with enum cases
    let errorDescription = String(describing: error)
    
    if errorDescription.contains("launchError") {
      return .lifecycleError("Launch error: \(errorDescription)")
    } else if errorDescription.contains("backgroundTransition") {
      return .lifecycleError("Background transition error: \(errorDescription)")
    } else if errorDescription.contains("foregroundTransition") {
      return .lifecycleError("Foreground transition error: \(errorDescription)")
    } else if errorDescription.contains("termination") {
      return .lifecycleError("Termination error: \(errorDescription)")
    } else if errorDescription.contains("stateRestoration") {
      return .stateError("State restoration error: \(errorDescription)")
    } else if errorDescription.contains("statePreservation") {
      return .stateError("State preservation error: \(errorDescription)")
    } else if errorDescription.contains("memoryWarning") {
      return .lifecycleError("Memory warning error: \(errorDescription)")
    } else {
      return .lifecycleError("Lifecycle error: \(errorDescription)")
    }
  }

  /// Maps from UmbraErrors.Application.Core to our consolidated ApplicationError for
  /// settings-related issues
  /// - Parameter error: The source UmbraErrors.Application.Core error
  /// - Returns: The mapped ApplicationError
  private func mapFromSettings(_ error: UmbraErrors.Application.Core) -> ApplicationError {
    // Use string descriptions to categorize settings-related errors
    let errorDescription = String(describing: error)
    
    if errorDescription.contains("configurationMissing") {
      return .settingsError("Settings not found: \(errorDescription)")
    } else if errorDescription.contains("configurationInvalid") {
      return .settingsError("Invalid settings: \(errorDescription)")
    } else if errorDescription.contains("persistenceFailed") {
      return .settingsError("Settings persistence error: \(errorDescription)")
    } else {
      return .unknown("Unhandled settings error: \(errorDescription)")
    }
  }
}

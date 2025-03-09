import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Resource {
  /// Core resource errors related to resource acquisition and management
  public enum Core: Error, UmbraError, StandardErrorCapabilities, ResourceErrors {
    // Resource acquisition errors
    /// Failed to acquire resource
    case acquisitionFailed(resource: String, reason: String)
    
    /// Resource is in an invalid state for the requested operation
    case invalidState(resource: String, currentState: String, requiredState: String?)
    
    /// Resource pool is exhausted (no more resources available)
    case poolExhausted(poolName: String, limit: Int)
    
    /// Resource not found
    case resourceNotFound(resource: String)
    
    /// Resource already exists
    case resourceAlreadyExists(resource: String)
    
    // Resource operation errors
    /// Resource operation failed
    case operationFailed(resource: String, operation: String, reason: String)
    
    /// Resource is locked by another process or thread
    case resourceLocked(resource: String, owner: String?)
    
    /// Timeout occurred waiting for resource
    case timeout(resource: String, timeoutMs: Int)
    
    /// Resource is corrupt
    case resourceCorrupt(resource: String, reason: String)
    
    /// Access to resource denied
    case accessDenied(resource: String, reason: String)
    
    /// Internal resource error
    case internalError(reason: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for resource core errors
    public var domain: String {
      "Resource.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .acquisitionFailed:
        return "acquisition_failed"
      case .invalidState:
        return "invalid_state"
      case .poolExhausted:
        return "pool_exhausted"
      case .resourceNotFound:
        return "resource_not_found"
      case .resourceAlreadyExists:
        return "resource_already_exists"
      case .operationFailed:
        return "operation_failed"
      case .resourceLocked:
        return "resource_locked"
      case .timeout:
        return "timeout"
      case .resourceCorrupt:
        return "resource_corrupt"
      case .accessDenied:
        return "access_denied"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .acquisitionFailed(resource, reason):
        return "Failed to acquire resource '\(resource)': \(reason)"
      case let .invalidState(resource, currentState, requiredState):
        if let required = requiredState {
          return "Resource '\(resource)' is in invalid state: current '\(currentState)', required '\(required)'"
        } else {
          return "Resource '\(resource)' is in invalid state: '\(currentState)'"
        }
      case let .poolExhausted(poolName, limit):
        return "Resource pool '\(poolName)' exhausted (limit: \(limit))"
      case let .resourceNotFound(resource):
        return "Resource not found: '\(resource)'"
      case let .resourceAlreadyExists(resource):
        return "Resource already exists: '\(resource)'"
      case let .operationFailed(resource, operation, reason):
        return "Operation '\(operation)' failed for resource '\(resource)': \(reason)"
      case let .resourceLocked(resource, owner):
        if let owner = owner {
          return "Resource '\(resource)' is locked by: \(owner)"
        } else {
          return "Resource '\(resource)' is locked by another process"
        }
      case let .timeout(resource, timeoutMs):
        return "Timeout waiting for resource '\(resource)' after \(timeoutMs)ms"
      case let .resourceCorrupt(resource, reason):
        return "Resource '\(resource)' is corrupt: \(reason)"
      case let .accessDenied(resource, reason):
        return "Access denied to resource '\(resource)': \(reason)"
      case let .internalError(reason):
        return "Internal resource error: \(reason)"
      }
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
        operation: "resource_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .acquisitionFailed(resource, reason):
        return .acquisitionFailed(resource: resource, reason: reason)
      case let .invalidState(resource, currentState, requiredState):
        return .invalidState(resource: resource, currentState: currentState, requiredState: requiredState)
      case let .poolExhausted(poolName, limit):
        return .poolExhausted(poolName: poolName, limit: limit)
      case let .resourceNotFound(resource):
        return .resourceNotFound(resource: resource)
      case let .resourceAlreadyExists(resource):
        return .resourceAlreadyExists(resource: resource)
      case let .operationFailed(resource, operation, reason):
        return .operationFailed(resource: resource, operation: operation, reason: reason)
      case let .resourceLocked(resource, owner):
        return .resourceLocked(resource: resource, owner: owner)
      case let .timeout(resource, timeoutMs):
        return .timeout(resource: resource, timeoutMs: timeoutMs)
      case let .resourceCorrupt(resource, reason):
        return .resourceCorrupt(resource: resource, reason: reason)
      case let .accessDenied(resource, reason):
        return .accessDenied(resource: resource, reason: reason)
      case let .internalError(reason):
        return .internalError(reason: reason)
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
    
    // MARK: - ResourceErrors Protocol
    
    /// Creates an error for a missing resource
    public static func resourceNotFound(resource: String) -> Self {
      .resourceNotFound(resource: resource)
    }
    
    /// Creates an error for a resource that already exists
    public static func resourceAlreadyExists(resource: String) -> Self {
      .resourceAlreadyExists(resource: resource)
    }
    
    /// Creates an error for a resource in an invalid format
    public static func resourceInvalidFormat(resource: String, reason: String) -> Self {
      .resourceCorrupt(resource: resource, reason: reason)
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Resource.Core {
  /// Create an error for a failed resource acquisition
  public static func acquisitionFailed(
    resource: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .acquisitionFailed(resource: resource, reason: reason)
  }
  
  /// Create an error for an exhausted resource pool
  public static func poolExhausted(
    poolName: String,
    limit: Int = 0,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .poolExhausted(poolName: poolName, limit: limit)
  }
  
  /// Create an error for a failed resource operation
  public static func operationFailed(
    resource: String,
    operation: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .operationFailed(resource: resource, operation: operation, reason: reason)
  }
}

import Foundation
import ErrorHandlingCommon

/// Severity level for service errors
@frozen
public enum ServiceErrorSeverity: String, Codable, Sendable {
  /// Critical errors that require immediate attention
  case critical
  /// Serious errors that affect functionality
  case error
  /// Less severe issues that may affect performance
  case warning
  /// Informational issues that don't affect functionality
  case info
}

/// Types of service errors
@frozen
public enum ServiceErrorType: String, Sendable, CaseIterable {
  /// Configuration-related errors
  case configuration="Configuration"
  /// Operation-related errors
  case operation="Operation"
  /// State-related errors
  case state="State"
  /// Resource-related errors
  case resource="Resource"
  /// Dependency-related errors
  case dependency="Dependency"
  /// Network-related errors
  case network="Network"
  /// Authentication-related errors
  case authentication="Authentication"
  /// Timeout-related errors
  case timeout="Timeout"
  /// Initialization-related errors
  case initialization="Initialization"
  /// Lifecycle-related errors
  case lifecycle="Lifecycle"
  /// Permission-related errors
  case permission="Permission"
  /// Unknown errors
  case unknown="Unknown"

  /// User-friendly description of the error type
  public var description: String {
    switch self {
      case .configuration:
        "Configuration Error"
      case .operation:
        "Operation Error"
      case .state:
        "State Error"
      case .resource:
        "Resource Error"
      case .dependency:
        "Dependency Error"
      case .network:
        "Network Error"
      case .authentication:
        "Authentication Error"
      case .timeout:
        "Timeout Error"
      case .initialization:
        "Initialization Error"
      case .lifecycle:
        "Lifecycle Error"
      case .permission:
        "Permission Error"
      case .unknown:
        "Unknown Error"
    }
  }
}

import Foundation
import ErrorHandlingCommon
import ErrorHandlingInterfaces

/// Extension to bridge between ErrorSeverity and ErrorNotificationLevel
extension ErrorHandlingCommon.ErrorSeverity {
  /// Converts the error severity to a notification level
  /// - Returns: The corresponding ErrorNotificationLevel
  public func toNotificationLevel() -> ErrorNotificationLevel {
    switch notificationLevel {
    case 4:
      return .critical
    case 3:
      return .error
    case 2:
      return .warning
    case 1:
      return .info
    default:
      return .debug
    }
  }
}

/// Extension to add ErrorSeverity conversion to ErrorNotificationLevel
extension ErrorNotificationLevel {
  /// Convert a notification level to a severity level
  /// - Returns: The corresponding ErrorSeverity
  public func toSeverityLevel() -> ErrorHandlingCommon.ErrorSeverity {
    switch self {
    case .critical:
      return .critical
    case .error:
      return .error
    case .warning:
      return .warning
    case .info:
      return .info
    case .debug:
      return .debug
    @unknown default:
      return .debug
    }
  }
}

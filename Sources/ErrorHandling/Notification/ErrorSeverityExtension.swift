import ErrorHandlingCommon
import ErrorHandlingInterfaces
import Foundation

/// Extension to bridge between ErrorSeverity and ErrorNotificationLevel
public extension ErrorHandlingCommon.ErrorSeverity {
    /// Converts the error severity to a notification level
    /// - Returns: The corresponding ErrorNotificationLevel
    func toNotificationLevel() -> ErrorNotificationLevel {
        switch notificationLevel {
        case 4:
            .critical
        case 3:
            .error
        case 2:
            .warning
        case 1:
            .info
        default:
            .debug
        }
    }
}

/// Extension to add ErrorSeverity conversion to ErrorNotificationLevel
public extension ErrorNotificationLevel {
    /// Convert a notification level to a severity level
    /// - Returns: The corresponding ErrorSeverity
    func toSeverityLevel() -> ErrorHandlingCommon.ErrorSeverity {
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

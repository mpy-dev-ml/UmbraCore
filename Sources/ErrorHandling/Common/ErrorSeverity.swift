import Foundation
@preconcurrency import SwiftyBeaver

/// Error severity levels for classification and logging
public enum ErrorSeverity: String, Comparable, Sendable {
  /// Critical error that requires immediate attention
  case critical = "Critical"
  
  /// Error that indicates a significant problem
  case error = "Error"
  
  /// Warning about potential issues
  case warning = "Warning"
  
  /// Informational message about error conditions
  case info = "Info"
  
  /// Debug-level severity for minor issues
  case debug = "Debug"
  
  /// Trace-level severity for detailed debugging
  case trace = "Trace"
  
  /// Comparison implementation for Comparable protocol
  public static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
    // Reverse order: critical > error > warning > info > debug > trace
    let order: [ErrorSeverity] = [.trace, .debug, .info, .warning, .error, .critical]
    guard let lhsIndex = order.firstIndex(of: lhs),
          let rhsIndex = order.firstIndex(of: rhs) else {
      return false
    }
    return lhsIndex < rhsIndex
  }
  
  /// Indicates whether errors of this severity should be shown to the user
  public var shouldNotify: Bool {
    switch self {
    case .critical, .error, .warning:
      return true
    case .info, .debug, .trace:
      return false
    }
  }
  
  /// Maps the severity level to an integer value that can be used for notification level mapping
  /// - Returns: An integer representing the notification level (0-4)
  public var notificationLevel: Int {
    switch self {
    case .critical:
      return 4 // Critical
    case .error:
      return 3 // Error
    case .warning:
      return 2 // Warning
    case .info:
      return 1 // Info
    case .debug, .trace:
      return 0 // Debug
    }
  }
  
  /// Converts the error severity to a SwiftyBeaver log level
  /// - Returns: The corresponding SwiftyBeaver log level
  public func toSwiftyBeaverLevel() -> SwiftyBeaver.Level {
    switch self {
    case .critical, .error:
      return .error
    case .warning:
      return .warning
    case .info:
      return .info
    case .debug:
      return .debug
    case .trace:
      return .verbose
    }
  }
  
  /// Converts a SwiftyBeaver log level to an ErrorSeverity
  /// - Parameter level: The SwiftyBeaver log level
  /// - Returns: The corresponding ErrorSeverity
  public static func from(swiftyBeaverLevel level: SwiftyBeaver.Level) -> ErrorSeverity {
    switch level {
    case .error:
      return .error
    case .warning:
      return .warning
    case .info:
      return .info
    case .debug:
      return .debug
    case .verbose:
      return .trace
    }
  }
  
  /// String representation of the severity level (in uppercase)
  public var stringValue: String {
    rawValue.uppercased()
  }
}

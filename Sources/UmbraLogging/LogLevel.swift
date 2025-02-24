import Foundation
import SwiftyBeaver

/// Represents the severity level of a log message
@frozen
public enum UmbraLogLevel: Int, Sendable, Comparable {
    case verbose
    case debug
    case info
    case warning
    case error
    case critical
    case fault

    /// Convert to SwiftyBeaver.Level
    var asSBLevel: SwiftyBeaver.Level {
        switch self {
        case .verbose: return .verbose
        case .debug: return .debug
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical, .fault: return .error // SwiftyBeaver doesn't have critical/fault levels
        }
    }

    public static func < (lhs: UmbraLogLevel, rhs: UmbraLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

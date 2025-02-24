import Foundation
import SwiftyBeaver

/// Represents the severity level of a log message.
///
/// The log level determines how a message should be handled and displayed.
/// Levels are ordered from least severe (verbose) to most severe (fault).
///
/// Example:
/// ```swift
/// let level = UmbraLogLevel.warning
/// if level >= .error {
///     // Handle severe issues
/// }
/// ```
@frozen
public enum UmbraLogLevel: Int, Sendable, Comparable {
    /// Detailed information, typically only useful for debugging.
    case verbose

    /// Debug-level messages with more detail than info.
    case debug

    /// General information about program execution.
    case info

    /// Potentially harmful situations that might need attention.
    case warning

    /// Error conditions that should be addressed.
    case error

    /// Critical errors that may lead to program termination.
    case critical

    /// System-level faults requiring immediate attention.
    case fault

    /// Converts this level to the equivalent SwiftyBeaver logging level.
    ///
    /// Note that SwiftyBeaver doesn't support levels above error, so critical
    /// and fault are mapped to error.
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

    /// Compares two log levels based on their severity.
    ///
    /// - Parameters:
    ///   - lhs: The first log level to compare.
    ///   - rhs: The second log level to compare.
    /// - Returns: `true` if the first level is less severe than the second.
    public static func < (lhs: UmbraLogLevel, rhs: UmbraLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

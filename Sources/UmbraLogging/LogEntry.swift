import Foundation
import SwiftyBeaver

/// Represents a log entry in the system
public struct LogEntry {
    /// The timestamp of the log entry
    public let timestamp: Date

    /// The log level
    public let level: SwiftyBeaver.Level

    /// The message to log
    public let message: String

    /// Optional metadata associated with the log entry
    public let metadata: [String: Any]?

    /// Create a new log entry
    /// - Parameters:
    ///   - level: The log level
    ///   - message: The message to log
    ///   - metadata: Optional metadata
    public init(level: SwiftyBeaver.Level, message: String, metadata: [String: Any]? = nil) {
        self.timestamp = Date()
        self.level = level
        self.message = message
        self.metadata = metadata
    }
}

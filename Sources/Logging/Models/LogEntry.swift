import Foundation
import Logging
import os

/// A log entry containing message and metadata
@frozen public struct LogEntry: Sendable, Identifiable {
    // MARK: - Properties
    
    /// Unique identifier
    public let id: UUID
    
    /// Timestamp when the log entry was created
    public let timestamp: Date
    
    /// Log level
    public let level: Logging.Logger.Level
    
    /// Log message
    public let message: String
    
    /// Optional metadata
    public let metadata: Logging.Logger.Metadata?
    
    /// Source file
    public let file: String
    
    /// Source function
    public let function: String
    
    /// Source line
    public let line: Int
    
    // MARK: - Computed Properties
    
    /// Formatted message including metadata
    public var formattedMessage: String {
        var result = message
        if let metadata = metadata, !metadata.isEmpty {
            let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            result += " {\(metadataString)}"
        }
        return result
    }
    
    /// Source location string
    public var sourceLocation: String {
        "\(file):\(line) - \(function)"
    }
    
    // MARK: - Initialization
    
    /// Initialize a new log entry
    /// - Parameters:
    ///   - id: Entry identifier (default: random UUID)
    ///   - timestamp: Entry timestamp (default: current time)
    ///   - level: Log level
    ///   - message: Log message
    ///   - metadata: Optional metadata
    ///   - file: Source file
    ///   - function: Source function
    ///   - line: Source line
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: Logging.Logger.Level,
        message: String,
        metadata: Logging.Logger.Metadata? = nil,
        file: String,
        function: String,
        line: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
    
    // MARK: - JSON Encoding
    
    /// Convert log entry to dictionary
    /// - Returns: Dictionary representation of the log entry
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "level": level.rawValue,
            "message": message,
            "file": file,
            "function": function,
            "line": line
        ]
        
        if let metadata = metadata {
            dict["metadata"] = metadata.mapValues { "\($0)" }
        }
        
        return dict
    }
    
    /// Convert log entry to JSON data
    /// - Returns: JSON data representation of the log entry
    public func toJSON() throws -> Data {
        let dict = toDictionary()
        return try JSONSerialization.data(withJSONObject: dict)
    }
    
    /// Convert log entry to JSON string
    /// - Returns: JSON string representation of the log entry
    public func toJSONString() throws -> String {
        let data = try toJSON()
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "LogEntry", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to string"])
        }
        return string
    }
}

// MARK: - CustomStringConvertible
extension LogEntry: CustomStringConvertible {
    public var description: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return """
            [\(dateFormatter.string(from: timestamp))][\(level)] \(message)
            Source: \(sourceLocation)
            \(metadata?.isEmpty == false ? "Metadata: \(metadata!)" : "")
            """
    }
}

// MARK: - Comparable
extension LogEntry: Comparable {
    public static func < (lhs: LogEntry, rhs: LogEntry) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}

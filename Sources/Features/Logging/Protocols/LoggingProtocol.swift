/// Logging Protocol
/// Defines the public interface for logging operations.
public protocol LoggingProtocol: Sendable {
    /// Initialize the logger with a file path
    /// - Parameter path: Path to log file
    /// - Throws: LoggingError if initialization fails
    func initialize(with path: String) async throws

    /// Log an entry
    /// - Parameter entry: Entry to log
    /// - Throws: LoggingError if logging fails
    func log(_ entry: LogEntry) async throws

    /// Stop logging and cleanup resources
    func stop() async
}

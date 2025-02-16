import Foundation
import Logging

/// Service for managing system-wide logging
@MainActor public final class LoggingService: LoggerProtocol {
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = LoggingService()
    
    /// Logger instance
    private var logger: Logging.Logger
    
    /// Operation queue for processing log messages
    private let operationQueue: OperationQueue
    
    /// Log file URL
    private let logFileURL: URL
    
    /// Subsystem identifier
    private let subsystem: String
    
    /// Category for this logger
    private let category: String
    
    /// Current log level
    nonisolated public var logLevel: Logging.Logger.Level {
        get async {
            await Task { @MainActor in
                logger.logLevel
            }.value
        }
    }
    
    /// Set the current log level
    /// - Parameter level: New log level
    nonisolated public func setLogLevel(_ level: Logging.Logger.Level) async {
        await MainActor.run {
            logger.logLevel = level
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize logging service
    /// - Parameters:
    ///   - label: Label for the logger (default: "UmbraCore")
    ///   - subsystem: The subsystem identifier (e.g., "com.example.app")
    ///   - category: The category for this logger (e.g., "networking")
    ///   - logLevel: Initial log level (default: .info)
    public init(
        label: String = "UmbraCore",
        subsystem: String = "dev.mpy.umbracore",
        category: String = "default",
        logLevel: Logging.Logger.Level = .info
    ) {
        self.logger = Logging.Logger(label: "\(subsystem).\(category)")
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.logFileURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs")
            .appendingPathComponent("\(label).log")
        self.subsystem = subsystem
        self.category = category
        self.logger.logLevel = logLevel
    }
    
    // MARK: - LoggerProtocol
    
    nonisolated public func log(
        level: Logging.Logger.Level,
        _ message: @autoclosure () -> String,
        metadata: Logging.Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        let messageValue = message()
        let currentLevel = await logger.logLevel
        
        guard level >= currentLevel else { return }
        
        let entry = LogEntry(
            level: level,
            message: messageValue,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        
        await MainActor.run {
            // Log to system logger
            self.logger.log(
                level: level,
                "\(entry.formattedMessage)",
                metadata: metadata,
                source: self.category,
                file: file,
                function: function,
                line: UInt(line)
            )
            
            // Queue file logging operation
            self.operationQueue.addOperation { [weak self] in
                guard let self = self else { return }
                Task { @MainActor in
                    await self.writeToFile(entry)
                }
            }
        }
    }
    
    // MARK: - File Operations
    
    /// Write log entry to file
    /// - Parameter entry: Log entry to write
    private func writeToFile(_ entry: LogEntry) async {
        do {
            let fileManager = FileManager.default
            let logDirectory = logFileURL.deletingLastPathComponent()
            
            if !fileManager.fileExists(atPath: logDirectory.path) {
                try fileManager.createDirectory(
                    at: logDirectory,
                    withIntermediateDirectories: true
                )
            }
            
            let entryString = "\(entry)\n"
            if let data = entryString.data(using: .utf8) {
                if fileManager.fileExists(atPath: logFileURL.path) {
                    let fileHandle = try FileHandle(forWritingTo: logFileURL)
                    try fileHandle.seekToEnd()
                    try fileHandle.write(contentsOf: data)
                    try fileHandle.close()
                } else {
                    try data.write(to: logFileURL, options: .atomic)
                }
            }
        } catch {
            logger.error("Failed to write log entry to file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Configuration
    
    /// Get the current log file URL
    public var currentLogFileURL: URL {
        logFileURL
    }
    
    /// Clear the log file
    public func clearLogFile() async throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: logFileURL.path) {
            try fileManager.removeItem(at: logFileURL)
        }
    }
}

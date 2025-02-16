import SecurityTypes

/// A simple file-based logger implementation
final class Logger {
    // MARK: - Properties
    
    /// Path to log file
    private let path: String
    
    /// File handle for writing
    private var fileHandle: FileHandle?
    
    // MARK: - Initialization
    
    /// Initialize with a file path
    /// - Parameter path: Path to log file
    /// - Throws: LoggingError if initialization fails
    init(path: String) throws {
        self.path = path
        try openFile()
    }
    
    deinit {
        try? fileHandle?.close()
    }
    
    // MARK: - Private Methods
    
    /// Open the log file
    private func openFile() throws {
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        }
        
        guard let handle = FileHandle(forWritingAtPath: path) else {
            throw LoggingError.fileError(message: "Failed to open file at path: \(path)")
        }
        
        try handle.seekToEnd()
        self.fileHandle = handle
    }
    
    // MARK: - Logging
    
    /// Log an entry to the file
    /// - Parameter entry: Entry to log
    /// - Throws: LoggingError if writing fails
    func log(_ entry: LogEntry) throws {
        guard let fileHandle = fileHandle else {
            throw LoggingError.notInitialized
        }
        
        let logLine = "\(entry.description)\n"
        guard let data = logLine.data(using: .utf8) else {
            throw LoggingError.encodingError(message: "Failed to encode log entry")
        }
        
        try fileHandle.write(contentsOf: data)
    }
}

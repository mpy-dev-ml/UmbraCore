import SecurityTypes

/// Service for managing logging operations
@MainActor public final class LoggingService: LoggingProtocol {
    // MARK: - Properties
    
    /// Shared instance with default security service
    public static let shared = LoggingService(securityProvider: MockSecurityProvider())
    
    /// The security service to use for file operations
    private let securityProvider: any SecurityProvider
    
    /// Current logger instance
    private var logger: SwiftyBeaverLoggingService?
    
    // MARK: - Initialization
    
    /// Initialize with a security service
    /// - Parameter securityProvider: Security provider to use for file operations
    public init(securityProvider: any SecurityProvider) {
        self.securityProvider = securityProvider
    }
    
    // MARK: - Logging Operations
    
    /// Initialize the logger with a file path
    /// - Parameter path: Path to log file
    /// - Throws: LoggingError if initialization fails
    public func initialize(with path: String) async throws {
        try await securityProvider.withSecurityScopedAccess(to: path) {
            let swiftyLogger = SwiftyBeaverLoggingService()
            try await swiftyLogger.initialize(with: path)
            logger = swiftyLogger
        }
    }
    
    /// Log an entry
    /// - Parameter entry: Entry to log
    /// - Throws: LoggingError if logging fails
    public func log(_ entry: LogEntry) async throws {
        guard let logger = logger else {
            throw LoggingError.notInitialized
        }
        try await logger.log(entry)
    }
    
    /// Stop logging and cleanup resources
    public func stop() async {
        await logger?.stop()
        logger = nil
    }
}

/// Handles security error recovery and reporting
public actor SecurityErrorHandler {
    // MARK: - Types
    
    /// Configuration for error handling behavior
    public struct Configuration {
        /// Maximum number of retry attempts for recoverable errors
        public var maxRetryAttempts: Int
        
        /// Delay between retry attempts in seconds
        public var retryDelay: Double
        
        /// Whether to automatically attempt recovery for recoverable errors
        public var autoRecoveryEnabled: Bool
        
        /// Whether to log all errors
        public var logAllErrors: Bool
        
        public init(
            maxRetryAttempts: Int = 3,
            retryDelay: Double = 1.0,
            autoRecoveryEnabled: Bool = true,
            logAllErrors: Bool = true
        ) {
            self.maxRetryAttempts = maxRetryAttempts
            self.retryDelay = retryDelay
            self.autoRecoveryEnabled = autoRecoveryEnabled
            self.logAllErrors = logAllErrors
        }
    }
    
    // MARK: - Properties
    
    private let configuration: Configuration
    private var errorCounts: [String: Int] = [:]
    private var lastErrors: [String: SecurityError] = [:]
    
    // MARK: - Initialization
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Error Handling
    
    /// Handle a security error and attempt recovery if possible
    /// - Parameters:
    ///   - error: The security error to handle
    ///   - context: Additional context for error handling
    ///   - operation: The operation to retry if recovery is possible
    /// - Returns: The result of the operation if recovery was successful
    public func handle<T>(
        _ error: SecurityError,
        context: String,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        // Log error if configured
        if configuration.logAllErrors {
            logError(error, context: context)
        }
        
        // Update error tracking
        trackError(error, context: context)
        
        // Check if we should attempt recovery
        guard shouldAttemptRecovery(for: error, context: context) else {
            throw error
        }
        
        // Attempt recovery
        return try await attemptRecovery(error, context: context, operation: operation)
    }
    
    // MARK: - Error Recovery
    
    private func attemptRecovery<T>(
        _ error: SecurityError,
        context: String,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        let attempts = errorCounts[context, default: 0]
        
        guard attempts < configuration.maxRetryAttempts else {
            throw error
        }
        
        // Wait before retrying
        let nanoseconds = UInt64(configuration.retryDelay * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
        
        // Attempt the operation again
        do {
            let result = try await operation()
            // Clear error count on success
            errorCounts[context] = 0
            return result
        } catch {
            guard let securityError = error as? SecurityError else { throw error }
            errorCounts[context, default: 0] += 1
            throw securityError
        }
    }
    
    // MARK: - Error Tracking
    
    private func trackError(_ error: SecurityError, context: String) {
        lastErrors[context] = error
        errorCounts[context, default: 0] += 1
    }
    
    private func shouldAttemptRecovery(for error: SecurityError, context: String) -> Bool {
        guard configuration.autoRecoveryEnabled else { return false }
        guard error.isRecoverable else { return false }
        
        let attempts = errorCounts[context, default: 0]
        return attempts < configuration.maxRetryAttempts
    }
    
    // MARK: - Error Reporting
    
    private func logError(_ error: SecurityError, context: String) {
        let message = """
            Security Error:
            Context: \(context)
            Error: \(error.errorDescription ?? "Unknown error")
            Recoverable: \(error.isRecoverable)
            User Intervention Required: \(error.requiresUserIntervention)
            Report to Developer: \(error.shouldReportToDeveloper)
            Recovery Suggestion: \(error.recoverySuggestion ?? "None")
            """
        
        // In a real implementation, this would use the logging system
        print(message)
    }
    
    // MARK: - Public Interface
    
    /// Get error statistics for a specific context
    /// - Parameter context: The context to get statistics for
    /// - Returns: Tuple containing error count and last error
    public func getErrorStats(for context: String) -> (count: Int, lastError: SecurityError?) {
        (errorCounts[context, default: 0], lastErrors[context])
    }
    
    /// Reset error tracking for a specific context
    /// - Parameter context: The context to reset
    public func resetErrorTracking(for context: String) {
        errorCounts[context] = 0
        lastErrors[context] = nil
    }
    
    /// Reset all error tracking
    public func resetAllErrorTracking() {
        errorCounts.removeAll()
        lastErrors.removeAll()
    }
}

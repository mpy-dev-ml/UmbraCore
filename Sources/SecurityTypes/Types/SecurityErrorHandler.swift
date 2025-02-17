import Foundation

/// Handler for security-related errors with retry logic
public actor SecurityErrorHandler {
    /// Maximum number of retry attempts for recoverable errors
    private let maxRetryAttempts: Int
    
    /// Map to track error counts by context
    private var errorCounts: [String: Int]
    
    /// Initialize a new SecurityErrorHandler
    /// - Parameter maxRetryAttempts: Maximum number of retry attempts for recoverable errors
    public init(maxRetryAttempts: Int = 3) {
        self.maxRetryAttempts = maxRetryAttempts
        self.errorCounts = [:]
    }
    
    /// Handle a security error and determine if it should be retried
    /// - Parameters:
    ///   - error: The error to handle
    ///   - context: Context string for tracking retry attempts
    /// - Returns: True if the operation should be retried, false otherwise
    public func handleError(_ error: SecurityError, context: String) async -> Bool {
        switch error {
        case .bookmarkCreationFailed, .bookmarkResolutionFailed:
            let attempts = errorCounts[context, default: 0]
            if attempts < maxRetryAttempts {
                errorCounts[context] = attempts + 1
                return true
            }
            return false
        case .accessDenied, .bookmarkNotFound:
            // These errors cannot be recovered from
            return false
        case .invalidData, .itemNotFound, .storageError:
            // These errors are not retryable
            return false
        }
    }
    
    /// Reset error counts for all contexts
    public func reset() {
        errorCounts.removeAll()
    }
    
    /// Reset error count for a specific context
    /// - Parameter context: The context to reset
    public func resetContext(_ context: String) {
        errorCounts.removeValue(forKey: context)
    }
    
    /// Get the current error count for a context
    /// - Parameter context: The context to check
    /// - Returns: Number of errors recorded for the context
    public func errorCount(forContext context: String) -> Int {
        errorCounts[context, default: 0]
    }
}

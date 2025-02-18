import Foundation

/// Handler for security-related errors with retry logic
public actor SecurityErrorHandler {
    /// Maximum number of retry attempts for recoverable errors
    private let maxRetryAttempts: Int

    /// Base delay between retries in nanoseconds (100ms)
    private let baseRetryDelay: UInt64 = 100_000_000

    /// Maximum delay between retries in nanoseconds (2s)
    private let maxRetryDelay: UInt64 = 2_000_000_000

    /// Map to track error counts by context
    private var errorCounts: [String: Int]

    /// Map to track last error time by context
    private var lastErrorTime: [String: Date]

    /// Map to track cumulative errors by type
    private var errorTypeCount: [String: Int]

    /// Initialize a new SecurityErrorHandler
    /// - Parameter maxRetryAttempts: Maximum number of retry attempts for recoverable errors
    public init(maxRetryAttempts: Int = 3) {
        self.maxRetryAttempts = maxRetryAttempts
        self.errorCounts = [:]
        self.lastErrorTime = [:]
        self.errorTypeCount = [:]
    }

    /// Handle a security error and determine if it should be retried
    /// - Parameters:
    ///   - error: The error to handle
    ///   - context: Context string for tracking retry attempts
    /// - Returns: True if the operation should be retried, false otherwise
    public func handleError(_ error: SecurityError, context: String) async -> Bool {
        // Track error type
        let errorType = String(describing: type(of: error))
        errorTypeCount[errorType, default: 0] += 1

        // Update last error time
        lastErrorTime[context] = Date()

        switch error {
        case .bookmarkCreationFailed, .bookmarkResolutionFailed:
            let attempts = errorCounts[context, default: 0]
            if attempts < maxRetryAttempts {
                errorCounts[context] = attempts + 1

                // Exponential backoff with jitter
                let delay = min(
                    baseRetryDelay * UInt64(pow(2.0, Double(attempts))),
                    maxRetryDelay
                )
                let jitter = UInt64.random(in: 0...(delay / 4))
                try? await Task.sleep(nanoseconds: delay + jitter)

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
        lastErrorTime.removeAll()
        errorTypeCount.removeAll()
    }

    /// Reset error count for a specific context
    /// - Parameter context: The context to reset
    public func resetContext(_ context: String) {
        errorCounts.removeValue(forKey: context)
        lastErrorTime.removeValue(forKey: context)
    }

    /// Get error statistics for monitoring
    /// - Returns: Dictionary containing error statistics
    public func getErrorStats() -> [String: any Sendable] {
        return [
            "totalErrors": errorCounts.values.reduce(0, +),
            "activeContexts": errorCounts.count,
            "errorsByType": errorTypeCount,
            "lastErrorTimes": lastErrorTime.mapValues { $0.timeIntervalSince1970 }
        ]
    }

    /// Check if a context is experiencing rapid failures
    /// - Parameter context: Context to check
    /// - Returns: True if the context is failing rapidly
    public func isRapidlyFailing(_ context: String) -> Bool {
        guard let lastError = lastErrorTime[context],
              let attempts = errorCounts[context],
              attempts > 1 else {
            return false
        }

        // Consider it rapidly failing if we have multiple errors within 5 seconds
        return Date().timeIntervalSince(lastError) < 5.0
    }
}

import Foundation
import os.log

// MARK: - SecurityMetrics

/// Tracks and analyses security-related metrics for monitoring and debugging
@available(macOS 13.0, *)
public actor SecurityMetrics {
    // MARK: - Types

    /// Type of security metric being recorded
    private enum MetricType: String {
        case access
        case permission
        case bookmark
        case xpc
        case session
    }

    // MARK: - Properties

    private let logger: Logger
    private let queue: DispatchQueue
    private let maxHistorySize: Int

    private(set) var accessCount = 0
    private(set) var permissionCount = 0
    private(set) var bookmarkCount = 0
    private(set) var xpcCount = 0
    private(set) var failureCount = 0
    private(set) var activeAccessCount = 0
    private(set) var operationHistory: [SecurityOperation] = []

    // MARK: - Initialization

    /// Creates a new security metrics tracker
    /// - Parameters:
    ///   - logger: Logger for recording events
    ///   - label: Queue label for synchronisation
    ///   - maxHistory: Maximum operations in history
    public init(
        logger: Logger,
        label: String = Bundle.main.bundleIdentifier ?? "com.umbra.core",
        maxHistory: Int = 100
    ) {
        self.logger = logger
        queue = DispatchQueue(
            label: "\(label).security-metrics",
            qos: .utility
        )
        maxHistorySize = maxHistory
    }

    // MARK: - Public Methods

    /// Records an access attempt
    public func recordAccess(
        success: Bool = true,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        recordMetric(
            type: .access,
            counter: { self.accessCount += 1 },
            success: success,
            error: error,
            metadata: metadata
        )
    }

    /// Records a permission request
    public func recordPermission(
        success: Bool = true,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        recordMetric(
            type: .permission,
            counter: { self.permissionCount += 1 },
            success: success,
            error: error,
            metadata: metadata
        )
    }

    /// Records a bookmark operation
    public func recordBookmark(
        success: Bool = true,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        recordMetric(
            type: .bookmark,
            counter: { self.bookmarkCount += 1 },
            success: success,
            error: error,
            metadata: metadata
        )
    }

    /// Records an XPC service interaction
    public func recordXPC(
        success: Bool = true,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        recordMetric(
            type: .xpc,
            counter: { self.xpcCount += 1 },
            success: success,
            error: error,
            metadata: metadata
        )
    }

    // MARK: - Session Management

    /// Increments active access count
    public func incrementActiveAccess() {
        queue.async {
            self.activeAccessCount += 1
            self.logMetric(
                type: .session,
                success: true,
                metadata: ["action": "start"]
            )
        }
    }

    /// Decrements active access count
    public func decrementActiveAccess() {
        queue.async {
            self.activeAccessCount = max(0, self.activeAccessCount - 1)
            self.logMetric(
                type: .session,
                success: true,
                metadata: ["action": "end"]
            )
        }
    }

    // MARK: - Private Methods

    private func recordMetric(
        type: MetricType,
        counter: () -> Void,
        success: Bool,
        error: String?,
        metadata: [String: String]
    ) {
        queue.async {
            counter()
            if !success {
                self.failureCount += 1
            }
            self.logMetric(
                type: type,
                success: success,
                error: error,
                metadata: metadata
            )
        }
    }

    private func logMetric(
        type: MetricType,
        success: Bool,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        var logMetadata = createBaseMetadata(
            type: type,
            success: success
        )

        if let error {
            logMetadata["error"] = error
        }

        logMetadata.merge(metadata) { current, _ in current }
        let config = LogConfig(metadata: logMetadata)

        logWithAppropriateLevel(
            type: type,
            success: success,
            error: error,
            config: config
        )
    }

    private func createBaseMetadata(
        type: MetricType,
        success: Bool
    ) -> [String: String] {
        [
            "type": type.rawValue,
            "success": String(success),
            "timestamp": Date().ISO8601Format()
        ]
    }

    private func logWithAppropriateLevel(
        type: MetricType,
        success: Bool,
        error: String?,
        config: LogConfig
    ) {
        if success {
            logger.info(
                "\(type.rawValue) operation completed",
                config: config
            )
        } else {
            logger.error(
                "\(type.rawValue) operation failed: \(error ?? "Unknown error")",
                config: config
            )
        }
    }

    private func addToHistory(_ operation: SecurityOperation) {
        operationHistory.append(operation)
        if operationHistory.count > maxHistorySize {
            operationHistory.removeFirst()
        }
    }
}

// MARK: - LogConfig

/// Configuration for metric logging
private struct LogConfig {
    let metadata: [String: String]
}

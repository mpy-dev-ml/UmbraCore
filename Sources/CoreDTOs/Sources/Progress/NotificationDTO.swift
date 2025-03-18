import UmbraCoreTypes

/// FoundationIndependent representation of a notification.
/// This data transfer object encapsulates notification data
/// without using any Foundation types.
public struct NotificationDTO: Sendable, Equatable {
    // MARK: - Types

    /// Represents the severity level of the notification
    public enum Level: String, Sendable, Equatable, Comparable {
        /// Informational message
        case info
        /// Warning message
        case warning
        /// Error message
        case error
        /// Success message
        case success
        
        /// Order for comparing severity levels
        public static func < (lhs: Level, rhs: Level) -> Bool {
            let order: [Level: Int] = [
                .info: 0,
                .success: 1,
                .warning: 2,
                .error: 3
            ]
            
            return order[lhs, default: 0] < order[rhs, default: 0]
        }
    }

    // MARK: - Properties

    /// Unique identifier for the notification
    public let id: String

    /// When the notification was created (Unix timestamp - seconds since epoch)
    public let timestamp: UInt64

    /// Severity level of the notification
    public let level: Level

    /// Short title for the notification
    public let title: String

    /// Detailed message
    public let message: String

    /// Source of the notification (e.g., "BackupManager", "SecurityProvider")
    public let source: String

    /// Whether the notification has been read
    public let isRead: Bool

    /// Whether the notification has an associated action
    public let isActionable: Bool

    /// Title for the action button if applicable
    public let actionTitle: String?

    /// Additional metadata for the notification
    public let metadata: [String: String]

    // MARK: - Initializers

    /// Full initializer with all notification properties
    /// - Parameters:
    ///   - id: Unique identifier for the notification
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - level: Severity level of the notification
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - isRead: Whether the notification has been read
    ///   - isActionable: Whether the notification has an associated action
    ///   - actionTitle: Title for the action button if applicable
    ///   - metadata: Additional metadata for the notification
    public init(
        id: String,
        timestamp: UInt64,
        level: Level,
        title: String,
        message: String,
        source: String,
        isRead: Bool = false,
        isActionable: Bool = false,
        actionTitle: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.title = title
        self.message = message
        self.source = source
        self.isRead = isRead
        self.isActionable = isActionable
        self.actionTitle = actionTitle
        self.metadata = metadata
    }

    // MARK: - Factory Methods

    /// Create an information notification
    /// - Parameters:
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO with info level
    public static func info(
        title: String,
        message: String,
        source: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "info")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: .info,
            title: title,
            message: message,
            source: source
        )
    }

    /// Create a warning notification
    /// - Parameters:
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO with warning level
    public static func warning(
        title: String,
        message: String,
        source: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "warn")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: .warning,
            title: title,
            message: message,
            source: source
        )
    }

    /// Create an error notification
    /// - Parameters:
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO with error level
    public static func error(
        title: String,
        message: String,
        source: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "err")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: .error,
            title: title,
            message: message,
            source: source
        )
    }

    /// Create a success notification
    /// - Parameters:
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO with success level
    public static func success(
        title: String,
        message: String,
        source: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "succ")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: .success,
            title: title,
            message: message,
            source: source
        )
    }

    /// Create an actionable notification
    /// - Parameters:
    ///   - level: Severity level of the notification
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - source: Source of the notification
    ///   - actionTitle: Title for the action button
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO with an associated action
    public static func actionable(
        level: Level,
        title: String,
        message: String,
        source: String,
        actionTitle: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "act")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: level,
            title: title,
            message: message,
            source: source,
            isRead: false,
            isActionable: true,
            actionTitle: actionTitle
        )
    }

    /// Create a security-related notification
    /// - Parameters:
    ///   - level: Severity level of the notification
    ///   - title: Short title for the notification
    ///   - message: Detailed message
    ///   - timestamp: When the notification was created (Unix timestamp)
    ///   - id: Unique identifier for the notification (auto-generated if nil)
    /// - Returns: A NotificationDTO for a security-related notification
    public static func security(
        level: Level,
        title: String,
        message: String,
        timestamp: UInt64,
        id: String? = nil
    ) -> NotificationDTO {
        let notificationId = id ?? generateId(prefix: "sec")
        
        return NotificationDTO(
            id: notificationId,
            timestamp: timestamp,
            level: level,
            title: title,
            message: message,
            source: "SecurityProvider",
            metadata: ["category": "security"]
        )
    }

    // MARK: - Helper Methods

    /// Generate a unique ID for notifications
    /// - Parameter prefix: Optional prefix for the ID
    /// - Returns: A unique ID string
    private static func generateId(prefix: String? = nil) -> String {
        let randomPart = String(format: "%08x%08x", 
                               arc4random(), 
                               arc4random())
        if let prefix = prefix {
            return "\(prefix)_\(randomPart)"
        }
        return randomPart
    }

    // MARK: - Utility Methods

    /// Create a copy of this notification marked as read
    /// - Returns: A new NotificationDTO marked as read
    public func markAsRead() -> NotificationDTO {
        NotificationDTO(
            id: id,
            timestamp: timestamp,
            level: level,
            title: title,
            message: message,
            source: source,
            isRead: true,
            isActionable: isActionable,
            actionTitle: actionTitle,
            metadata: metadata
        )
    }

    /// Create a copy of this notification with updated metadata
    /// - Parameter additionalMetadata: The metadata to add or update
    /// - Returns: A new NotificationDTO with updated metadata
    public func withUpdatedMetadata(_ additionalMetadata: [String: String]) -> NotificationDTO {
        var newMetadata = self.metadata
        for (key, value) in additionalMetadata {
            newMetadata[key] = value
        }
        
        return NotificationDTO(
            id: id,
            timestamp: timestamp,
            level: level,
            title: title,
            message: message,
            source: source,
            isRead: isRead,
            isActionable: isActionable,
            actionTitle: actionTitle,
            metadata: newMetadata
        )
    }

    /// Create a copy of this notification with an action
    /// - Parameter actionTitle: Title for the action button
    /// - Returns: A new NotificationDTO with an action
    public func withAction(_ actionTitle: String) -> NotificationDTO {
        NotificationDTO(
            id: id,
            timestamp: timestamp,
            level: level,
            title: title,
            message: message,
            source: source,
            isRead: isRead,
            isActionable: true,
            actionTitle: actionTitle,
            metadata: metadata
        )
    }

    /// Create a copy of this notification with updated message
    /// - Parameter newMessage: The updated message
    /// - Returns: A new NotificationDTO with updated message
    public func withMessage(_ newMessage: String) -> NotificationDTO {
        NotificationDTO(
            id: id,
            timestamp: timestamp,
            level: level,
            title: title,
            message: newMessage,
            source: source,
            isRead: isRead,
            isActionable: isActionable,
            actionTitle: actionTitle,
            metadata: metadata
        )
    }
}

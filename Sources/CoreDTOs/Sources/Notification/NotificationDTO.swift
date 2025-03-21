import Foundation

/// A Foundation-independent representation of a notification.
public struct NotificationDTO: Sendable, Equatable, Hashable {
    // MARK: - Properties
    
    /// Name of the notification
    public let name: String
    
    /// Object that posted the notification
    public let sender: AnyHashable?
    
    /// User info dictionary
    public let userInfo: [String: AnyHashable]
    
    /// Timestamp when the notification was posted (seconds since 1970)
    public let timestamp: Double
    
    // MARK: - Initialization
    
    /// Initialize a notification with specified values
    /// - Parameters:
    ///   - name: Name of the notification
    ///   - sender: Object that posted the notification
    ///   - userInfo: User info dictionary
    ///   - timestamp: Timestamp when the notification was posted
    public init(
        name: String,
        sender: AnyHashable? = nil,
        userInfo: [String: AnyHashable] = [:],
        timestamp: Double = Date().timeIntervalSince1970
    ) {
        self.name = name
        self.sender = sender
        self.userInfo = userInfo
        self.timestamp = timestamp
    }
    
    // MARK: - Accessing User Info
    
    /// Get a value from user info as a specific type
    /// - Parameters:
    ///   - key: Key to look up
    ///   - type: Expected type
    /// - Returns: Value of the specified type or nil
    public func userInfoValue<T>(for key: String, as type: T.Type) -> T? {
        return userInfo[key] as? T
    }
    
    /// Get a string value from user info
    /// - Parameter key: Key to look up
    /// - Returns: String value or nil
    public func stringValue(for key: String) -> String? {
        return userInfoValue(for: key, as: String.self)
    }
    
    /// Get an integer value from user info
    /// - Parameter key: Key to look up
    /// - Returns: Integer value or nil
    public func intValue(for key: String) -> Int? {
        return userInfoValue(for: key, as: Int.self)
    }
    
    /// Get a double value from user info
    /// - Parameter key: Key to look up
    /// - Returns: Double value or nil
    public func doubleValue(for key: String) -> Double? {
        return userInfoValue(for: key, as: Double.self)
    }
    
    /// Get a boolean value from user info
    /// - Parameter key: Key to look up
    /// - Returns: Boolean value or nil
    public func boolValue(for key: String) -> Bool? {
        return userInfoValue(for: key, as: Bool.self)
    }
    
    /// Get a date value from user info
    /// - Parameter key: Key to look up
    /// - Returns: Date value or nil
    public func dateValue(for key: String) -> Date? {
        return userInfoValue(for: key, as: Date.self)
    }
    
    /// Get a data value from user info
    /// - Parameter key: Key to look up
    /// - Returns: Data value or nil
    public func dataValue(for key: String) -> [UInt8]? {
        if let data = userInfoValue(for: key, as: Data.self) {
            return [UInt8](data)
        } else if let bytes = userInfoValue(for: key, as: [UInt8].self) {
            return bytes
        }
        return nil
    }
    
    // MARK: - Creating Modified Notifications
    
    /// Create a copy with additional user info
    /// - Parameter additionalInfo: Additional user info to add
    /// - Returns: New notification with combined user info
    public func withAdditionalUserInfo(_ additionalInfo: [String: AnyHashable]) -> NotificationDTO {
        var newUserInfo = userInfo
        for (key, value) in additionalInfo {
            newUserInfo[key] = value
        }
        
        return NotificationDTO(
            name: name,
            sender: sender,
            userInfo: newUserInfo,
            timestamp: timestamp
        )
    }
}

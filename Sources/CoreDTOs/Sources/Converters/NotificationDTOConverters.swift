import Foundation

/// Extension for converting between Foundation types and NotificationDTO
public extension NotificationDTO {
    /// Create a NotificationDTO from a Foundation Notification
    /// - Parameter notification: The Foundation Notification to convert
    /// - Returns: A NotificationDTO representation
    static func from(notification: Notification) -> NotificationDTO {
        // Convert user info dictionary
        var userInfoDict = [String: AnyHashable]()
        if let userInfo = notification.userInfo {
            for (key, value) in userInfo {
                if let keyString = key as? String, let hashableValue = value as? AnyHashable {
                    userInfoDict[keyString] = hashableValue
                }
            }
        }
        
        return NotificationDTO(
            name: notification.name.rawValue,
            sender: notification.object as? AnyHashable,
            userInfo: userInfoDict,
            timestamp: Date().timeIntervalSince1970
        )
    }
    
    /// Convert to a Foundation Notification
    /// - Returns: A Foundation Notification
    func toNotification() -> Notification {
        let notificationName = Notification.Name(name)
        return Notification(
            name: notificationName,
            object: sender,
            userInfo: userInfo
        )
    }
}

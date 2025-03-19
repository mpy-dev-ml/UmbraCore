import Foundation

public extension TimeInterval {
    /// Convert hours to TimeInterval
    /// - Parameter value: Number of hours
    /// - Returns: TimeInterval representing the specified hours
    static func hours(_ value: Double) -> TimeInterval {
        value * 3_600
    }

    /// Convert minutes to TimeInterval
    /// - Parameter value: Number of minutes
    /// - Returns: TimeInterval representing the specified minutes
    static func minutes(_ value: Double) -> TimeInterval {
        value * 60
    }

    /// Convert days to TimeInterval
    /// - Parameter value: Number of days
    /// - Returns: TimeInterval representing the specified days
    static func days(_ value: Double) -> TimeInterval {
        hours(value * 24)
    }
}

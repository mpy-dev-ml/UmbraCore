import Foundation

/// A Foundation-independent representation of a date and time.
public struct DateTimeDTO: Sendable, Equatable, Hashable, Codable {
    // MARK: - Types
    
    /// Calendar month representation
    public enum Month: Int, Sendable, Equatable, Hashable, Codable {
        case january = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
    }
    
    /// Day of week representation
    public enum Weekday: Int, Sendable, Equatable, Hashable, Codable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }
    
    /// Time zone offset in hours and minutes from UTC
    public struct TimeZoneOffset: Sendable, Equatable, Hashable, Codable {
        /// Hours offset from UTC (-12 to +14)
        public let hours: Int
        
        /// Minutes offset from UTC (0 to 59)
        public let minutes: Int
        
        /// Whether the offset is positive
        public let isPositive: Bool
        
        /// Initialize with hours, minutes and sign
        public init(hours: Int, minutes: Int, isPositive: Bool) {
            self.hours = hours
            self.minutes = minutes
            self.isPositive = isPositive
        }
        
        /// Initialize with total minutes
        public init(totalMinutes: Int) {
            self.isPositive = totalMinutes >= 0
            let absoluteMinutes = abs(totalMinutes)
            self.hours = absoluteMinutes / 60
            self.minutes = absoluteMinutes % 60
        }
        
        /// Get the total number of minutes in this offset
        public var totalMinutes: Int {
            let value = hours * 60 + minutes
            return isPositive ? value : -value
        }
        
        /// Format as a string (e.g., "+08:00", "-05:30")
        public var formatted: String {
            let sign = isPositive ? "+" : "-"
            return String(format: "%@%02d:%02d", sign, hours, minutes)
        }
        
        /// UTC time zone offset (zero)
        public static let utc = TimeZoneOffset(hours: 0, minutes: 0, isPositive: true)
    }
    
    // MARK: - Properties
    
    /// Year component (e.g., 2025)
    public let year: Int
    
    /// Month component (1-12)
    public let month: Month
    
    /// Day component (1-31)
    public let day: Int
    
    /// Hour component (0-23)
    public let hour: Int
    
    /// Minute component (0-59)
    public let minute: Int
    
    /// Second component (0-59)
    public let second: Int
    
    /// Nanosecond component (0-999,999,999)
    public let nanosecond: Int
    
    /// Time zone offset from UTC
    public let timeZoneOffset: TimeZoneOffset
    
    // MARK: - Initialization
    
    /// Initialize with components
    public init(
        year: Int,
        month: Month,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        timeZoneOffset: TimeZoneOffset = TimeZoneOffset.utc
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.nanosecond = nanosecond
        self.timeZoneOffset = timeZoneOffset
    }
    
    /// Initialize with Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
    /// - Parameter timestamp: Unix timestamp in seconds
    /// - Parameter timeZoneOffset: Optional time zone offset (defaults to UTC)
    public init(timestamp: Double, timeZoneOffset: TimeZoneOffset = TimeZoneOffset.utc) {
        // Split into seconds and nanoseconds
        let wholeSeconds = floor(timestamp)
        let fractionalSeconds = timestamp - wholeSeconds
        let nanoseconds = Int(fractionalSeconds * 1_000_000_000)
        
        // Initialize with Foundation's Date for proper calendar calculations
        let date = Date(timeIntervalSince1970: timestamp)
        
        // Create calendar in the desired time zone
        let calendar = Calendar(identifier: .gregorian)
        var timeZone = TimeZone(secondsFromGMT: timeZoneOffset.totalMinutes * 60) ?? TimeZone(secondsFromGMT: 0)!
        
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .weekday],
            from: date
        )
        
        // Extract components
        self.year = components.year ?? 1970
        self.month = Month(rawValue: components.month ?? 1) ?? .january
        self.day = components.day ?? 1
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
        self.second = components.second ?? 0
        self.nanosecond = nanoseconds
        self.timeZoneOffset = timeZoneOffset
    }
    
    // MARK: - Computed Properties
    
    /// Get the weekday for this date
    public var weekday: Weekday {
        // Use Foundation's Date for proper calendar calculations
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            calendar: calendar,
            year: year,
            month: month.rawValue,
            day: day
        )
        
        if let date = calendar.date(from: components),
           let weekday = calendar.component(.weekday, from: date) as Int? {
            return Weekday(rawValue: weekday) ?? .sunday
        }
        
        // Default to Sunday if calculation fails
        return .sunday
    }
    
    /// Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
    public var timestamp: Double {
        // Convert to Foundation's Date for timestamp calculation
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: timeZoneOffset.totalMinutes * 60),
            year: year,
            month: month.rawValue,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        )
        
        if let date = calendar.date(from: components) {
            return date.timeIntervalSince1970
        }
        
        // Return a safe default if calculation fails
        return 0
    }
    
    // MARK: - Date Operations
    
    /// Add a duration to this date
    /// - Parameter duration: The duration to add
    /// - Returns: A new date with the duration added
    public func adding(seconds: Int) -> DateTimeDTO {
        let newTimestamp = timestamp + Double(seconds)
        return DateTimeDTO(timestamp: newTimestamp, timeZoneOffset: timeZoneOffset)
    }
    
    /// Add components to this date
    /// - Parameters:
    ///   - years: Years to add
    ///   - months: Months to add
    ///   - days: Days to add
    ///   - hours: Hours to add
    ///   - minutes: Minutes to add
    ///   - seconds: Seconds to add
    /// - Returns: A new date with the components added
    public func adding(
        years: Int = 0,
        months: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> DateTimeDTO {
        // Use Foundation's Date for calendar calculations
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: timeZoneOffset.totalMinutes * 60),
            year: year,
            month: month.rawValue,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        )
        
        if let date = calendar.date(from: components) {
            var dateComponents = DateComponents()
            dateComponents.year = years
            dateComponents.month = months
            dateComponents.day = days
            dateComponents.hour = hours
            dateComponents.minute = minutes
            dateComponents.second = seconds
            
            if let newDate = calendar.date(byAdding: dateComponents, to: date) {
                return DateTimeDTO(
                    timestamp: newDate.timeIntervalSince1970,
                    timeZoneOffset: timeZoneOffset
                )
            }
        }
        
        // Return self if calculation fails
        return self
    }
    
    /// Calculate the difference between two dates in seconds
    /// - Parameter other: The other date
    /// - Returns: Difference in seconds
    public func secondsUntil(_ other: DateTimeDTO) -> Double {
        return other.timestamp - self.timestamp
    }
    
    /// Convert to a different time zone
    /// - Parameter timeZoneOffset: The new time zone offset
    /// - Returns: A new date in the specified time zone
    public func inTimeZone(_ timeZoneOffset: TimeZoneOffset) -> DateTimeDTO {
        return DateTimeDTO(timestamp: timestamp, timeZoneOffset: timeZoneOffset)
    }
    
    // MARK: - Static Factory Methods
    
    /// Create a DateTimeDTO representing the current date and time in UTC
    /// - Returns: Current date and time
    public static func now() -> DateTimeDTO {
        return DateTimeDTO(timestamp: Date().timeIntervalSince1970)
    }
    
    /// Create a DateTimeDTO representing the current date and time in the specified time zone
    /// - Parameter timeZoneOffset: Time zone offset
    /// - Returns: Current date and time in the specified time zone
    public static func now(in timeZoneOffset: TimeZoneOffset) -> DateTimeDTO {
        return DateTimeDTO(timestamp: Date().timeIntervalSince1970, timeZoneOffset: timeZoneOffset)
    }
}

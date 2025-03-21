import Foundation

/// A Foundation-independent representation of date formatting options.
public struct DateFormatterDTO: Sendable, Equatable, Hashable {
    // MARK: - Types
    
    /// Date format style
    public enum FormatStyle: Sendable, Equatable, Hashable {
        /// Short style (e.g., "12/31/23")
        case short
        /// Medium style (e.g., "Dec 31, 2023")
        case medium
        /// Long style (e.g., "December 31, 2023")
        case long
        /// Full style (e.g., "Sunday, December 31, 2023")
        case full
        /// Custom format string using strftime-like format
        case custom(String)
    }
    
    /// Time format style
    public enum TimeStyle: Sendable, Equatable, Hashable {
        /// No time
        case none
        /// Short style (e.g., "12:30 PM")
        case short
        /// Medium style (e.g., "12:30:45 PM")
        case medium
        /// Long style (e.g., "12:30:45 PM GMT")
        case long
        /// Full style (e.g., "12:30:45 PM Greenwich Mean Time")
        case full
        /// Custom format string using strftime-like format
        case custom(String)
    }
    
    // MARK: - Properties
    
    /// Date format style
    public let dateStyle: FormatStyle
    
    /// Time format style
    public let timeStyle: TimeStyle
    
    /// Locale identifier (e.g., "en_US", "fr_FR")
    public let localeIdentifier: String?
    
    // MARK: - Initialization
    
    /// Initialize with format styles
    /// - Parameters:
    ///   - dateStyle: Date format style
    ///   - timeStyle: Time format style
    ///   - localeIdentifier: Optional locale identifier
    public init(
        dateStyle: FormatStyle = .medium,
        timeStyle: TimeStyle = .medium,
        localeIdentifier: String? = nil
    ) {
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        self.localeIdentifier = localeIdentifier
    }
    
    // MARK: - Formatting Methods
    
    /// Format a DateTimeDTO as a string
    /// - Parameter date: Date to format
    /// - Returns: Formatted date string
    public func format(_ date: DateTimeDTO) -> String {
        // Convert to Foundation Date for formatting
        let timestamp = date.timestamp
        let foundationDate = Date(timeIntervalSince1970: timestamp)
        
        // Create DateFormatter
        let formatter = DateFormatter()
        
        // Set locale if provided
        if let localeIdentifier = localeIdentifier {
            formatter.locale = Locale(identifier: localeIdentifier)
        }
        
        // Set time zone
        formatter.timeZone = TimeZone(secondsFromGMT: date.timeZoneOffset.totalMinutes * 60)
        
        // Configure date style
        switch dateStyle {
        case .short:
            formatter.dateStyle = .short
        case .medium:
            formatter.dateStyle = .medium
        case .long:
            formatter.dateStyle = .long
        case .full:
            formatter.dateStyle = .full
        case .custom(let format):
            // Custom format for date part
            formatter.dateFormat = format
        }
        
        // Configure time style if using predefined styles
        if case .custom = dateStyle {
            // Already handled in date format
        } else {
            switch timeStyle {
            case .none:
                formatter.timeStyle = .none
            case .short:
                formatter.timeStyle = .short
            case .medium:
                formatter.timeStyle = .medium
            case .long:
                formatter.timeStyle = .long
            case .full:
                formatter.timeStyle = .full
            case .custom(let format):
                // For custom time format with predefined date format,
                // we need to combine them
                let dateFormat = formatter.dateFormat ?? ""
                formatter.dateFormat = "\(dateFormat) \(format)"
            }
        }
        
        return formatter.string(from: foundationDate)
    }
    
    // MARK: - Static Factory Methods
    
    /// Create a date-only formatter
    /// - Parameters:
    ///   - style: Date format style
    ///   - localeIdentifier: Optional locale identifier
    /// - Returns: A formatter configured for date-only formatting
    public static func dateOnly(
        style: FormatStyle = .medium,
        localeIdentifier: String? = nil
    ) -> DateFormatterDTO {
        return DateFormatterDTO(
            dateStyle: style,
            timeStyle: .none,
            localeIdentifier: localeIdentifier
        )
    }
    
    /// Create a time-only formatter
    /// - Parameters:
    ///   - style: Time format style
    ///   - localeIdentifier: Optional locale identifier
    /// - Returns: A formatter configured for time-only formatting
    public static func timeOnly(
        style: TimeStyle = .medium,
        localeIdentifier: String? = nil
    ) -> DateFormatterDTO {
        return DateFormatterDTO(
            dateStyle: .none,
            timeStyle: style,
            localeIdentifier: localeIdentifier
        )
    }
    
    /// Create a formatter with ISO 8601 format
    /// - Returns: A formatter configured for ISO 8601 format
    public static func iso8601() -> DateFormatterDTO {
        return DateFormatterDTO(
            dateStyle: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"),
            timeStyle: .none
        )
    }
    
    /// Create a formatter with a custom format string
    /// - Parameters:
    ///   - format: Custom format string
    ///   - localeIdentifier: Optional locale identifier
    /// - Returns: A formatter with the specified custom format
    public static func custom(
        format: String,
        localeIdentifier: String? = nil
    ) -> DateFormatterDTO {
        return DateFormatterDTO(
            dateStyle: .custom(format),
            timeStyle: .none,
            localeIdentifier: localeIdentifier
        )
    }
}

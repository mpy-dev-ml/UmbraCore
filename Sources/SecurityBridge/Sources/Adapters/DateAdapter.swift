// DateAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import UmbraCoreTypes

/// DateAdapter provides bidirectional conversion between Foundation Date and TimePoint.
///
/// This adapter serves as the bridge for time points between Foundation-dependent
/// and Foundation-independent code.
public enum DateAdapter {
    
    /// Convert Foundation Date to TimePoint
    /// - Parameter date: Foundation Date instance
    /// - Returns: A new TimePoint instance representing the same point in time
    public static func timePoint(from date: Date) -> TimePoint {
        return TimePoint(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    /// Convert TimePoint to Foundation Date
    /// - Parameter timePoint: TimePoint instance
    /// - Returns: A new Date instance representing the same point in time
    public static func date(from timePoint: TimePoint) -> Date {
        return Date(timeIntervalSince1970: timePoint.timeIntervalSince1970)
    }
    
    /// Create a TimePoint representing the current time using Foundation
    /// - Returns: A TimePoint representing now
    public static func now() -> TimePoint {
        return timePoint(from: Date())
    }
    
    /// Extension point for additional conversion methods for different date formats and calendars
}

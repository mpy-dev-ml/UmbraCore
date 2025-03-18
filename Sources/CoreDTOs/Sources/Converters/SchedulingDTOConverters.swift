import Foundation

// MARK: - Date Extensions for ScheduleDTO

public extension Date {
    /// Convert a Date to a UInt64 timestamp (seconds since 1970)
    var timestampInSeconds: UInt64 {
        UInt64(timeIntervalSince1970)
    }
    
    /// Create a Date from a UInt64 timestamp (seconds since 1970)
    /// - Parameter timestamp: The timestamp in seconds
    /// - Returns: A Date object
    static func fromTimestamp(_ timestamp: UInt64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

// MARK: - Foundation Date Extensions for ScheduleDTO

extension ScheduleDTO {
    /// Create a ScheduleDTO from Foundation Date objects
    /// - Parameters:
    ///   - frequencyType: The frequency type
    ///   - startDate: The starting date
    ///   - endDate: Optional ending date
    ///   - windowStartTime: Optional window start time
    ///   - windowEndTime: Optional window end time
    ///   - maxRuns: Optional maximum runs
    ///   - enabled: Whether the schedule is enabled
    /// - Returns: A ScheduleDTO configured with dates converted to timestamps
    public static func fromDates(
        frequencyType: FrequencyType,
        startDate: Date,
        endDate: Date? = nil,
        windowStartTime: Date? = nil,
        windowEndTime: Date? = nil,
        maxRuns: Int? = nil,
        enabled: Bool = true
    ) -> ScheduleDTO {
        // Convert dates to timestamps
        let startTimestamp = startDate.timestampInSeconds
        
        // Convert end date if present
        let endTimestamp: UInt64? = endDate?.timestampInSeconds
        
        // Calculate window start/end times if present
        // Extract just the time component for the window times
        var windowStart: UInt32?
        if let windowStartTime = windowStartTime {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: windowStartTime)
            let secondsFromMidnight = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
            windowStart = UInt32(secondsFromMidnight)
        }
        
        var windowEnd: UInt32?
        if let windowEndTime = windowEndTime {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: windowEndTime)
            let secondsFromMidnight = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
            windowEnd = UInt32(secondsFromMidnight)
        }
        
        return ScheduleDTO(
            frequencyType: frequencyType,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            windowStartTime: windowStart,
            windowEndTime: windowEnd,
            maxRuns: maxRuns,
            enabled: enabled
        )
    }
    
    /// Get the start date of this schedule
    /// - Returns: A Date object representing the start date
    public func startDate() -> Date {
        Date.fromTimestamp(startTimestamp)
    }
    
    /// Get the end date of this schedule
    /// - Returns: A Date object representing the end date, if available
    public func endDate() -> Date? {
        endTimestamp.map { Date.fromTimestamp($0) }
    }
    
    /// Get the window start time
    /// - Returns: A Date object representing today at the window start time, if available
    public func windowStartDate() -> Date? {
        guard let windowStartTime = windowStartTime else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // Add the window start time (seconds from midnight) to the start of day
        return calendar.date(byAdding: .second, value: Int(windowStartTime), to: startOfDay)
    }
    
    /// Get the window end time
    /// - Returns: A Date object representing today at the window end time, if available
    public func windowEndDate() -> Date? {
        guard let windowEndTime = windowEndTime else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // Add the window end time (seconds from midnight) to the start of day
        return calendar.date(byAdding: .second, value: Int(windowEndTime), to: startOfDay)
    }
}

// MARK: - ScheduledTaskDTO Extensions

extension ScheduledTaskDTO {
    /// Create a ScheduledTaskDTO from Foundation Date objects
    /// - Parameters:
    ///   - taskId: The task identifier
    ///   - schedule: The schedule for this task
    ///   - status: The task status
    ///   - configData: Optional configuration data for the task
    ///   - lastRunDate: Optional last run date
    ///   - nextRunDate: Optional next run date
    ///   - creationDate: Creation date
    /// - Returns: A ScheduledTaskDTO with dates converted to timestamps
    public static func fromDates(
        taskId: String,
        schedule: ScheduleDTO,
        status: TaskStatus = .idle,
        configData: [String: String] = [:],
        lastRunDate: Date? = nil,
        nextRunDate: Date? = nil,
        creationDate: Date
    ) -> ScheduledTaskDTO {
        // Convert dates to timestamps
        let lastRunTimestamp = lastRunDate?.timestampInSeconds
        let nextRunTimestamp = nextRunDate?.timestampInSeconds
        let creationTimestamp = creationDate.timestampInSeconds
        
        return ScheduledTaskDTO(
            taskId: taskId,
            schedule: schedule,
            status: status,
            configData: configData,
            lastRunTimestamp: lastRunTimestamp,
            nextRunTimestamp: nextRunTimestamp,
            creationTimestamp: creationTimestamp
        )
    }
    
    /// Get the last run date of this task
    /// - Returns: A Date object representing the last run date, if available
    public func lastRunDate() -> Date? {
        lastRunTimestamp.map { Date.fromTimestamp($0) }
    }
    
    /// Get the next run date of this task
    /// - Returns: A Date object representing the next run date, if available
    public func nextRunDate() -> Date? {
        nextRunTimestamp.map { Date.fromTimestamp($0) }
    }
    
    /// Get the creation date of this task
    /// - Returns: A Date object representing the creation date
    public func creationDate() -> Date {
        Date.fromTimestamp(creationTimestamp)
    }
    
    /// Calculate and update the next run timestamp based on the schedule
    /// - Parameter currentDate: The current date (defaults to now)
    /// - Returns: A new task with the updated next run timestamp
    public func calculateNextRun(currentDate: Date = Date()) -> ScheduledTaskDTO {
        // Get current timestamp
        let currentTimestamp = currentDate.timestampInSeconds
        
        // If schedule is disabled or end date is passed, no next run
        if !schedule.enabled || (schedule.endTimestamp != nil && schedule.endTimestamp! < currentTimestamp) {
            return .init(
                taskId: taskId,
                schedule: schedule,
                status: status,
                configData: configData,
                lastRunTimestamp: lastRunTimestamp,
                nextRunTimestamp: nil,
                creationTimestamp: creationTimestamp
            )
        }
        
        // Calculate next run based on frequency type
        let nextTimestamp: UInt64
        
        switch schedule.frequencyType {
        case .hourly:
            // Next hour
            let calendar = Calendar.current
            var nextHourDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
            
            // If we have a time window, ensure next run is within that window
            if let windowStart = schedule.windowStartTime, let windowEnd = schedule.windowEndTime {
                let components = calendar.dateComponents([.hour, .minute, .second], from: nextHourDate)
                let secondsFromMidnight = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
                
                // If not within window, adjust to next window start
                if secondsFromMidnight < windowStart || secondsFromMidnight > windowEnd {
                    // Move to start of day
                    nextHourDate = calendar.startOfDay(for: nextHourDate)
                    
                    // Add window start time
                    nextHourDate = calendar.date(byAdding: .second, value: Int(windowStart), to: nextHourDate)!
                    
                    // If still earlier than current time, move to next day
                    if nextHourDate.compare(currentDate) == .orderedAscending {
                        nextHourDate = calendar.date(byAdding: .day, value: 1, to: nextHourDate)!
                    }
                }
            }
            
            nextTimestamp = nextHourDate.timestampInSeconds
            
        case .daily:
            // Next day at same time
            let calendar = Calendar.current
            var nextDayDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            
            // If we have a time window, adjust to window start
            if let windowStart = schedule.windowStartTime {
                // Get time components
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: nextDayDate)
                
                // Start of the next day
                nextDayDate = calendar.startOfDay(for: nextDayDate)
                
                // Add window start time
                nextDayDate = calendar.date(byAdding: .second, value: Int(windowStart), to: nextDayDate)!
            }
            
            nextTimestamp = nextDayDate.timestampInSeconds
            
        case .weekly:
            // Next week, same day and time
            let calendar = Calendar.current
            var nextWeekDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
            
            // If we have a time window, adjust to window start
            if let windowStart = schedule.windowStartTime {
                // Start of the day for next week
                nextWeekDate = calendar.startOfDay(for: nextWeekDate)
                
                // Add window start time
                nextWeekDate = calendar.date(byAdding: .second, value: Int(windowStart), to: nextWeekDate)!
            }
            
            nextTimestamp = nextWeekDate.timestampInSeconds
            
        case .monthly:
            // Next month, same day and time
            let calendar = Calendar.current
            var nextMonthDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
            
            // If we have a time window, adjust to window start
            if let windowStart = schedule.windowStartTime {
                // Start of the day for next month
                nextMonthDate = calendar.startOfDay(for: nextMonthDate)
                
                // Add window start time
                nextMonthDate = calendar.date(byAdding: .second, value: Int(windowStart), to: nextMonthDate)!
            }
            
            nextTimestamp = nextMonthDate.timestampInSeconds
            
        case .custom:
            // For custom, assume it's a one-time schedule
            nextTimestamp = 0
        }
        
        // Check if we've reached max runs
        if let maxRuns = schedule.maxRuns, let lastRunCount = runCount {
            if lastRunCount >= maxRuns {
                // Max runs reached, no more runs
                return .init(
                    taskId: taskId,
                    schedule: schedule,
                    status: status,
                    configData: configData,
                    lastRunTimestamp: lastRunTimestamp,
                    nextRunTimestamp: nil,
                    creationTimestamp: creationTimestamp,
                    runCount: lastRunCount
                )
            }
        }
        
        // Return updated task with new next run timestamp
        return .init(
            taskId: taskId,
            schedule: schedule,
            status: status,
            configData: configData,
            lastRunTimestamp: lastRunTimestamp,
            nextRunTimestamp: nextTimestamp,
            creationTimestamp: creationTimestamp,
            runCount: runCount
        )
    }
}

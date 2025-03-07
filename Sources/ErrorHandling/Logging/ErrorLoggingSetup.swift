// ErrorLoggingSetup.swift
// Examples of how to set up and configure SwiftyBeaver-based error logging
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import SwiftyBeaver
import UmbraLogging
import UmbraLoggingAdapters

/// Helper class to set up error logging in the application
public final class ErrorLoggingSetup {
    
    /// Sets up error logging for the application in the AppDelegate
    /// - Returns: A configured ErrorLogger instance
    public static func setupApplicationLogging() -> ErrorLogger {
        // Set up SwiftyBeaver destinations optimally
        configureSwiftyBeaver()
        
        // Configure the error logger based on build configuration
        #if DEBUG
        return ErrorLogger.setupDevelopmentLogger()
        #else
        return ErrorLogger.setupProductionLogger()
        #endif
    }
    
    /// Sets up SwiftyBeaver with optimal configuration
    private static func configureSwiftyBeaver() {
        // Get the SwiftyBeaver instance from the LoggerImplementation
        // This is a simplified example - in a real app, we might need to 
        // configure the LoggerImplementation more directly
        
        // Configure colours for different log levels (British spelling in comments)
        let console = ConsoleDestination()
        
        // Use OSLog API for better console integration in Xcode 15
        console.logPrintWay = .logger(subsystem: "com.umbracorp.umbra-core", category: "ErrorHandling")
        
        // Use a custom format that includes helpful debugging information
        // Format: timestamp [level] filename:line - message
        console.format = "$DHH:mm:ss.SSS$d [$L] $N.$F:$l - $M $X"
        
        // Set up file logging for persistent records
        #if !DEBUG
        let file = FileDestination()
        
        // Configure the file destination
        file.format = "$J" // Use JSON format for machine readability
        
        // Set a custom log file in the application support directory
        if let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let errorLogURL = appSupportDir.appendingPathComponent("umbra_errors.log")
            file.logFileURL = errorLogURL
        }
        
        // Add both destinations via the UmbraLoggingAdapters API
        LoggerImplementation.withDestinations([console, file])
        #else
        // Just add console for development
        LoggerImplementation.withDestinations([console])
        #endif
    }
    
    /// Demonstrates various filtering options for the ErrorLogger
    /// - Returns: An ErrorLogger configured with filters
    public static func setupWithFilters() -> ErrorLogger {
        return ErrorLogger.shared.configure { config in
            // Filter 1: Only log errors from specific domains
            let domainFilter: (UmbraError) -> Bool = { error in
                let criticalDomains = ["Security", "DataStore", "Networking"]
                return criticalDomains.contains(error.domain)
            }
            
            // Filter 2: Exclude errors with specific codes
            let codeFilter: (UmbraError) -> Bool = { error in
                let ignoredCodes = ["user_cancelled", "timeout_recoverable"]
                return !ignoredCodes.contains(error.code)
            }
            
            // Filter 3: Only log errors with source information in production
            let sourceFilter: (UmbraError) -> Bool = { error in
                #if DEBUG
                return true
                #else
                return error.source != nil
                #endif
            }
            
            // Combine all filters
            config.filters = [domainFilter, codeFilter, sourceFilter]
        }
    }
    
    /// Demonstrates how to capture device and system information for error logs
    /// - Returns: A configured ErrorLogger with system info
    public static func setupWithSystemInfo() -> ErrorLogger {
        // Create a base logger
        let logger = ErrorLogger.shared
        
        // Add system information to the logger configuration
        return logger.configure { config in
            // Add system information as default metadata for all logs
            let systemInfo = captureSystemInformation()
            
            // Create a filter that adds system information to each error
            let systemInfoFilter: (UmbraError) -> Bool = { error in
                // This filter always returns true but adds system info as a side effect
                var context = error.context
                for (key, value) in systemInfo {
                    context.metadata[key] = value
                }
                
                // We can't actually modify the error here since filters should be pure functions,
                // but in a real implementation we might use a different approach to add
                // this information to the error context before logging
                
                return true
            }
            
            // Add this as our first filter
            config.filters.insert(systemInfoFilter, at: 0)
        }
    }
    
    /// Captures system information for error context
    /// - Returns: Dictionary of system information
    private static func captureSystemInformation() -> [String: Any] {
        // In a real implementation, this would capture more system info
        var systemInfo: [String: Any] = [:]
        
        #if os(iOS)
        systemInfo["platform"] = "iOS"
        #elseif os(macOS)
        systemInfo["platform"] = "macOS"
        #endif
        
        systemInfo["appVersion"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        systemInfo["buildNumber"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        
        // Add more system information as needed
        
        return systemInfo
    }
}

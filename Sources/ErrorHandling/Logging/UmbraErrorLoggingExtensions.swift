// UmbraErrorLoggingExtensions.swift
// Logging extensions for UmbraError
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// Extension to add logging capabilities to UmbraError
public extension UmbraError {
    /// Logs this error at error level
    /// - Parameters:
    ///   - additionalMessage: Optional additional message for context
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func logAsError(
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        ErrorLogger.shared.logError(
            self,
            additionalMessage: additionalMessage,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Logs this error at warning level
    /// - Parameters:
    ///   - additionalMessage: Optional additional message for context
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func logAsWarning(
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        ErrorLogger.shared.logWarning(
            self,
            additionalMessage: additionalMessage,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Logs this error at info level
    /// - Parameters:
    ///   - additionalMessage: Optional additional message for context
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func logAsInfo(
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        ErrorLogger.shared.logInfo(
            self,
            additionalMessage: additionalMessage,
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Logs this error at debug level
    /// - Parameters:
    ///   - additionalMessage: Optional additional message for context
    ///   - file: Source file (auto-filled by the compiler)
    ///   - function: Function name (auto-filled by the compiler)
    ///   - line: Line number (auto-filled by the compiler)
    func logAsDebug(
        additionalMessage: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        ErrorLogger.shared.logDebug(
            self,
            additionalMessage: additionalMessage,
            file: file,
            function: function,
            line: line
        )
    }
}

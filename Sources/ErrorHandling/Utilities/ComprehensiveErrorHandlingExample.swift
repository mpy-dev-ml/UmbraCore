// ComprehensiveErrorHandlingExample.swift
// Comprehensive examples of how to use the enhanced error handling system
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import UmbraLogging
import UmbraLoggingAdapters

/// Comprehensive examples showing how to use the enhanced error handling system
/// with SwiftyBeaver logging, error recovery, and notifications
public final class ComprehensiveErrorHandlingExample {
    
    /// Sets up the error handling system for an application
    public func setupErrorHandling() {
        // 1. Configure SwiftyBeaver logging first
        let logger = ErrorLoggingSetup.setupApplicationLogging()
        
        // 2. Register error recovery services
        ErrorRecoveryRegistry.shared.register(SecurityErrorRecoveryService.shared)
        
        // 3. Register error notification services
        #if os(macOS)
        ErrorNotifier.shared.register(MacErrorNotificationService.forAllDomains())
        #endif
        
        // 4. Configure notification settings
        #if DEBUG
        ErrorNotifier.shared.minimumNotificationLevel = .debug
        #else
        ErrorNotifier.shared.minimumNotificationLevel = .warning
        #endif
        
        logger.logDebug("Error handling system initialised successfully", metadata: nil)
    }
    
    /// Example of handling errors with recovery and notification
    public func comprehensiveErrorHandlingExample() async {
        do {
            // Try an operation that might fail
            try await performSecureOperation()
        } catch let error as SecurityError {
            // Handle security error with recovery and notification
            await handleSecurityErrorComprehensively(error)
        } catch let error as UmbraError {
            // Handle other UmbraError types
            await handleUmbraErrorComprehensively(error)
        } catch {
            // Handle standard Swift errors by wrapping them
            let wrappedError = ErrorFactory.wrapError(
                error,
                domain: "AppErrors",
                code: "unknown_error",
                description: "An unexpected error occurred"
            )
            
            // Then handle like any other UmbraError
            await handleUmbraErrorComprehensively(wrappedError)
        }
    }
    
    /// Example of handling errors with automatic recovery
    public func tryWithAutoRecoveryExample() async -> Bool {
        do {
            // Try an operation that might fail
            try await performSecureOperation()
            return true
        } catch let error as RecoverableError where error.isRecoverable {
            // If the error is recoverable, try automatic recovery
            if await ErrorRecoveryRegistry.shared.attemptRecovery(for: error) {
                // Recovery succeeded, retry the operation
                return await tryWithAutoRecoveryExample()
            } else {
                // Recovery failed, log and notify
                error.logAsError("Automatic recovery failed")
                await error.notify(level: .error, logError: false)
                return false
            }
        } catch let error as UmbraError {
            // Not automatically recoverable, log and notify
            error.logAsError("Non-recoverable error")
            await error.notify(level: .error, logError: false)
            return false
        } catch {
            // Handle standard Swift errors
            let wrappedError = ErrorFactory.wrapError(
                error,
                domain: "AppErrors",
                code: "unknown_error",
                description: "An unexpected error occurred"
            )
            
            wrappedError.logAsError()
            await wrappedError.notify(level: .error, logError: false)
            return false
        }
    }
    
    /// Example of using the error handling system with async/await and Tasks
    public func asyncTaskErrorHandlingExample() async {
        // Create a task group to handle multiple operations that might fail
        await withTaskGroup(of: Result<Void, UmbraError>.self) { group in
            // Add multiple tasks
            group.addTask {
                do {
                    try await self.performSecureOperation()
                    return .success(())
                } catch let error as UmbraError {
                    return .failure(error)
                } catch {
                    return .failure(ErrorFactory.wrapError(
                        error,
                        domain: "TaskErrors",
                        code: "task_failure",
                        description: "Task failed with error"
                    ))
                }
            }
            
            group.addTask {
                do {
                    try await self.performDatabaseOperation()
                    return .success(())
                } catch let error as UmbraError {
                    return .failure(error)
                } catch {
                    return .failure(ErrorFactory.wrapError(
                        error,
                        domain: "TaskErrors",
                        code: "task_failure",
                        description: "Task failed with error"
                    ))
                }
            }
            
            // Process results of each task
            for await result in group {
                switch result {
                case .success:
                    continue
                case .failure(let error):
                    // Log the error
                    error.logAsError("Task failed")
                    
                    // Try to recover and notify
                    _ = await error.notifyAndRecover(level: .warning)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Handle security errors comprehensively
    private func handleSecurityErrorComprehensively(_ error: SecurityError) async {
        // 1. Log the error with SwiftyBeaver
        error.logAsError("Security operation failed")
        
        // 2. Try to automatically recover
        let recoveryOptions = ErrorRecoveryRegistry.shared.recoveryOptions(for: error)
        
        if !recoveryOptions.isEmpty {
            // Only try non-disruptive recovery options automatically
            let nonDisruptiveOptions = recoveryOptions.filter { !$0.isDisruptive }
            
            for option in nonDisruptiveOptions {
                if await option.attemptRecovery() {
                    // Recovery succeeded, log and return
                    ErrorLogger.shared.logInfo(
                        error,
                        additionalMessage: "Successfully recovered from error with option: \(option.title)"
                    )
                    return
                }
            }
        }
        
        // 3. Notify user if automatic recovery failed or wasn't possible
        let recoverySucceeded = await error.notifyAndRecover(level: .error, logError: false)
        
        if recoverySucceeded {
            ErrorLogger.shared.logInfo(
                error,
                additionalMessage: "User-initiated recovery succeeded"
            )
        } else {
            ErrorLogger.shared.logError(
                error,
                additionalMessage: "Recovery failed or not attempted"
            )
        }
    }
    
    /// Handle general UmbraErrors comprehensively
    private func handleUmbraErrorComprehensively(_ error: UmbraError) async {
        // 1. Log the error with SwiftyBeaver
        error.logAsError()
        
        // 2. Determine appropriate notification level based on error
        let notificationLevel: ErrorNotificationLevel
        
        switch error.domain {
        case "Security":
            notificationLevel = .critical
        case "Network", "Database":
            notificationLevel = .error
        default:
            notificationLevel = .warning
        }
        
        // 3. Notify user and try recovery
        let recoverySucceeded = await error.notifyAndRecover(level: notificationLevel, logError: false)
        
        if recoverySucceeded {
            ErrorLogger.shared.logInfo(
                error,
                additionalMessage: "Error recovered successfully"
            )
        }
    }
    
    /// Simulated secure operation that might fail
    private func performSecureOperation() async throws {
        // Simulate a security operation
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Randomly fail with different security errors for demonstration
        let random = Int.random(in: 0...5)
        
        switch random {
        case 0:
            return // Success
        case 1:
            throw SecurityError.authenticationFailed("User authentication failed")
                .with(source: makeErrorSource())
        case 2:
            throw SecurityError.authorizationFailed("Insufficient permissions")
                .with(source: makeErrorSource())
        case 3:
            throw SecurityError.cryptoOperationFailed("Encryption failed")
                .with(source: makeErrorSource())
        case 4:
            throw SecurityError.connectionFailed("Security service unavailable")
                .with(source: makeErrorSource())
        case 5:
            throw SecurityError.tamperedData("Data integrity check failed")
                .with(source: makeErrorSource())
                .with(context: ErrorContext(
                    source: "IntegrityChecker",
                    code: "checksum_mismatch",
                    message: "Expected checksum does not match",
                    metadata: [
                        "expectedChecksum": "abcdef123456",
                        "actualChecksum": "abcdef123400"
                    ]
                ))
        default:
            throw SecurityError.generalError("Unknown security error")
                .with(source: makeErrorSource())
        }
    }
    
    /// Simulated database operation that might fail
    private func performDatabaseOperation() async throws {
        // Simulate a database operation
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Use a different error domain for variety
        if Bool.random() {
            throw ErrorFactory.makeError(
                domain: "Database",
                code: "query_failed",
                description: "Database query failed",
                source: makeErrorSource(),
                context: ErrorContext(
                    source: "QueryEngine",
                    code: "syntax_error",
                    message: "SQL syntax error in query",
                    metadata: [
                        "query": "SELECT * FROM users WHERE id = ?",
                        "parameters": "['user_123']"
                    ]
                )
            )
        }
    }
}

// MARK: - Helper Extensions

extension SecurityError: RecoverableError {
    /// Provides recovery options for this security error
    public func recoveryOptions() -> [ErrorRecoveryOption] {
        return SecurityErrorRecoveryService.shared.recoveryOptions(for: self)
    }
}

// ErrorRecovery.swift
// Error recovery mechanisms for the enhanced error handling system
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// Represents a potential recovery option for an error
public struct ErrorRecoveryOption {
    /// A unique identifier for this recovery option
    public let id: String
    
    /// User-facing title for this recovery option
    public let title: String
    
    /// Additional description of what this recovery will do
    public let description: String?
    
    /// How likely this recovery option is to succeed
    public let successLikelihood: RecoveryLikelihood
    
    /// Whether this recovery option can disrupt the user's workflow
    public let isDisruptive: Bool
    
    /// The action to perform for recovery
    public let recoveryAction: () async throws -> Void
    
    /// Creates a new recovery option
    /// - Parameters:
    ///   - id: Unique identifier for this recovery option
    ///   - title: User-facing title
    ///   - description: Optional detailed description
    ///   - successLikelihood: How likely the recovery is to succeed
    ///   - isDisruptive: Whether this recovery may disrupt the user's workflow
    ///   - recoveryAction: The action to perform for recovery
    public init(
        id: String,
        title: String,
        description: String? = nil,
        successLikelihood: RecoveryLikelihood = .likely,
        isDisruptive: Bool = false,
        recoveryAction: @escaping () async throws -> Void
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.successLikelihood = successLikelihood
        self.isDisruptive = isDisruptive
        self.recoveryAction = recoveryAction
    }
    
    /// Executes the recovery action
    /// - Returns: Whether the recovery was successful
    public func attemptRecovery() async -> Bool {
        do {
            try await recoveryAction()
            return true
        } catch {
            ErrorLogger.shared.logError(
                ErrorFactory.wrapError(
                    error,
                    domain: "ErrorRecovery",
                    code: "recovery_failed",
                    description: "Recovery attempt failed: \(title)"
                )
            )
            return false
        }
    }
}

/// Indicates how likely a recovery option is to succeed
public enum RecoveryLikelihood: Int, Comparable {
    case unlikely = 0
    case possible = 1
    case likely = 2
    case veryLikely = 3
    
    public static func < (lhs: RecoveryLikelihood, rhs: RecoveryLikelihood) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Protocol for errors that provide recovery options
public protocol RecoverableError: UmbraError {
    /// Gets available recovery options for this error
    /// - Returns: Array of recovery options
    func recoveryOptions() -> [ErrorRecoveryOption]
    
    /// Whether this error can be recovered from
    var isRecoverable: Bool { get }
}

/// Default implementation for RecoverableError
public extension RecoverableError {
    /// Default implementation returns whether there are any recovery options
    var isRecoverable: Bool {
        return !recoveryOptions().isEmpty
    }
}

/// Protocol for services that can help recover from errors
public protocol ErrorRecoveryService {
    /// Gets recovery options for a given error
    /// - Parameter error: The error to recover from
    /// - Returns: Array of recovery options, if available
    func recoveryOptions(for error: UmbraError) -> [ErrorRecoveryOption]
    
    /// Attempts to recover from an error using all available options
    /// - Parameter error: The error to recover from
    /// - Returns: Whether recovery was successful
    func attemptRecovery(for error: UmbraError) async -> Bool
}

/// A registry of error recovery services
public final class ErrorRecoveryRegistry {
    /// The shared instance
    public static let shared = ErrorRecoveryRegistry()
    
    /// Registered recovery services
    private var recoveryServices: [ErrorRecoveryService] = []
    
    /// Private initialiser to enforce singleton pattern
    private init() {}
    
    /// Registers a recovery service
    /// - Parameter service: The service to register
    public func register(_ service: ErrorRecoveryService) {
        recoveryServices.append(service)
    }
    
    /// Gets all available recovery options for an error
    /// - Parameter error: The error to find recovery options for
    /// - Returns: Array of recovery options from all registered services
    public func recoveryOptions(for error: UmbraError) -> [ErrorRecoveryOption] {
        var options: [ErrorRecoveryOption] = []
        
        // If the error itself provides recovery options, use those first
        if let recoverableError = error as? RecoverableError {
            options.append(contentsOf: recoverableError.recoveryOptions())
        }
        
        // Then add options from all registered recovery services
        for service in recoveryServices {
            options.append(contentsOf: service.recoveryOptions(for: error))
        }
        
        // Remove duplicates by ID
        var uniqueOptions: [ErrorRecoveryOption] = []
        var seenIDs = Set<String>()
        
        for option in options {
            if !seenIDs.contains(option.id) {
                uniqueOptions.append(option)
                seenIDs.insert(option.id)
            }
        }
        
        // Sort options by likelihood of success (most likely first)
        return uniqueOptions.sorted { $0.successLikelihood > $1.successLikelihood }
    }
    
    /// Attempts to recover from an error using all registered services
    /// - Parameters:
    ///   - error: The error to recover from
    ///   - filterOptions: Optional filter to select specific recovery options
    /// - Returns: Whether any recovery was successful
    public func attemptRecovery(
        for error: UmbraError,
        filterOptions: ((ErrorRecoveryOption) -> Bool)? = nil
    ) async -> Bool {
        // Get recovery options
        var options = recoveryOptions(for: error)
        
        // Apply filter if provided
        if let filterOptions = filterOptions {
            options = options.filter(filterOptions)
        }
        
        // Try options in order (most likely to succeed first)
        for option in options {
            if await option.attemptRecovery() {
                return true
            }
        }
        
        return false
    }
}

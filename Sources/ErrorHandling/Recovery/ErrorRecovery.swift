// ErrorRecovery.swift
// Error recovery mechanisms for the enhanced error handling system
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingProtocols
import ErrorHandlingModels
import ErrorHandlingCommon
import ErrorHandlingLogging
import ErrorHandlingDomains

/// Represents a potential recovery option for an error
public struct ErrorRecoveryOption: Sendable {
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
    public let recoveryAction: @Sendable () async throws -> Void
    
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
        recoveryAction: @escaping @Sendable () async throws -> Void
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.successLikelihood = successLikelihood
        self.isDisruptive = isDisruptive
        self.recoveryAction = recoveryAction
    }
    
    /// Execute the recovery action
    /// - Returns: Whether recovery was successful
    public func execute() async -> Bool {
        do {
            try await recoveryAction()
            return true
        } catch {
            ErrorLogger.shared.logError(
                GenericUmbraError(
                    domain: "ErrorRecovery",
                    code: "RecoveryFailed",
                    errorDescription: "Recovery action failed: \(error.localizedDescription)",
                    underlyingError: error
                )
            )
            return false
        }
    }
}

/// How likely a recovery option is to succeed
public enum RecoveryLikelihood: String, CaseIterable, Sendable {
    case veryLikely = "Very Likely"
    case likely = "Likely"
    case possible = "Possible"
    case unlikely = "Unlikely"
    case veryUnlikely = "Very Unlikely"
    
    /// Gets a numerical value representing the likelihood (0-1)
    public var probability: Double {
        switch self {
        case .veryLikely: return 0.9
        case .likely: return 0.7
        case .possible: return 0.5
        case .unlikely: return 0.3
        case .veryUnlikely: return 0.1
        }
    }
}

/// Protocol for errors that provide recovery options
public protocol RecoverableError: ErrorHandlingProtocols.UmbraError {
    /// Gets available recovery options for this error
    /// - Returns: Array of recovery options
    func recoveryOptions() -> [ErrorRecoveryOption]
    
    /// Attempts to recover from this error using all available options
    /// - Returns: Whether recovery was successful
    func attemptRecovery() async -> Bool
}

/// Default implementation of RecoverableError
public extension RecoverableError {
    /// Default implementation attempts each recovery option in order
    func attemptRecovery() async -> Bool {
        let options = recoveryOptions()
        for option in options {
            if await option.execute() {
                return true
            }
        }
        return false
    }
}

/// Protocol for error recovery services
public protocol ErrorRecoveryService: AnyObject, Sendable {
    /// Gets recovery options for a specific error
    /// - Parameter error: The error to recover from
    /// - Returns: Array of recovery options, if available
    func recoveryOptions(for error: ErrorHandlingProtocols.UmbraError) -> [ErrorRecoveryOption]
    
    /// Attempts to recover from an error using all available options
    /// - Parameter error: The error to recover from
    /// - Returns: Whether recovery was successful
    func attemptRecovery(for error: ErrorHandlingProtocols.UmbraError) async -> Bool
}

/// A registry of error recovery services
@MainActor
public final class ErrorRecoveryRegistry {
    /// The shared instance
    public static let shared = ErrorRecoveryRegistry()
    
    /// Registered recovery services
    private var services: [any ErrorRecoveryService] = []
    
    /// Private initialiser to enforce singleton pattern
    private init() {}
    
    /// Register a new recovery service
    /// - Parameter service: The service to register
    public func register(service: any ErrorRecoveryService) {
        services.append(service)
    }
    
    /// Get recovery options for an error from all registered services
    /// - Parameter error: The error to get recovery options for
    /// - Returns: Array of recovery options from all services
    public func recoveryOptions(for error: ErrorHandlingProtocols.UmbraError) -> [ErrorRecoveryOption] {
        var options: [ErrorRecoveryOption] = []
        for service in services {
            options.append(contentsOf: service.recoveryOptions(for: error))
        }
        return options
    }
    
    /// Attempt to recover from an error using all registered services
    /// - Parameter error: The error to recover from
    /// - Returns: Whether recovery was successful
    public func attemptRecovery(for error: ErrorHandlingProtocols.UmbraError) async -> Bool {
        for service in services {
            if await service.attemptRecovery(for: error) {
                return true
            }
        }
        return false
    }
}

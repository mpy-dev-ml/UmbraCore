// ErrorHandlingExamples.swift
// Examples of how to use the enhanced error handling system
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import UmbraLogging
import UmbraLoggingAdapters

/// Examples of how to use the enhanced error handling system
public final class ErrorHandlingExamples {
    
    /// Example of creating and handling a security error
    public func securityErrorExample() {
        do {
            try authenticateUser(username: "user", password: "pass")
        } catch let error as SecurityError {
            // Handle security error with rich context
            handleSecurityError(error)
        } catch {
            // Handle other errors
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    /// Example of mapping between error types
    public func errorMappingExample() {
        // Get an instance of SecurityError
        let securityError = authenticationFailedError("Invalid credentials")
        
        // Map to CoreError using the registry
        if let coreError = ErrorRegistry.shared.map(securityError, to: CoreError.self) {
            print("Mapped to CoreError: \(coreError.localizedDescription)")
        }
        
        // Create a CoreError
        let coreError = CoreError.insufficientPermissions
        
        // Map back to SecurityError
        if let mappedSecurityError = ErrorRegistry.shared.map(coreError, to: SecurityError.self) {
            print("Mapped back to SecurityError: \(mappedSecurityError.errorDescription)")
        }
    }
    
    /// Example of adding context to errors
    public func contextEnrichmentExample() {
        do {
            try performOperation()
        } catch let error as UmbraError {
            // Enrich the error with additional context
            let enrichedError = error.with(context: ErrorContext.withDetails(
                message: "Operation failed with additional details",
                source: "ContextExample",
                code: "enriched_error"
            ))
            
            // Log the enriched error
            enrichedError.logAsError("Enriched error example")
            
            // Extract information from the context
            if let file = enrichedError.context.typedValue(for: "file", as: String.self),
               let line = enrichedError.context.typedValue(for: "line", as: Int.self) {
                print("Error occurred in file \(file) at line \(line)")
            }
        } catch {
            // Handle other errors
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    /// Example of wrapping errors
    public func errorWrappingExample() {
        do {
            try performNetworkOperation()
        } catch {
            // Wrap the error in a GenericUmbraError
            let wrappedError = ErrorFactory.wrapError(
                error,
                domain: "NetworkOperations",
                code: "network_failure",
                description: "Network operation failed"
            )
            
            // Access the underlying error
            if let underlyingError = wrappedError.underlyingError {
                print("Underlying error: \(underlyingError.localizedDescription)")
            }
            
            // Log the wrapped error
            wrappedError.logAsError()
        }
    }
    
    /// Example of using SwiftyBeaver logging with errors
    public func loggingExample() {
        // Create errors with different severity levels
        let debugError = SecurityError.generalError("This is a debug-level issue")
            .with(source: makeErrorSource())
        
        let infoError = SecurityError.connectionFailed("Connection temporarily unavailable")
            .with(source: makeErrorSource())
        
        let warningError = SecurityError.authorizationFailed("Permissions will expire soon")
            .with(source: makeErrorSource())
        
        let criticalError = SecurityError.tamperedData("Data integrity violation detected")
            .with(source: makeErrorSource())
            .with(context: ErrorContext(
                source: "DataValidator",
                code: "integrity_violation",
                message: "Checksum verification failed",
                metadata: [
                    "expectedHash": "a1b2c3d4e5f6",
                    "actualHash": "a1b2c3d4e5f7",
                    "userID": "user123",
                    "documentID": "doc456"
                ]
            ))
        
        // Log each error at the appropriate level
        debugError.logAsDebug("Debugging information")
        infoError.logAsInfo("System status")
        warningError.logAsWarning("Security notice")
        criticalError.logAsError("CRITICAL SECURITY ALERT")
        
        // Demonstrate using the ErrorLogger directly
        ErrorLogger.shared.logError(
            criticalError,
            additionalMessage: "Security team has been notified"
        )
    }
    
    // MARK: - Private Methods
    
    private func authenticateUser(username: String, password: String) throws {
        // Simulated authentication failure
        throw authenticationFailedError("Invalid credentials for user \(username)")
    }
    
    private func performOperation() throws {
        // Simulated operation failure
        throw SecurityError.cryptoOperationFailed("Failed to encrypt data")
            .with(source: makeErrorSource())
    }
    
    private func performNetworkOperation() throws {
        // Simulated network error
        struct NetworkError: Error {
            let message: String
        }
        
        throw NetworkError(message: "Connection timeout")
    }
    
    private func handleSecurityError(_ error: SecurityError) {
        error.logAsError("Security system encountered an error")
        
        // Log source information if available
        if let source = error.source {
            print("Error occurred at \(source.function) in \(source.fileName):\(source.line)")
        }
        
        // Extract additional context
        for (key, value) in error.context.metadata {
            print("Context [\(key)]: \(String(describing: value))")
        }
        
        // Handle different types of security errors
        switch error {
        case .authenticationFailed:
            print("Authentication failed, prompting user to re-enter credentials")
            
        case .authorizationFailed:
            print("Authorization failed, checking user permissions")
            
        case .cryptoOperationFailed:
            print("Cryptographic operation failed, checking algorithm and keys")
            
        default:
            print("Other security error: \(error.code)")
        }
    }
}

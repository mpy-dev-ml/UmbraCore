// RepositoryError.swift
// Error types for repository operations
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingInterfaces
import ErrorHandlingCommon

/// Enum representing the specific repository error types
public enum RepositoryErrorType: Error {
    /// The repository could not be found
    case repositoryNotFound(String)
    
    /// The repository could not be opened
    case repositoryOpenFailed(String)
    
    /// The repository is corrupt
    case repositoryCorrupt(String)
    
    /// The repository is locked by another process
    case repositoryLocked(String)
    
    /// The repository is in an invalid state
    case invalidState(String)
    
    /// Permission denied for repository operation
    case permissionDenied(String)
    
    /// The object could not be found in the repository
    case objectNotFound(String)
    
    /// The object already exists in the repository
    case objectAlreadyExists(String)
    
    /// The object is corrupt
    case objectCorrupt(String)
    
    /// The object type is invalid
    case invalidObjectType(String)
    
    /// The object data is invalid
    case invalidObjectData(String)
    
    /// Failed to save the object
    case saveFailed(String)
    
    /// Failed to load the object
    case loadFailed(String)
    
    /// Failed to delete the object
    case deleteFailed(String)
    
    /// Operation timed out
    case timeout(String)
    
    /// General repository error
    case general(String)
    
    /// Get a descriptive message for this error type
    var message: String {
        switch self {
        case .repositoryNotFound(let message): return "Repository not found: \(message)"
        case .repositoryOpenFailed(let message): return "Failed to open repository: \(message)"
        case .repositoryCorrupt(let message): return "Repository is corrupt: \(message)"
        case .repositoryLocked(let message): return "Repository is locked: \(message)"
        case .invalidState(let message): return "Invalid repository state: \(message)"
        case .permissionDenied(let message): return "Permission denied: \(message)"
        case .objectNotFound(let message): return "Object not found: \(message)"
        case .objectAlreadyExists(let message): return "Object already exists: \(message)"
        case .objectCorrupt(let message): return "Object is corrupt: \(message)"
        case .invalidObjectType(let message): return "Invalid object type: \(message)"
        case .invalidObjectData(let message): return "Invalid object data: \(message)"
        case .saveFailed(let message): return "Failed to save object: \(message)"
        case .loadFailed(let message): return "Failed to load object: \(message)"
        case .deleteFailed(let message): return "Failed to delete object: \(message)"
        case .timeout(let message): return "Operation timed out: \(message)"
        case .general(let message): return "Repository error: \(message)"
        }
    }
    
    /// Get a short code for this error type
    var code: String {
        switch self {
        case .repositoryNotFound: return "repo_not_found"
        case .repositoryOpenFailed: return "repo_open_failed"
        case .repositoryCorrupt: return "repo_corrupt"
        case .repositoryLocked: return "repo_locked"
        case .invalidState: return "invalid_state"
        case .permissionDenied: return "permission_denied"
        case .objectNotFound: return "object_not_found"
        case .objectAlreadyExists: return "object_already_exists"
        case .objectCorrupt: return "object_corrupt"
        case .invalidObjectType: return "invalid_object_type"
        case .invalidObjectData: return "invalid_object_data"
        case .saveFailed: return "save_failed"
        case .loadFailed: return "load_failed"
        case .deleteFailed: return "delete_failed"
        case .timeout: return "timeout"
        case .general: return "general_error"
        }
    }
}

/// Struct wrapper for repository errors that conforms to UmbraError
public struct RepositoryError: Error, UmbraError, Sendable, CustomStringConvertible {
    /// The specific repository error type
    public let errorType: RepositoryErrorType
    
    /// The domain for repository errors
    public let domain: String = "Repository"
    
    /// The error code
    public var code: String {
        errorType.code
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
        errorType.message
    }
    
    /// A user-readable description of the error
    public var description: String {
        return "[\(domain).\(code)] \(errorDescription)"
    }
    
    /// Source information about where the error occurred
    public let source: ErrorHandlingCommon.ErrorSource?
    
    /// The underlying error, if any
    public let underlyingError: Error?
    
    /// Additional context for the error
    public let context: ErrorHandlingCommon.ErrorContext
    
    /// Initialize a new repository error
    public init(
        errorType: RepositoryErrorType,
        source: ErrorHandlingCommon.ErrorSource? = nil,
        underlyingError: Error? = nil,
        context: ErrorHandlingCommon.ErrorContext? = nil
    ) {
        self.errorType = errorType
        self.source = source
        self.underlyingError = underlyingError
        self.context = context ?? ErrorHandlingCommon.ErrorContext(
            source: "Repository",
            operation: "repositoryOperation",
            details: errorType.message
        )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> Self {
        RepositoryError(
            errorType: self.errorType,
            source: self.source,
            underlyingError: self.underlyingError,
            context: context
        )
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
        RepositoryError(
            errorType: self.errorType,
            source: self.source,
            underlyingError: underlyingError,
            context: self.context
        )
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> Self {
        RepositoryError(
            errorType: self.errorType,
            source: source,
            underlyingError: self.underlyingError,
            context: self.context
        )
    }
    
    /// Create a repository error with the specified type and message
    public static func create(
        _ type: RepositoryErrorType,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> RepositoryError {
        RepositoryError(
            errorType: type,
            source: ErrorHandlingCommon.ErrorSource(
                file: file,
                function: function,
                line: line
            )
        )
    }
    
    /// Convenience initializers for specific error types
    public static func notFound(_ message: String, file: String = #file, function: String = #function, line: Int = #line) -> RepositoryError {
        create(.repositoryNotFound(message), file: file, function: function, line: line)
    }
    
    public static func openFailed(_ message: String, file: String = #file, function: String = #function, line: Int = #line) -> RepositoryError {
        create(.repositoryOpenFailed(message), file: file, function: function, line: line)
    }
    
    // Add other convenience methods as needed
}

// MARK: - Mapping Extension

extension RepositoryError {
    /// Create a RepositoryError from a CoreErrors.RepositoryError
    ///
    /// This allows for easier migration from the legacy error system
    ///
    /// - Parameter legacyError: The legacy CoreErrors.RepositoryError
    /// - Returns: The equivalent RepositoryError
    public static func from(legacyError: Any) -> RepositoryError {
        // We need to refactor this mapping once we have access to the actual CoreErrors type
        // For now just return a generic error to fix the build
        return RepositoryError(errorType: .general("Converted from legacy error"))
    }
}

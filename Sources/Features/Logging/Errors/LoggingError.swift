import Foundation
import SecurityTypes

/// Errors that can occur during logging operations
public enum LoggingError: LocalizedError {
    /// Failed to initialize logging
    case initializationFailed(reason: String)
    
    /// Failed to write to log file
    case writeError(reason: String)
    
    /// Failed to read from log file
    case readError(reason: String)
    
    /// Failed to create log directory
    case directoryCreationFailed(path: String)
    
    /// Failed to access log file
    case accessDenied(path: String)
    
    /// Invalid log file path
    case invalidPath(path: String)
    
    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let reason):
            return "Failed to initialize logging: \(reason)"
        case .writeError(let reason):
            return "Failed to write to log file: \(reason)"
        case .readError(let reason):
            return "Failed to read from log file: \(reason)"
        case .directoryCreationFailed(let path):
            return "Failed to create log directory at path: \(path)"
        case .accessDenied(let path):
            return "Access denied to log file at path: \(path)"
        case .invalidPath(let path):
            return "Invalid log file path: \(path)"
        }
    }
}

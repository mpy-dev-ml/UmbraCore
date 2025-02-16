import Foundation

/// Errors that can occur during logging operations
public enum LoggingError: LocalizedError {
    /// Failed to create log directory
    case directoryCreationFailed(reason: String)
    
    /// Failed to write to log file
    case writeError(underlying: Error)
    
    /// User-friendly error description
    public var errorDescription: String? {
        switch self {
        case .directoryCreationFailed(let reason):
            return "Failed to create log directory: \(reason)"
        case .writeError:
            return "Failed to write to log file"
        }
    }
    
    /// Additional error context
    public var failureReason: String? {
        switch self {
        case .directoryCreationFailed:
            return "The application may not have permission to create directories"
        case .writeError(let error):
            return error.localizedDescription
        }
    }
    
    /// Recovery suggestion
    public var recoverySuggestion: String? {
        switch self {
        case .directoryCreationFailed:
            return "Please ensure the application has permission to access Application Support"
        case .writeError:
            return "Check disk space and permissions, then try again"
        }
    }
}

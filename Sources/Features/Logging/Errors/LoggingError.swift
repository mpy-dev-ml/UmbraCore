import Foundation
import UmbraCore

/// Errors that can occur during logging operations
public enum LoggingError: UmbraError, Equatable {
    /// The logging service has not been initialized
    case notInitialized
    /// The log entry is invalid (e.g., empty message)
    case invalidEntry
    /// Failed to write to the log file
    case writeFailure(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Logging service has not been initialized"
        case .invalidEntry:
            return "Invalid log entry: message cannot be empty"
        case .writeFailure(let error):
            return "Failed to write to log file: \(error.localizedDescription)"
        }
    }
    
    public var domain: String {
        return "dev.mpy.UmbraCore.Logging"
    }
    
    public var isRecoverable: Bool {
        switch self {
        case .notInitialized:
            return true
        case .invalidEntry:
            return true
        case .writeFailure:
            return false
        }
    }
    
    public var context: [String: Any] {
        switch self {
        case .notInitialized:
            return [:]
        case .invalidEntry:
            return [:]
        case .writeFailure(let error):
            return ["underlyingError": error]
        }
    }
    
    public static func == (lhs: LoggingError, rhs: LoggingError) -> Bool {
        switch (lhs, rhs) {
        case (.notInitialized, .notInitialized):
            return true
        case (.invalidEntry, .invalidEntry):
            return true
        case (.writeFailure(let lhsError), .writeFailure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

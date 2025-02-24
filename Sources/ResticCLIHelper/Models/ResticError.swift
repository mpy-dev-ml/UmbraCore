import Foundation

/// Errors that can occur when working with Restic
public enum ResticError: LocalizedError, Equatable {
    /// A required parameter is missing
    case missingParameter(String)

    /// A parameter has an invalid value
    case invalidParameter(String)

    /// A path is invalid or does not exist
    case invalidPath(String)

    /// Command execution failed
    case executionFailed(String)

    /// Invalid data format
    case invalidData(String)

    /// Output parsing failed
    case outputParsingFailed(String)

    /// Command execution failed with specific exit code
    case commandFailed(exitCode: Int, message: String)

    /// Repository not found or inaccessible
    case repositoryNotFound(path: String)

    /// Invalid repository password
    case invalidPassword

    /// Repository is corrupted
    case repositoryCorrupted(details: String)

    /// Network error occurred
    case networkError(underlying: Error)

    /// Permission denied
    case permissionDenied(path: String)

    /// Invalid command arguments
    case invalidArguments(details: String)

    /// Invalid configuration
    case invalidConfiguration(String)

    /// Repository error
    case repositoryError(String)

    /// Authentication error
    case authenticationError(String)

    /// Generic error
    case other(message: String)

    public var errorDescription: String? {
        switch self {
        case .missingParameter(let param):
            return "Missing required parameter: \(param)"
        case .invalidParameter(let details):
            return "Invalid parameter: \(details)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .executionFailed(let error):
            return "Command execution failed: \(error)"
        case .invalidData(let details):
            return "Invalid data format: \(details)"
        case .outputParsingFailed(let details):
            return "Failed to parse output: \(details)"
        case .commandFailed(let exitCode, let message):
            return "Command failed with exit code \(exitCode): \(message)"
        case .repositoryNotFound(let path):
            return "Repository not found at path: \(path)"
        case .invalidPassword:
            return "Invalid repository password"
        case .repositoryCorrupted(let details):
            return "Repository is corrupted: \(details)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidArguments(let details):
            return "Invalid arguments: \(details)"
        case .invalidConfiguration(let details):
            return "Invalid configuration: \(details)"
        case .repositoryError(let details):
            return "Repository error: \(details)"
        case .authenticationError(let details):
            return "Authentication error: \(details)"
        case .other(let message):
            return message
        }
    }

    private static func compareAssociatedValues<T: Equatable>(_ lhs: T, _ rhs: T) -> Bool {
        return lhs == rhs
    }
    
    private static func compareNetworkErrors(_ lhs: Error, _ rhs: Error) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    private static func compareCommandFailure(_ lhs: (Int, String), _ rhs: (Int, String)) -> Bool {
        return lhs.0 == rhs.0 && lhs.1 == rhs.1
    }

    public static func == (lhs: ResticError, rhs: ResticError) -> Bool {
        switch (lhs, rhs) {
        case (.missingParameter(let left), .missingParameter(let right)): return compareAssociatedValues(left, right)
        case (.invalidParameter(let left), .invalidParameter(let right)): return compareAssociatedValues(left, right)
        case (.invalidPath(let left), .invalidPath(let right)): return compareAssociatedValues(left, right)
        case (.executionFailed(let left), .executionFailed(let right)): return compareAssociatedValues(left, right)
        case (.invalidData(let left), .invalidData(let right)): return compareAssociatedValues(left, right)
        case (.outputParsingFailed(let left), .outputParsingFailed(let right)): return compareAssociatedValues(left, right)
        case (.commandFailed(let exitCode1, let message1), .commandFailed(let exitCode2, let message2)):
            return compareCommandFailure((exitCode1, message1), (exitCode2, message2))
        case (.repositoryNotFound(let left), .repositoryNotFound(let right)): return compareAssociatedValues(left, right)
        case (.invalidPassword, .invalidPassword): return true
        case (.repositoryCorrupted(let left), .repositoryCorrupted(let right)): return compareAssociatedValues(left, right)
        case (.networkError(let left), .networkError(let right)): return compareNetworkErrors(left, right)
        case (.permissionDenied(let left), .permissionDenied(let right)): return compareAssociatedValues(left, right)
        case (.invalidArguments(let left), .invalidArguments(let right)): return compareAssociatedValues(left, right)
        case (.invalidConfiguration(let left), .invalidConfiguration(let right)): return compareAssociatedValues(left, right)
        case (.repositoryError(let left), .repositoryError(let right)): return compareAssociatedValues(left, right)
        case (.authenticationError(let left), .authenticationError(let right)): return compareAssociatedValues(left, right)
        case (.other(let left), .other(let right)): return compareAssociatedValues(left, right)
        default: return false
        }
    }
}
